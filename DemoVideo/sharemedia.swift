//
//  sharemedia.swift
//  DemoVideo
//
//  Created by SOTSYS034 on 22/12/16.
//  Copyright © 2016 SOTSYS027. All rights reserved.
//
import UIKit
import Photos
import MobileCoreServices
import VideoEditor
import AssetsLibrary
import GoogleMobileAds
import FBSDKShareKit
import MessageUI
import AVKit

class sharemedia: UIViewController,VideoEditorSDKDelegate ,UIImagePickerControllerDelegate, UINavigationControllerDelegate, GADInterstitialDelegate,MFMailComposeViewControllerDelegate {

      var videoUrl = NSURL()
    
    @IBOutlet var viewplayer: UIView!
    
    var player:AVPlayer!
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBAction func btnHomeClicked(sender: AnyObject) {
       
       navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let string =  "\(appDel.videoUrl)" as String
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sharemedia.playerDidFinish), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        self.player = AVPlayer(URL: appDel.videoUrl as NSURL)
        
        let avPlayerLayer = AVPlayerLayer(player:self.player)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
        
        avPlayerLayer.frame = CGRectMake(0, 0, self.viewplayer.frame.size.width, self.viewplayer.frame.size.height)
        avPlayerLayer.backgroundColor = UIColor.whiteColor().CGColor
        self.viewplayer.layer.addSublayer(avPlayerLayer)
        }
        
    }

    
    
    
    @IBAction func btnfacebook(sender: AnyObject) {
        
        
        
        let string =  "\(appDel.videoUrl)"
        if string.containsString("DCIM")
        {
            let alertController = UIAlertController(title: "No Video Editing Made By You", message: nil, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else
        {
            let params = ["fields": "id, name"]



                    SOFacebook.sharedInstance.uploadVideoOnFacebook(appDel.videoUrl) { (success:Bool? ) in
                        if success == true
                        {
                            SVProgressHUD.dismiss()
                            print("video post")
                            let alert = UIAlertController(title: "Success", message: "Your Video is Successfully Uploaded.!", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                            appDel.window?.rootViewController!.presentViewController(alert, animated: true, completion: nil)
                        }
                        else
                        {
                            SVProgressHUD.dismiss()
                            let alert = UIAlertController(title: "Success", message: "Your Video is failed to Uploaded.!", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
//                else
//                {
//                    SVProgressHUD.dismiss()
//                    print("failed \(obj)")
//                    //                SOFacebook.sharedInstance.SOLoginWithReadFacebook { (obj, success) -> Void in
//                    //                    if success == true
//                    //                    {
//                    //                        print("success \(obj)")
//                    //                    }
//                    //                    else
//                    //                    {
//                    //                        print("Failed \(obj)")
//                    //                    }
//                    //                }
//                }
//            }
//        }
 
 
        
        
      /*  let string =  "\(appDel.videoUrl)"
        if string.containsString("DCIM")
        {
            let alertController = UIAlertController(title: "No Video Editing Made By You", message: nil, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else
        {
            let params = ["fields": "id, name"]
            
            SOFacebook.sharedInstance.SOFacebookUserData(params) { (obj, success) -> Void in
                if success == true
                {
                    //SVProgressHUD.showWithStatus("Loading..")
                    print("success \(obj)")
                    
                    SOFacebook.sharedInstance.uploadVideoOnFacebook(appDel.videoUrl) { (success:Bool? ) in
                        if success == true
                        {
                            SVProgressHUD.dismiss()
                            let alertController = UIAlertController(title: "Your Video is Successfully Uploaded!", message: nil, preferredStyle: .Alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            alertController.addAction(defaultAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                            print("video post")
                        }
                        else
                        {
                            SVProgressHUD.dismiss()
                            print("video not post")
                        }
                    }
                }
                else
                {
                    SVProgressHUD.dismiss()
                    print("failed \(obj)")
                    //                SOFacebook.sharedInstance.SOLoginWithReadFacebook { (obj, success) -> Void in
                    //                    if success == true
                    //                    {
                    //                        print("success \(obj)")
                    //                    }
                    //                    else
                    //                    {
                    //                        print("Failed \(obj)")
                    //                    }
                    //                }
                }
            }
        }
        */
        

    }
    @IBAction func btnmsg(sender: AnyObject) {
        
         actionShare(appDel.videoUrl)
    }
    @IBAction func btnother(sender: AnyObject) {
        
        let string =  "\(appDel.videoUrl)" as String
        if string.containsString("DCIM")
        {
            let alertController = UIAlertController(title: "No Video Editing Made By You", message: nil, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else
        {
            let url = NSURL(string: string)
            
            let activityVC = UIActivityViewController(activityItems: [url!], applicationActivities: [])
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    @IBAction func btnsave(sender: AnyObject) {
        
        let string =  "\(appDel.videoUrl)"
        if string.containsString("DCIM")
        {
            let alertController = UIAlertController(title: "No Video Editing Made By You", message: nil, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else{
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(appDel.videoUrl)
        }) { saved, error in
            if saved {
                let alertController = UIAlertController(title: appConstants.APP_NAME , message: "Your video successfully saved", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        }
    }
  /*  override func viewDidLoad() {
               super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sharemedia.playerDidFinish), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
           self.player = AVPlayer(URL: appDel.videoUrl as NSURL)
            let avPlayerLayer = AVPlayerLayer(player:self.player)
            avPlayerLayer.frame = CGRectMake(0, 0, self.viewplayer.frame.size.width, self.viewplayer.frame.size.height)
            avPlayerLayer.backgroundColor = UIColor.whiteColor().CGColor
            self.viewplayer.layer.addSublayer(avPlayerLayer)
        
    }*/
    
    @IBAction func viewPlayerDidTap(sender: AnyObject) {
        
        if(self.player.rate > 0)
        {
            self.btnPlay.hidden = false
            self.player.pause()
        }
        
    }
    @IBAction func btnPlayClicked(sender: AnyObject) {
        if(self.player.rate > 0)
        {
            self.player.pause()
        }else{
            self.player.play()
            self.btnPlay.hidden = true
        }
    }
    
    func playerDidFinish()
    {
        self.player.seekToTime(kCMTimeZero)
        self.btnPlay.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func actionShare(localVideo: NSURL)
    {
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        let string =  "\(appDel.videoUrl)"
        if string.containsString("DCIM")
        {
            let alertController = UIAlertController(title: "No Video Editing Made By You", message: nil, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else{
   
        if (MFMailComposeViewController.canSendMail())
        {
            let subject = "Video Magic"
            let messageBody = ""
            let toRecipint = ["reachus@futuremillenniagaming.com"]
            let mailComposer = MFMailComposeViewController()
            mailComposer.setSubject(subject)
            mailComposer.setMessageBody(messageBody, isHTML: false)
            mailComposer.setToRecipients(toRecipint)
            mailComposer.mailComposeDelegate = self
            
            let filePart = appDel.videoUrl.lastPathComponent!.componentsSeparatedByString(".")
            let fileNme = filePart[0] as String
            let fileExtension = filePart[1] as String 
            
            if let fileData = NSData(contentsOfURL: appDel.videoUrl)//, mimeType = MIMEType(type: fileExtension)
            {
                mailComposer.addAttachmentData(fileData, mimeType: "video/mp4", fileName: fileNme)
            }
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
        else
        {
            let alertController = UIAlertController(title: "E-Mail", message: "please config your E-mail", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            print("This device cannot send email")
        }
    }
            
}
    func mailComposeController(controller2: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            
            print("Mail cancelled")
            controller2.dismissViewControllerAnimated(true, completion: nil)
        case MFMailComposeResultSaved.rawValue:
            print("Mail saved")
            controller2.dismissViewControllerAnimated(true, completion: nil)
        case MFMailComposeResultSent.rawValue:
           
            print("Mail sent")
            controller2.dismissViewControllerAnimated(true, completion: nil)
        case MFMailComposeResultFailed.rawValue:
            
                      
            print("Mail sent failure.")
            controller2.dismissViewControllerAnimated(true, completion: nil)
        default:
            controller2.dismissViewControllerAnimated(true, completion: nil)

            break
        }
    }
    @IBAction func btnSaveLibraryClicked(sender: AnyObject) {
        
        let string =  "\(appDel.videoUrl)"
        if string.containsString("DCIM")
        {
            let alertController = UIAlertController(title: "No Video Editing Made By You", message: nil, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }else{
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(appDel.videoUrl)
        }) { saved, error in
            if saved {
                let alertController = UIAlertController(title: appConstants.APP_NAME , message: "Your video successfully saved", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    }
}
