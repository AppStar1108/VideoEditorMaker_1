

import UIKit
import Photos
import MobileCoreServices
import VideoEditor
import AssetsLibrary
import GoogleMobileAds
import FBSDKShareKit
import MessageUI

class SettingsVC: UIViewController {
    
    var arrSettings:NSArray!
    
    var posts=[[Dictionary<String,AnyObject>]]()

    @IBOutlet weak var tableView: UITableView!
    @IBAction func btnBack(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        
        self.title = "Settings"
    
        arrSettings = ["Remove Ads","Restore Purchase","Rate this App","Support Email"];
        //restorePurchase
        
        self.tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.arrSettings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        let lblTitle = cell?.viewWithTag(1) as! UILabel
        let imageView = cell?.viewWithTag(2) as! UIImageView
        
        lblTitle.text = self.arrSettings[indexPath.row] as? String
        
        if(indexPath.row == 0){
            
            imageView.image = UIImage(named: "removeAd")
        }else if(indexPath.row == 1){
            imageView.image = UIImage(named: "restorePurchase")
        }
        else if(indexPath.row == 1){
            imageView.image = UIImage(named: "rateApp")
        }
        else{
            imageView.image = UIImage(named: "supportMail")
        }
        
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if(indexPath.row == 1){
            
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
                            self.postAlert("VideoMagic", message: "Restored Successfully.")
                            
                            NSNotificationCenter.defaultCenter().postNotificationName("RemoveAdSuccessfully", object: nil)
                            let defaults = NSUserDefaults.standardUserDefaults()
                            defaults .setBool(true, forKey: "NoAds")
                            defaults.synchronize()
                        }
                        else
                        {
                            self.postAlert("VideoMagic", message: "Product not purchase yet.")
                        }
                    }
                    else{
                        print("Fail")
                        self.postAlert("VideoMagic", message: "Product not purchase yet.")
                    }
                })
            }
            else{
                print("Already Purchased")
                self.postAlert("VideoMagic", message: "You have already purchased.")
            }

        }
        else if(indexPath.row == 2){
           
        
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isAppRated")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            let url  = NSURL(string: "http://itunes.apple.com/app/id\(appConstants.App_ID)")
            
            if UIApplication.sharedApplication().canOpenURL(url!) {
                UIApplication.sharedApplication().openURL(url!)
            }
        
        
        }
        else if(indexPath.row == 0){
            
            
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
                            self.postAlert("VideoMagic", message: "Remove ads Successfully.")
                            let defaults = NSUserDefaults.standardUserDefaults()
                            defaults .setBool(true, forKey: appConstants.REMOVE_ADS_USER_DEFAULTS)
                            defaults.synchronize()
                        }
                        else
                        {
                            self.postAlert("VideoMagic", message: "Product not purchase yet.")
                        }
                    }
                    else{
                        print("Fail")
                        self.postAlert("VideoMagic", message: "Product not purchase yet.")
                    }
                }
            }
            else{
                print("Already Purchased")
                self.postAlert("VideoMagic", message: "you have already purchased.")
            }

            
            
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
    func postAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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

    
}

