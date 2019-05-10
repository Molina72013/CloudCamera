//
//  CloudTableViewCell.swift
//  CloudCamera
//
//  Created by Cristian Molina on 10/17/18.
//  Copyright © 2018 Cristian Molina. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth




class CloudTableViewImageCell: UITableViewCell {
    var usersLike: MomentsViewController.Likes?
    
    var tempLike: Int?
    
    @IBOutlet weak var threeDotsButton: UIButton!
    
    
    var likes : [MomentsViewController.Likes]? {
        didSet {
            if let user = Auth.auth().currentUser, let likes = likes {
                if likes.isEmpty {
                    likedButton.isSelected = false
                }
                for like in likes {
                    if like.userid ==  user.uid {
                        likedButton.isSelected = true
                        usersLike = like
                        break
                    } else {
                        likedButton.isSelected = false
                    }
                }
                //                guard let likes = likes else {return}
                likesLabel.text = "\(likes.count)"
                tempLike = likes.count
                
            }
            
        }
        
    }
    
    
    @IBOutlet weak var photoView: CloudImage!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet var likedButton: UIButton!
    
    weak var refViewController: MomentsDetailViewController?
    
    var currentImageInfo: MomentsViewController.ImageInfo? {
        didSet {
            threeDotsButton.isHidden = true
            if let user = Auth.auth().currentUser {
                guard let currentImageInfo = currentImageInfo, let ownerID = currentImageInfo.ownerid else {return}
                if user.uid == ownerID {
                    print("YAY")
                    threeDotsButton.isHidden = false
                }
            }
        }
    }
    
    
    @IBAction func likedButtonTapepd(_ sender: UIButton) {
        if let temppLike = tempLike {
            
            if likedButton.isSelected ==  false {
                //            tempLike = tempLike + 1
                likesLabel.text = "\(temppLike + 1)"
                likedButton.isSelected = true
                tempLike = tempLike! + 1
            } else if likedButton.isSelected ==  true && !(likes?.isEmpty)!{
                //            tempLike = tempLike - 1
                likesLabel.text = "\(temppLike - 1)"
                likedButton.isSelected = false
                tempLike = tempLike! - 1
                
            } else {
                tempLike = 0
                likesLabel.text = "0"
                likedButton.isSelected = false
            }
            
            refViewController?.likingFunctinality()
            
            
            
        }
        
    }
    
    
    @IBAction func threeDotButtonTapped(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] (action) in
            guard let this = self else {return}
            this.refViewController?.deletePicture()
            
        })
        
        alertController.addAction(action)
        alertController.addAction(deleteAction)
        
        guard let refController = refViewController else {
            return
        }
        refController.present(alertController, animated: true, completion: nil)
    }
}



class  CloudTableViewReuseableCell: UITableViewCell {
    
    weak var refController : MomentsDetailViewController?
    var currentImageInfo : MomentsViewController.ImageInfo?
    var currentCommentInfo: MomentsViewController.CommentInfo? {
        didSet {
            guard let user = Auth.auth().currentUser, let comment = currentCommentInfo, user.uid == comment.userid else {
                deleteButton.isHidden = true
                return
            }
            deleteButton.isHidden = false
        }
    }
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        usernameLabel.text = ""
        commentTextField.text = ""
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        guard let controller = refController else { return}
        
        
        
        let ref : DatabaseReference = Database.database().reference()
        
        
        
        ref.child("users").child((currentImageInfo?.ownerid)!).child("images").child((currentImageInfo?.imageid)!).child("comments").child((currentCommentInfo?.commentid)!).removeValue { (error, _) in
            if let error = error {
                print(error)
                return
            } else {
                controller.comments?.removeAll(where: { (singleComment: MomentsViewController.CommentInfo) -> Bool in
                    singleComment.commentid == self.currentCommentInfo?.commentid
                })
                ()
                UIView.animate (withDuration: 0.25, animations: {
                    controller.myTableView.contentOffset = .zero
                }) {(_) in
                    controller.myTableView.reloadData ()
                }
                
                
                
            }
        }
    }
}




extension MomentsDetailViewController {
    
    
    
    
    
    func likingFunctinality() {
        
        let reff = Database.database().reference().child("users").child((pictureInfo?.ownerid)!).child("images").child((pictureInfo?.imageid)!).child("likes")
        
        
        reff.observeSingleEvent(of: .value) { (data) in
            guard let value = data.value as? [String:Any] else {
                let value = ["userid":self.currentUser?.userID]
                
                reff.childByAutoId().setValue(value)
                return}
            
            
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: [])
                
                let likes = try JSONDecoder().decode([String:MomentsViewController.Likes].self, from: data)
                
                for (key,like) in likes {
                    if like.userid == self.currentUser?.userID {
                        
                        reff.child(key).removeValue()
                        return
                    }
                    
                }
                let value = ["userid":self.currentUser?.userID]
                
                reff.childByAutoId().setValue(value)
                
            } catch let error {
                print(error)
            }
            
            
        }
        
    }
    
}


