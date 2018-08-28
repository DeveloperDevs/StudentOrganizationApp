//
//  ImageLoadExtention.swift
//  FetchCoins
//
//  Created by Silc Corp on 6/5/18.
//  Copyright © 2018 Devin Lee. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func load(image imageName: String) -> UIImage {
        // declare image location
        let imagePath: String = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(imageName).png"
        let imageUrl: URL = URL(fileURLWithPath: imagePath)
        
        // check if the image is stored already
        if FileManager.default.fileExists(atPath: imagePath),
            let imageData: Data = try? Data(contentsOf: imageUrl),
            let image: UIImage = UIImage(data: imageData, scale: UIScreen.main.scale) {
            return image
        }
        
        // image has not been created yet: create it, store it, return it
        let newImage: UIImage = self
            try? UIImagePNGRepresentation(newImage)?.write(to: imageUrl)
        return newImage
    }
}
