import UIKit
import PureLayout

class HomeView: UIView {
    let layoutView: HomeLayoutView

    init(layoutView: HomeLayoutView) {
        self.layoutView = layoutView
        super.init(frame: someRect)
        self.addSubview(self.layoutView)
        self.layoutView.translatesAutoresizingMaskIntoConstraints = false
        self.layoutView.autoPinEdge(.Top, toEdge: .Top, ofView: self, withOffset: 25)
        self.layoutView.autoPinEdge(.Left, toEdge: .Left, ofView: self, withOffset: 15)
        self.layoutView.autoPinEdge(.Right, toEdge: .Right, ofView: self, withOffset: -15)
        self.layoutView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self, withOffset: -25)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}