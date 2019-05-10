//
//  MomentsDetailViewController.swift
//  CloudCamera
//
//  Created by Cristian Molina on 10/17/18.
//  Copyright © 2018 Cristian Molina. All rights reserved.
//

import UIKit
import Firebase





class MomentsDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let refreshControl = UIRefreshControl()

    
    
    var shouldScrollDownAfterReload = false
    
    
    
    @IBOutlet var textFieldButtomConstraint: NSLayoutConstraint!
    @IBOutlet var myTableView: UITableView!
    
    var loadType = 0
    
    var likes : [MomentsViewController.Likes]? {
        didSet {
//            myTableView.reloadData()
//            myTableView.layoutIfNeeded()
//            UIView.animate (withDuration: 0.25, animations: {
//                self.myTableView.contentOffset = .zero
//            }) {(_) in
//                self.myTableView.reloadData ()
//            }
           // loadTable()
            
//            myTableView.scrollToRow(at: <#T##IndexPath#>, at: .bottom, animated: true)
        }
    }
    
//    let indexpath = IndexPath(row: Int, section: 0)

    
    var currentUser: MomentsViewController.currentLoggedInUser?
    
    var tap : UITapGestureRecognizer?
    
    @IBOutlet var commentTextField: UITextField!
    
    var picture: UIImage? = nil
    
    var pictureInfo:  MomentsViewController.ImageInfo? {
        didSet{
            print(pictureInfo!)
            
        }
        
        
        
    }
    
    var comments : [MomentsViewController.CommentInfo]? {
        didSet {
            
           
            
//            UIView.animate (withDuration: 0.25, animations: {
//                self.myTableView.contentOffset = .zero
//            }) {(_) in
//                self.myTableView.reloadData ()
//            }
        }
        
        
    }
    
    
    
    func loadTable() {
        if loadType==0 {
           self.myTableView.reloadData()
        }
        if loadType==1 {
            if let cell = self.myTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CloudTableViewImageCell {
                if let likess = likes {
                    cell.likes = likess
                }
            }
        }
        if loadType==2 {
            self.myTableView.reloadData()
            self.myTableView.contentOffset = .zero
        }
        loadType=0
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let comments = comments?.count else {
            return 1
        }
        
        return comments + 1
      
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellimage") as! CloudTableViewImageCell
            
            cell.selectionStyle = .none
            cell.currentImageInfo = pictureInfo
            cell.refViewController = self
            
//            guard let cellImgView = cell.photoView  else {
//                print("Didn't Make it")
//                return cell}
//            print("MADE IT")
            
            if let likess = likes {
                cell.likes = likess
            }
            
            
            
            if let strigURL = pictureInfo?.imageurl {
                
                cell.photoView.loadImageFromURL(url: URL(string: strigURL)!)
            }
            
            return cell
        } else {
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell") as! CloudTableViewReuseableCell
            cell.selectionStyle = .none
            
            cell.currentImageInfo = pictureInfo
            
   
            cell.refController = self
            
            if let currComment = comments?[indexPath.row - 1] {
                cell.currentCommentInfo = currComment

                cell.usernameLabel.text = currComment.username
                cell.commentTextField.text = currComment.commenttext
                
            }
            
            
            
            
            
            
            
            
            return cell

        }
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.separatorColor = UIColor.clear
        
        
        myTableView.refreshControl = refreshControl
        
        
        refreshControl.addTarget(self, action: #selector(refreshControllerFuction), for: .valueChanged)
//        myTableView.alwaysBounceVertical = false

        NotificationCenter.default.addObserver(self, selector: #selector(MomentsDetailViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(MomentsDetailViewController.keyboardWillDisapear(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        
        commentTextField.delegate = self
        commentTextField.enablesReturnKeyAutomatically = true
        
        if let user = currentUser {
            
            print(user)
        }
        
        commentRefresher()
//        likeRefresher()

    }
    


    @objc func refreshControllerFuction() {
        commentRefresher()
        
        
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return self.view.frame.height * 0.68 
        } else {
            return 75
        }
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let s = keyboardSize.height - commentTextField.frame.height + 2
            self.textFieldButtomConstraint.constant = s * -1
            self.view.layoutIfNeeded()
          }
        self.tap = UITapGestureRecognizer(target: self, action: #selector(MomentsDetailViewController.handleTap(sender:)))
        self.view.addGestureRecognizer(tap!)
        
        
//        print("working")
    }
    
    @objc func keyboardWillDisapear(notification: NSNotification?) {

        self.textFieldButtomConstraint.constant = 0
        
        guard let tap = tap else {return}
        
        self.view.removeGestureRecognizer(tap)
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()

    }
    
}


extension MomentsDetailViewController : UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment()
        textFieldButtomConstraint.constant = 0
        textField.resignFirstResponder()
        return true

    }
    
    


    
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
        textFieldButtomConstraint.constant = 0
    }
    
    
    
//    let ref: DatabaseReference! =  Database.database().reference()

    
    func sendComment() {
        
        loadType = 2
        

        guard let userID = currentUser?.userID, let userName = currentUser?.username else {
            return
        }
        
        
        
        let ref: DatabaseReference! = Database.database().reference()
        
        
        
        
        
       
            
        let values  = [
            "userid": userID,
            "commenttext" : commentTextField.text!,
            "date" : "\(Date().timeIntervalSince1970)",
            "username": userName
            ] as [String : Any]
        
        
        do {
            let temptCommentData = try JSONSerialization.data(withJSONObject: values, options: [])
            let temptComment = try JSONDecoder().decode(MomentsViewController.CommentInfo.self, from: temptCommentData)
            
            self.comments?.append(temptComment)
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        ref.child("users").child((pictureInfo?.ownerid)!).child("images").child((pictureInfo?.imageid)!).child("comments").childByAutoId().setValue(values) { [weak self] (error, _) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                
                print("success")
                guard let this = self else { return }
                this.commentTextField.text = ""
//                let myIndexPath = IndexPath(row: this.comments!.count, section: 0)
//                UIView.animate (withDuration: 0.3, animations: {
////                    this.shouldScrollDownAfterReload = true
//                    this.commentRefresher()
////                    this.shouldScrollDownAfterReload = true
////                    this.myTableView.reloadData ()
////                    this.myTableView.scrollToRow(at: myIndexPath, at: .bottom , animated: true)
//                })
                
                this.shouldScrollDownAfterReload = true
                this.commentRefresher()


            }
            }
            
            
            
            
            
            
            
        }
        
        
    
    
    


     func commentRefresher () {
        
        let ref: DatabaseReference! =  Database.database().reference()

        
        ref.child("users").child((pictureInfo?.ownerid)!).child("images").child((pictureInfo?.imageid)!).observeSingleEvent(of: .value) {[weak self] (data) in
            
//            let commentCounts = self?.comments?.count
//            let likedCounts = self?.likes?.count
            
            
            guard let value = data.value as? [String: Any] else {return}
            
            print("we made it to here")
//            var commentsArray = [MomentsViewController.CommentInfo]()

            do{
                
                
                let data = try JSONSerialization.data(withJSONObject: value, options: [])
                
                
                let photo = try JSONDecoder().decode(MomentsViewController.ImageInfo.self, from: data)
                
                
                print(photo)
                
                var commentsArray = [MomentsViewController.CommentInfo]()

    
                
                if let unwrappedComments = photo.getComments() {
                    
                    for(key,var values) in unwrappedComments {
                        
                        values.commentid = key
                        commentsArray.append(values)
                    
                    }
                    commentsArray = commentsArray.sorted(by: { (one: MomentsViewController.CommentInfo,two: MomentsViewController.CommentInfo) -> Bool in
                        return one.date < two.date
                    })
                    guard let this = self else {return}
                    this.comments = commentsArray

                } else {
                    guard let this = self else {return}
                    this.comments = []
                }
                
                if let unwrappedLikes = photo.getLikes() {
                    guard let this = self else {return}
//                    guard let likesInfo = unwrappedLikes else {return}
                    var likesArray = [MomentsViewController.Likes]()
                    
                    for (key,var value) in unwrappedLikes {
                        print(key)
                        value.likeid = key
                        likesArray.append(value)
                    }
                
                    
                    this.likes = likesArray
                    print(unwrappedLikes)
                } else {
                     guard let this = self else {return}
                    this.likes = []
                }
                
                DispatchQueue.main.async {[weak self ] in
                    guard let weakSelf = self else {return}
                    weakSelf.myTableView.reloadData()
                    weakSelf.refreshControl.endRefreshing()
                    if weakSelf.shouldScrollDownAfterReload {
                   UIView.animate (withDuration: 0.3, animations: {
                    let myIndexPath = IndexPath(row: weakSelf.comments!.count, section: 0)
                    weakSelf.myTableView.scrollToRow(at: myIndexPath, at: .bottom , animated: true)

                    })
                    }
                }
        
        
        
        
        
            } catch let error {
                print(error.localizedDescription)
                
                
            }
            
            
            
        }
        
        
        
    }
    
    

    
    
    
    
    func deletePicture() {
        
        
        
                if let user = Auth.auth().currentUser {
        
                    guard let currentImageInfo = pictureInfo, let ownerID = currentImageInfo.ownerid, let imageID = currentImageInfo.imageid  else {return}
        //            guard let ownerID = currentImageInfo.ownerid else {return}
        
        
        
                    if user.uid == currentImageInfo.ownerid {
                        let ref: DatabaseReference! =  Database.database().reference()
        
                        ref.child("users").child(ownerID).child("images").child(imageID).removeValue()
        
        
                        let storage = Storage.storage()
        
        
                        let url = currentImageInfo.imageurl
        
        
                        let storageRef = storage.reference(forURL: url)
        
        
                        storageRef.delete { (error) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                print("file was deleted")
                            }
                        }
        
        
        
        
                    }
        
        
        
        
                    self.navigationController?.popViewController(animated: true)
        
        
        
        
        
        
        
        }
        
        
        
        
        
    }
    
    
    

}
