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
import ReactiveSwift
import Result

func isPortrait() -> Bool {
    return UIDeviceOrientationIsPortrait(UIDevice.current.orientation)
}

let keyboardHeight = MutableProperty<CGFloat>(0)

func prepareKeyboardHeight() {
    NotificationCenter.default.reactive.notifications(forName: NSNotification.Name.UIKeyboardWillShow).start {
        event in
        if let rect = ((event.value! as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight.swap(isPortrait() ? rect.size.height : rect.size.width)
        }
    }
    NotificationCenter.default.reactive.notifications(forName: NSNotification.Name.UIKeyboardWillHide).start {
        event in
        keyboardHeight.swap(0)
    }
}

class ThingViewModel: ButtonViewModel, EditViewModel {
    let thing: Fact<Thing>?
    let text: String?
    let magnitude: Magnitude // pop pop
    let defaultText: String
    let didTap: (ThingViewModel) -> ()
    let editDone_: (ThingViewModel, String?) -> ()
    let didTapDone: (ThingViewModel) -> ()
    let active: Bool

    init(thing: Fact<Thing>?, magnitude: Magnitude, defaultText: String, didTap: @escaping (ThingViewModel) -> (), editDone: @escaping (ThingViewModel, String?) -> (), didTapDone: @escaping (ThingViewModel) -> (), active: Bool) {
        self.magnitude = magnitude
        self.thing = thing
        self.defaultText = defaultText
        self.text = thing?.fact.text
        self.didTap = didTap
        self.editDone_ = editDone
        self.didTapDone = didTapDone
        self.active = active
    }

    var chunkyButtonActive: Bool {
        return active
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

    func chunkyButtonDone() {
        return didTapDone(self)
    }

    func editDone(_ text: String) {
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
    fileprivate let db: Connection!
    fileprivate var tabVC: UITabBarController!
    fileprivate var thingsVC: RootVC!
    fileprivate var homeVC: HomeVC!
    fileprivate var editVC: EditVC!
    fileprivate var calendarVC: UIViewController!

    fileprivate let editView = EditView()
    fileprivate let bigButton = ChunkyButton()
    fileprivate let midButton = ChunkyButton()
    fileprivate let smallButton = ChunkyButton()

    init(db: Connection!) {
        prepareKeyboardHeight()

        self.db = db
        let homeLayoutView = HomeLayoutView(withBigView: bigButton, midView: midButton, smallView: smallButton)
        let homeView = HomeView(layoutView: homeLayoutView)

        homeVC = HomeVC(homeView: homeView)

        editVC = EditVC(editView: editView, focusBlock: {
            [unowned self] in
            self.editView.focus()
        })

        thingsVC = RootVC(childVC: homeVC)
        thingsVC.title = "Home".localized()
        thingsVC.tabBarItem.image = UIImage(named: "person")!

        calendarVC = UIViewController(nibName: nil, bundle: nil)
        calendarVC.title = "Calendar".localized()
        calendarVC.tabBarItem.image = UIImage(named: "clock")!

        tabVC = UITabBarController(nibName: nil, bundle: nil)
        tabVC.viewControllers = [thingsVC, calendarVC]

        _reloadData()
    }

    fileprivate func _makeThingViewModel(_ thing0: Fact<Thing>?, _ defaultText: String, _ magnitude: Magnitude, _ button: ChunkyButton) -> ThingViewModel {
        return ThingViewModel(thing: thing0, magnitude: magnitude, defaultText: defaultText, didTap: {
            [unowned self] me in
            self.editView.updateViewModel(me)
            self.thingsVC.present(self.editVC, self.thingsVC.view.bounds)
        }, editDone: {
            [unowned self] (me, newText) in
            if let text = newText {
                let thing = Thing(text: text, creation: Date(), due: nil, magnitude: me.magnitude, done: false)
                try! insertThing(self.db, thing: thing)
            }
            self._reloadData()
            self.thingsVC.present(self.homeVC, self.thingsVC.view.bounds)
        }, didTapDone: {
            [unowned self] me in
            if let thing = thing0 {
                try! markThingDone(self.db, thing: thing)
            }
            self._reloadData()
        }, active: thing0 != nil && thing0?.fact.done != true)
    }

    fileprivate func _didClick(_ mag: Magnitude) -> (ChunkyButton) -> () {
        return {
            [unowned self] button in
            self.thingsVC.present(self.editVC, self.thingsVC.view.bounds)
        }
    }

    fileprivate func _reloadData() {
        let things = try! listThings(db)
        bigButton.updateViewModel(_makeThingViewModel(things[0], "A BIG THING".localized(), .big, bigButton))
        midButton.updateViewModel(_makeThingViewModel(things[1], "A MEDIUM THING".localized(), .mid, midButton))
        smallButton.updateViewModel(_makeThingViewModel(things[2], "A SMALL THING".localized(), .small, smallButton))
    }

    var vc: UIViewController {
        return self.tabVC
    }
}
