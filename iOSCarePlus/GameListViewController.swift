//
//  GameListViewController.swift
//  iOSCarePlus
//
//  Created by 김지혜 on 2020/12/16.
//

import Alamofire
import UIKit

class GameListViewController: UIViewController {
    let getNewGameListUrl: String = "https://ec.nintendo.com/api/KR/ko/search/new?count=10&offset=0"
    let getGamePriceUrl: String = "https://api.ec.nintendo.com/v1/price"
    
    @IBOutlet private weak var tableView: UITableView!
    
    var gameItems: [GameItemModel]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newGameListApiCall()
    }
    
    private func newGameListApiCall() {
        AF.request(getNewGameListUrl).responseJSON { [weak self] response in
            guard let data = response.data else { return }
            
            let decoder: JSONDecoder = JSONDecoder()
            guard let modelResponse: NewGameResponse = try? decoder.decode(NewGameResponse.self, from: data) else { return }
            
            var contentDictionary: [Int: NewGameContent] = [:]
            for content in modelResponse.contents {
                contentDictionary[content.titleId] = content
            }
            
            self?.getGamePriceApiCall(contentDictionary)
        }
    }
    
    private func getGamePriceApiCall(_ contentDictionary: [Int: NewGameContent]) { // class 로 만드는 방법? inout
        let ids: String = contentDictionary.keys.map { String($0) }.joined(separator: ",")
        let parameters: [String: String] = ["country": "KR", "ids": ids, "lang": "ko"]
        
        AF.request(getGamePriceUrl, method: .get, parameters: parameters).responseJSON { [weak self] response in
            guard let data = response.data else { return }
            let decoder: JSONDecoder = JSONDecoder()
            guard let modelResponse: NewGamePriceResponse = try? decoder.decode(NewGamePriceResponse.self, from: data) else { return }
            
            var newGameItems: [GameItemModel] = []
            for price in modelResponse.prices {
                guard let content = contentDictionary[price.titleId],
                      let model = self?.makeModel(content: content, price: price) else { return }
                
                newGameItems.append(model)
            }
            
            self?.gameItems = newGameItems
        }
    }
    
    private func makeModel(content: NewGameContent, price: NewGamePrice) -> GameItemModel? {
        guard let regularIntPrice = Int(price.regularPrice.rawValue) else { return nil }
        
        var gamePrice: Int?
        var gameSalePrice: Int = regularIntPrice
        
        if let discountPrice: Price = price.discountPrice {
            guard let discountIntPrice = Int(discountPrice.rawValue) else { return nil }
            
            gamePrice = regularIntPrice
            gameSalePrice = discountIntPrice
        }
        
        return GameItemModel(gameTitle: content.formalName,
                             gamePrice: gamePrice,
                             gameSalePrice: gameSalePrice,
                             imageUrl: content.heroBannerUrl,
                             subImageUrls: content.screenShots.map(\.images).flatMap { $0 }.map(\.url))
    }
}

extension GameListViewController: UITableViewDelegate {
}

extension GameListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        gameItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let gameItems = gameItems else { return .init() }
        
        let cell: GameItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: "GameItemTableViewCell",
                                                                        for: indexPath) as! GameItemTableViewCell
        
        cell.setModel(gameItems[indexPath.row])
        return cell
    }
}
