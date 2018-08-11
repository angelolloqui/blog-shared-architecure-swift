//
//  IFileStorage.swift
//  Anemone SDK
//
//  Created by Angel Luis Garcia on 08/02/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

public protocol IFileStorage: class {

    func writeData(_ data: Data, file: String) throws
    func writeDataAsync(_ data: Data, file: String) -> Promise<Void>

    func readData(file: String) -> Data?
    func readDataAsync(file: String) -> Promise<Data>

}
