//
//  IDeepLinkHandler.swift
//  My Sports
//
//  Created by Angel Luis Garcia on 02/10/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

protocol IDeepLinkHandler {
    func processUrl(_ url: URL, appRelaunched: Bool) -> Bool
}
