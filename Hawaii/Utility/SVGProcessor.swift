//
//  SVGProcessor.swift
//
//  Created by Paolo Musolino on 21/03/17.
//  Copyright © 2017. All rights reserved.
//

import UIKit
//import PocketSVG
import Kingfisher

struct SVGProcessor: ImageProcessor {
    let imgSize: CGSize?
    
    init(size: CGSize? = CGSize(width: 250, height: 250)) {
        imgSize = size
    }
    
    // `identifier` should be the same for processors with same properties/functionality
    // It will be used when storing and retrieving the image to/from cache.
    let identifier = "eu.execom.Hawaii"
    
    // Convert input data/image to target image and return it.
    func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> Image? {
        switch item {
        case .image(let image):
            //already an image
            return image
        case .data(let data):
            return generateSVGImage(data: data, size: imgSize) ?? DefaultImageProcessor().process(item: item, options: options)
        }
    }
}

struct SVGCacheSerializer: CacheSerializer {
    func data(with image: Image, original: Data?) -> Data? {
        return original
    }
    
    func image(with data: Data, options: KingfisherOptionsInfo?) -> Image? {
        return generateSVGImage(data: data) ?? image(with: data, options: options)
    }
}

func generateSVGImage(data: Data, size: CGSize? = CGSize(width: 250, height: 250)) -> UIImage? {
    guard let size = size else {
        return nil
    }
    let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    if let svgString = String(data: data, encoding: .utf8) {
//        let svgLayer = SVGLayer(svgSource: svgString)
//        svgLayer.frame = frame
//        return snapshotImage(for: svgLayer)
        return nil
    }
    return nil
}

func snapshotImage(for layer: CALayer) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(layer.bounds.size, false, UIScreen.main.scale)
    guard let context = UIGraphicsGetCurrentContext() else {
        return nil
    }
    layer.render(in: context)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}
