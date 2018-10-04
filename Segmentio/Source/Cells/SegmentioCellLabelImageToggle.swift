//
//  SegmentioCellLabelImageToggle.swift
//  Pods
//
//  Created by Aft3rmath on 04.09.2018.
//

import UIKit

final class SegmentioCellLabelImageToggle: SegmentioCell {
    
    override var cellSelected: Bool {
        set {
            if super.cellSelected != newValue {
//            print("IS SELECTED = \(newValue), WAS = \(super.cellSelected)")
                super.cellSelected = newValue
                setupConstraintsForSubviews()
            }
        }
        get {
            return super.cellSelected
        }
    }
    
    override func setupConstraintsForSubviews() {
        super.setupConstraintsForSubviews()
        var views: [String: UIView]
        if cellSelected {
            guard let containerView = containerView, let imageContainerView = imageContainerView else {
                return
            }
                        
            views = ["containerView": containerView]
            
            // main constraints
            
            let segmentTitleLabelHorizontConstraint = NSLayoutConstraint.constraints(
                withVisualFormat: "|-[containerView]-|",
                options: [.alignAllCenterX],
                metrics: nil,
                views: views
            )
            NSLayoutConstraint.activate(segmentTitleLabelHorizontConstraint)
            
//            self.setNeedsUpdateConstraints()

//            UIView.animate(withDuration: 0.25, animations: {
//                self.layoutIfNeeded()
//            })
            
//            UIView.animate(withDuration: 1.0) {
//                self.layoutIfNeeded() //layout your constraint with the new value
//            }
            
         
//            let transition:CATransition = CATransition()
//            transition.duration = 0.3
//            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//            transition.type = kCATransitionFade
//            transition.subtype = kCATransitionFromRight
//            self.layer.add(transition, forKey: kCATransition)
//
            containerView.isHidden = false
            imageContainerView.isHidden = true

            self.setNeedsUpdateConstraints()
            
//            UIView.animate(withDuration: 0.25, animations: {
//                self.layoutIfNeeded()
//            })

            UIView.animate(withDuration: 0.45/*Animation Duration second*/, animations: {
                imageContainerView.alpha = 0
                containerView.alpha = 1
//                self.layoutIfNeeded()
            }, completion:  {
                (value: Bool) in

            })
            
            
        } else {
            guard let containerView = containerView, let imageContainerView = imageContainerView else {
                return
            }

            views = ["imageContainerView": imageContainerView]
            
            // main constraints
            
            let segmentImageViewlHorizontConstraint = NSLayoutConstraint.constraints(
                withVisualFormat: "|-[imageContainerView]-|",
                options: [],
                metrics: nil,
                views: views)
            NSLayoutConstraint.activate(segmentImageViewlHorizontConstraint)
            
//            self.setNeedsUpdateConstraints()
            
         
            
//            UIView.animate(withDuration: 1.0) {
//                self.layoutIfNeeded() //layout your constraint with the new value
//            }
            
         

//            let transition:CATransition = CATransition()
//            transition.duration = 0.3
//            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//            transition.type = kCATransitionFade
//            transition.subtype = kCATransitionFromLeft
//            self.layer.add(transition, forKey: kCATransition)
//
            imageContainerView.isHidden = false
            containerView.isHidden = true
            
            self.setNeedsUpdateConstraints()
            
//            UIView.animate(withDuration: 0.25, animations: {
//                self.layoutIfNeeded()
//            })
            
            UIView.animate(withDuration: 0.45/*Animation Duration second*/, animations: {
                containerView.alpha = 0
                imageContainerView.alpha = 1
//                self.layoutIfNeeded()
            }, completion:  {
                (value: Bool) in
            })
            
        }
        
        // custom constraints
        
        topConstraint = NSLayoutConstraint(
            item: views.first!.value,
            attribute: .top,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .top,
            multiplier: 1,
            constant: padding
        )
        topConstraint?.isActive = true
        
        bottomConstraint = NSLayoutConstraint(
            item: contentView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: views.first!.value,
            attribute: .bottom,
            multiplier: 1,
            constant: padding
        )
        bottomConstraint?.isActive = true
        
    
    }
    
}
