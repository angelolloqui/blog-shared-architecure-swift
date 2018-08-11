//
//  ViewNavigationIntent.swift
//  My Sports
//
//  Created by Angel Luis Garcia on 20/04/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

class ViewNavigationIntent: INavigationIntent {
    public let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

}
