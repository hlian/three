//
//  ChunkyButton.swift
//  ThreeThings
//
//  Created by hao on 6/28/16.
//  Copyright © 2016 ThreeThings. All rights reserved.
//

import UIKit
import PureLayout
import ReactiveCocoa

private class DoneControl: UIControl {
    let label: UILabel
    override init(frame: CGRect) {
        label = UILabel(frame: someRect)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = bodyFont.fontWithSize(13)
        label.textColor = UIColor.whiteColor()
        let doneText = "Done".localized()
        let doneString = NSMutableAttributedString(string: doneText)
        doneString.addAttribute(NSKernAttributeName, value: 5, range: NSMakeRange(0, doneText.characters.count))
        label.attributedText = doneString
        super.init(frame: frame)

        addSubview(label)
        label.autoCenterInSuperview()
        _invalidateSelected()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        selected = true
        UIView.animateWithDuration(0.1) {
            self._invalidateSelected()
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        selected = false
        UIView.animateWithDuration(0.1) {
            self._invalidateSelected()
        }
        sendActionsForControlEvents([.TouchUpInside])
    }

    func _invalidateSelected() {
        if (selected) {
            backgroundColor = lightHomeColor
        } else {
            backgroundColor = homeColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class InnerChunkyButton: UIView {
    let label: UILabel
    let insetView: UIView
    let shadowView: UIView
    let doneView: DoneControl
    var bottomLabelConstraint: NSLayoutConstraint!

    init() {
        self.label = UILabel(frame: someRect)
        self.shadowView = UIView(frame: someRect)
        self.insetView = UIView(frame: someRect)
        self.doneView = DoneControl(frame: someRect)
        super.init(frame: someRect)

        label.numberOfLines = 0
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.autoAlignAxisToSuperviewAxis(.Vertical)
        label.autoMatchDimension(.Width, toDimension: .Width, ofView: self, withMultiplier: 0.75)
        label.autoPinEdge(.Top, toEdge: .Top, ofView: self, withOffset: 0)
        bottomLabelConstraint = label.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self, withOffset: 0)
        label.textAlignment = .Center
        label.font = bodyFont
        addSubview(shadowView)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.autoPinEdge(.Left, toEdge: .Left, ofView: self)
        shadowView.autoPinEdge(.Right, toEdge: .Right, ofView: self)
        shadowView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self)
        shadowView.autoSetDimension(.Height, toSize: 3)
        addSubview(insetView)
        insetView.translatesAutoresizingMaskIntoConstraints = false
        insetView.autoPinEdge(.Left, toEdge: .Left, ofView: self)
        insetView.autoPinEdge(.Right, toEdge: .Right, ofView: self)
        insetView.autoPinEdge(.Top, toEdge: .Top, ofView: self)
        insetView.autoSetDimension(.Height, toSize: 3)
        addSubview(doneView)
        doneView.translatesAutoresizingMaskIntoConstraints = false
        doneView.autoPinEdge(.Left, toEdge: .Left, ofView: self)
        doneView.autoPinEdge(.Right, toEdge: .Right, ofView: self)
        doneView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self, withOffset: -3)
        doneView.autoSetDimension(.Height, toSize: 44)
    }

    func updateText(text: String) {
        label.text = text
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol ButtonViewModel {
    var chunkyButtonText: String { get }
    var chunkyButtonActive: Bool { get }
    func chunkyButtonDidClick()
    func chunkyButtonDone()
}

class ChunkyButton: UIControl {
    private let inner: InnerChunkyButton
    private var viewModel: ButtonViewModel!

    init() {
        self.inner = InnerChunkyButton()
        super.init(frame: someRect)

        _invalidateSelected()
        addSubview(self.inner)

        rac_signalForControlEvents([.TouchUpInside]).subscribeNext {
            [unowned self] _ in
            self.viewModel.chunkyButtonDidClick()
        }

        inner.doneView.rac_signalForControlEvents([.TouchUpInside]).subscribeNext {
            [unowned self] _ in
            self.viewModel.chunkyButtonDone()
        }
    }

    func updateViewModel(viewModel: ButtonViewModel) {
        self.viewModel = viewModel
        self.inner.updateText(viewModel.chunkyButtonText)
        if viewModel.chunkyButtonActive {
            inner.backgroundColor = homeTextColor
            inner.label.textColor = homeColor
            inner.doneView.hidden = false
            inner.bottomLabelConstraint.constant = -44
        } else {
            inner.backgroundColor = homeColor
            inner.label.textColor = homeTextColor
            inner.doneView.hidden = true
            inner.bottomLabelConstraint.constant = 0
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Set the font to be proportional to height. That way we don't have to hardcode
        // font sizes for each screen size.
        self.inner.label.font = self.inner.label.font.fontWithSize(self.bounds.size.height / 8)
        if self.selected {
            self.inner._frameOrigin = CGPointMake(0, 3)
        } else {
            self.inner.frame = self.bounds
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.selected = true
        self._invalidateSelected()
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.selected = false
        self._invalidateSelected()
        self.sendActionsForControlEvents([.TouchUpInside])
    }

    func _invalidateSelected() {
        if (self.selected) {
            self.inner.shadowView.backgroundColor = UIColor.clearColor()
        } else {
            self.inner.shadowView.backgroundColor = homeShadowColor
        }
        self.setNeedsLayout()
    }
}