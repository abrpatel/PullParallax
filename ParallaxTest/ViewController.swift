//
//  ViewController.swift
//  ParallaxTest
//
//  Created by Abhishek Patel on 8/15/15.
//  Copyright (c) 2015 Abhishek Patel. All rights reserved.
//

import UIKit

class HeaderFooterCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        let collectionView = self.collectionView
        
        if let
            insets = collectionView?.contentInset,
            offSet = collectionView?.contentOffset,
            attributes = super.layoutAttributesForElementsInRect(rect) {
                
                let minY = insets.bottom
                let headerSize = self.headerReferenceSize
                let footerSize = self.footerReferenceSize
                var deltaY = fabs(offSet.y - minY)
                
                for attribute in attributes {
                    let attribute : UICollectionViewLayoutAttributes = attribute as! UICollectionViewLayoutAttributes
                    
                    if let
                        theRepresentedElementKind = attribute.representedElementKind {
                        
                            if offSet.y < minY {
                                if theRepresentedElementKind == UICollectionElementKindSectionHeader {
                                    
                                    var headerFrame = attribute.frame
                                    headerFrame.size.height = max(minY, headerFrame.height + deltaY)
                                    headerFrame.origin.y = headerFrame.origin.y - deltaY
                                    attribute.frame = headerFrame
                                    
                                    break
                                }
                            } else {
                                if theRepresentedElementKind == UICollectionElementKindSectionFooter {
                                    
                                    var footerFrame = attribute.frame
                                    footerFrame.size.height = max(minY, footerFrame.height + deltaY) / 2
                                    footerFrame.origin.y = footerFrame.origin.y
                                    attribute.frame = footerFrame
                                    
                                    break
                                }
                            }
                            
                            var scale = 1 + fabs(offSet.y) / rect.height
                            scale = max(0, scale)
                            attribute.transform = CGAffineTransformMakeScale(scale, scale)
                    }
                }
                
                return attributes
        } else {
            return nil
        }
    }
}

class ViewController: UIViewController {
    
    var collectionView : UICollectionView!
    var header : UICollectionReusableView!
    var footer : UICollectionReusableView!
    
    var isScrolled = false
    
    let cellIdentifer = "Cell Identifier"
    let headerIdentifier = "Header Identifier"
    let footerIdentifier = "Footer Identifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var headerFooterCollectionViewLayout = HeaderFooterCollectionViewLayout()
        headerFooterCollectionViewLayout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
        headerFooterCollectionViewLayout.itemSize = CGSizeMake(320.0, 494.0)
        headerFooterCollectionViewLayout.headerReferenceSize = CGSizeMake(320.0, 160.0)
        headerFooterCollectionViewLayout.footerReferenceSize = CGSizeMake(320.0, 160.0)
        
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: headerFooterCollectionViewLayout)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.alwaysBounceVertical = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        
        self.view.addSubview(collectionView)
        
        
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifer)
        
        collectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerIdentifier)
        
        collectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addParallaxEffect(view: UIView) {
        // Set vertical effect
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
            type: .TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -20
        verticalMotionEffect.maximumRelativeValue = 20
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
            type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -20
        horizontalMotionEffect.maximumRelativeValue = 20
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        view.addMotionEffect(group)
    }
}

extension ViewController : UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerIdentifier, forIndexPath: indexPath) as! UICollectionReusableView
            
            let imageView = UIImageView(frame: CGRectMake(-20, -20, CGRectGetWidth(header.bounds) + 40, CGRectGetHeight(header.bounds) + 40))
            imageView.image = UIImage(named: "spacedoggy")
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
            imageView.clipsToBounds = true
            
            header.addSubview(imageView)
            
            self.addParallaxEffect(header)

            return header
        } else {
            footer = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: footerIdentifier, forIndexPath: indexPath) as! UICollectionReusableView
            
            let imageView = UIImageView(frame: CGRectMake(-20, -20, CGRectGetWidth(footer.bounds) + 40, CGRectGetHeight(footer.bounds) + 40))
            imageView.image = UIImage(named: "ThanksgivingRocks")
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
            imageView.clipsToBounds = true
                    
            footer.addSubview(imageView)
            
            self.addParallaxEffect(footer)

            return footer
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifer, forIndexPath: indexPath) as! UICollectionViewCell
        
        let attributes = NSDictionary(objectsAndKeys: UIFont(name: "HelveticaNeue-Thin", size: 30.0)!, NSFontAttributeName, UIColor.lightGrayColor(), NSForegroundColorAttributeName)
        
        let attributedText = NSAttributedString(string: "This is where you place a table view to scale contents and the view", attributes: attributes as [NSObject : AnyObject])
        
        let label = UILabel(frame: CGRectMake(10, 10, CGRectGetWidth(cell.bounds) - 20, CGRectGetHeight(cell.bounds) - 20))
        label.backgroundColor = UIColor.clearColor()
        label.numberOfLines = 0
        label.attributedText = attributedText
        
        self.addParallaxEffect(label)

        cell.addSubview(label)
        
        return cell
    }
}
