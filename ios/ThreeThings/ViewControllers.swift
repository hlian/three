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