//
//  ViewController.swift
//  ThreeThings
//
//  Created by hao on 6/28/16.
//  Copyright © 2016 ThreeThings. All rights reserved.
//

import UIKit
import PureLayout
import SQLite
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

func prepareKeyboardHeight() {
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
}

class ThingViewModel: ButtonViewModel, EditViewModel {
    let thing: Thing?
    let text: String?
    let defaultText: String
    let didTap: ThingViewModel -> ()
    let editDone_: (ThingViewModel, String?) -> ()

    init(thing: Thing?, defaultText: String, didTap: ThingViewModel -> (), editDone: (ThingViewModel, String?) -> ()) {
        self.thing = thing
        self.defaultText = defaultText
        self.text = thing?.text
        self.didTap = didTap
        self.editDone_ = editDone
    }

    var chunkyButtonText: String {
        return text ?? defaultText
    }

    var editText: String {
        return chunkyButtonText
    }

    func chunkyButtonDidClick() {
        return didTap(self)
    }

    func editDone(text: String) {
        let text_ = {
            () -> String? in
            switch text {
            case self.defaultText:
                return nil
            default:
                return text
            }
        }()
        editDone_((self, text_))
    }
}

class Root {
    private let db: Connection!
    private var rootVC: RootVC!
    private var homeVC: HomeVC!
    private var editVC: EditVC!

    private let editView = EditView()
    private let bigButton = ChunkyButton()
    private let midButton = ChunkyButton()
    private let smallButton = ChunkyButton()

    init(db: Connection!) {
        prepareKeyboardHeight()

        self.db = db
        let homeLayoutView = HomeLayoutView(withBigView: bigButton, midView: midButton, smallView: smallButton)
        let homeView = HomeView(layoutView: homeLayoutView)
        let homeVC = HomeVC(homeView: homeView)
        self.homeVC = homeVC

        let editVC = EditVC(editView: editView, focusBlock: {
            [unowned self] in
            self.editView.focus()
        })
        self.editVC = editVC
        self.rootVC = RootVC(childVC: homeVC)

        bigButton.updateViewModel(_makeThingViewModel("A BIG THING".localized(), button: bigButton))
        midButton.updateViewModel(_makeThingViewModel("A MEDIUM THING".localized(), button: midButton))
        smallButton.updateViewModel(_makeThingViewModel("A SMALL THING".localized(), button: smallButton))
    }

    private func _makeThingViewModel(defaultText: String, button: ChunkyButton) -> ThingViewModel {
        return ThingViewModel(thing: nil, defaultText: defaultText, didTap: {
            [unowned self] me in
            self.editView.updateViewModel(me)
            self.rootVC.present(self.editVC, self.rootVC.view.bounds)
        }, editDone: {
            [unowned self] (me, newText) in
            let newThing = try! {
                _ -> Thing? in
                if let text = newText {
                    let thing = Thing(text: text, due: nil)
                    try insertThing(self.db, thing: thing)
                    return thing
                } else {
                    return nil
                }
            }()
            let newViewModel = ThingViewModel(thing: newThing, defaultText: me.defaultText, didTap: me.didTap, editDone: me.editDone_)
            button.updateViewModel(newViewModel)
            self.rootVC.present(self.homeVC, self.rootVC.view.bounds)
        })
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
