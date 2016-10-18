//
//  ChunkyButton.swift
//  ThreeThings
//
//  Created by hao on 6/28/16.
//  Copyright © 2016 ThreeThings. All rights reserved.
//

import UIKit
import PureLayout
import ReactiveSwift

private class DoneControl: UIControl {
    let label: UILabel
    override init(frame: CGRect) {
        label = UILabel(frame: someRect)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = bodyFont.withSize(13)
        label.textColor = UIColor.white
        let doneText = "Done".localized()
        let doneString = NSMutableAttributedString(string: doneText)
        doneString.addAttribute(NSKernAttributeName, value: 5, range: NSMakeRange(0, doneText.characters.count))
        label.attributedText = doneString
        super.init(frame: frame)

        addSubview(label)
        label.autoCenterInSuperview()
        _invalidateSelected()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSelected = true
        UIView.animate(withDuration: 0.1, animations: {
            self._invalidateSelected()
        }) 
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSelected = false
        UIView.animate(withDuration: 0.1, animations: {
            self._invalidateSelected()
        }) 
        sendActions(for: [.touchUpInside])
    }

    func _invalidateSelected() {
        if (isSelected) {
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
        label.autoAlignAxis(toSuperviewAxis: .vertical)
        label.autoMatch(.width, to: .width, of: self, withMultiplier: 0.75)
        label.autoPinEdge(.top, to: .top, of: self, withOffset: 0)
        bottomLabelConstraint = label.autoPinEdge(.bottom, to: .bottom, of: self, withOffset: 0)
        label.textAlignment = .center
        label.font = bodyFont
        addSubview(shadowView)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.autoPinEdge(.left, to: .left, of: self)
        shadowView.autoPinEdge(.right, to: .right, of: self)
        shadowView.autoPinEdge(.bottom, to: .bottom, of: self)
        shadowView.autoSetDimension(.height, toSize: 3)
        addSubview(insetView)
        insetView.translatesAutoresizingMaskIntoConstraints = false
        insetView.autoPinEdge(.left, to: .left, of: self)
        insetView.autoPinEdge(.right, to: .right, of: self)
        insetView.autoPinEdge(.top, to: .top, of: self)
        insetView.autoSetDimension(.height, toSize: 3)
        addSubview(doneView)
        doneView.translatesAutoresizingMaskIntoConstraints = false
        doneView.autoPinEdge(.left, to: .left, of: self)
        doneView.autoPinEdge(.right, to: .right, of: self)
        doneView.autoPinEdge(.bottom, to: .bottom, of: self, withOffset: -3)
        doneView.autoSetDimension(.height, toSize: 44)
    }

    func updateText(_ text: String) {
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
    fileprivate let inner: InnerChunkyButton
    fileprivate var viewModel: ButtonViewModel!

    init() {
        self.inner = InnerChunkyButton()
        super.init(frame: someRect)

        _invalidateSelected()
        addSubview(self.inner)

        rac_signal(for: [.touchUpInside]).subscribeNext {
            [unowned self] _ in
            self.viewModel.chunkyButtonDidClick()
        }

        inner.doneView.rac_signal(for: [.touchUpInside]).subscribeNext {
            [unowned self] _ in
            self.viewModel.chunkyButtonDone()
        }
    }

    func updateViewModel(_ viewModel: ButtonViewModel) {
        self.viewModel = viewModel
        self.inner.updateText(viewModel.chunkyButtonText)
        if viewModel.chunkyButtonActive {
            inner.backgroundColor = homeTextColor
            inner.label.textColor = homeColor
            inner.doneView.isHidden = false
            inner.bottomLabelConstraint.constant = -44
        } else {
            inner.backgroundColor = homeColor
            inner.label.textColor = homeTextColor
            inner.doneView.isHidden = true
            inner.bottomLabelConstraint.constant = 0
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Set the font to be proportional to height. That way we don't have to hardcode
        // font sizes for each screen size.
        self.inner.label.font = self.inner.label.font.withSize(self.bounds.size.height / 8)
        if self.isSelected {
            self.inner._frameOrigin = CGPoint(x: 0, y: 3)
        } else {
            self.inner.frame = self.bounds
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isSelected = true
        self._invalidateSelected()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isSelected = false
        self._invalidateSelected()
        self.sendActions(for: [.touchUpInside])
    }

    func _invalidateSelected() {
        if (self.isSelected) {
            self.inner.shadowView.backgroundColor = UIColor.clear
        } else {
            self.inner.shadowView.backgroundColor = homeShadowColor
        }
        self.setNeedsLayout()
    }
}
