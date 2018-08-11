//
//  INavigationManager.swift
//  My Sports
//
//  Created by Manuel Gonzalez Villegas on 5/12/16.
//  Copyright © 2016 Syltek Solutions S.L. All rights reserved.
//

import Foundation
import UIKit

protocol INavigationManager {

    func show(_ intent: INavigationIntent, animation: NavigationAnimation)
    func replace(view: IView, intent: INavigationIntent)
    func dismiss(view: IView, animated: Bool)

    func show(_ intent: IDialogIntent, animation: DialogAnimation)
}
