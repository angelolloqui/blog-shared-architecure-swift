//
//  FileStorage.swift
//  Anemone SDK
//
//  Created by Angel Luis Garcia on 08/02/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

public class FileStorage: IFileStorage {
    let path: String

    public init(directory: FileManager.SearchPathDirectory) {
        let paths = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)
        self.path = paths[0]
    }

    public func writeData(_ data: Data, file: String) throws {
        let url = try fileURL(name: file)
        try data.write(to: url, options: Data.WritingOptions.atomic)
    }

    public func writeDataAsync(_ data: Data, file: String) -> Promise<Void> {
        return Promise(executeInBackground: true) { (fulfill, reject) in
            try self.writeData(data, file: file)
            fulfill(Void())
        }
    }

    public func readData(file: String) -> Data? {
        guard let url = try? fileURL(name: file) else {
            return nil
        }
        return try? Data(contentsOf: url)
    }

    public func readDataAsync(file: String) -> Promise<Data> {
        return Promise(executeInBackground: true) { (fulfill, reject) in
            if let data = self.readData(file: file) {
                fulfill(data)
            } else {
                reject(AnemoneException.notFound)
            }
        }
    }

    private func fileURL(name: String) throws -> URL {
        guard let url = URL(string: "file://\(path)/\(name)") else {
            throw AnemoneException.wrongUrl
        }
        return url
    }
}
