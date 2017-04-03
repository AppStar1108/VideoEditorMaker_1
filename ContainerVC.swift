//
//  ContainerVC.swift
//  DemoVideo
//
//  Created by SOTSYS027 on 10/15/16.
//  Copyright © 2016 SOTSYS027. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ContainerVC: UIViewController,GADInterstitialDelegate {
    
    
    @IBOutlet weak var bottomCpnstraint: NSLayoutConstraint!
    static let sharedInstance = ContainerVC()
       // let interstitial = GADInterstitial.sharedInstance()
    
    
    @IBOutlet weak var adbannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            //    self.adbannerView.adUnitID = "ca-app-pub-6674851127211099/4236714762"
        if appConstants.IS_REMOVE_ADS_PUR == false
        {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.methodOfReceivedNotification), name:"RemoveAdSuccessfully", object: nil)
        }
        
        if appConstants.IS_REMOVE_ADS_PUR == false
        {
            self.bottomCpnstraint.constant = 50
            self.adbannerView.adUnitID = appConstants.BANNER_ID
            let req : GADRequest = GADRequest()
            self.adbannerView.rootViewController = self
            self.adbannerView.loadRequest(req)
        }
        else
        {
            self.bottomCpnstraint.constant = 0
            self.adbannerView.removeFromSuperview()
        }
        // Do any additional setup after loading the view.
    }
    func methodOfReceivedNotification()
    {
        self.bottomCpnstraint.constant = 0
        self.adbannerView.removeFromSuperview()
    }
    func adViewDidReceiveAd(bannerView: GADBannerView)
    {
    }
    func adView(bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
