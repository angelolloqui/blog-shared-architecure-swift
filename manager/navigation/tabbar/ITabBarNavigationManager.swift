//
//  ITabBarNavigationManager.swift
//  My Sports
//
//  Created by Manuel Gonzalez Villegas on 9/1/17.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

protocol ITabBarNavigationManager: INavigationManager {
    var tabItems: [TabItemConfig] { get }
    var selectedTabIndex: Int { get }
    func configTabs(tabItems: [TabItemConfig])
    func selectTab(item: TabItemConfig)
}
