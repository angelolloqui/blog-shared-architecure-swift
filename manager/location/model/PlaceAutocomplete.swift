//
//  PlaceAutocomplete.swift
//  Anemone SDK
//
//  Created by Angel Luis Garcia on 21/04/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation
import AnemoneSDK

public struct PlaceAutocomplete {

    public let id: String
    public let description: String
    public let mainText: String
    public let secondaryText: String
    public let types: [PlaceAutocompleteType]

}

extension PlaceAutocomplete: JSONMappable {
    public init(json: JSONObject) throws {
        self.id = try json.getString("place_id")
        self.description = try json.getString("description")
        self.types = try json.getStringArray("types").map(PlaceAutocompleteType.init)
        let structuredFormattingJson = try json.getJSONObject("structured_formatting")
        self.mainText = try structuredFormattingJson.getString("main_text")
        self.secondaryText = try structuredFormattingJson.getString("secondary_text")
    }
}
