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
    
    let network = DataService()
    var defImages = [String]()
    var responseString = String()
    var downloadTime = String()
    var connection = Bool()
    var page: Int = 2 {
        didSet {
            print("didset page")
            network.getImages(strUrl: "https://picsum.photos/v2/list?page=" + "\(self.page)" + "&limit=100") { [weak self] in
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()

//                    self?.collectionView.insertItems(at: [(self?.network.insertIndexPath)!])
                }
                
//                self?.collectionView.reloadData()
                
            }
        }
    }
    
    var baseUrl = "https://picsum.photos/v2/list?page=2&limit=100"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadingNib = UINib(nibName: "LoadingCell", bundle: nil)
        collectionView.register(loadingNib, forCellWithReuseIdentifier: "loadingCell")
        navigationController?.isNavigationBarHidden = true
        KingfisherManager.shared.cache.memoryStorage.config.totalCostLimit = 30 * 1024
        
        if CheckInternet.Connection(){
            print("Connect")
            connection = true
            network.getImages(strUrl: baseUrl) { [weak self] in
            
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
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return network.photos.count
        } else if section == 1 {
            return 1
        }
        return 0
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ImageCell else {
//            fatalError("Unable to dequeue PersonCell")
//        }
        
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCell
            let image = network.photos[indexPath.item]
            let imageUrl: URL? = URL(string: image.download_url)
            //        cell.imageView.kf.setImage(with: imageUrl)
            
            let resizingProcessor = ResizingImageProcessor(referenceSize: CGSize(width: cell.imageView.frame.size.width * UIScreen.main.scale, height: cell.imageView.frame.size.height * UIScreen.main.scale))
            cell.imageView.kf.setImage(with: imageUrl, options: [.backgroundDecode,.processor(resizingProcessor), .scaleFactor(UIScreen.main.scale),.cacheOriginalImage])
      
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
        

    }

    // MARK: UICollectionViewDelegate

//    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//
//        guard page < 10 else { return }
//        if indexPath.row == 50 {
//            page += 1
//        } else if indexPath.row == 100 {
//            page += 1
//        } else if indexPath.row == 200 {
//            page += 1
//        } else if indexPath.row == 300 {
//            page += 1
//        } else if indexPath.row == 400 {
//            page += 1
//        } else if indexPath.row == 500 {
//            page += 1
//        }
//    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            let index = indexPath.row
            vc.photo = network.photos[index]
            vc.downloadTime = downloadTime
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard page < 10 else {  return }
        let lastItem = network.photos.count - 1
        if indexPath.row == lastItem {
            print(#function)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.page += 1
                
            }
            
        }
    }

    func reload() {
        collectionView.reloadData()
    }
    
    
    
}

