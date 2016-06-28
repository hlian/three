//
//  ViewController.swift
//  ThreeThings
//
//  Created by hao on 6/28/16.
//  Copyright © 2016 ThreeThings. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let homeLayoutView: HomeLayoutView

    init(homeLayoutView: HomeLayoutView) {
        self.homeLayoutView = homeLayoutView
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        self.view = self.homeLayoutView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

