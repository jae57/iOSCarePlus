//
//  GameListViewController.swift
//  iOSCarePlus
//
//  Created by 김지혜 on 2020/12/16.
//

import Alamofire
import UIKit

class GameListViewController: UIViewController {
    @IBOutlet private weak var newButton: SelectableButton!
    @IBOutlet private weak var saleButton: SelectableButton!
    @IBAction private func newButtonTouchUp(_ sender: SelectableButton) {
//        newButton.select(true)
//        saleButton.select(false)
        newButton.isSelected = true
        saleButton.isSelected = false
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.selectedLineCenterConstraints.constant = 0
            self?.view.layoutIfNeeded()
        }
        gameItems.removeAll()
        newGameListApiCall()
    }
    @IBOutlet private weak var selectedLineCenterConstraints: NSLayoutConstraint!
    
    @IBAction private func saleButtonTouchUp(_ sender: SelectableButton) {
        newButton.isSelected = false
        saleButton.isSelected = true
        
        let constant: CGFloat = saleButton.center.x - newButton.center.x
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.selectedLineCenterConstraints.constant = constant
            self?.view.layoutIfNeeded()
        }
        gameItems.removeAll()
        saleGameListApiCall()
    }
    var newCount: Int = 10
    var newOffset: Int = 0
    var isEnd: Bool? // 여기를 응답의 total 과 비교해서 바로 불린값 계산해서 주는 computedProperty 로 해줘도 됨
    var getNewGameListUrl: String { // computedProperty 는 무조건 var
        "https://ec.nintendo.com/api/KR/ko/search/new?count=\(newCount)&offset=\(newOffset)"
    }
    var getSaleGameListUrl: String {
        "https://ec.nintendo.com/api/KR/ko/search/sales?count=\(newCount)&offset=\(newOffset)"
    }
    
    // 1. 함수로 만들거나 2. 확장을 만들거나
//    private func isIndicatorCell(_ indexPath) -> Bool {
//        indexPath.row == gameItems.count
//    }
    
    let getGamePriceUrl: String = "https://api.ec.nintendo.com/v1/price"
    
    @IBOutlet private weak var tableView: UITableView!
    
    var gameItems: [GameItemModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.register(GameItemCodeTableViewCell.self, forCellReuseIdentifier: "GameItemCodeTableViewCell")
//        newButton.select(true)
//        saleButton.select(false)
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
    
    // NEW
    private func saleGameListApiCall() {
        AF.request(getSaleGameListUrl).responseJSON { [weak self] response in
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
            
            self?.isEnd = newGameItems.isEmpty
            
            self?.gameItems.append(contentsOf: newGameItems)
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

//extension IndexPath {
//    var isIndicatorCell: Bool {
//        indexPath.row == gameItems.count
//    }
//}

extension GameListViewController: UITableViewDataSource {
    // 테이블 뷰가 그려질 때 최초에 한번 ( reload 할 때도 계속 호출 되는 듯? )
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let isEnd = isEnd else { return 0 }

        if isEnd {
            return gameItems.count
        } else {
            return gameItems.count + 1
        }
    }
    
    // cellForRowAt 보다 더 빨리 불림 // 이제 보이려고 할 때
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == gameItems.count {
            newOffset += 10
            newGameListApiCall()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "GameItemCodeTableViewCell", for: indexPath)
        //        return cell
        
        // 페이징 1. 맨 마지막 셀을 이용하는 방법
        if indexPath.row == gameItems.count {
            // 위로 옮겼음
//            newOffset += 10
//            newGameListApiCall()
            
            // storyboard에서만들면 자동으로 table view 에 register 해줌
            // return UITableViewCell()
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "IndicatorCell", for: indexPath) as? IndicatorTableViewCell else { return .init() }
            cell.animationIndicatorView(isOn: true)
            
            return cell
        }

        let cell: GameItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: "GameItemTableViewCell",
                                                                        for: indexPath) as! GameItemTableViewCell

        cell.setModel(gameItems[indexPath.row])
        return cell
    }
}
