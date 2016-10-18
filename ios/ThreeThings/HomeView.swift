import UIKit
import PureLayout

class HomeView: UIView {
    let layoutView: HomeLayoutView

    init(layoutView: HomeLayoutView) {
        self.layoutView = layoutView
        super.init(frame: someRect)
        self.addSubview(self.layoutView)
        self.layoutView.translatesAutoresizingMaskIntoConstraints = false
        self.layoutView.autoPinEdge(.top, to: .top, of: self, withOffset: 25)
        self.layoutView.autoPinEdge(.left, to: .left, of: self, withOffset: 15)
        self.layoutView.autoPinEdge(.right, to: .right, of: self, withOffset: -15)
        self.layoutView.autoPinEdge(.bottom, to: .bottom, of: self, withOffset: -25)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
