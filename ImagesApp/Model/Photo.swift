//
//  Photo.swift
//  ImagesApp
//
//  Created by Yury Popov on 27/08/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import Foundation



struct Photo: Codable {
    let id: String
    let author: String
    let url: String
    let download_url: String
    var time: String?
}



