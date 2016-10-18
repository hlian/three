import UIKit

extension UIFont {
    func sizeOfString(_ string: String, constrainedToWidth width: CGFloat) -> CGSize {
        return NSString(string: string).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                                                             options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                             attributes: [NSFontAttributeName: self],
                                                             context: nil).size
    }
}
