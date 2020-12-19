//
//  GameItemModel.swift
//  iOSCarePlus
//
//  Created by 김지혜 on 2020/12/16.
//

import Foundation

struct NewGameResponse: Decodable {
    let contents: [NewGameContent]
}

struct NewGameContent: Decodable {
    let formalName: String
    let heroBannerUrl: String
    let titleId: Int
    let screenShots: [ScreenShot]
    
    enum CodingKeys: String, CodingKey {
        case formalName = "formal_name"
        case heroBannerUrl = "hero_banner_url"
        case titleId = "id"
        case screenShots = "screenshots"
    }
}

struct ScreenShot: Decodable {
    let images: [Image]
}

struct Image: Decodable {
    let url: String
}

struct NewGamePriceResponse: Decodable {
    let prices: [NewGamePrice]
}

struct NewGamePrice: Decodable {
    let titleId: Int
    let regularPrice: Price
    let discountPrice: Price?
    
    enum CodingKeys: String, CodingKey {
        case titleId = "title_id"
        case regularPrice = "regular_price"
        case discountPrice = "discount_price"
    }
}

struct Price: Decodable {
    let rawValue: String
    
    enum CodingKeys: String, CodingKey {
        case rawValue = "raw_value"
    }
}

struct GameItemModel: Codable {
    let gameTitle: String
    let gamePrice: Int?
    let gameSalePrice: Int
    let imageUrl: String
    let subImageUrls: [String]
}
