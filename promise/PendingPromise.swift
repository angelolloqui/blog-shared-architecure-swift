//
//  PendingPromise.swift
//  Anemone SDK
//
//  Created by Angel Luis Garcia on 13/06/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation
import PromiseKit

public class PendingPromise<T>: Promise<T> {
    let pending: (fulfill: (T) -> Void, reject: (Error) -> Void)

    required public init() {
        let pending = PromiseKit.Promise<T>.pending()
        self.pending = (pending.fulfill, pending.reject)
        super.init(promise: pending.promise)
    }

    @available(*, unavailable, renamed: "init()")
    required public init(executeInBackground: Bool = false, resolvers: @escaping (_ fulfill: @escaping (T) -> Void, _ reject: @escaping (Error) -> Void) throws -> Void) {
        fatalError()
    }

    @available(*, unavailable, renamed: "init()")
    required public init(error: Error) {
        fatalError()
    }

    @available(*, unavailable, renamed: "init()")
    required public init(value: T) {
        fatalError()
    }

    public func fulfill(_ value: T) {
        pending.fulfill(value)
    }

    public func reject(_ error: Error) {
        pending.reject(error)
    }
}
