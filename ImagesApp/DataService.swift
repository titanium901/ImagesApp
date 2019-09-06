//
//  Network.swift
//  ImagesApp
//
//  Created by Yury Popov on 06/09/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import Foundation

class DataService {
    
    static let instance = DataService()
    
    var photos = [Photo]()
    var photos2 = [Photo]()
    var insertIndexPath: IndexPath!
    
    func getImages(strUrl: String, completion: @escaping () -> (Void)) {
        print("Функция")
        print(#function)
        DispatchQueue.global(qos: .background).async {
            let url = URL(string: strUrl)!
            let request = NSMutableURLRequest(url: url)
            
            URLSession.shared.dataTask(with: request as URLRequest) { [weak self] (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }
                
                do {
                    let dataJson = try JSONDecoder().decode([Photo].self, from: data!)
                    self?.photos2 = dataJson
                    print("Json Data2")
                    if self?.photos2.isEmpty ?? true {
                        print("returnnnnnnn")
                        return
                    }
                    print(dataJson)
                    DispatchQueue.main.async {
                        var index = 0
                        for _ in self!.photos2 {
                            self?.photos2[index].time = self?.currentTime()
                             self?.insertIndexPath = IndexPath(item: (self?.photos.count)!, section: 0)
                            self?.photos.append((self?.photos2[index])!)
//                            self?.collectionView.insertItems(at: [insertIndexPath])
                            completion()
                            index += 1
                        }
                    }
                    
                    
                    
                } catch let error {
                    print(error.localizedDescription)
                }
                
                }.resume()
        }
    }
    
    func currentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        let str = formatter.string(from: Date())
        return str.replacingOccurrences(of: "+0000", with: "", options: [], range: nil)
        
        
    }
}
