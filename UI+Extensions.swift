//
//  UIWindow+extensions.swift
//  Multibrand
//
//  Created by Louis Tran on 3/13/20.
//  Copyright © 2020 ZillowGroup. All rights reserved.
//


import UIKit

extension UIWindow {
  // This is the delegate's window; it should never be nil and it usually is the key window.
  @objc public class var root: UIWindow {
    guard let optionalRootWindow = UIApplication.shared.delegate?.window,
      let rootWindow = optionalRootWindow else { fatalError("Fatal Error: delegate's window is nil!") }
    return rootWindow
  }
}
// adapted from
//  https://stackoverflow.com/questions/29618760/create-a-rectangle-with-just-two-rounded-corners-in-swift/35621736#35621736
extension UIView {
    func round (corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    /// Draw the circle of the UIView
    /// - Parameters:
    ///   - center: the center, if omits then the center will be the UIView center
    ///   - radius: the radius, if omits then the radius is half the smaller of width or height
    func circle (_ center : CGPoint? = nil, _ radius: CGFloat? = nil) {
        var localCenter: CGPoint
        var localRadius: CGFloat
        if let unwrappedCenter = center {
            localCenter = unwrappedCenter
        } else {
            localCenter = CGPoint(x: bounds.width/2, y: bounds.height/2)
        }
        if let unwrappedRadius = radius {
            localRadius = unwrappedRadius
        } else {
            localRadius = bounds.width < bounds.height ? bounds.width/2 : bounds.height/2
        }
        let path = UIBezierPath(arcCenter: localCenter, radius: localRadius, startAngle: 0, endAngle: CGFloat(2*Float.pi), clockwise: true)
        let mask =  CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

// Adapted from
// https://stackoverflow.com/questions/26542035/create-uiimage-with-solid-color-in-swift/33675160
public extension UIImage {
    /// Create an UIImage object with color
    /// - Parameters:
    ///   - color: the color
    ///   - size: size, defauts to 1x1
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage)
  }
}

