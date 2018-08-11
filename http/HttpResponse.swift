//
//  HttpResponse.swift
//  Anemone SDK
//
//  Created by Angel Luis Garcia on 21/09/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

public struct HttpResponse {
    public let request: HttpRequest
    public let headers: [String: String]
    public let code: Int
    public let body: Data

    public var isSuccessful: Bool {
        return code >= 200 && code < 400
    }
}

extension HttpResponse: Equatable {}
public func == (lhs: HttpResponse, rhs: HttpResponse) -> Bool {
    return lhs.request == rhs.request &&
        lhs.headers == rhs.headers &&
        lhs.code == rhs.code &&
        lhs.body == rhs.body
}
