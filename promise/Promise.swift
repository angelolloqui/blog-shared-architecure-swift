//
//  Promise.swift
//  Anemone SDK
//
//  Created by Angel Luis Garcia on 27/01/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation
import PromiseKit

public class Promise<T> {
    var promise: PromiseKit.Promise<T>

    required public init(executeInBackground: Bool = false, resolvers: @escaping (_ fulfill: @escaping (T) -> Void, _ reject: @escaping (Error) -> Void) throws -> Void) {
        self.promise = PromiseKit.Promise { fulfill, reject in
            let executionJob = {
                do {
                    try resolvers(fulfill, reject)
                } catch {
                    reject(error)
                }
            }

            if executeInBackground {
                DispatchQueue.global(qos: .background).async(execute: executionJob)
            } else {
                executionJob()
            }
        }
    }

    required public init(value: T) {
        self.promise = PromiseKit.Promise(value: value)
    }

    required public init(error: Error) {
        self.promise = PromiseKit.Promise(error: error)
    }

    internal init(promise: PromiseKit.Promise<T>) {
        self.promise = promise
    }

    public var value: T? {
        return promise.value
    }
    public var error: Error? {
        return promise.error
    }

    @discardableResult
    public func then(_ body: @escaping (T) throws -> Void) -> Promise<T> {
        return then(map: { (value) in
            try body(value)
            return value
        })
    }

    @discardableResult
    public func then<U>(map body: @escaping (T) throws -> U) -> Promise<U> {
        return Promise<U>(promise: promise.then(execute: body))
    }

    @discardableResult
    public func then<U>(promise body: @escaping (T) throws -> Promise<U>) -> Promise<U> {
        let pendingPromise = PromiseKit.Promise<U>.pending()
        promise
            .then { (result: T) -> Void in
                let deferredPromise = try body(result)
                deferredPromise
                    .then(map: pendingPromise.fulfill)
                    .catchError(pendingPromise.reject)
            }.catch(execute: pendingPromise.reject)

        return Promise<U>(promise: pendingPromise.promise)
    }

    @discardableResult
    public func catchError(_ body: @escaping (Error) -> Void) -> Promise<T> {
        return Promise<T>(promise: promise.catch(execute: body))
    }

    @discardableResult
    public func always(_ body: @escaping () -> Void) -> Promise<T> {
        return Promise<T>(promise: promise.always(execute: body))
    }

}

public func whenAll<T>(promises: [Promise<T>]) -> Promise<[T]> {
    return Promise { fulfill, reject in
        let internalPromises = promises.map { $0.promise }
        when(fulfilled: internalPromises).then(execute: fulfill).catch(execute: reject)
    }
}

public func whenAll<T1, T2>(_ promise1: Promise<T1>, _ promise2: Promise<T2>) -> Promise<(T1, T2)> {
    return Promise { fulfill, reject in
        when(fulfilled: promise1.promise, promise2.promise)
            .then(execute: fulfill)
            .catch(execute: reject)
    }
}

public func whenAll<T1, T2, T3>(_ promise1: Promise<T1>, _ promise2: Promise<T2>, _ promise3: Promise<T3>) -> Promise<(T1, T2, T3)> {
    return Promise { fulfill, reject in
        when(fulfilled: promise1.promise, promise2.promise, promise3.promise)
            .then(execute: fulfill)
            .catch(execute: reject)
    }
}

public func whenAll<T1, T2, T3, T4>(_ promise1: Promise<T1>, _ promise2: Promise<T2>, _ promise3: Promise<T3>, _ promise4: Promise<T4>) -> Promise<(T1, T2, T3, T4)> {
    return Promise { fulfill, reject in
        when(fulfilled: promise1.promise, promise2.promise, promise3.promise, promise4.promise)
            .then(execute: fulfill)
            .catch(execute: reject)
    }
}
