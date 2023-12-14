//
//  AppDelegate.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/7/21.
//

import UIKit
import Firebase
import Sentry
import AVFoundation
import GoogleMobileAds
@available(iOS 13.0, *)
@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    var window: UIWindow?
    var myOrientation: UIInterfaceOrientationMask = .portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return myOrientation
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        SentrySDK.start { options in
            options.dsn = "https://6b0c0c721630485aa9cceab91e58ac5e@sentry.admon.com.vn/12"
            options.debug = true // Enabled debug when first installing is always helpful
        }
        NetworkMonitor.shared.startMonitoring()
        //FirebaseApp.configure()
        
        Messaging.messaging().delegate = self //Nhận các message từ FirebaseMessaging
        configApplePush(application)
        Messaging.messaging().subscribe(toTopic: "all") { error in
          print("Subscribed to weather topic")
        }
        APIService.shared.getChuongTrinh { (data, error) in
            if let data = data as? CategoryModel{
                chuongTrinh = data
            }
        }
        APIService.shared.getLive { (data, error) in
            if let data = data as? CategoryModel{
                live = data
            }
        }
        APIService.shared.getAdmobNativeKey { data, error in
            if let data = data as? String {
//                print(data)
                adNativeAd = data
            }
        }
        let udid = UIDevice.current.identifierForVendor?.uuidString
        let version = UIDevice.current.systemVersion
        let modelName = UIDevice.modelName
        let osName = UIDevice.current.systemName
        let monitor = IPMonitor(ipType: .ipv4)
        monitor.pathUpdateHandler = { status in
            network = status.interfaceType.rawValue
            ip = status.ip.debugDescription
        }
        
        var json: [String: String] = [:]
        json["UDID"] = udid ?? "notfound"
        json["Model"] = modelName
        json["Version"] = version
        json["OS"] = osName
        device = json.toJSONString() ?? ""
        resetUserDefault()
        
        
        return true
    }
    func resetUserDefault(){
        guard let startDate = UserDefaults.standard.object(forKey: "reset") as? Date else {
            UserDefaults.standard.setValue(Date(), forKeyPath: "reset")
            print("First time")
            return
        }
//        print(startDate)
        let now = Date()
        let duration = now - startDate
        if duration.day! >= 7 {
            UserDefaults.resetStandardUserDefaults()
            UserDefaults.standard.setValue(Date(), forKeyPath: "reset")
        } else {
            print("no reset")
        }
//        print(duration.second)
        
    }
    // MARK: UISceneSession Lifecycle
    func configApplePush(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()

        if let token = Messaging.messaging().fcmToken {
            print("FCM token: \(token)")
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
        let privateID = response.notification.request.content.userInfo["privateid"] as! String
        let privateKey = response.notification.request.content.userInfo["privatekey"] as! String
        let type = response.notification.request.content.userInfo["type"] as! String
        typeNoti = type
        idNoti = privateID
        print(privateID)
        isMessaging = true
        
        APIService.shared.getContentPlaylist(privateKey: privateKey) { (listData, error) in
            if let listData = listData as? CategoryModel{
                listDataNoti = listData.media
                APIService.shared.getVideoRelated(privateKey: privateID) { (media, error) in
                    if let media = media as? MediaModel{
                        mediaNoti = media
                        NotificationCenter.default.post(name: NSNotification.Name("HomeOpenVideo"), object: nil)
                    }
                }
            }
        }
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension UIApplication {
    /*function will return reference to tabbarcontroller */
    func tabbarController() -> UIViewController? {
        guard let vcs = self.keyWindow?.rootViewController?.children else { return nil }
        for vc in vcs {
            if  let _ = vc as? RootTabbar {
                return vc
            }
        }
        return nil
    }
}
var isMessaging = false
var mediaNoti: MediaModel!
var listDataNoti: [MediaModel] = []
var typeNoti: String = ""
var idNoti: String = ""

var device = ""
var network = ""
var ip = ""

extension Dictionary {
    var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
    }
    
    func toJSONString() -> String? {
        if let jsonData = jsonData {
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        }
        
        return nil
    }
}
public extension UIDevice {
  static let modelName: String = {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    func mapToDevice(identifier: String) -> String {
      #if os(iOS)
      switch identifier {
      case "iPod5,1":                                 return "iPod Touch 5"
      case "iPod7,1":                                 return "iPod Touch 6"
      case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
      case "iPhone4,1":                               return "iPhone 4s"
      case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
      case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
      case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
      case "iPhone7,2":                               return "iPhone 6"
      case "iPhone7,1":                               return "iPhone 6 Plus"
      case "iPhone8,1":                               return "iPhone 6s"
      case "iPhone8,2":                               return "iPhone 6s Plus"
      case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
      case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
      case "iPhone8,4":                               return "iPhone SE"
      case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
      case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
      case "iPhone10,3", "iPhone10,6":                return "iPhone X"
      case "iPhone11,2":                              return "iPhone XS"
      case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
      case "iPhone11,8":                              return "iPhone XR"
      case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
      case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
      case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
      case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
      case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
      case "iPad6,11", "iPad6,12":                    return "iPad 5"
      case "iPad7,5", "iPad7,6":                      return "iPad 6"
      case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
      case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
      case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
      case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
      case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
      case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
      case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
      case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
      case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
      case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
      case "AppleTV5,3":                              return "Apple TV"
      case "AppleTV6,2":                              return "Apple TV 4K"
      case "AudioAccessory1,1":                       return "HomePod"
      case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
      default:                                        return identifier
      }
      #elseif os(tvOS)
      switch identifier {
      case "AppleTV5,3": return "Apple TV 4"
      case "AppleTV6,2": return "Apple TV 4K"
      case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
      default: return identifier
      }
      #endif
    }
    
    return mapToDevice(identifier: identifier)
  }()
}

