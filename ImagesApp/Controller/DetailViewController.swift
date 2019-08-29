//
//  DetailViewController.swift
//  ImagesApp
//
//  Created by Yury Popov on 27/08/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

/*
 Добрый день/вечер! Спасибо! Интересное задание, многое было в новинку и многое к сожалению не получилось
 Первое это с загрузкой проблемы. Плавную красивую подзагрузку не смог реализовать
 Для кэша картинок выбрал Kingfisher, пробывал еще SDWebImage. Но в Kingfisher на взгляд лучше кешировались картинки. С NSCache не успел разобраться.
 И конечно с проверкой конекта так себе решение. По хорошему надо было сделать наверно notification и загружать к примеру 10 дефолтных картинок при загрузке приложения.
 Хорошего дня!
 */

import UIKit

class DetailViewController: UIViewController {
    

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var downloadInfoLabel: UILabel!
    @IBOutlet weak var metaInfoLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    var downloadTime: String?
    var photo: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        metaInfoLabel.alpha = 0
        downloadInfoLabel.alpha = 0
        navigationController?.isNavigationBarHidden = false
        activityIndicator.startAnimating()
        
        
        if let imageToLoad = photo {
            DispatchQueue.global().async { [weak self] in
                guard let imageUrl = URL(string: imageToLoad.download_url) else { return }
                guard let imageData = try? Data(contentsOf: imageUrl) else { return }
                let data = self?.imageDataProperties(imageData)
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
                    self?.imageView.image = UIImage(data: imageData)
                    self?.metaInfoLabel.text = data?.description.filter { $0 != "}" && $0 != "{" && $0 != ";"  }
                    self?.downloadInfoLabel.text = imageToLoad.time
                    UIView.animate(withDuration: 1, animations: {
                        self?.metaInfoLabel.alpha = 1
                        self?.downloadInfoLabel.alpha = 1
                    })

                    
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
    
    @objc func shareTapped() {
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else {
            print("No image Found")
            return
        }
        
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

    


}


