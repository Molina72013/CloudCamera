
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage



class MomentsViewController: UIViewController {
    var currentUser: currentLoggedInUser?
    var sendingImageInfo: ImageInfo?
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentImages = [ImageInfo]() {
        didSet {
            collectionView.reloadData()
        }
    }
    var currentUsers = [User]() 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        getListOfImages()
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("Moments")
    }
    
    @IBAction func logOutTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            dismiss(animated: false, completion: nil)
        } catch {
            print(error)
        }
    }
    
    
    
    struct CommentInfo: Decodable {
        let userid: String
        let date: String
        let username: String
        let commenttext: String
        var commentid: String?
    }
    
    
    struct Likes: Decodable {
        let userid: String?
        var likeid: String?
    }
    
    struct ImageInfo: Decodable {
        var imageid: String?
        var ownerid: String?
        let imagename: String
        let imageurl: String
        var thumnailUrl: String?
        let likes: [String:Likes]?
        let comments: [String:CommentInfo]?
        func getLikes() ->  [String: Likes]?{
            return likes
        }
        func getComments() ->  [String: CommentInfo]?{
            return comments
        }
    }
    
    struct User: Decodable {
        var userid : String?
        let username: String
        let email: String
        let images : [String: ImageInfo]?
        
        func getImages() ->  [String: ImageInfo]?{
            return images
        }
    }
    
    struct currentLoggedInUser {
        var userID : String
        var username : String
    }
    
    
    func getListOfImages() {
        ref.child("users").observe(.value) {[weak self] (data) in
            guard let value = data.value as? [String: [String:Any]] else {return}
            
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: [])
                let user = try JSONDecoder().decode([String: User].self, from: data)
                guard let weakSelf = self else {return}
                weakSelf.currentImages.removeAll()
                
                var userarray = [User]()
                var imageArray = [ImageInfo]()
                
                for (key, var value) in user {
                    value.userid = key
                    userarray.append(value)
                }
                
                for user in userarray {
                    if let authuser = Auth.auth().currentUser {
                        if user.userid == authuser.uid {
                            weakSelf.currentUser = currentLoggedInUser(userID: authuser.uid, username: user.username)
                        }
                    }
                    
                    if let userImageInfo = user.getImages() {
                        
                        for (key, var value) in userImageInfo {
                            value.imageid = key
                            value.ownerid = user.userid
                            imageArray.append(value)
                        }
                    }
                    
                    
                    
                    imageArray = imageArray.sorted(by: { (imageObj: ImageInfo, secondImageObj: ImageInfo) -> Bool in
                        return imageObj.imagename < secondImageObj.imagename
                    })
                    
                    weakSelf.currentUsers = userarray
                    weakSelf.currentImages = imageArray
                }
            } catch let error {
                print(error)
            }
        }
        
        
    }
}


extension MomentsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cloudCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CloudCell
        let currentImageObj = currentImages[indexPath.row]
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let addressString = "images/\(currentImageObj.imagename)"
        
        
        if cloudCell.imageView.image == nil {
            storageReference.child(addressString).downloadURL { (url, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "Couldn't get thumbnail image")
                    
                }
                if url != nil {
                    cloudCell.imageView.loadImageFromURL(url:url!)
                    
                }
                else {
                    print("no thum")
                    
                    Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                        
                        DispatchQueue.main.async {[weak self] in
//                            collectionView.reloadItems(at: [indexPath])
                            guard let unwrappedself = self else {return}
                            unwrappedself.collectionView.reloadItems(at: [indexPath])
                        }
                    })
                }
            }
            
        }
        return cloudCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentImageObj = currentImages[indexPath.row]
        
        sendingImageInfo = currentImageObj
        
        self.performSegue(withIdentifier: "detailview", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailview" {
            if let vc = segue.destination as? MomentsDetailViewController {
                vc.pictureInfo = sendingImageInfo
                vc.currentUser = currentUser
            }
        }
    }
}




extension MomentsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.width / 4) - 1.0 , height: self.view.frame.height / 7.0)
    }
}
