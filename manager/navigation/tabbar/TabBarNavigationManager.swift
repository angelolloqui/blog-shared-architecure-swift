//
//  TabBarNavigationManager.swift
//  My Sports
//
//  Created by Manuel Gonzalez Villegas on 5/12/16.
//  Copyright © 2016 Syltek Solutions S.L. All rights reserved.
//

import Foundation
import UIKit

class TabBarNavigationManager: NSObject, ITabBarNavigationManager {
    var tabItems: [TabItemConfig] = []
    var selectedTabIndex: Int {
        return tabBarController.selectedIndex
    }

    fileprivate let tabBarController: UITabBarController
    fileprivate var navigationManagers: [INavigationManager] = []

    fileprivate var selectedNavigationManager: INavigationManager {
        return navigationManagers[selectedTabIndex]
    }

    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
        super.init()
        tabBarController.delegate = self
    }

    func configTabs(tabItems: [TabItemConfig]) {
        self.tabItems = tabItems
        let navigationControllers: [UINavigationController] = tabItems.map { item in
            let navBarController = UINavigationController()
            navBarController.tabBarItem.title = item.title
            navBarController.tabBarItem.image = UIImage(resource: item.icon)
            if item.title == nil {
                navBarController.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0, bottom: -6, right: 0)
            }
            return navBarController
        }
        navigationManagers = navigationControllers.map { NavigationManager(navigationController: $0) }
        tabBarController.viewControllers = navigationControllers
        openSelectedTab()
    }

    func selectTab(item: TabItemConfig) {
        guard let index = tabItems.index(of: item) else { return }
        tabBarController.selectedIndex = index
        openSelectedTab()
    }

    func show(_ intent: INavigationIntent, animation: NavigationAnimation) {
        selectedNavigationManager.show(intent, animation: animation)
    }

    func replace(view: IView, intent: INavigationIntent) {
        selectedNavigationManager.replace(view: view, intent: intent)
    }

    func dismiss(view: IView, animated: Bool) {
        selectedNavigationManager.dismiss(view: view, animated: animated)
    }

    func show(_ intent: IDialogIntent, animation: DialogAnimation) {
        selectedNavigationManager.show(intent, animation: animation)
    }
}

extension TabBarNavigationManager {

    fileprivate func openSelectedTab() {
        guard let navController = tabBarController.selectedViewController as? UINavigationController else { return }

        if let presentedViewController = tabBarController.presentedViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
        }

        if navController.viewControllers.isEmpty {
            let item = tabItems[selectedTabIndex]
            let coordinator = item.coordinator
            let intent = coordinator.mainIntent()
            navController.setViewControllers([intent.viewController], animated: false)
        } else {
            navController.popToRootViewController(animated: false)
        }
    }
}

extension TabBarNavigationManager: UITabBarControllerDelegate {

    // Always force tab change to be programmatic
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let index = tabBarController.viewControllers?.index(of: viewController) else { return true }
        selectTab(item: tabItems[index])
        return false
    }
}
