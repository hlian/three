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

private class HomeVC: UIViewController {
    let homeView: UIView

    init(homeView: UIView) {
        self.homeView = homeView
        super.init(nibName: nil, bundle: nil)
    }

    override private func loadView() {
        self.view = homeView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class RootVC: UIViewController {
    var childVC: UIViewController

    init(childVC: UIViewController) {
        self.childVC = childVC
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = ambientBackgroundColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(self.childVC)
        view.addSubview(self.childVC.view)
        childVC.view.frame = view.bounds
        childVC.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        childVC.didMoveToParentViewController(self)
    }

    func present(siblingVC: UIViewController, _ frame: CGRect) {
        childVC.willMoveToParentViewController(nil)
        addChildViewController(siblingVC)
        siblingVC.view.frame = frame
        siblingVC.view.layer.opacity = 0
        transitionFromViewController(childVC, toViewController: siblingVC, duration: 0.2, options: UIViewAnimationOptions(rawValue: 0), animations: {
            siblingVC.view.frame = self.view.bounds
            siblingVC.view.layer.opacity = 1
            self.childVC.view.layer.opacity = 0
        }) { finished in
            self.childVC.view.layer.opacity = 1
            self.childVC.removeFromParentViewController()
            siblingVC.didMoveToParentViewController(self)
            self.childVC = siblingVC
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: CGFloat) -> CGSize {
        return NSString(string: string).boundingRectWithSize(CGSize(width: width, height: CGFloat.max),
                                                             options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                                                             attributes: [NSFontAttributeName: self],
                                                             context: nil).size
    }
}

class EditView: UIView {
    let didClick: (EditView -> ())?
    let textView: UITextView = UITextView(forAutoLayout: ())
    let done: UIButton = UIButton(type: .System)

    private var doneRightConstraint: NSLayoutConstraint!

    init(didClick: (EditView -> ())?) {
        self.didClick = didClick
        super.init(frame: someRect)

        addSubview(self.textView)
        textView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(100, 0, 0, 0))
        textView.editable = true
        textView.text = "ONE BIG THING"
        textView.textColor = editTextColor
        textView.backgroundColor = editBackgroundColor
        textView.autocapitalizationType = .AllCharacters
        textView.textContainer.lineFragmentPadding = 0
        textView.returnKeyType = .Done

        addSubview(done)
        done.translatesAutoresizingMaskIntoConstraints = false
        done.autoPinEdgeToSuperviewEdge(.Top, withInset: 25)
        doneRightConstraint = done.autoPinEdgeToSuperviewEdge(.Right, withInset: 0)
        done.setTitle("DONE".localized(), forState: [.Normal])
        done.titleLabel?.font = UIFont.systemFontOfSize(18, weight: UIFontWeightHeavy)

        done.rac_signalForControlEvents([.TouchUpInside]).subscribeNext {
            [unowned self] _ in
            self.didClick?(self)
        }

        textView.rac_textSignal().subscribeNext {
            [unowned self] _ in
            self._invalidateTextViewFont()
        }

        keyboardHeight.signal.observeNext {
            [unowned self] _ in
            self._invalidateTextViewFont()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let w = self._width
        textView.textContainerInset = UIEdgeInsetsMake(0.08 * w, 0.04 * w, 0, 0.04 * w)
        doneRightConstraint.constant = -0.04 * w
        self._invalidateTextViewFont()
    }

    private func _invalidateTextViewFont() {
        let w = _width
        let minSize: CGFloat = 18.0
        textView.font = UIFont.systemFontOfSize(w / 5, weight: UIFontWeightHeavy)
        while true {
            let font = textView.font!
            if font.pointSize <= minSize {
                break
            }
            let size = font.sizeOfString(textView.text, constrainedToWidth: w - 0.08 * w)
            if size.height <= textView._height - keyboardHeight.value - 0.08 * w {
                break
            }
            textView.font = UIFont.systemFontOfSize(font.pointSize - 1, weight: UIFontWeightHeavy)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EditVC: UIViewController {
    let editView: UIView
    let focusBlock: () -> ()
    init(editView: UIView, focusBlock: () -> ()) {
        self.editView = editView
        self.focusBlock = focusBlock
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        self.view = editView
        self.view.backgroundColor = ambientBackgroundColor
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.focusBlock()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
        NSNotificationCenter.defaultCenter().rac_notifications(UIKeyboardDidShowNotification, object: nil).start {
            event in
            if let rect = (event.value!.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
                keyboardHeight.swap(isPortrait() ? rect.size.height : rect.size.width)
            }
        }
        NSNotificationCenter.defaultCenter().rac_notifications(UIKeyboardDidHideNotification, object: nil).start {
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
