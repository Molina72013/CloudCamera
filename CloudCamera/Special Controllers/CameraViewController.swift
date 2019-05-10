//
//  CameraViewController.swift
//  CloudCamera
//
//  Created by Cristian Molina on 10/10/18.
//  Copyright © 2018 Cristian Molina. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth





class CameraViewController: UIViewController {
    @IBOutlet weak var stackViewBottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var libraryImageView: UIImageView!
    @IBOutlet weak var cameraImageView: UIImageView!
//    var delegate: ImageUploadingFinish?
    
    var ref: DatabaseReference!
    
   
//    var imagePickedBlock: ((UIImage) -> Void)?
    
    var testImage: UIImage? 
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //UPDATE CONSTRAINTS
        if let bottomConstraintFloat = self.tabBarController?.tabBar.frame.height
        {
            stackViewBottonConstraint.constant = bottomConstraintFloat
        }
        if let topConstraintFloat = self.navigationController?.navigationBar.frame.height
        {
            stackViewTopConstraint.constant = topConstraintFloat
        }
     
        let cameraGesture = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.goToCamera))
            
        let libraryGesture = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.goToLibrary))
        cameraImageView.addGestureRecognizer(cameraGesture)
        libraryImageView.addGestureRecognizer(libraryGesture)
        
        ref = Database.database().reference()
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("Camera")
        
    }

    
    
    @objc func goToCamera()
    {
        print("pressed camera image")
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    
    
    @objc func goToLibrary()
    {
        print("pressed library image")
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    
}


extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Cliked")
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let imageUploader = ImageUploadManager()
            
            
            imageUploader.uploadImage(ImageResizer.resizeImage(image: image, targetSize: CGSize(width: 1024.0, height: 1024.0))) { [weak self] (url,name,error)  in
                if error != nil {
                    return
                }
                else if let url = url {

                    self?.setData(url,name!)
                }
                
            }
                    }else{
            print("Something went wrong")
        }

        self.dismiss(animated: true, completion: nil)
        
        self.tabBarController?.selectedIndex = 0
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)

    }
    
    
    func setData (_ url: String,_ dateName: String) {
//        let imageName = "\(Date().timeIntervalSince1970)"
        
        let values = ["imagename":dateName,
            "imageurl": url
            ] as [String : Any]
        
//        let imageArray = [values]
        
        
        if let user = Auth.auth().currentUser {
//            let imageName = "\(Date().timeIntervalSince1970)"
            self.ref.child("users").child(user.uid).child("images").childByAutoId().setValue(values) { (error, _) in
                if error != nil {
                    print("error")
                } else {
                    print("ok sucess")
                    
                    
              
                    
                    
                }
                
            }
            
        }
    }
    
}

