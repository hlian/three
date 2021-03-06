//
//  UIViewExtensions.swift
//  ThreeThings
//
//  Created by hao on 6/28/16.
//  Copyright © 2016 ThreeThings. All rights reserved.
//

import UIKit

extension UIView {
    public var _frameWidth: CGFloat {
        get {
            return self.frame.width
        }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }

    public var _frameHeight: CGFloat {
        get {
            return self.frame.height
        }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }

    public var _frameOrigin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }

    public var _frameSteam: CGPoint {
        get {
            var origin = self.frame.origin
            origin.x += self.frame.size.width
            origin.y += self.frame.size.height
            return origin
        }
        set {
            self.frame = CGRect(x: newValue.x - self._frameWidth, y: newValue.y - self._frameHeight, width: self._frameWidth, height: self._frameHeight)
        }
    }

    public var _width: CGFloat {
        get {
            return self.bounds.size.width
        }
    }

    public var _height: CGFloat {
        get {
            return self.bounds.size.height
        }
    }

    public func debug() {
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1
    }
}
