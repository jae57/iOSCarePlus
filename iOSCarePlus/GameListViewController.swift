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
        
        AF.request(getGamePriceUrl,
                   method: .get,
                   parameters: ["country": "KR", "ids": ids, "lang": "ko"]).responseJSON { [weak self] response in
                    guard let data = response.data else { return }
                    let decoder: JSONDecoder = JSONDecoder()
                    guard let modelResponse: NewGamePriceResponse = try? decoder.decode(NewGamePriceResponse.self, from: data) else { return }
                    
                    var newGameItems: [GameItemModel] = []
                    for price in modelResponse.prices {
                        guard let content = contentDictionary[price.titleId] else { return }
                        
                        var model: GameItemModel
                        guard let regularIntPrice = Int(price.regularPrice.rawValue) else { return }
                        
                        if let discountPrice: Price = price.discountPrice {
                            guard let discountIntPrice = Int(discountPrice.rawValue) else { return }
                            
                            model = GameItemModel(gameTitle: content.formalName,
                                                  gamePrice: regularIntPrice,
                                                  gameSalePrice: discountIntPrice,
                                                  imageUrl: content.heroBannerUrl)
                        } else {
                            model = GameItemModel(gameTitle: content.formalName,
                                                  gamePrice: nil,
                                                  gameSalePrice: regularIntPrice,
                                                  imageUrl: content.heroBannerUrl)
                        }
                        
                        newGameItems.append(model)
                    }
                    
                    self?.gameItems = newGameItems
                   }
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
        
        let cell: GameItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: "GameItemTableViewCell", for: indexPath) as! GameItemTableViewCell
        
        cell.setModel(gameItems[indexPath.row])
        return cell
    }
}
