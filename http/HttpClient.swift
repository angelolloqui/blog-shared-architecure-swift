//
//  HttpClient.swift
//  Anemone SDK
//
//  Created by Angel Garcia on 20/12/2016.
//  Copyright © 2016 Syltek Solutions S.L. All rights reserved.
//

import Foundation
import UIKit

public class HttpClient: IHttpClient {
    let urlSession: URLSession
    let baseUrl: String
    let urlEncoder: IHttpParameterEncoder
    let bodyEncoders: [IHttpParameterEncoder]

    public init(baseUrl: String,
                timeOut: TimeInterval? = nil,
                urlSession: URLSession? = nil,
                urlEncoder: IHttpParameterEncoder = HttpUrlParameterEncoder(),
                bodyEncoders: [IHttpParameterEncoder] = [HttpJsonParameterEncoder(), HttpUrlParameterEncoder()]) {
        self.baseUrl = baseUrl
        self.urlSession = urlSession ?? URLSession(configuration: URLSessionConfiguration.default)
        if let timeOut = timeOut {
            self.urlSession.configuration.timeoutIntervalForRequest = timeOut
        }
        self.urlEncoder = urlEncoder
        self.bodyEncoders = bodyEncoders
    }

    public func request(_ httpRequest: HttpRequest) -> Promise<HttpResponse> {
        var urlString = hasScheme(httpRequest.url) ? httpRequest.url : "\(baseUrl)\(httpRequest.url)"
        var body: Data? = nil

        do {
            body = try buildRequestBody(httpRequest)
            try buildRequestQuery(httpRequest).let {
                urlString += "?\($0)"
            }
        } catch {
            return Promise(error: AnemoneException.jsonInvalidFormat)
        }

        guard let url = URL(string: urlString) else {
            return Promise(error: AnemoneException.wrongUrl)
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpRequest.method.rawValue
        request.httpBody = body
        request.setValue(encoderForType(httpRequest.contentType)?.contentType, forHTTPHeaderField: "Content-Type")
        httpRequest.headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        return Promise { fulfill, reject in
            let task = self.urlSession.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                let httpResponse = HttpResponse(request: httpRequest, response: response, body: data)

                if error == nil && httpResponse.isSuccessful {
                    fulfill(httpResponse)
                } else {
                    var serverMessage: Message? = nil
                    if let data = data {
                        serverMessage = self.getErrorMessage(data: data)
                    }
                    reject(AnemoneException.network(response: httpResponse, error: error, serverMessage: serverMessage))
                }
            }

            task.resume()
        }
    }

    func buildRequestQuery(_ request: HttpRequest) throws -> String? {
        guard let params = request.queryParams else { return nil }
        return try urlEncoder.stringEncode(params)
    }

    func buildRequestBody(_ request: HttpRequest) throws -> Data? {
        guard request.method != .get && request.method != .delete else { return nil }
        guard let params = request.bodyParams else { return nil }
        guard let encoder = encoderForType(request.contentType) else {
            throw AnemoneException.jsonInvalidFormat
        }
        return try encoder.dataEncode(params)
    }

    func getErrorMessage(data: Data) -> Message? {
        return JSONTransformer().transform(data: data)
    }

    func hasScheme(_ endpoint: String) -> Bool {
        return endpoint.hasPrefix("http://") || endpoint.hasPrefix("https://")
    }

    func encoderForType(_ type: String?) -> IHttpParameterEncoder? {
        guard let type = type else { return bodyEncoders.first }
        return bodyEncoders.filter { $0.contentType.starts(with: type) }.first
    }
}

extension HttpResponse {
    fileprivate init(request: HttpRequest, response: URLResponse?, body: Data?) {
        let httpResponse = response as? HTTPURLResponse
        self.init(request: request,
                  headers: httpResponse?.allHeaderFields as? [String : String] ?? [:],
                  code: httpResponse?.statusCode ?? 0,
                  body: body ?? Data())
    }
}
