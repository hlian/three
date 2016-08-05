import UIKit

class HomeVC: UIViewController {
    let homeView: UIView

    init(homeView: UIView) {
        self.homeView = homeView
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        self.view = homeView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RootVC: UIViewController {
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
        addChildViewController(childVC)
        view.addSubview(childVC.view)
        _constrainChildView(childVC.view)
        childVC.didMoveToParentViewController(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func present(siblingVC: UIViewController, _ frame: CGRect) {
        childVC.willMoveToParentViewController(nil)
        addChildViewController(siblingVC)
        siblingVC.view.frame = frame
        siblingVC.view.layer.opacity = 0
        transitionFromViewController(childVC, toViewController: siblingVC, duration: 0.2, options: UIViewAnimationOptions(rawValue: 0), animations: {
            siblingVC.view.frame = self.childVC.view.bounds
            self._constrainChildView(siblingVC.view)
            siblingVC.view.layer.opacity = 1
            self.childVC.view.layer.opacity = 0
        }) { finished in
            self.childVC.view.layer.opacity = 1
            self.childVC.removeFromParentViewController()
            siblingVC.didMoveToParentViewController(self)
            self.childVC = siblingVC
        }
    }

    private func _constrainChildView(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
        view.autoPinEdgeToSuperviewEdge(.Left)
        view.autoPinEdgeToSuperviewEdge(.Right)
        view.autoPinToBottomLayoutGuideOfViewController(self, withInset: 0)
        view.frame = view.bounds
        view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
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