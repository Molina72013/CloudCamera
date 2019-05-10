//
//  ViewController.swift
//  CloudCamera
//
//  Created by Cristian Molina on 10/10/18.
//  Copyright © 2018 Cristian Molina. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let homeIcon = ImageResizer.resizeImage(image: UIImage(named: "home")!, targetSize: CGSize(width: 25.0, height: 25.0))
        
        
        let cameraIcon = ImageResizer.resizeImage(image: UIImage(named: "camera")!, targetSize: CGSize(width: 25.0, height: 25.0))
        
//        let tabBarImages = [homeIcon, cameraIcon]
        
        self.tabBar.items![0].image = homeIcon
        self.tabBar.items![1].image = cameraIcon
        
        
    }


}

