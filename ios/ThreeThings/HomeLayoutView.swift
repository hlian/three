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

        self.bigView._frameOrigin = CGPoint(x: 0, y: 0)
        self.bigView._frameWidth = self.bounds.size.width
        self.bigView._frameHeight = usableY * 0.55

        self.midView._frameOrigin = CGPoint(x: 0, y: self.bigView._frameSteam.y + 20)
        self.midView._frameWidth = usableX * 0.55
        self.midView._frameHeight = usableY * 0.45

        self.smallView._frameOrigin = CGPoint(x: self.midView._frameSteam.x + 20, y: self.midView._frameOrigin.y)
        self.smallView._frameWidth = usableX * 0.45
        self.smallView._frameHeight = usableY * 0.45
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
