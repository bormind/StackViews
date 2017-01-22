import Foundation
import UIKit



public extension CGRect {
    init(position: CGPoint, size: CGSize) {
        self.init(x: position.x, y: position.y, width: size.width, height: size.height)
    }
    
    init(x: CGFloat, y: CGFloat, size: CGSize) {
        self.init(x: x, y: y, width: size.width, height: size.height)
    }
    
    
    func set(y: CGFloat) -> CGRect {
        return CGRect(x: self.minX, y: y, width: self.width, height: self.height)
    }
}

extension UIColor {
    convenience public init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience public init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
}









