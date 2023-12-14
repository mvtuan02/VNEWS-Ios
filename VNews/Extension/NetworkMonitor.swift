//
//  NetworkMonitor.swift
//  VTCNews
//
//  Created by Nguyễn Văn Chiến on 4/7/21.
//

import Foundation
import Network

@available(iOS 12.0, *)
final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    public private(set) var isConnected: Bool = false
    
    public private(set) var connectionType: ConnectionType = .unknown
    enum ConnectionType{
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init(){
        monitor = NWPathMonitor()
    }
    
    public func startMonitoring(){
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = {[weak self] path in
            self?.isConnected = path.status == .satisfied
            self?.getConnectionType(path)
        }
    }
    
    public func stopMonitoring(){
        monitor.cancel()
    }
    
    private func getConnectionType(_ path: NWPath){
        if path.usesInterfaceType(.wifi){
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular){
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet){
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
}

@available(iOS 12.0, *)
class IPMonitor {
    
    enum InterfaceType: String {
        case cellular = "cellular"
        case wifi = "wifi"
        case wired = "wired"
        case loopback = "loopback"
        case other = "other"
        case notFound = "not found"
    }
    
    enum IPType: String {
        case ipv4 = "IPv4"
        case ipv6 = "ipV6"
        case unknown = "unknown"
    }
    
    struct Status {
        var name = "unknown"
        var interfaceType: InterfaceType = InterfaceType.notFound
        var ip: [String] = []
        var ipType: IPType = IPType.unknown
        
        var debugDescription: String {
            let result = "Interface: \(name)/\(interfaceType.rawValue), \(ipType.rawValue)\(ip.debugDescription)"
            return result
        }
    }
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ip_monitor_queue")
    
    final var pathUpdateHandler: ((Status) -> Void)?
    
    init(ipType: IPType) {
        monitor.pathUpdateHandler = { path in
            let name = self.getInterfaceName(path: path)
            let type = self.getInterfaceType(path: path)
            let ip = self.getIPAddresses(interfaceName: name, ipType: ipType)
            let status = Status(name: name, interfaceType: type, ip: ip, ipType: ipType)
            //print("\(status)")
            self.pathUpdateHandler?(status)
        }
        monitor.start(queue: queue)
    }
    
    private func getInterfaceName(path: NWPath) -> String {
        if let name = path.availableInterfaces.first?.name {
            return name
        }
        return "unknown"
    }
    
    private func getInterfaceType(path: NWPath) -> InterfaceType {
        if let type = path.availableInterfaces.first?.type {
            switch type {
            case NWInterface.InterfaceType.cellular:
                return InterfaceType.cellular
            case NWInterface.InterfaceType.wifi:
                return InterfaceType.wifi
            case NWInterface.InterfaceType.wiredEthernet:
                return InterfaceType.wired
            case NWInterface.InterfaceType.loopback:
                return InterfaceType.loopback
            default:
                return InterfaceType.other
            }
        }
        
        return InterfaceType.notFound
    }
    
    private func getIPAddresses(interfaceName: String, ipType: IPType)-> [String]{
        var addresses: [String] = []
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if (addrFamily == UInt8(AF_INET) && ipType == .ipv4)
                    || (addrFamily == UInt8(AF_INET6) && ipType == .ipv6) {
                    let name = String(cString: (interface?.ifa_name)!)
                    if name == interfaceName {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        addresses.append(String(cString: hostname))
                    }
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return addresses
    }
}
