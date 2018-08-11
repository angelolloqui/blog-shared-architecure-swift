//
//  DialogIntent.swift
//  My Sports
//
//  Created by Angel Luis Garcia on 14/06/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

class DialogIntent: IDialogIntent {
    var image: UIImage?
    var imageUrl: String?
    var title: String?
    var message: String?
    var positiveAction: DialogAction?
    var negativeAction: DialogAction?
    var neutralAction: DialogAction?
    var cancelable: Bool = true
    var onCancel: (() -> Void)?

    @discardableResult
    func image(_ image: UIImage?) -> DialogIntent {
        self.image = image
        return self
    }

    @discardableResult
    func imageUrl(_ imageUrl: String?) -> DialogIntent {
        self.imageUrl = imageUrl
        return self
    }

    @discardableResult
    func title(_ title: String?) -> DialogIntent {
        self.title = title
        return self
    }

    @discardableResult
    func message(_ message: String?) -> DialogIntent {
        self.message = message
        return self
    }

    @discardableResult
    func positiveAction(title: String, handler: (() -> Void)? = nil) -> DialogIntent {
        positiveAction = DialogAction(title: title, handler: handler)
        return self
    }

    @discardableResult
    func negativeAction(title: String, handler: (() -> Void)? = nil) -> DialogIntent {
        negativeAction = DialogAction(title: title, handler: handler)
        return self
    }

    @discardableResult
    func neutralAction(title: String, handler: (() -> Void)? = nil) -> DialogIntent {
        neutralAction = DialogAction(title: title, handler: handler)
        return self
    }

    @discardableResult
    func cancelable(_ cancelable: Bool = true, onCancel: (() -> Void)? = nil) -> DialogIntent {
        self.cancelable = cancelable
        self.onCancel = onCancel
        return self
    }

}
