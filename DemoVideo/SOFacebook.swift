//
//  SOFacebook.swift
//  SOFacebook
//
//  Created by Hitesh on 2/3/16.
//  Copyright © 2016 myCompany. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

typealias SOFacebookCompletionHandler = (obj:AnyObject?, success:Bool?) -> Void

class SOFacebook: NSObject, FBSDKAppInviteDialogDelegate,FBSDKSharingDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    //    static let sharedInstance = NRFacebook()
    class var sharedInstance: SOFacebook
    {
        struct Static {
            static let instance: SOFacebook = SOFacebook()
        }
        return Static.instance
    }
    
    //MARK: SOFacebook LOGIN
    /// Login From facebook API with Read Permission
    /// - Parameter no parameters required
    /// - Returns: SOFacebookCompletionHandler = (obj:AnyObject?, success:Bool?)
    func SOLoginWithReadFacebook(completionHandler:SOFacebookCompletionHandler) {
        if FBSDKAccessToken.currentAccessToken() == nil {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logInWithReadPermissions(["public_profile","email","user_friends"], fromViewController: appDelegate.window!.rootViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj: nil, success: false)
                } else if result.isCancelled {
                    completionHandler(obj: nil, success: false)
                } else {
                    completionHandler(obj: result, success: true)
                }
            })
        } else {
            completionHandler(obj: nil, success: true)
        }
    }
    
    
    /// Login From facebook API with Publish Permission
    /// - Parameter no parameters required
    /// - Returns: SOFacebookCompletionHandler = (obj:AnyObject?, success:Bool?)
    func SOLoginWithPublishFacebook(completionHandler:SOFacebookCompletionHandler) {
        if FBSDKAccessToken.currentAccessToken() == nil {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logInWithPublishPermissions(["publish_actions"], fromViewController: appDelegate.window?.rootViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj: nil, success: false)
                } else if result.isCancelled {
                    completionHandler(obj: nil, success: false)
                } else {
                    completionHandler(obj: result, success: true)
                }
            })
        } else {
            completionHandler(obj: nil, success: true)
        }
    }
    
    //MARK: SOFacebook LOGOUT
    /// Logout From facebook
    /// - Parameter no parameters required
    /// - Returns: SOFacebookCompletionHandler = (obj:AnyObject?, success:Bool?)
    func SOLogoutFacebook(completionHandler:SOFacebookCompletionHandler) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        if FBSDKAccessToken.currentAccessToken() != nil {
            loginManager.logOut()
            completionHandler(obj: nil, success: true)
        }
    }
    
    
    //MARK: SOFacebook USER INFO
    /// Get User's Information
    /// pass dictionary in format of [String : String] 
    ///
    /// ex:- ["fields": "id, name, email, last_name, first_name"]
    /// - Parameter Parameters require as per given above example
    /// - Returns: SOFacebookCompletionHandler = (obj:AnyObject?, success:Bool?)
    func SOFacebookUserData(params:[String:String]?, completionHandler:SOFacebookCompletionHandler) {
        let SendRequestBlock = {() -> Void in
            FBSDKGraphRequest(graphPath:"me", parameters: params).startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, user:AnyObject!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj:error , success:false)
                } else {
                    completionHandler(obj:user, success: true)
                }
            })
        }

        if FBSDKAccessToken.currentAccessToken() != nil {
            SendRequestBlock()
        } else {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logInWithReadPermissions(["public_profile","email","user_friends"], fromViewController: appDelegate.window!.rootViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj: nil, success: false)
                } else if result.isCancelled {
                    completionHandler(obj: nil, success: false)
                } else {
                    SendRequestBlock()
                }
            })
        }
    }
    
    //MARK: SOFacebook USER'S TAGGED FRIEND
    /// Get User's Tagged Friend List
    /// pass dictionary in format of [String : String]
    ///
    /// ex:- ["fields": "id, first_name, last_name, middle_name, name, email, picture"]
    /// - Parameter Parameters require as per given above example
    /// - Returns: SOFacebookCompletionHandler = (obj:AnyObject?, success:Bool?)
    func SOgetFacebookTaggedFriend(params:[String: String]?, completionHandler:SOFacebookCompletionHandler){
        let SendRequestBlock = {() -> Void in
            FBSDKGraphRequest(graphPath: "me/taggable_friends", parameters: params).startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj:error , success:false)
                } else {
                    completionHandler(obj:result, success: true)
                }
            })
        }
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            SendRequestBlock()
        } else {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logInWithReadPermissions(["public_profile","email","user_friends"], fromViewController: appDelegate.window!.rootViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj: nil, success: false)
                } else if result.isCancelled {
                    completionHandler(obj: nil, success: false)
                } else {
                    SendRequestBlock()
                }
            })
        }
    }
    
    
    //MARK: SOFacebook USER'S APP RELATED FRIENDS
    /// Get User's Friend List who are using the same app
    /// pass dictionary in format of [String : String]
    ///
    /// ex:- ["fields": "picture,id,name"]
    /// - Parameter Parameters require as per given above example
    /// - Returns: SOFacebookCompletionHandler = (obj:AnyObject?, success:Bool?)
    func SOgetFacebookAppFriend(params:[String: String]?, completionHandler:SOFacebookCompletionHandler){
        let SendRequestBlock = {() -> Void in
            FBSDKGraphRequest(graphPath: "me/friends", parameters: params).startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj:error , success:false)
                } else {
                    completionHandler(obj:result, success: true)
                }
            })
        }
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            SendRequestBlock()
        } else {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logInWithReadPermissions(["public_profile","email","user_friends"], fromViewController: appDelegate.window!.rootViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj: nil, success: false)
                } else if result.isCancelled {
                    completionHandler(obj: nil, success: false)
                } else {
                    SendRequestBlock()
                }
            })
        }
    }
    
    
    
    //MARK: SOFacebook INVITE FRIENDS
    /// Get User's Friend List who are using the same app
    /// - Parameter applinkUrl: Pass string URL
    func CallInviteFriends(applinkUrl:String?)
    {
        var topController = UIApplication.sharedApplication().keyWindow?.rootViewController
        
        if (topController == nil) {
            while let presentedViewController = topController!.presentedViewController {
                topController = presentedViewController
            }
            // topController should now be your topmost view controller
        }
        
        let contentShare: FBSDKAppInviteContent = FBSDKAppInviteContent()
        contentShare.appLinkURL = NSURL(string:applinkUrl!)
        FBSDKAppInviteDialog.showFromViewController(topController, withContent: contentShare, delegate: self)
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("Complete invite without error")
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print("Error in invite \(error)")
    }
    
    
    
    //MARK: SOFacebook GET ALL ALBUMES
    /// Get User's Album
    /// It will provide you first 25 Album name
    /// - Returns: SOFacebookCompletionHandler = (obj:AnyObject?, success:Bool?)
    func SOgetFacebookAlbums(completionHandler:SOFacebookCompletionHandler){
        let SendRequestBlock = {() -> Void in
            //let params = []
            FBSDKGraphRequest(graphPath: "me/albums", parameters: nil).startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj:error , success:false)
                } else {
                    completionHandler(obj:result, success: true)
                }
            })
        }
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            SendRequestBlock()
        } else {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logInWithReadPermissions(["public_profile","email","user_friends"], fromViewController: appDelegate.window!.rootViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj: nil, success: false)
                } else if result.isCancelled {
                    completionHandler(obj: nil, success: false)
                } else {
                    SendRequestBlock()
                }
            })
        }
    }
    
    /// Get User Album's next page
    /// It will provide next 25 Album name
    /// - Parameter strPage: Pass 'after' id from Paging-->cursors of previous Graph API call of album api. (ex- MTM4NjIxMzk1ODI3MDM1NQZDZD)
    /// - Returns: SOFacebookCompletionHandler = (obj:AnyObject?, success:Bool?)
    func SOgetFacebookAlbumsNextPage(strPage:String, completionHandler:SOFacebookCompletionHandler){
        let SendRequestBlock = {() -> Void in
            //let params = []
            //"/\(strPage)/albums"
            FBSDKGraphRequest(graphPath: "/me/albums?after=\(strPage)", parameters: nil).startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj:error , success:false)
                } else {
                    completionHandler(obj:result, success: true)
                }
            })
        }
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            SendRequestBlock()
        } else {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logInWithReadPermissions(["public_profile","email","user_friends"], fromViewController: appDelegate.window!.rootViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj: nil, success: false)
                } else if result.isCancelled {
                    completionHandler(obj: nil, success: false)
                } else {
                    SendRequestBlock()
                }
            })
        }
    }
    
    //MARK: SOFacebook GET ALBUM'S PHOTOS
    /// Get Photos of Album
    /// It will provide you first 25 Photos of a particular Album
    /// - Parameter albumID: Pass Album ID for get Photos of that particular Album
    /// - Returns: SOFacebookCompletionHandler = (obj:AnyObject?, success:Bool?)
    func SOgetFacebookAlbumsPhotos(albumID: String, completionHandler:SOFacebookCompletionHandler){
        let SendRequestBlock = {() -> Void in
            //let params = []
            FBSDKGraphRequest(graphPath: "\(albumID)/photos", parameters: ["fields": "id, source"]).startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj:error , success:false)
                } else {
                    completionHandler(obj:result, success: true)
                }
            })
        }
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            SendRequestBlock()
        } else {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logInWithReadPermissions(["public_profile","email","user_friends"], fromViewController: appDelegate.window!.rootViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj: nil, success: false)
                } else if result.isCancelled {
                    completionHandler(obj: nil, success: false)
                } else {
                    SendRequestBlock()
                }
            })
        }
    }
    
    
    /// Get more Photos of Album
    /// It will provide you Next 25 Photos of a particular Album
    /// - Parameter albumID: Pass Album ID for get Photos of that particular Album
    /// - Parameter strPage: Pass 'after' id from Paging-->cursors of previous Graph API call of Photos api. (ex- MTM4NjIxMzk1ODI3MDM1NQZDZD)
    /// - Returns: SOFacebookCompletionHandler = (obj:AnyObject?, success:Bool?)
    func SOgetFacebookAlbumsPhotosNextPage(albumID: String, strPage:String, completionHandler:SOFacebookCompletionHandler){
        let SendRequestBlock = {() -> Void in
            //let params = []
            //"/\(strPage)/albums"
            FBSDKGraphRequest(graphPath: "\(albumID)/photos?after=\(strPage)", parameters: ["fields": "id, source"]).startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj:error , success:false)
                } else {
                    completionHandler(obj:result, success: true)
                }
            })
        }
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            SendRequestBlock()
        } else {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logInWithReadPermissions(["public_profile","email","user_friends"], fromViewController: appDelegate.window!.rootViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj: nil, success: false)
                } else if result.isCancelled {
                    completionHandler(obj: nil, success: false)
                } else {
                    SendRequestBlock()
                }
            })
        }
    }
    
    //MARK: SOFacebook GET ALL VIDEOS
    /// Get User's Videos
    /// It will provide you first 25 Videos name
    /// - Returns: SOFacebookCompletionHandler = (obj:AnyObject?, success:Bool?)
    func SOgetFacebookVideos(completionHandler:SOFacebookCompletionHandler){
        let SendRequestBlock = {() -> Void in
            //let params = []
            FBSDKGraphRequest(graphPath: "me/videos", parameters: nil).startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj:error , success:false)
                } else {
                    completionHandler(obj:result, success: true)
                }
            })
        }
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            SendRequestBlock()
        } else {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logInWithReadPermissions(["public_profile","email","user_friends"], fromViewController: appDelegate.window!.rootViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj: nil, success: false)
                } else if result.isCancelled {
                    completionHandler(obj: nil, success: false)
                } else {
                    SendRequestBlock()
                }
            })
        }
    }
    
    /// Get User Video's next page
    /// It will provide next 25 Videos name
    /// - Parameter strPage: Pass 'after' id from Paging-->cursors of previous Graph API call of album api. (ex- MTM4NjIxMzk1ODI3MDM1NQZDZD)
    /// - Returns: SOFacebookCompletionHandler = (obj:AnyObject?, success:Bool?)
    func SOgetFacebookVideosNextPage(strPage:String, completionHandler:SOFacebookCompletionHandler){
        let SendRequestBlock = {() -> Void in
            //let params = []
            //"/\(strPage)/albums"
            FBSDKGraphRequest(graphPath: "/me/Videos?after=\(strPage)", parameters: nil).startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj:error , success:false)
                } else {
                    completionHandler(obj:result, success: true)
                }
            })
        }
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            SendRequestBlock()
        } else {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logInWithReadPermissions(["public_profile","email","user_friends"], fromViewController: appDelegate.window!.rootViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj: nil, success: false)
                } else if result.isCancelled {
                    completionHandler(obj: nil, success: false)
                } else {
                    SendRequestBlock()
                }
            })
        }
    }
    
    
    
    //MARK: SOFacebook POST IMAGE OR TEXT
    /// Post Image and text on facebook
    /// - Parameter txtMessage: Message you want to post on facebook along with image
    /// - Parameter img: Pass UIImage
    /// - Returns: SOFacebookCompletionHandler = (obj:AnyObject?, success:Bool?)
    
    func SOPostTextAndImageOnFacebook(txtMessage: String, img: UIImage?,completionHandler:SOFacebookCompletionHandler){
        let SendRequestPostData = {() -> Void in
            if FBSDKAccessToken.currentAccessToken().hasGranted("publish_actions") {
                if txtMessage.characters.count>0 && !img!.isKindOfClass(UIImage) {
                    
                    FBSDKGraphRequest(graphPath: "me/feed", parameters: ["message": txtMessage], HTTPMethod: "POST").startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                        if error != nil {
                            print("text not sent")
                        } else {
                            print("post id \(result)");
                        }
                    })
                } else if txtMessage.characters.count>0 && img!.isKindOfClass(UIImage) {
                    let imageData: NSData = UIImagePNGRepresentation(img!)!
                    let param: [NSObject : AnyObject] = [
                        "message" : txtMessage,
                        "image.png" : imageData
                    ]
                    
                    FBSDKGraphRequest(graphPath: "me/photos", parameters: param, HTTPMethod: "POST").startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                        if error != nil {
                            print("text not sent")
                            completionHandler(obj: nil, success: false)
                        } else {
                            print("post id \(result)");
                            completionHandler(obj: result, success: true)
                        }
                    })
                }
            }
        }
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            SendRequestPostData()
        } else {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logInWithPublishPermissions(["publish_actions"], fromViewController: appDelegate.window!.rootViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj: nil, success: false)
                } else if result.isCancelled {
                    completionHandler(obj: nil, success: false)
                } else {
                    SendRequestPostData()
                }
            })
        }
    }
    
    
    
    //MARK: SOFacebook POST VIDEO
    /// Post Image and text on facebook
    /// - Parameter txtMessage: Message you want to post on facebook along with image
    /// - Parameter txtDescription: Description of Video
    /// - Parameter videoURL: Pass url of video
    /// - Parameter img: Pass thumbnail of video as UIImage
    /// - Returns: SOFacebookCompletionHandler = (obj:AnyObject?, success:Bool?)
    
    func SOPostVideoOnFacebook(videoURL: String?, txtMessage: String?, txtDescription: String?, img: UIImage?, completionHandler:SOFacebookCompletionHandler){
        let SendRequestPostData = {() -> Void in
            if FBSDKAccessToken.currentAccessToken().hasGranted("publish_actions") {
                //let imageData: NSData = UIImagePNGRepresentation(img)?
                let param: [NSObject : AnyObject] = [
                    "title" : txtMessage!,
                    "description" : txtDescription!,
                    "file_url": videoURL!
                ]
                
                FBSDKGraphRequest(graphPath: "me/videos", parameters: param, HTTPMethod: "POST").startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                    if error != nil {
                        print("text not sent")
                        completionHandler(obj: nil, success: false)
                    } else {
                        print("post id \(result)");
                        completionHandler(obj: result, success: true)
                    }
                })
            }
        }
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            SendRequestPostData()
        } else {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logInWithPublishPermissions(["publish_actions"], fromViewController: appDelegate.window!.rootViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if error != nil {
                    completionHandler(obj: nil, success: false)
                } else if result.isCancelled {
                    completionHandler(obj: nil, success: false)
                } else {
                    SendRequestPostData()
                }
            })
        }
    }
    
    
    //MARK: SOFacebook UPDATE STATUS ON WALL
    func uploadStatus(txtMessage: String, txtDescription: String, completionHandler:SOFacebookCompletionHandler) -> Void
    {
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentTitle = txtMessage
        content.contentDescription = txtDescription
        FBSDKShareDialog.showFromViewController(appDelegate.window?.rootViewController, withContent: content, delegate: nil)
    }
    
    
    
    func uploadPhotoOnFacebook(image:UIImage,completionHandler:(Bool?)-> Void)
    {
        let loginManager: FBSDKLoginManager=FBSDKLoginManager()
        loginManager.logInWithPublishPermissions(["publish_actions"], fromViewController: appDelegate.window?.rootViewController, handler: { (result, error) -> Void in
            if ((error) != nil) {
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                
                let sharePhoto = FBSDKSharePhoto()
                sharePhoto.caption = "Test"
                sharePhoto.image = image
                
                let content = FBSDKSharePhotoContent()
                content.photos = [sharePhoto]
                
                FBSDKShareDialog.showFromViewController(self.appDelegate.window?.rootViewController, withContent: content, delegate: nil)
            }
        })
    }
    
    func uploadVideoOnFacebook(videoURL:NSURL,completionHandler:(Bool?)-> Void)
    {
        let loginManager: FBSDKLoginManager=FBSDKLoginManager()
        
        loginManager.logInWithPublishPermissions(["publish_actions"], fromViewController: appDelegate.window?.rootViewController, handler: { (result, error) -> Void in
            
            SVProgressHUD.showWithStatus("Uploading..")
            if ((error) != nil) {
                print("Error: \(error)")
                
                let alert = UIAlertController(title: "Error", message: "Your Video is not Successfully Uploaded.!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                appDel.window?.rootViewController!.presentViewController(alert, animated: true, completion: nil)
                SVProgressHUD.dismiss()
                
            }
            else
            {

                print("fetched user: \(result)")
                print(videoURL)
                let videoURLl = videoURL
                let video : FBSDKShareVideo = FBSDKShareVideo()
                video.videoURL = videoURLl
                let content : FBSDKShareVideoContent = FBSDKShareVideoContent()
                content.video = video
                FBSDKShareAPI.shareWithContent(content, delegate: self)
               
            }
        })
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!)
    {
        print("sharing results \(results)")
        if results["video_id"] != nil
        {
            SVProgressHUD.dismiss()
            print("shared")
            let alert = UIAlertController(title: "Success", message: "Your Video is Successfully Uploaded.!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
            appDel.window?.rootViewController!.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "Failed", message: "Your Video is not Successfully Uploaded.!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
            appDel.window?.rootViewController!.presentViewController(alert, animated: true, completion: nil)
            print("canceled")
            
        }
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!)
    {
        print(error)
        SVProgressHUD.dismiss()
    }
    func sharerDidCancel(sharer: FBSDKSharing!)
    {
        
    }
}
