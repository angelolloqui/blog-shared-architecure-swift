//
//  HttpRequest.swift
//  Anemone SDK
//
//  Created by Angel Luis Garcia on 25/08/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

public struct HttpRequest {
    public let method: HttpMethod
    public let url: String
    public let queryParams: [String: Any]?
    public let bodyParams: [String: Any]?
    public let headers: [String: String]?

    public init(method: HttpMethod, url: String, queryParams: [String: Any]?, bodyParams: [String: Any]?, headers: [String: String]?) {
        self.method = method
        self.url = url
        self.queryParams = queryParams
        self.bodyParams = bodyParams
        self.headers = headers
    }

    public func copy(method: HttpMethod? = nil,
                     url: String? = nil,
                     queryParams: [String: Any]? = nil,
                     bodyParams: [String: Any]? = nil,
                     headers: [String: String]? = nil) -> HttpRequest {
        return HttpRequest(
            method: method ?? self.method,
            url: url ?? self.url,
            queryParams: queryParams ?? self.queryParams,
            bodyParams: bodyParams ?? self.bodyParams,
            headers: headers ?? self.headers)
    }

    public var contentType: String? {
        return headers?["Content-Type"]
    }

}

extension HttpRequest: Equatable {}
public func == (lhs: HttpRequest, rhs: HttpRequest) -> Bool {
    return lhs.method == rhs.method &&
        lhs.url == rhs.url &&
        lhs.queryParams?.description == rhs.queryParams?.description &&
        lhs.bodyParams?.description == rhs.bodyParams?.description &&
        (lhs.headers ?? [:]) == (rhs.headers ?? [:])

}
