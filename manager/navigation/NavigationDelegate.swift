//
//  NavigationDelegate.swift
//  Playtomic
//
//  Created by Angel Luis Garcia on 22/05/2018.
//  Copyright © 2018 Syltek Solutions S.L. All rights reserved.
//
// swiftlint:disable weak_delegate
import Foundation

class NavigationDelegate: NSObject, UIGestureRecognizerDelegate {

    weak var navigationController: UINavigationController?
    weak var originalDelegate: UIGestureRecognizerDelegate?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.originalDelegate = navigationController.interactivePopGestureRecognizer?.delegate
    }

    @objc
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let nav = navigationController, nav.isNavigationBarHidden && nav.viewControllers.count > 1 else {
            return self.originalDelegate?.gestureRecognizer?(gestureRecognizer, shouldReceive: touch) ?? false
        }
        return true
    }

    override func responds(to aSelector: Selector) -> Bool {
        guard aSelector == #selector(gestureRecognizer(_:shouldReceive:)) else {
            return self.originalDelegate?.responds(to: aSelector) ?? false
        }
        return true
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return self.originalDelegate
    }

}

extension UINavigationController {

    var forwardingNavigationDelegate: NavigationDelegate? {
        get {
            let pointer = Unmanaged.passUnretained(self).toOpaque()
            return objc_getAssociatedObject(self, pointer) as? NavigationDelegate
        }
        set {
            let pointer = Unmanaged.passUnretained(self).toOpaque()
            objc_setAssociatedObject(self, pointer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
