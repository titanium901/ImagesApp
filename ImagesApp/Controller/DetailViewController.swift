//
//  DetailViewController.swift
//  ImagesApp
//
//  Created by Yury Popov on 27/08/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var downloadInfoLabel: UILabel!
    @IBOutlet weak var metaInfoLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: - Properties
    var downloadTime: String?
    var photo: Photo?
    
    //MARK: - override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        activityIndicator.startAnimating()
        
        
        if let imageToLoad = photo {
            DispatchQueue.global().async {
                guard let imageUrl = URL(string: imageToLoad.download_url) else { return }
                guard let imageData = try? Data(contentsOf: imageUrl) else { return }
                let data = self.imageDataProperties(imageData)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.imageView.image = UIImage(data: imageData)
                    self.metaInfoLabel.text = data?.description.filter { $0 != "}" && $0 != "{" && $0 != ";"  }
                    self.downloadInfoLabel.text = imageToLoad.time
                    
                }
            }
        }
    }
    
    func imageDataProperties(_ imageData: Data) -> NSDictionary? {
        if let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil)
        {
            if let dictionary = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) {
                return dictionary
            }
        }
        return nil
    }
    


}


