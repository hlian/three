import UIKit

protocol EditViewModel {
    var editText: String { get }
    func editDone(text: String)
}

class EditView: UIView {
    private let textView: UITextView = UITextView(forAutoLayout: ())
    private let done: UIButton = UIButton(type: .System)
    private var viewModel: EditViewModel?

    private var doneRightConstraint: NSLayoutConstraint!

    init() {
        super.init(frame: someRect)

        addSubview(self.textView)
        textView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(44, 0, 0, 0))
        textView.editable = true
        textView.textColor = editTextColor
        textView.backgroundColor = editBackgroundColor
        textView.textContainer.lineFragmentPadding = 0
        textView.returnKeyType = .Done

        addSubview(done)
        done.translatesAutoresizingMaskIntoConstraints = false
        done.autoPinEdgeToSuperviewEdge(.Top, withInset: 0)
        doneRightConstraint = done.autoPinEdgeToSuperviewEdge(.Right, withInset: 0)
        done.setTitle("DONE".localized(), forState: [.Normal])
        done.titleLabel?.font = bodyFont.fontWithSize(18)

        done.rac_signalForControlEvents([.TouchUpInside]).subscribeNext {
            [unowned self] _ in
            self.viewModel?.editDone(self.textView.text)
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

    func updateViewModel(viewModel: EditViewModel) {
        textView.text = viewModel.editText
        self.viewModel = viewModel
        self._invalidateTextViewFont()
    }

    func focus() {
        textView.becomeFirstResponder()
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
        textView.font = bodyFont.fontWithSize(w / 5)
        while true {
            let font = textView.font!
            if font.pointSize <= minSize {
                break
            }
            let size = font.sizeOfString(textView.text, constrainedToWidth: w - 0.08 * w)
            if size.height <= textView._height - keyboardHeight.value - 0.08 * w {
                break
            }
            textView.font = font.fontWithSize(font.pointSize - 1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}