//
//  CustomCamera.swift
//  DemoVideo
//
//  Created by SOTSYS027 on 10/3/16.
//  Copyright © 2016 SOTSYS027. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import MediaPlayer

class CustomCamera: UIViewController {
    
    @IBOutlet weak var vwVideo: UIView!
    @IBOutlet weak var btnSelfy: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnFlash: UIButton!
    @IBOutlet weak var btnTakeVideo: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    var startTime = NSTimeInterval()
    var photosAsset: PHFetchResult!
    var assetCollection: PHAssetCollection = PHAssetCollection()
    var timer:NSTimer = NSTimer()
    let cameraManager = CameraManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        /// Check cameraManager.showAccessPermission
        let currentCameraState = cameraManager.currentCameraStatus()
        
        if currentCameraState == .NotDetermined
        {
            /// Code
        }
        else if (currentCameraState == .Ready)
        {
            addCameraToView()
        }
    }
    
    // MARK: - Add Camera in View.
    private func addCameraToView()
    {
        cameraManager.addPreviewLayerToView(vwVideo, newCameraOutputMode: CameraOutputMode.VideoWithMic)
        cameraManager.showErrorBlock =
            {
                (erTitle: String, erMessage: String) -> Void in
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //navigationController!.setNavigationBarHidden(true, animated: true)
        
        self.navigationController?.hidesBarsOnTap = false   //!! Use optional chaining
        self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
        
        
        // cameraManager.showAccessPermissionPopupAutomatically = false
        cameraManager.resumeCaptureSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionBack(sender: AnyObject) {
       self.dismissViewControllerAnimated(false, completion: nil)
    }
    @IBAction func actionFlash(sender: AnyObject)
    {
        guard let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) else {return}
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                btnFlash.selected = !btnFlash.selected
                if btnFlash.selected {
                    device.torchMode = .On
                    
                } else {
                    device.torchMode = .Off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
        
    }
    @IBAction func actionSelfy(sender: AnyObject)
    {
        cameraManager.cameraDevice = cameraManager.cameraDevice == CameraDevice.Front ? CameraDevice.Back : CameraDevice.Front
        switch (cameraManager.cameraDevice) {
        case .Front:
            btnSelfy.setTitle("Front", forState: UIControlState.Normal)
        case .Back:
            btnSelfy.setTitle("Back", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func actionVideoTapped(sender: AnyObject)
    {
        cameraManager.cameraOutputMode = .VideoWithMic
        btnTakeVideo.selected = !btnTakeVideo.selected
        if btnTakeVideo.selected {
            if (!timer.valid) {
                let aSelector : Selector = #selector(CustomCamera.updateTime)
                timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
                startTime = NSDate.timeIntervalSinceReferenceDate()
            }
            
            cameraManager.startRecordingVideo()
        } else {
            timer.invalidate()
            cameraManager.stopRecordingVideo({ (videoURL, error) -> Void in
                if let errorOccured = error {
                    self.cameraManager.showErrorBlock(erTitle: "Error occurred", erMessage: errorOccured.localizedDescription)
                }
            })
        }
        
    }
    
    
    // MARK: - Display Current timer For Video capture .
    func updateTime() {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
        //calculate the hours in elapsed time.
        let hours = UInt8(elapsedTime / 3600.0)
        elapsedTime -= (NSTimeInterval(hours) * 3600)
        
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        // let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let hourss = String(format: "%02d", hours)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        lblTime.text = "\(hourss):\(strMinutes):\(strSeconds)"
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


