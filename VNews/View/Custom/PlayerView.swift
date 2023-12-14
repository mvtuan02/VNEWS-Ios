//
//  PlayerView.swift
//  NOW
//
//  Created by dovietduy on 2/3/21.
//
import AVFoundation

import UIKit

class PlayerView: UIView {
    
    
    override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
    
    
    var player:AVPlayer? {
        set {
            if let layer = layer as? AVPlayerLayer {
                layer.videoGravity = .resizeAspect
                layer.player = newValue
            }
        }
        get {
            if let layer = layer as? AVPlayerLayer {
                return layer.player
            } else {
                return nil
            }
        }
    }
}

class CustomSlider: UISlider {
    @IBInspectable var trackHeight: CGFloat = 3 * scaleH
    @IBInspectable var thumbRadius: CGFloat = 12 * scaleH
    
    private lazy var thumbView: UIView = {
        let thumb = UIView()
        thumb.backgroundColor = #colorLiteral(red: 0.2256926, green: 0.3269798756, blue: 0.6443627477, alpha: 1)
        thumb.layer.borderWidth = 0.4
        thumb.layer.borderColor = UIColor.darkGray.cgColor
        return thumb
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        let thumb = thumbImage(radius: thumbRadius)
        setThumbImage(thumb, for: .normal)
    }

    private func thumbImage(radius: CGFloat) -> UIImage {
        thumbView.frame = CGRect(x: 0, y: radius / 2, width: radius, height: radius)
        thumbView.layer.cornerRadius = radius / 2

        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newRect = super.trackRect(forBounds: bounds)
        newRect.size.height = trackHeight
        return newRect
    }
}
class StreamHelper{
    static let shared = StreamHelper()
    
    func getPlaylist(from url: URL, completion: @escaping (Result<RawPlaylist, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let string = String(data: data, encoding: .utf8) {
                completion(.success(RawPlaylist(url: url, content: string)))
            }else if let error = error {
                completion(.failure(error))
            }
            
        }
        task.resume()
    }

    func getStreamResolutions(from playlist: RawPlaylist) -> [StreamResolution] {
        var resolutions = [StreamResolution]()
        playlist.content.enumerateLines { line, shouldStop in
            let infoline = line.replacingOccurrences(of: "#EXT-X-STREAM-INF", with: "")
            let infoItems = infoline.components(separatedBy: ",")
            let bandwidthItem = infoItems.first(where: { $0.contains(":BANDWIDTH") })
            let resolutionItem = infoItems.first(where: { $0.contains("RESOLUTION")})
            if let bandwidth = bandwidthItem?.components(separatedBy: "=").last,
               let numericBandwidth = Double(bandwidth),
               let resolution = resolutionItem?.components(separatedBy: "=").last?.components(separatedBy: "x"),
               let strignWidth = resolution.first,
               let stringHeight = resolution.last,
               let width = Double(strignWidth),
               let height = Double(stringHeight) {
                resolutions.append(StreamResolution(maxBandwidth: numericBandwidth,
                                                    averageBandwidth: numericBandwidth,
                                                    resolution: CGSize(width: width, height: height)))
            }
        }
        return resolutions
    }
}
class RawPlaylist{
    var url: URL!
    var content: String = ""
    init(url: URL, content: String){
        self.url = url
        self.content = content
    }
}
class StreamResolution{
    var isTicked = false
    var maxBandwidth: Double = 0.0
    var averageBandwidth: Double = 0.0
    var resolution: CGSize!
    init(maxBandwidth: Double,
        averageBandwidth: Double,
        resolution: CGSize) {
        self.maxBandwidth = maxBandwidth
        self.averageBandwidth = averageBandwidth
        self.resolution = resolution
    }
    init(){
        
    }
}
