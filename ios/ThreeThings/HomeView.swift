//
//  HomeView.swift
//  ThreeThings
//
//  Created by hao on 6/28/16.
//  Copyright © 2016 ThreeThings. All rights reserved.
//

import UIKit
import PureLayout

class HomeView: UIView {
    let layoutView: HomeLayoutView

    init(layoutView: HomeLayoutView) {
        self.layoutView = layoutView
        super.init(frame: someRect)
        self.addSubview(self.layoutView)
        self.layoutView.translatesAutoresizingMaskIntoConstraints = false
        self.layoutView.autoPinEdge(.Top, toEdge: .Top, ofView: self, withOffset: 100)
        self.layoutView.autoPinEdge(.Left, toEdge: .Left, ofView: self, withOffset: 15)
        self.layoutView.autoPinEdge(.Right, toEdge: .Right, ofView: self, withOffset: -15)
        let constraint = NSLayoutConstraint(item: self.layoutView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0.75, constant: -100)
        self.addConstraint(constraint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}