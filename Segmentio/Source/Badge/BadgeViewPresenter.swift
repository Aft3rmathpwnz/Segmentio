//
//  BadgeViewPresenter.swift
//  Pods
//
//  Created by Eugene on 22.09.16.
//
//

import UIKit

class BadgeViewPresenter {
    
    func addBadgeForContainerView(_ containerView: UIView, counterValue: Int, backgroundColor: UIColor = .red,
                                  badgeSize: BadgeSize = .standard, relativeTo relativeView: UIView) {
        var badgeView: BadgeWithCounterView!
        for view in containerView.subviews {
            if let badgeView = view as? BadgeWithCounterView {
                badgeView.setBadgeBackgroundColor(backgroundColor)
                badgeView.setBadgeCounterValue(counterValue)
            }
        }
        if badgeView == nil {
            badgeView = badgeViewForCounterValue(counterValue, backgroundColor: backgroundColor, size: badgeSize)
            badgeView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(badgeView)
            containerView.bringSubviewToFront(badgeView)
            setupBadgeConstraints(badgeView, counterValue: counterValue, relativeTo: relativeView)
        }
    }
    
    func addBadgeForContainerView(_ containerView: UIView, counterValue: Int, backgroundColors: [UIColor],
                                  badgeSize: BadgeSize = .standard, relativeTo relativeView: UIView) {
        var badgeView: BadgeWithCounterView!
        for view in containerView.subviews {
            if let badgeView = view as? BadgeWithCounterView {
                badgeView.setBadgeBackgroundColors(backgroundColors)
                badgeView.setBadgeCounterValue(counterValue)
            }
        }
        if badgeView == nil {
            badgeView = badgeViewForCounterValue(counterValue, backgroundColors: backgroundColors, size: badgeSize)
            badgeView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(badgeView)
            containerView.bringSubviewToFront(badgeView)
            setupBadgeConstraints(badgeView, counterValue: counterValue, relativeTo: relativeView)
        }
    }
    
    func removeBadgeFromContainerView(_ containerView: UIView) {
        for view in containerView.subviews {
            if view is BadgeWithCounterView {
                view.removeFromSuperview()
            }
        }
    }
    
    fileprivate func setupBadgeConstraints(_ badgeView: BadgeWithCounterView, counterValue: Int, relativeTo relativeView: UIView) {
        let segmentTitleLabelHorizontalCenterConstraint =
            NSLayoutConstraint(
                item: badgeView,
                attribute: .top,
                relatedBy: .equal,
                toItem: relativeView,
                attribute: .top,
                multiplier: 1,
                constant: 0
        )
        
        let segmentTitleLabelVerticalCenterConstraint =
            NSLayoutConstraint(
                item: badgeView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: relativeView,
                attribute: .trailing,
                multiplier: 1,
                constant: badgeView.frame.size.height / 3.0
        )
        segmentTitleLabelHorizontalCenterConstraint.isActive = true
        segmentTitleLabelVerticalCenterConstraint.isActive = true
    }
    
}

enum Separator {
    
    case top
    case bottom
    case topAndBottom
    
}



// MARK: Badges views creation

extension BadgeViewPresenter {
    
    fileprivate func badgeViewForCounterValue(_ counter: Int, backgroundColor: UIColor, size: BadgeSize) -> BadgeWithCounterView {
        let view = BadgeWithCounterView.instanceFromNib(size: size)
        view.setBadgeBackgroundColor(backgroundColor)
        view.setBadgeCounterValue(counter)
        return view
    }
    
    fileprivate func badgeViewForCounterValue(_ counter: Int, backgroundColors: [UIColor], size: BadgeSize) -> BadgeWithCounterView {
        let view = BadgeWithCounterView.instanceFromNib(size: size)
        view.setBadgeBackgroundColors(backgroundColors)
        view.setBadgeCounterValue(counter)
        return view
    }
    
}
