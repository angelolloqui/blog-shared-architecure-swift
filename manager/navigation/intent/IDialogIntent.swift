//
//  IDialogIntent.swift
//  My Sports
//
//  Created by Angel Luis Garcia on 14/06/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

protocol IDialogIntent {
    var image: UIImage? { get }
    var title: String? { get }
    var imageUrl: String? { get }
    var message: String? { get }
    var positiveAction: DialogAction? { get }
    var negativeAction: DialogAction? { get }
    var neutralAction: DialogAction? { get }
    var cancelable: Bool { get }
    var onCancel: (() -> Void)? { get }
}

struct DialogAction {
    let title: String
    let handler: (() -> Void)?
}
