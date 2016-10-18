import UIKit
import ReactiveCocoa
import ReactiveObjC

protocol EditViewModel {
    var editText: String { get }
    func editDone(_ text: String)
}

class EditView: UIView {
    fileprivate let textView: UITextView = UITextView(forAutoLayout: ())
    fileprivate let done: UIButton = UIButton(type: .system)
    fileprivate var viewModel: EditViewModel?

    fileprivate var doneRightConstraint: NSLayoutConstraint!

    init() {
        super.init(frame: someRect)

        addSubview(self.textView)
        textView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsetsMake(44, 0, 0, 0))
        textView.isEditable = true
        textView.textColor = editTextColor
        textView.backgroundColor = editBackgroundColor
        textView.textContainer.lineFragmentPadding = 0
        textView.returnKeyType = .done

        addSubview(done)
        done.translatesAutoresizingMaskIntoConstraints = false
        done.autoPinEdge(toSuperviewEdge: .top, withInset: 0)
        doneRightConstraint = done.autoPinEdge(toSuperviewEdge: .right, withInset: 0)
        done.setTitle("DONE".localized(), for: UIControlState())
        done.titleLabel?.font = bodyFont.withSize(18)

        done.rac_signal(for: [.touchUpInside]).subscribeNext {
            [unowned self] _ in
            self.viewModel?.editDone(self.textView.text)
        }

        textView.rac_textSignal().subscribeNext {
            [unowned self] _ in
            self._invalidateTextViewFont()
        }

        keyboardHeight.signal.observeValues {
            [unowned self] _ in
            self._invalidateTextViewFont()
        }
    }

    func updateViewModel(_ viewModel: EditViewModel) {
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

    fileprivate func _invalidateTextViewFont() {
        let w = _width
        let minSize: CGFloat = 18.0
        textView.font = bodyFont.withSize(w / 5)
        while true {
            let font = textView.font!
            if font.pointSize <= minSize {
                break
            }
            let size = font.sizeOfString(textView.text, constrainedToWidth: w - 0.08 * w)
            if size.height <= textView._height - keyboardHeight.value - 0.08 * w {
                break
            }
            textView.font = font.withSize(font.pointSize - 1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
