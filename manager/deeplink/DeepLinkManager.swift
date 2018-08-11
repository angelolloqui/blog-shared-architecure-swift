//
//  DeepLinkManager.swift
//  My Sports
//
//  Created by Angel Luis Garcia on 17/03/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

class DeepLinkManager: IDeepLinkManager {
    var handlers: [IDeepLinkHandler] = []

    func addHandler(_ handler: IDeepLinkHandler) {
        handlers.append(handler)
    }

    func processUrl(_ url: URL, appRelaunched: Bool) -> Bool {
        guard let url = convertToAppLinkUrl(url) else {
            return false
        }

        var processed = false
        handlers.forEach { handler in
            if handler.processUrl(url, appRelaunched: appRelaunched) {
                processed = true
            }
        }

        return processed
    }

    private func convertToAppLinkUrl(_ url: URL) -> URL? {
        guard let baseUrl = URL(string: Constants.webUrl), let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        if url.host?.contains("playtomic") ?? false {
            return url
        }

        if url.scheme != Constants.scheme {
            return nil
        }

        components.path = "/\(components.host ?? "")\(components.path ?? "")"
        components.host = baseUrl.host
        components.scheme = baseUrl.scheme

        return components.url
    }

}
