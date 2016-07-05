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

private class InnerChunkyButton: UIView {
    let label: UILabel
    let insetView: UIView
    let shadowView: UIView

    init() {
        self.label = UILabel(frame: someRect)
        self.shadowView = UIView(frame: someRect)
        self.insetView = UIView(frame: someRect)
        super.init(frame: someRect)

        self.label.numberOfLines = 0
        self.addSubview(self.label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.autoCenterInSuperview()
        self.label.autoMatchDimension(.Width, toDimension: .Width, ofView: self, withMultiplier: 0.75)
        self.label.autoMatchDimension(.Height, toDimension: .Height, ofView: self, withMultiplier: 0.75)
        self.label.textAlignment = .Center
        self.addSubview(self.shadowView)
        self.shadowView.translatesAutoresizingMaskIntoConstraints = false
        self.shadowView.autoPinEdge(.Left, toEdge: .Left, ofView: self)
        self.shadowView.autoPinEdge(.Right, toEdge: .Right, ofView: self)
        self.shadowView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self)
        self.shadowView.autoSetDimension(.Height, toSize: 3)
        self.addSubview(self.insetView)
        self.insetView.translatesAutoresizingMaskIntoConstraints = false
        self.insetView.autoPinEdge(.Left, toEdge: .Left, ofView: self)
        self.insetView.autoPinEdge(.Right, toEdge: .Right, ofView: self)
        self.insetView.autoPinEdge(.Top, toEdge: .Top, ofView: self)
        self.insetView.autoSetDimension(.Height, toSize: 3)
    }

    func updateText(text: String) {
        self.label.text = text
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol ButtonViewModel {
    var chunkyButtonText: String { get }
    var chunkyButtonActive: Bool { get }
    func chunkyButtonDidClick()
}

class ChunkyButton: UIControl {
    private let inner: InnerChunkyButton
    private var viewModel: ButtonViewModel!

    init() {
        self.inner = InnerChunkyButton()
        super.init(frame: someRect)
        self.selected = false
        self._invalidateSelected()
        self.addSubview(self.inner)

        self.rac_signalForControlEvents([.TouchUpInside]).subscribeNext {
            [unowned self] _ in
            self.viewModel.chunkyButtonDidClick()
        }
    }

    func updateViewModel(viewModel: ButtonViewModel) {
        self.viewModel = viewModel
        self.inner.updateText(viewModel.chunkyButtonText)
        if viewModel.chunkyButtonActive {
            inner.backgroundColor = homeTextColor
            inner.label.textColor = homeColor
        } else {
            inner.backgroundColor = homeColor
            inner.label.textColor = homeTextColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Set the font to be proportional to height. That way we don't have to hardcode
        // font sizes for each screen size.
        self.inner.label.font = UIFont.systemFontOfSize(self.bounds.size.height / 8, weight: UIFontWeightHeavy)
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