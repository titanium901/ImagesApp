//
//  ImagesViewController.swift
//  ImagesApp
//
//  Created by Yury Popov on 27/08/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import UIKit
import Kingfisher


class ImagesViewController: UICollectionViewController {
   
    let cache = KingfisherManager.shared.cache
    
    var photos = [Photo]()
    var photos2 = [Photo]()
    var defImages = [String]()
    var responseString = String()
    var downloadTime = String()
    var connection = Bool()
    var page: Int = 2 {
        didSet {
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.getImages(strUrl: "https://picsum.photos/v2/list?page=" + "\(self!.page)" + "&limit=100") { () -> (Void) in
                    print("done \(String(describing: self?.page))")
                    
                }
            }
            
        }
    }
    
    var baseUrl = "https://picsum.photos/v2/list?page=2&limit=100"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        navigationController?.isNavigationBarHidden = true
        KingfisherManager.shared.cache.memoryStorage.config.totalCostLimit = 30 * 1024
        
        if CheckInternet.Connection(){
            print("Connect")
            connection = true
            getImage(strUrl: baseUrl) { [weak self] in
                print("done")
                DispatchQueue.main.async {
                    self?.reload()
                }
            }
            
        }
            
        else {
            print("Disconnect")
            connection = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                let ac = UIAlertController(title: "Connection Error", message: "Please chech your connection and reload the app", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default))
                self?.present(ac, animated: true)
                self?.defImages.append("back2")
            }
            
            
        }
        
        
        
        
        
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    

    // MARK: UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        return connection ? photos.count : defImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ImageCell else {
            fatalError("Unable to dequeue PersonCell")
        }
        
        let image = photos[indexPath.item]
        let imageUrl: URL? = URL(string: image.download_url)
        cell.imageView.kf.setImage(with: imageUrl)
        

        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if photos.count - 1 == indexPath.row {
            
        }
        print(photos.count)
        print(indexPath.row)
        guard page < 10 else { return }
        if indexPath.row == 50 {
            page += 1
        } else if indexPath.row == 100 {
            page += 1
        } else if indexPath.row == 200 {
            page += 1
        } else if indexPath.row == 300 {
            page += 1
        } else if indexPath.row == 400 {
            page += 1
        } else if indexPath.row == 500 {
            page += 1
        } else if indexPath.row == 600 {
//            page += 1
        } else if indexPath.row == 700 {
//            page += 1
        } else if indexPath.row > 800 {
            print(page)
//            if page >= 9 {
//
//            } else {
//                page += 1
//            }
            
        }
//        print(indexPath.row)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            let index = indexPath.row
            vc.photo = photos[index]
            vc.downloadTime = downloadTime
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    
    func currentTime() -> String {
        print(#function)
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        formatter.string(from: currentDateTime)
        let time = "\(currentDateTime)"
        return time.replacingOccurrences(of: "+0000", with: "", options: [], range: nil)
        
        
        
    }
    
    
    func reload() {
        collectionView.reloadData()
    }
    
    func getImage(strUrl: String, completion: @escaping () -> (Void)) {
        print(#function)
        let url = URL(string: strUrl)!
        let request = NSMutableURLRequest(url: url)
        
        URLSession.shared.dataTask(with: request as URLRequest) { [weak self] (data, response, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            
            do {
                let dataJson = try JSONDecoder().decode([Photo].self, from: data!)
                self?.photos = dataJson
                print(dataJson)
                
                var index = 0
                for _ in self!.photos {
                    self?.photos[index].time = self?.currentTime()
                    index += 1
                }
                completion()
            } catch let error {
                print(error.localizedDescription)
            }
            
            }.resume()
        
    }
    
    func getImages(strUrl: String, completion: @escaping () -> (Void)) {
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
                         print("page \(self?.page)")
                        return
                    }
                    print(dataJson)
                    DispatchQueue.main.async {
                        var index = 0
                        for _ in self!.photos2 {
                            self?.photos2[index].time = self?.currentTime()
                            let insertIndexPath = IndexPath(item: (self?.photos.count)!, section: 0)
                            self?.photos.append((self?.photos2[index])!)
                            self?.collectionView.insertItems(at: [insertIndexPath])
                            index += 1
                        }
                        print("page \(self?.page)")
                    }
                    
                    
                    completion()
                } catch let error {
                    print(error.localizedDescription)
                }
                
                }.resume()
        }
        
        
        
    }
    

    
}

