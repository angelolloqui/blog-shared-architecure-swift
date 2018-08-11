//
//  IHttpClient.swift
//  Anemone SDK
//
//  Created by Manuel Gonzalez Villegas on 5/12/16.
//  Copyright © 2016 Syltek Solutions S.L. All rights reserved.
//

import Foundation

public protocol IHttpClient {
    func request(_ httpRequest: HttpRequest) -> Promise<HttpResponse>
}

extension IHttpClient {

    public func get(endpoint: String, params: [String: Any]?) -> Promise<Data> {
        return request(HttpRequest(method: .get, url: endpoint, queryParams: params, bodyParams: nil, headers: nil))
            .then { $0.body }
    }

    public func post(endpoint: String, params: [String: Any]?) -> Promise<Data> {
        return request(HttpRequest(method: .post, url: endpoint, queryParams: nil, bodyParams: params, headers: nil))
            .then { $0.body }
    }

    public func put(endpoint: String, params: [String: Any]?) -> Promise<Data> {
        return request(HttpRequest(method: .put, url: endpoint, queryParams: nil, bodyParams: params, headers: nil))
            .then { $0.body }
    }

    public func patch(endpoint: String, params: [String: Any]?) -> Promise<Data> {
        return request(HttpRequest(method: .patch, url: endpoint, queryParams: nil, bodyParams: params, headers: nil))
            .then { $0.body }
    }

    public func delete(endpoint: String, params: [String: Any]?) -> Promise<Data> {
        return request(HttpRequest(method: .delete, url: endpoint, queryParams: params, bodyParams: nil, headers: nil))
            .then { $0.body }
    }

}
