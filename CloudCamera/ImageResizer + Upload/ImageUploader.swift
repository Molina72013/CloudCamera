//
//  ImageUploader.swift
//  CloudCamera
//
//  Created by Cristian Molina on 10/14/18.
//  Copyright © 2018 Cristian Molina. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase


class ImageUploadManager: NSObject {
    
    
    
    func uploadImage(_ image: UIImage, completion:@escaping (_ url: String?,_ dateName: String?, _ error: String?) -> ())
    {
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let imageName = "\(Date().timeIntervalSince1970)"
        let imageRef = storageReference.child("images").child(imageName)
        
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            
            print(imageData.count)
            _ = imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                if let metadata = metadata {
                    print(metadata)
                    
                    
                    
                    imageRef.downloadURL(completion: { (url, error) in
                        guard let url = url else {return}
                        completion(url.absoluteString,imageName, nil)
                        
                    })
                    completion(nil,nil,nil)
                } else {
                    completion(nil,nil, "errorr geting data URL")
                }
            }
        } else {
            completion(nil,nil,"error uploading")
        }
    }
}



