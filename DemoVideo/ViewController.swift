//
//  ViewController.swift
//  DemoVideo
//
//  Created by SOTSYS027 on 9/28/16.
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

//import <Photos/PHAsset.h>

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,VideoEditorSDKDelegate,UINavigationControllerDelegate, GADInterstitialDelegate,MFMailComposeViewControllerDelegate {

    
    @IBOutlet var btnadd: UIButton!
    @IBOutlet weak var collectionVW: UICollectionView!
    var arrVideo : Array<AnyObject> = []
    var assets: [PHAsset] = []
    var interstitial:GADInterstitial!
    var videoEditorObj: VideoEditorVC! = nil
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet weak var vwBlur: UIView!
    @IBOutlet weak var popvw: UIView!
    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    var cancelText = ""
    var successText = ""
   var videoUrl = NSURL()
    var screenRect: CGRect!
    var cellWidth: CGFloat!
    var screenWidth: CGFloat!
      var navView = UIView()
    var indexp = NSIndexPath()
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    let saveFileName = "/test.mp4"
    
    private enum MIMEType : String{
        
        case jpg = "image/jpeg"
        case png = "image/png"
         case doc = "application/msword"
         case ppt = "application/vnd.ms-powerpoint"
         case html = "text/html"
         case pdf = "application/pdf"
         case mov = "video/quicktime"
        
        init?(type: String){
            switch type.lowercaseString {
                case "jpg": self = .jpg
                case "png": self = .png
                case "doc": self = .doc
                case "ppt": self = .ppt
                case "html": self = .html
                case "pdf": self = .pdf
                case "mov": self = .mov
            default:
                return nil
            }
        }

    }
    
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
    var blurEffectView = UIVisualEffectView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(openVideoEditor), name: "OpenVideoEditor", object: nil)
        
        self.navigationController?.navigationBarHidden = false
        self.activityIndicatorView.hidden = true
        PHPhotoLibrary.requestAuthorization({(status: PHAuthorizationStatus) -> Void in
            if status == .Authorized {
                self.func_fetchPhotos()
            }
            else if status == .Denied {
//                DisplayAlertWithTitle("Please allow access to photos for this app from settings", APP_NAME)
            }
            else {
//                DisplayAlertWithTitle("Please allow access to photos for this app from settings", APP_NAME)
            }
            
        })
       self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
       
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        screenRect = UIScreen.mainScreen().bounds
        screenWidth = screenRect.size.width
        cellWidth = screenWidth / 3.0 - 2
        //badal
       /* navView = UIView.init(frame: CGRectMake(0, 0,200, 44))
        let label = UILabel(frame: CGRectMake(5,12 ,190 ,25))
        label.textAlignment = NSTextAlignment.Center
        label.text = "VideoEditor"
        label.textColor = UIColor.whiteColor()
        navView.addSubview(label)
//        self.navView.backgroundColor = UIColor.whiteColor()
        self.navigationItem.titleView = navView*/

        /*
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        settingView.addGestureRecognizer(tap)
         */
        
//        navigationBarSetFirst()
        
        
        //self.setImageInNavigationBarTitle()
        
        settingView.hidden = true
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("isAppRated")
        {
            let compareDate = NSUserDefaults.standardUserDefaults().objectForKey("RateAlertDate") as! NSDate
            let today = NSDate()
            let difference = self.daysBetweenDates(compareDate, endDate: today)
            if difference > 2
            {
                let alertController = UIAlertController(title: "We need your help, can you help us quick", message: "Give us your honest review, Your reviews are very important to us.", preferredStyle: .Alert)
                let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action -> Void in
                    //Do some other stuff
                    
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isAppRated")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    let url  = NSURL(string: "http://itunes.apple.com/app/id\(appConstants.App_ID)")
                    
                    if UIApplication.sharedApplication().canOpenURL(url!) {
                        UIApplication.sharedApplication().openURL(url!)
                    }
                }
                let defaultAction = UIAlertAction(title: "No", style: .Default, handler: nil)
                alertController.addAction(yesAction)
                alertController.addAction(defaultAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
        // showing intial advertise
        let IS_REMOVE_ADS_PUR1 = (NSUserDefaults.standardUserDefaults().boolForKey("NoAds"))
        
        if IS_REMOVE_ADS_PUR1 == false
        {
            self.interstitial = self.createAndLoadInterstitial()
        }
        
        self.data_request()
    }
    
    func data_request()
    {
        let bundleID = NSBundle.mainBundle().bundleIdentifier
        
        let url:NSURL = NSURL(string: "http://itunes.apple.com/lookup?bundleId=\(bundleID!)")!
        
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        //   let paramString = "data=Hello"
        //  request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(dataString)
            
            
            let jsonResults = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as! NSDictionary
            
            print(jsonResults)
            
            let arrResults = jsonResults["results"] as! NSArray
            if(arrResults.count == 0)
            {
                print("Turn off your constant boolean")
            }else{
                
                guard let text = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String else {
                    print("error")
                    return
                }
                
                let version = arrResults.valueForKey("version").objectAtIndex(0) as? String
                
                if version == text
                {
                    print("Both version matches turn on your rate boolean")
                    appConstants.showImojiStickers = "YES"
                }else{
                    print("Turn off your constant boolean")
                }
            }
            
            
            
            
        }
        
        task.resume()
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        self.activityIndicatorView.hidden = true
         self.navigationController?.navigationBarHidden = false
        //UINavigationBar.appearance().barTintColor = UIColor.whiteColor() //UIColor(red: 21.0/255.0, green: 21.0/255.0, blue: 21.0/255.0, alpha: 1.0)
        self.title = "VideoPro Editor"

        indexp = NSIndexPath(forRow:2000, inSection: 0)
        self.collectionVW!.reloadData()
        navigationBarSetFirst()
    }
    func daysBetweenDates(startDate: NSDate, endDate: NSDate) -> Int
    {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([.Day], fromDate: startDate, toDate: endDate, options: [])
        
        return components.day
    }
    
    func navigationBarSetFirst()
    {
        self.navigationItem.rightBarButtonItem = nil;
        let btnCamera = UIButton()
        btnCamera.setImage(UIImage(named: "video"), forState: .Normal)
        btnCamera.frame = CGRectMake(0, 0, 25, 25)
        btnCamera.addTarget(self, action: #selector(actionCamera), forControlEvents: .TouchUpInside)
        let itemCamera = UIBarButtonItem()
        itemCamera.customView = btnCamera
        self.navigationItem.rightBarButtonItem = itemCamera
        
        let btnSttig = UIButton()
        btnSttig.setImage(UIImage(named: "setting"), forState: .Normal)
        btnSttig.frame = CGRectMake(0, 0, 30, 30)
        btnSttig.addTarget(self, action: #selector(settingClicked), forControlEvents: .TouchUpInside)
        let itemSttig = UIBarButtonItem()
        itemSttig.customView = btnSttig
        self.navigationItem.leftBarButtonItem = itemSttig
        
      //  UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.barTintColor = UIColor.blackColor()

        
    }
    
    func setImageInNavigationBarTitle()
    {
        
        var label = UILabel(frame: CGRectMake(0, 0, (self.navigationItem.titleView?.frame.size.width)! , (self.navigationItem.titleView?.frame.size.height)!))
        label.center = (self.navigationItem.titleView?.center)!
        label.textAlignment = NSTextAlignment.Center
        label.text = "EZVid"
        //self.view.addSubview(label)
        
       // let logo = UILabel(named: "navBarTitle")
       // let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = label
    }
    
    func func_fetchPhotos()
    {
        self.assets.removeAll()
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d ",PHAssetMediaType.Video.rawValue)
        let allVids = PHAsset.fetchAssetsWithOptions(allPhotosOptions)
        
        allVids.enumerateObjectsUsingBlock{(obj, idx, stop) in
            
            let asset = (obj as! PHAsset)
            self.assets.append(asset)
            
            if idx == self.assets.count - 1
            {
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    self.collectionVW!.reloadData()
                })
            }
        }
    }
    
    func handleTap(sender: UITapGestureRecognizer? = nil) {
        self.closeSettingsView()
    }
    
    @IBAction func closeBtnClk(sender: UIButton) {
        self.closeSettingsView()
    }
    @IBAction func btnCameraClick(sender: AnyObject) {
        
        //btnadd.addTarget(self, action: #selector(actionCamera), forControlEvents: .TouchUpInside)
        self.presentViewController(CameraVC(), animated: true, completion: nil)

    }
    
    
    func closeSettingsView(){
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if settingView.hidden == false
        {
            settingView.hidden = true
        }
    }

    @IBOutlet weak var btnSaveToGalleryClicked: UIButton!
    func stringFromTimeInterval(interval:NSTimeInterval) -> NSString
    {
        let ti = NSInteger(interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        return NSString(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : CustomCell = collectionView.dequeueReusableCellWithReuseIdentifier("CelIID", forIndexPath: indexPath) as! CustomCell
        PHImageManager.defaultManager().requestImageForAsset(self.assets[indexPath.row], targetSize: CGSizeMake(self.cellWidth, self.cellWidth), contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            
            if (image != nil)
            {
                 cell.imgVW.image = image
                cell.imgVW.tag = indexPath.row
                let dTotalSeconds = self.assets[indexPath.row].duration
                cell.lblTime.text =  (self.stringFromTimeInterval(dTotalSeconds)) as String
                cell.lblTime.layer.shadowColor = UIColor.blackColor().CGColor
                cell.lblTime.layer.shadowOpacity = 1.0;
            
            }
        }
        //cell.imgVW.backgroundColor = UIColor.redColor()
        if indexPath == indexp
        {
            cell.imgDone.hidden = false
        }
        else
        {
            cell.imgDone.hidden = true
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = CGSize(width: cellWidth, height: cellWidth)
        return size
    }

   func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
   {
        indexp = indexPath
        setNavigationButton()
        collectionView.reloadItemsAtIndexPaths(collectionView.indexPathsForVisibleItems())
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
   }
    
   func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
    func setNavigationButton()
    {
        let btnCamera = UIButton()
        btnCamera.setImage(UIImage(named: "video"), forState: .Normal)
        btnCamera.frame = CGRectMake(0, 0, 25, 25)
        btnCamera.addTarget(self, action: #selector(actionCamera), forControlEvents: .TouchUpInside)
        let itemCamera = UIBarButtonItem()
        itemCamera.customView = btnCamera
        self.navigationItem.rightBarButtonItem = itemCamera
        
        let btnDone = UIButton()
        btnDone.setImage(UIImage(named: "done"), forState: .Normal)
        btnDone.frame = CGRectMake(0, 0, 30, 30)
        btnDone.addTarget(self, action: #selector(actionDone), forControlEvents: .TouchUpInside)
        let itemDone = UIBarButtonItem()
        itemDone.customView = btnDone
        self.navigationItem.rightBarButtonItems = [itemDone,itemCamera]
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touch called")
        if touches.first != nil {
            let touch: UITouch = touches.first!
            print("view is \(touch.view)")
            if touch.view == self.view {
                if self.popvw.hidden == false{
                    self.popvw.touchesBegan(touches, withEvent: event)
                }
            }else{
                return
            }
        }
    }
    
    // Swift
    //MARK: - VideoEditorSDK Delegate Method
    func videoEditorSDKFinishedWithUrl(url: NSURL!) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "/index")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        
        self.videoUrl = url
        print("Video editing finished url :",url)
        print("Video editing finished url :",self.videoUrl)
    
        appDel.videoUrl = url;
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            /*self.blurEffectView.frame = self.view.bounds
            self.blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.popvw.insertSubview(self.blurEffectView, atIndex: 0)
            
            self.popvw.hidden = false
            self.popvw.userInteractionEnabled = true*/
            
            
            let obj = self.storyboard?.instantiateViewControllerWithIdentifier("shareController") as! sharemedia
            self.navigationController?.pushViewController(obj, animated: true)
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            
        }
   
    }
    
    func videoEditorSDKDidSelectCategory(category: String!) {
        print(category)
        if ((category == "VEFilter" ) || (category == "VEAdjust") || (category == "VETrim") || (category == "VEOrientation"))
        {
            let IS_REMOVE_ADS_PUR1 = (NSUserDefaults.standardUserDefaults().boolForKey("NoAds"))
            
            if IS_REMOVE_ADS_PUR1 == false
            {
                self.interstitial = self.createAndLoadInterstitial()
            }
        }
    }

    //Interstitial func
    func createAndLoadInterstitial()->GADInterstitial {
        let interstitial = GADInterstitial(adUnitID:appConstants.FULL_SCREEN_ID)
        interstitial.delegate = self
        interstitial.loadRequest(GADRequest())
        return interstitial
    }
    
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        if (ad.isReady) {
            if let topController = UIApplication.topViewController() {
                self.interstitial.presentFromRootViewController(topController);
            }
        }
    }
    
    //MARK: - UIbutton action Delegate Method 
    func actionDone(sender: UIButton!)
    {
       // UINavigationBar.appearance().barTintColor = UIColor.redColor()
        let asset = self.assets[indexp.row]
        let options1 = PHVideoRequestOptions()
        options1.networkAccessAllowed = false
        PHImageManager.defaultManager().requestAVAssetForVideo(asset, options:options1) { (asset, audioMix, info) in
            
            if asset != nil
            {
                if let urlAsset = asset as? AVURLAsset
                {
                    /*if((info![PHImageResultIsInCloudKey]?.boolValue) != nil){
                     
                     print("video for icloude")
                     }
                     else
                     {
                     print("video not supported")
                     }*/
                    // options1.synchronize = false
                    print("its not cloude video")
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        let obj: VideoEditorVC = UIStoryboard(name: "Storyboard_VE", bundle: NSBundle(identifier:"com.VideoEditor")).instantiateViewControllerWithIdentifier("VideoEditorVC") as! VideoEditorVC
                        obj.delegate = self;
                        
                        if (asset is AVComposition)
                        {
                            let compoition = (asset as! AVComposition)
                            let backgroundVideoTrack = (compoition.tracks[0] as! AVMutableCompositionTrack)
                            let segment = backgroundVideoTrack.segments[0]
                            obj.videoPath = segment.sourceURL
                        }
                        else
                        {
                            obj.videoPath = urlAsset.URL
                        }
                        // set NO only for testing purpose
                        if(appConstants.showImojiStickers == "YES"){
                            obj.showStickers = "YES"
                        }
                        obj.clientKey = appConstants.CLIENT_KEY
                        obj.clientSecretKey = appConstants.CLIENT_SECRET_KEY
                        self.presentViewController(obj, animated: true, completion: { _ in })
                    })
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        self.videoEditorObj = UIStoryboard(name: "Storyboard_VE", bundle: NSBundle(identifier:"com.VideoEditor")).instantiateViewControllerWithIdentifier("VideoEditorVC") as! VideoEditorVC
                        self.videoEditorObj.delegate = self;
                        
                        if (asset is AVComposition)
                        {
                            let compoition = (asset as! AVComposition)
                            let backgroundVideoTrack = (compoition.tracks[0])
                            let segment = backgroundVideoTrack.segments[0]
                            self.videoEditorObj.videoPath = segment.sourceURL
                        }
                        // set NO only for testing purpose
                        if(appConstants.showImojiStickers == "YES"){
                            self.videoEditorObj.showStickers = "YES"
                        }
                        self.videoEditorObj.clientKey = appConstants.CLIENT_KEY
                        self.videoEditorObj.clientSecretKey = appConstants.CLIENT_SECRET_KEY
                        self.presentViewController( self.videoEditorObj, animated: true, completion: { _ in })
                    })
                    
                }
            }
            else
            {
                self.postAlert(appConstants.APP_NAME, message: "Video is either corrupted OR Video didn’t fully downloaded from iCloud")
            }
        }
        
    }
    
    @IBAction func btnWhatsUpClicked(sender: AnyObject)
    {
        let string =  "\(self.videoUrl)" as String
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
    
     @IBAction func actionFacebook(sender: AnyObject)
     {
        
        let string =  "\(self.videoUrl)"
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
                    SVProgressHUD.showWithStatus("Loading..")
                    print("success \(obj)")
                    
                    SOFacebook.sharedInstance.uploadVideoOnFacebook(self.videoUrl) { (success:Bool? ) in
                        if success == true
                        {
                            SVProgressHUD.dismiss()
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
        
    }
    
    @IBAction func actionMail(sender: AnyObject)
    {
        actionShare(videoUrl)
    }
    
     func actionShare(localVideo: NSURL)
     {
        if (MFMailComposeViewController.canSendMail())
        {
            let subject = "My Baby Milestones and Video Editor"
            let messageBody = "msgBody"
             let toRecipint = ["chris.lippincott@hotmail.com"]
            let mailComposer = MFMailComposeViewController()
            mailComposer.setSubject(subject)
            mailComposer.setMessageBody(messageBody, isHTML: false)
              mailComposer.setToRecipients(toRecipint)
            mailComposer.mailComposeDelegate = self
            
            
            
            let filePart = videoUrl.lastPathComponent!.componentsSeparatedByString(".")
            
            let fileNme = filePart[0] as String
            let fileExtension = filePart[1] as String
            
            if let fileData = NSData(contentsOfURL: localVideo)//, mimeType = MIMEType(type: fileExtension)
            {
             mailComposer.addAttachmentData(fileData, mimeType: "video/mp4", fileName: fileNme)
            }
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
        else
        {
            print("This device cannot send email")
        }
     }
    
    @IBAction func helpBtnClk(sender: UIButton) {
        let helpVC : HelpVC = self.storyboard?.instantiateViewControllerWithIdentifier("helpVC") as! HelpVC
        self.navigationController?.pushViewController(helpVC, animated: true)
    }
    
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK:- Setting Clicked
    func settingClicked(sender: UIButton!)
    {
       /* let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "/index")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        
        
        self.blurEffectView.frame = self.view.bounds
        self.blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.settingView.insertSubview(self.blurEffectView, atIndex: 0)
        
//        self.settingView.alpha = 0
        self.settingView.hidden = false
        
        UIView.animateWithDuration(0.2, animations: {
            self.settingView.alpha = 1.0
            }, completion: {
                (value: Bool) in
                
                self.navigationController?.setNavigationBarHidden(true, animated: false)
        })*/
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        self.title = ""
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let ViewController = storyBoard.instantiateViewControllerWithIdentifier("VideoSetting") as! SettingsVC
        self.navigationController?.pushViewController(ViewController, animated: true)
    
    }
   
    func actionCamera(sender: UIButton!)
    {
//        var nibView = NSBundle.mainBundle().loadNibNamed("CameraVC", owner: self, options: nil)[0] as! UIView
//        nibView.frame = self.view.bounds;
//        self.view.addSubview(nibView)
        
        self.presentViewController(CameraVC(), animated: true, completion: nil)
        
//        self.navigationController?.pushViewController(CameraVC(), animated: true)
        
        /*
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                
                imagePicker.sourceType = .Camera
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.allowsEditing = false
                imagePicker.delegate = self
                
                presentViewController(imagePicker, animated: true, completion: {})
            } else {
                postAlert("Rear camera doesn't exist", message: "Application cannot access the camera.")
            }
        } else {
            postAlert("Camera inaccessable", message: "Application cannot access the camera.")
        }
        */
        
    }
    // MARK: UIImagePickerControllerDelegate delegate methods
    // Finished recording a video
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("Got a video")
       
        let paths = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        let dataPath = documentsDirectory.stringByAppendingPathComponent(saveFileName)
        
        if let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {
            // Save video to the main photo album
            let selectorToCall = #selector(ViewController.videoWasSavedSuccessfully(_:didFinishSavingWithError:context:))
//            UISaveVideoAtPathToSavedPhotosAlbum(pickedVideo.relativePath!, self, selectorToCall, nil)
            
            // Save the video to the app directory so we can play it later
            let videoData = NSData(contentsOfURL: pickedVideo)
            videoData?.writeToFile(dataPath, atomically: false)
        }
       
        imagePicker.dismissViewControllerAnimated(true) { 
          
        }
        
        self.openVideoEditor()
        
        /*
        let obj: VideoEditorVC = UIStoryboard(name: "Storyboard_VE", bundle: NSBundle(identifier:"com.VideoEditor")).instantiateViewControllerWithIdentifier("VideoEditorVC") as! VideoEditorVC
        obj.delegate = self;
        obj.clientKey = appConstants.CLIENT_KEY
        obj.clientSecretKey = appConstants.CLIENT_SECRET_KEY
        
        obj.videoPath = NSURL.fileURLWithPath(dataPath)
        self.presentViewController(obj, animated: true, completion: nil)
         */
    }
    
    // Called when the user selects cancel
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("User canceled image")
        dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user selects cancel
        })
    }
    
    // Any tasks you want to perform after recording a video
    func videoWasSavedSuccessfully(video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutablePointer<()>){
        print("Video saved")
        if let theError = error {
            print("An error happened while saving the video = \(theError)")
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // What you want to happen
            })
        }
    }
    
    
    // MARK: Utility methods for app
    // Utility method to display an alert to the user.
    func postAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnSupportMailClicked(sender: AnyObject)
    {
//        let url  = NSURL(string: "http://www.zippyvid.com.au.")
//        
//        if UIApplication.sharedApplication().canOpenURL(url!) {
//            UIApplication.sharedApplication().openURL(url!)
//        }
        
        let subject = "My Baby Milestones and Video Editor"
        let messageBody = ""
        let toRecipint = ["chris.lippincott@hotmail.com"]
        let mailComposer = MFMailComposeViewController()
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(messageBody, isHTML: false)
        mailComposer.setToRecipients(toRecipint)
        mailComposer.mailComposeDelegate = self
        self.presentViewController(mailComposer, animated: true, completion: nil)
    }
    
    @IBAction func btnRestorePurchaseClicked(sender: AnyObject)
    {
        let IS_REMOVE_ADS_PUR = (NSUserDefaults.standardUserDefaults().boolForKey("NoAds"))
        
        if IS_REMOVE_ADS_PUR == false
        {
            SVProgressHUD.showWithStatus("Loading..")
            appConstants.objIAPHelper.restoreProductWithCompletionHandler({ (success, purchasedProducts, faildeProducts) in
                SVProgressHUD.dismiss()
                
                if success
                {
                    let array : NSArray = purchasedProducts
                    if array.containsObject(appConstants.REMOVE_ADS_KEY)
                    {
                        print("Restored")
                        self.postAlert("BabyVideoEditor", message: "Restored Successfully.")
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("RemoveAdSuccessfully", object: nil)
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults .setBool(true, forKey: "NoAds")
                        defaults.synchronize()
                    }
                    else
                    {
                        self.postAlert("BabyVideoEditor", message: "Product not purchase yet.")
                    }
                }
                else{
                    print("Fail")
                    self.postAlert("BabyVideoEditor", message: "Product not purchase yet.")
                }
            })
        }
        else{
            print("Already Purchased")
            self.postAlert("BabyVideoEditor", message: "You have already purchased.")
        }
        
        
    }
    @IBAction func btnRemoveAdsPurchaseClicked(sender: AnyObject)
    {
        let IS_REMOVE_ADS_PUR = (NSUserDefaults.standardUserDefaults().boolForKey("NoAds"))
        
        if IS_REMOVE_ADS_PUR == false
        {
            SVProgressHUD.showWithStatus("Loading..")
            appConstants.objIAPHelper.doBuyProductWithIdentifiers(NSSet(array:[appConstants.REMOVE_ADS_KEY]) as Set<NSObject>) { (success, purchasedProducts, failedProducts) in
                
                SVProgressHUD.dismiss()
                if success {
                    let array : NSArray = purchasedProducts!
                    if array.containsObject(appConstants.REMOVE_ADS_KEY)
                    {
                        NSNotificationCenter.defaultCenter().postNotificationName("RemoveAdSuccessfully", object: nil)
                        
                        print("Remove Ads")
                        self.postAlert("BabyVideoEditor", message: "Remove ads Successfully.")
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults .setBool(true, forKey: appConstants.REMOVE_ADS_USER_DEFAULTS)
                        defaults.synchronize()
                    }
                    else
                    {
                        self.postAlert("BabyVideoEditor", message: "Product not purchase yet.")
                    }
                }
                else{
                    print("Fail")
                    self.postAlert("BabyVideoEditor", message: "Product not purchase yet.")
                }
            }
        }
        else{
            print("Already Purchased")
            self.postAlert("BabyVideoEditor", message: "you have already purchased.")
        }
    }
    
    @IBAction func btnRateThisAppClicked(sender: AnyObject)
    {
        //        var url  = NSURL(string: "itms-apps://itunes.apple.com/app/bars/id706081574")
        
        let url  = NSURL(string: "https://itunes.apple.com/us/app/my-baby-milestones-video-editor/id1181391936?ls=1&mt=8")
        
        if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        }
    }
   
    @IBAction func actionBackToGallary(sender: AnyObject)
    {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "/index")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        
        //let cell  = collectionVW.cellForItemAtIndexPath(indexp) as! CustomCell
       // cell.imgDone.hidden = true
        func_fetchPhotos()
        self.popvw.hidden = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)

    }
    
    @IBAction func actionSaveVideo(sender: AnyObject)
    {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "/index")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        
        let string =  "\(self.videoUrl)"
        if string.containsString("DCIM")
        {
            let alertController = UIAlertController(title: "No Video Editing Made By You", message: nil, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else
        {
           // let videoUrl = NSURL(string: "\(self.videoUrl)")!
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(self.videoUrl)
            }) { saved, error in
                if saved {
                    let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }

      
    }
    
   /* func SaveToAlbum(videoUrl : NSURL)
    {
       
        //if CFloat(UIDevice.currentDevice().systemVersion) >= 8.0
        //{
             let videoUrl = NSURL(string: "\(videoUrl)")!
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
               // let url = NSURL(string: videoUrl);
                let urlData = NSData(contentsOfURL: videoUrl);
                if(urlData != nil)
                {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0];
                    let filePath="\(documentsPath)/tempFile.mp4";
                    dispatch_async(dispatch_get_main_queue(), {
                        urlData?.writeToFile(filePath, atomically: true);
                        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(NSURL(fileURLWithPath: filePath))
                        }) { completed, error in
                            if completed {
                                print("Video is saved!")
                            }
                        }
                    })
                }
            })
//        }
//        else
//        {
//            let videoUrl = NSURL(string: "\(videoUrl)")!
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                // let url = NSURL(string: videoUrl);
//                let urlData = NSData(contentsOfURL: videoUrl);
//                if(urlData != nil)
//                {
//                    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0];
//                    let filePath="\(documentsPath)/tempFile.mp4";
//                    dispatch_async(dispatch_get_main_queue(), {
//                        urlData?.writeToFile(filePath, atomically: true);
//                        
//                    
//                    
//                    
//                    })
//                }
//            })
//
//        }
    }*/
    
    func videoEditorSDKCanceled() {
        print("Video editing cancel")
    }
    func displayVideoEditorForVideo(videoUrl: NSURL) {
        
    }

    func openVideoEditor(){
        
        let paths = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        let dataPath = documentsDirectory.stringByAppendingPathComponent(saveFileName)
        
        let obj: VideoEditorVC = UIStoryboard(name: "Storyboard_VE", bundle: NSBundle(identifier:"com.VideoEditor")).instantiateViewControllerWithIdentifier("VideoEditorVC") as! VideoEditorVC
        obj.delegate = self;
        obj.clientKey = appConstants.CLIENT_KEY
        obj.clientSecretKey = appConstants.CLIENT_SECRET_KEY
        if(appConstants.showImojiStickers == "YES"){
            obj.showStickers = "YES"
        }
        obj.videoPath = NSURL.fileURLWithPath(dataPath)
        self.presentViewController(obj, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

