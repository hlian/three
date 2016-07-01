import UIKit

extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: CGFloat) -> CGSize {
        return NSString(string: string).boundingRectWithSize(CGSize(width: width, height: CGFloat.max),
                                                             options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                                                             attributes: [NSFontAttributeName: self],
                                                             context: nil).size
    }
}