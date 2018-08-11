//
//  IDeepLinkManager.swift
//  My Sports
//
//  Created by Angel Luis Garcia on 17/03/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation
import AnemoneSDK

protocol IDeepLinkManager {
    func addHandler(_ handler: IDeepLinkHandler)
    func processUrl(_ url: URL, appRelaunched: Bool) -> Bool
}
