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
                super.cellSelected = newValue
                print("IS SELECTED = \(newValue)")
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
            imageContainerView.isHidden = true
            containerView.isHidden = false
            
        } else {
            guard let containerView = containerView, let imageContainerView = imageContainerView else {
                return
            }
            containerView.isHidden = true
            imageContainerView.isHidden = false

            views = ["imageContainerView": imageContainerView]
            
            // main constraints
            
            let segmentImageViewlHorizontConstraint = NSLayoutConstraint.constraints(
                withVisualFormat: "|-[imageContainerView]-|",
                options: [],
                metrics: nil,
                views: views)
            NSLayoutConstraint.activate(segmentImageViewlHorizontConstraint)
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
