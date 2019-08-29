//
//  ImagesViewController.swift
//  ImagesApp
//
//  Created by Yury Popov on 27/08/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//




/*
Добрый день/вечер! Спасибо! Интересное задание, многое было в новинку и многое к сожалению не получилось
Первое это с загрузкой проблемы. Плавную красивую подзагрузку не смог реализовать
Для кэша картинок выбрал SDWebImage, пробывал еще Kingfisher. Но там возникли большие проблемы с памятью и приложение всегда крашилось. С NSCache не успел разобраться.
 И конечно с проверкой конекта так себе решение. По хорошему надо было сделать наверно notification и загружать к примеру 10 дефолтных картинок при загрузке приложения.
 Хорошего дня!
*/
import UIKit
import SDWebImage

class ImagesViewController: UICollectionViewController {
  
    
    //MARK: - Properties
    var photos = [Photo]()
    var photos2 = [Photo]()
    var defImages = [String]()
    var responseString = String()
    var downloadTime = String()
    var isConnection = CheckInternet.Connection()
    var page: Int = 2 {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.getImages(strUrl: "https://picsum.photos/v2/list?page=" + "\(self.page)" + "&limit=100") { () -> (Void) in
                    print("done \(self.page)")
                    
                    
                }
            }
            
        }
    }
    
    var baseUrl = "https://picsum.photos/v2/list?page=2&limit=100"
    
    //MARK: - override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        navigationController?.isNavigationBarHidden = true
        
        if CheckInternet.Connection() {
            print("Connect")
            getImage(strUrl: baseUrl) { [weak self] in
                print("done")
                DispatchQueue.main.async {
                    self?.reload()
                }
            }
            
        }
            
        else {
            print("Disconnect")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let ac = UIAlertController(title: "Connection Error", message: "Please chech your connection and reload the app", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(ac, animated: true)
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
        
        return isConnection ? photos.count : defImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ImageCell else {
            fatalError("Unable to dequeue PersonCell")
        }

        let image = photos[indexPath.item]
        DispatchQueue.main.async {
            cell.imageView.sd_setImage(with: URL(string: image.download_url), placeholderImage: UIImage(named: image.download_url))
        }

        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == 50 {
            page += 1
        } else if indexPath.row == 100 {
            page += 1
        } else if indexPath.row == 200 {
            page += 1
        } else if indexPath.row == 300 {
            page += 1
        } else if indexPath.row > 400 {
            page += 1
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            let index = indexPath.row
            vc.photo = photos[index]
            vc.downloadTime = downloadTime
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: - Methods

    
    func currentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        let str = formatter.string(from: Date())
        return str.replacingOccurrences(of: "+0000", with: "", options: [], range: nil)
        
        
        
    }
    
    
    func reload() {
        collectionView.reloadData()
    }
    
    func getImage(strUrl: String, completion: @escaping () -> (Void)) {
        let url = URL(string: strUrl)!
        let request = NSMutableURLRequest(url: url)
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            
            do {
                let dataJson = try JSONDecoder().decode([Photo].self, from: data!)
                self.photos = dataJson
                print(dataJson)
                
                var index = 0
                for _ in self.photos {
                    self.photos[index].time = self.currentTime()
                    index += 1
                }
                completion()
            } catch let error {
                print(error.localizedDescription)
            }
            
            }.resume()
        
    }
    
    func getImages(strUrl: String, completion: @escaping () -> (Void)) {
        DispatchQueue.global(qos: .background).async {
            let url = URL(string: strUrl)!
            let request = NSMutableURLRequest(url: url)
            
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                    let ac = UIAlertController(title: "Connection Error", message: "Please chech your connection and reload the app", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(ac, animated: true)
                    return
                }
                
                do {
                    let dataJson = try JSONDecoder().decode([Photo].self, from: data!)
                    self.photos2 = dataJson
                    print("Json Data2")
                    if self.photos2.isEmpty {
                        return
                    }
                    print(dataJson)
                    DispatchQueue.main.async {
                        var index = 0
                        if index < self.photos2.count {
                            for _ in self.photos2 {
                                self.photos2[index].time = self.currentTime()
                                let insertIndexPath = IndexPath(item: self.photos.count, section: 0)
                                self.photos.append(self.photos2[index])
                                self.collectionView.insertItems(at: [insertIndexPath])
                                index += 1
                                
                            }
                        }
                        
                    }
                    
                    completion()
                } catch let error {
                    print(error.localizedDescription)
                }
                
                }.resume()
        }
    
    }

}

