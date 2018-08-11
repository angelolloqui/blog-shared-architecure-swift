//
//  NavigationManager.swift
//  My Sports
//
//  Created by Manuel Gonzalez Villegas on 5/12/16.
//  Copyright © 2016 Syltek Solutions S.L. All rights reserved.
//

import Foundation
import UIKit
import Hero
import PlaytomicUI

class NavigationManager: INavigationManager {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func show(_ intent: INavigationIntent, animation: NavigationAnimation) {
        guard !isModalPresented else {
            NSLog("WARN: Trying to show a view controller when a modal is shown -> Do nothing")
            return
        }
        let viewController = intent.viewController
        if animation == .push || animation == .none {
            push(viewController: viewController, animation: animation)
        } else if animation == .modal {
            presentModal(viewController: viewController)
        } else {
            let navVC = UINavigationController(rootViewController: viewController)
            configureInteractivePopGestureDelegate(navigationController: navVC)
            viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icAssetArrowBack(),
                                                                      style: .plain,
                                                                      target: viewController,
                                                                      action: #selector(UIViewController.dismissIfPresented))
            present(viewController: navVC, animation: animation)
        }
    }

    func replace(view: IView, intent: INavigationIntent) {
        guard let viewController = view as? UIViewController,
            let navigationController = viewController.navigationController,
            let index = navigationController.viewControllers.index(of: viewController) else { return }

        var viewControllers = Array(navigationController.viewControllers.prefix(upTo: index))
        viewControllers.append(intent.viewController)
        navigationController.setViewControllers(viewControllers, animated: false)
    }

    func dismiss(view: IView, animated: Bool) {
        guard let viewController = view as? UIViewController else {
            return
        }

        //If not first, pop to current
        if  let navigationController = viewController.navigationController,
            let index = navigationController.viewControllers.index(of: viewController),
            index > 0 {
            let toViewController = navigationController.viewControllers[index - 1]
            navigationController.popToViewController(toViewController, animated: animated)
        } else if let presentingViewController = viewController.presentingViewController {
            animatingDismissViewController = viewController.presentingViewController?.presentedViewController       // Check comment below
            presentingViewController.dismiss(animated: animated, completion: nil)
        }
    }

    func show(_ intent: IDialogIntent, animation: DialogAnimation) {
        var handled = false
        var alert = AlertDialog.Builder(rootViewController: topViewController)
            .setTitle(intent.title)
            .setImage(intent.image)
            .setImageUrl(intent.imageUrl)
            .setMessage(intent.message)
            .setCancelable(intent.cancelable)
            .setOnCancelListener {
                if !handled {
                    handled = true
                    intent.onCancel?()
                }
        }
        intent.positiveAction.let { action in
            alert = alert.setPositiveButton(text: action.title) {
                if !handled {
                    handled = true
                    action.handler?()
                }
            }
        }
        intent.negativeAction.let { action in
            alert = alert.setNegativeButton(text: action.title) {
                if !handled {
                    handled = true
                    action.handler?()
                }
            }
        }
        intent.neutralAction.let { action in
            alert = alert.setNeutralButton(text: action.title) {
                if !handled {
                    handled = true
                    action.handler?()
                }
            }
        }
        alert.show()
    }

    private func push(viewController: UIViewController, animation: NavigationAnimation) {
        let navigationController = topNavigationController
        if animation == .custom {
            navigationController.hero.isEnabled = true
        } else {
            navigationController.hero.isEnabled = false
        }
        viewController.hidesBottomBarWhenPushed = true
        configureInteractivePopGestureDelegate(navigationController: navigationController)
        navigationController.pushViewController(viewController, animated: animation != .none)
    }

    private func present(viewController: UINavigationController, animation: NavigationAnimation) {
        if animation == .transparent {
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = TransitionDelegates.transparent
        } else if animation == .fade {
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = TransitionDelegates.fade
        } else if animation == .custom {
            viewController.hero.isEnabled = true
            topNavigationController.tabBarController?.tabBar.hero.modifiers = [.fade, .translate(y: 60), .zPosition(1000), .useGlobalCoordinateSpace]
        } else {
            viewController.hero.isEnabled = false
            topNavigationController.tabBarController?.tabBar.hero.id = nil
        }
        if let popover = viewController.popoverPresentationController {
            popover.configureSource(fromSender: nil)
        }
        topNavigationController.present(viewController, animated: animation != .none) { [weak self] in
            self?.animatingPresentViewController = nil
        }
        animatingPresentViewController = viewController
    }

    private func presentModal(viewController: UIViewController) {
        lastModalViewController = viewController

        let topViewController = self.topViewController
        viewController.hero.isEnabled = false
        topNavigationController.tabBarController?.tabBar.hero.id = nil

        perform(
            when: { topViewController.presentedViewController == nil },
            action: {
                topViewController.present(viewController, animated: true) { [weak self] in
                    self?.animatingPresentViewController = nil
                }
        })
        animatingPresentViewController = viewController
    }

    private var topNavigationController: UINavigationController {
        var currentController: UIViewController? = self.topViewController
        while currentController != nil {
            if let navController = currentController as? UINavigationController {
                return navController
            }
            currentController = currentController?.presentingViewController
        }

        return navigationController
    }

    // agarcia: Dirty hack but when a view is being dismissed (not poped) the "isBeingDismissed" takes some time to reflect the change on the parent.
    private weak var animatingDismissViewController: UIViewController?

    // agarcia: Dirty hack but when a view is being presented (not pushed) the "presentedViewController" takes some time to reflect the change.
    // Keeps the presentingViewController performing animation to consider it for concurrent presentation actions (like present and push at same time)
    private weak var animatingPresentViewController: UIViewController?

    private var topViewController: UIViewController {
        if let animatingPresentViewController = animatingPresentViewController,
            !animatingPresentViewController.isBeingDismissed,
            animatingPresentViewController.presentingViewController != nil {
            return animatingPresentViewController
        }
        var topViewController: UIViewController = navigationController
        var currentController = navigationController.presentedViewController
        while currentController != nil && currentController?.isBeingDismissed == false && currentController !== animatingDismissViewController {
            topViewController = currentController ?? topViewController
            currentController = currentController?.presentedViewController
        }
        return topViewController
    }

    private weak var lastModalViewController: UIViewController?
    private var isModalPresented: Bool {
        var viewController: UIViewController? = topViewController
        repeat {
            if viewController === lastModalViewController {
                return true
            }
            viewController = viewController?.presentingViewController
        } while viewController != nil
        return false
    }

    private func configureInteractivePopGestureDelegate(navigationController: UINavigationController) {
        if navigationController.forwardingNavigationDelegate != nil {
            return
        }
        navigationController.forwardingNavigationDelegate = NavigationDelegate(navigationController: navigationController)
        navigationController.interactivePopGestureRecognizer?.delegate = navigationController.forwardingNavigationDelegate
    }

    private func perform(when: @escaping () -> Bool, action: @escaping () -> Void, timeout: TimeInterval = 0.5) {
        if when() || timeout < 0.1 {
            action()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.perform(when: when, action: action, timeout: timeout - 0.1)
            }
        }
    }
}

extension UIViewController {

    @objc
    func dismissIfPresented() {
        guard self.presentingViewController != nil else { return }
        self.dismiss(animated: true, completion: nil)
    }

    @objc
    func popOrDismiss() {
        if let navController = self.navigationController, let index = navController.viewControllers.index(of: self), index > 0 {
            navController.popToViewController(navController.viewControllers[index - 1], animated: true)
        } else {
            self.dismissIfPresented()
        }
    }
}
