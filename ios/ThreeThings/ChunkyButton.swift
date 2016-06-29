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
    let text: String
    let label: UILabel
    let insetView: UIView
    let shadowView: UIView

    init(text: String) {
        self.text = text
        self.label = UILabel(frame: someRect)
        self.shadowView = UIView(frame: someRect)
        self.insetView = UIView(frame: someRect)
        super.init(frame: someRect)

        self.label.text = self.text
        self.backgroundColor = homeColor
        self.label.textColor = homeTextColor

        self.label.numberOfLines = 0
        self.addSubview(self.label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.autoCenterInSuperview()
        self.label.autoMatchDimension(.Width, toDimension: .Width, ofView: self, withMultiplier: 0.75)
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ChunkyButton: UIControl {
    private let inner: InnerChunkyButton
    private let didClick: (ChunkyButton -> ())?

    init(text: String, didClick: (ChunkyButton -> ())?) {
        self.inner = InnerChunkyButton(text: text)
        self.didClick = didClick
        super.init(frame: someRect)
        self.selected = false
        self._invalidateSelected()
        self.addSubview(self.inner)

        self.rac_signalForControlEvents([.TouchUpInside]).subscribeNext {
            [unowned self] _ in
            self.didClick?(self)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Set the font to be proportional to height. That way we don't have to hardcode
        // font sizes for each screen size.
        self.inner.label.font = UIFont.systemFontOfSize(self.bounds.size.height / 5.5, weight: UIFontWeightHeavy)
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