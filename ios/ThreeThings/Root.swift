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
    let magnitude: Magnitude // pop pop
    let defaultText: String
    let didTap: ThingViewModel -> ()
    let editDone_: (ThingViewModel, String?) -> ()

    init(thing: Thing?, magnitude: Magnitude, defaultText: String, didTap: ThingViewModel -> (), editDone: (ThingViewModel, String?) -> ()) {
        self.magnitude = magnitude
        self.thing = thing
        self.defaultText = defaultText
        self.text = thing?.text
        self.didTap = didTap
        self.editDone_ = editDone
    }

    var chunkyButtonActive: Bool {
        return thing != nil
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

        _reloadData()
    }

    private func _makeThingViewModel(thing0: Thing?, _ defaultText: String, _ magnitude: Magnitude, _ button: ChunkyButton) -> ThingViewModel {
        return ThingViewModel(thing: thing0, magnitude: magnitude, defaultText: defaultText, didTap: {
            [unowned self] me in
            self.editView.updateViewModel(me)
            self.rootVC.present(self.editVC, self.rootVC.view.bounds)
        }, editDone: {
            [unowned self] (me, newText) in
            if let text = newText {
                let thing = Thing(text: text, creation: NSDate(), due: nil, magnitude: me.magnitude)
                try! insertThing(self.db, thing: thing)
            }
            self._reloadData()
            self.rootVC.present(self.homeVC, self.rootVC.view.bounds)
        })
    }

    private func _didClick(mag: Magnitude) -> ChunkyButton -> () {
        return {
            [unowned self] button in
            self.rootVC.present(self.editVC, self.rootVC.view.bounds)
        }
    }

    private func _reloadData() {
        let things = try! listThings(db)
        bigButton.updateViewModel(_makeThingViewModel(things[0], "A BIG THING".localized(), .Big, bigButton))
        midButton.updateViewModel(_makeThingViewModel(things[1], "A MEDIUM THING".localized(), .Mid, midButton))
        smallButton.updateViewModel(_makeThingViewModel(things[2], "A SMALL THING".localized(), .Small, smallButton))
    }

    var vc: UIViewController {
        return self.rootVC
    }
}
