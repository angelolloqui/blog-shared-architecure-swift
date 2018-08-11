//
//  TabItemConfig.swift
//  My Sports
//
//  Created by Manuel Gonzalez Villegas on 9/1/17.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation
import Rswift

struct TabItemConfig {
    let id: String
    let title: String?
    let icon: ImageResource
    let coordinator: IMainCoordinator
}

extension TabItemConfig: Equatable {
    static func == (lhs: TabItemConfig, rhs: TabItemConfig) -> Bool {
        return lhs.id == rhs.id
    }
}
