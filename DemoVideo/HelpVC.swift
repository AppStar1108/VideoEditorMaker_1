//
//  HelpVC.swift
//  DemoVideo
//
//  Created by SOTSYS028 on 24/11/16.
//  Copyright © 2016 SOTSYS027. All rights reserved.
//

import UIKit

class HelpVC: UIViewController {

    @IBOutlet weak var colView: UICollectionView!
    var imgArray : Array<String> = []
    
    @IBOutlet weak var pageControl: UIPageControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imgArray = ["help1","help2","help3"]
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell : UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("helpVCCellIdentifier", forIndexPath: indexPath)
        let imgView = cell.viewWithTag(99) as! UIImageView
        imgView.image = UIImage(named: imgArray[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let size = CGSize(width: colView.frame.size.width,height: colView.frame.size.height)
        return size
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        
//        self.setImageInPageControl()
    }
    
    @IBAction func backBtnClk(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
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
