import UIKit

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