import UIKit

class HomeLayoutView: UIView {
    let bigView: UIView
    let midView: UIView
    let smallView: UIView

    init(withBigView bigView: UIView, midView: UIView, smallView: UIView) {
        self.bigView = bigView
        self.midView = midView
        self.smallView = smallView
        super.init(frame: someRect)

        self.addSubview(self.bigView)
        self.addSubview(self.midView)
        self.addSubview(self.smallView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let usableX = self.bounds.size.width - 20
        let usableY = self.bounds.size.height - 20

        self.bigView._frameOrigin = CGPointMake(0, 0)
        self.bigView._frameWidth = self.bounds.size.width
        self.bigView._frameHeight = usableY * 0.55

        self.midView._frameOrigin = CGPointMake(0, self.bigView._frameSteam.y + 20)
        self.midView._frameWidth = usableX * 0.55
        self.midView._frameHeight = usableY * 0.45

        self.smallView._frameOrigin = CGPointMake(self.midView._frameSteam.x + 20, self.midView._frameOrigin.y)
        self.smallView._frameWidth = usableX * 0.45
        self.smallView._frameHeight = usableY * 0.45

        self.bigView.layer.borderColor = UIColor.redColor().CGColor
        self.bigView.layer.borderWidth = 1
        self.midView.layer.borderColor = UIColor.redColor().CGColor
        self.midView.layer.borderWidth = 1
        self.smallView.layer.borderColor = UIColor.redColor().CGColor
        self.smallView.layer.borderWidth = 1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}