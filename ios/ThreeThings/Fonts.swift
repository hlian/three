import UIKit

let bodyFont = UIFont(name: "Phosphate-Solid", size: 12)!

func debugFonts() {
    for family in UIFont.familyNames {
        for names in UIFont.fontNames(forFamilyName: family) {
            print(names)
        }
    }
}
