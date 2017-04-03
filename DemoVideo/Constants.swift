//
//  Constant.swift
//  Sohil Memon

import UIKit

//Appdelegate shared object
let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

//App Constants Shared Object
let appConstants: Constants = Constants()


//Class Name to print Values

var TAG = String()

class Constants: NSObject {
    
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    
    
    let APP_NAME = "VideoMagic"
    let App_ID = "1191721460"
    
    var showImojiStickers = "NO"
    
    //AD Mob Key
    let FULL_SCREEN_ID = "ca-app-pub-6674851127211099/4236714762"   //"ca-app-pub-3935008194402437/4482997505"
    let BANNER_ID = "ca-app-pub-6674851127211099/7061986365"    //"ca-app-pub-3935008194402437/7727181905"
    //Video Editor Key
    let CLIENT_KEY = "586ca32fabfa8"    //"5829b891a4672"    //"5805f0edc878d"
    let CLIENT_SECRET_KEY = "VES586ca32faba400.43926331"    //"VES5829b891a41c94.44559684"    //"VES5805f0edc82973.59655845"
    
    let objIAPHelper = StoreKitController()
    
     let FULL_VERSION_KEY = "com.videoeditorappsdk.app.videoeditor.unlockeverything"  //"com.zippy.video.videoeditor.unlockeverything"
        
    let REMOVE_ADS_KEY = "com.videoEditorFilmMake.removeAds"    //"com.zippy.video.removeAds"
    
    let IS_REMOVE_ADS_PUR = (NSUserDefaults.standardUserDefaults().boolForKey("NoAds"))
    
    let REMOVE_ADS_USER_DEFAULTS = "NoAds"
    
    

    
}