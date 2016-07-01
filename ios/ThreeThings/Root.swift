//
//  ViewController.swift
//  ThreeThings
//
//  Created by hao on 6/28/16.
//  Copyright © 2016 ThreeThings. All rights reserved.
//

import UIKit
import PureLayout
import ReactiveCocoa
import Result

private enum Magnitude {
    case Big
    case Mid
    case Small
}

func isPortrait() -> Bool {
    return UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)
}

let keyboardHeight = MutableProperty<CGFloat>(0)

class Root {
    private var rootVC: RootVC!
    private var homeVC: HomeVC!
    private var editVC: EditVC!

    init() {
        NSNotificationCenter.defaultCenter().rac_notifications(UIKeyboardWillShowNotification, object: nil).start {
            event in
            if let rect = (event.value!.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
                keyboardHeight.swap(isPortrait() ? rect.size.height : rect.size.width)
            }
        }
        NSNotificationCenter.defaultCenter().rac_notifications(UIKeyboardWillHideNotification, object: nil).start {
            event in
            keyboardHeight.swap(0)
        }

        let bigButton = ChunkyButton(text: "ONE BIG THING".localized(), didClick: _didClick(.Big))
        let midButton = ChunkyButton(text: "ONE MID THING".localized (), didClick: _didClick(.Mid))
        let smallButton = ChunkyButton(text: "ONE SMALL THING".localized(), didClick: _didClick(.Small))

        let homeLayoutView = HomeLayoutView(withBigView: bigButton, midView: midButton, smallView: smallButton)
        let homeView = HomeView(layoutView: homeLayoutView)
        let homeVC = HomeVC(homeView: homeView)
        self.homeVC = homeVC

        let editView = EditView(didClick: { v in
            self.rootVC.present(self.homeVC, self.rootVC.view.bounds)
        })
        editView.backgroundColor = UIColor.purpleColor()
        let editVC = EditVC(editView: editView, focusBlock: {
            editView.textView.becomeFirstResponder()
        })
        self.editVC = editVC
        self.rootVC = RootVC(childVC: homeVC)
    }

    private func _didClick(mag: Magnitude) -> ChunkyButton -> () {
        return {
            [unowned self] button in
            self.rootVC.present(self.editVC, self.rootVC.view.bounds)
        }
    }

    var vc: UIViewController {
        return self.rootVC
    }
}
