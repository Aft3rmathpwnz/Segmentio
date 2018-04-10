//
//  SegmentioBuilder.swift
//  Segmentio
//
//  Created by Dmitriy Demchenko on 11/14/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Segmentio
import UIKit

struct SegmentioBuilder {
    
    static func setupBadgeCountForIndex(_ segmentioView: Segmentio, index: Int) {
        if index % 2 == 0 {
            segmentioView.addBadge(
                at: index,
                count: 10,
                color: ColorPalette.coral
            )
        } else {
            segmentioView.addBadge(
                at: index,
                count: 10,
                gradientColors: [ColorPalette.coral, ColorPalette.grayChateau]
            )
        }
    }
    
    static func buildSegmentioView(segmentioView: Segmentio, segmentioStyle: SegmentioStyle, segmentioPosition: SegmentioPosition = .fixed(maxVisibleItems: 3)) {
        segmentioView.setup(
            content: segmentioContent(),
            style: segmentioStyle,
            options: segmentioOptions(segmentioStyle: segmentioStyle, segmentioPosition: segmentioPosition)
        )
    }
    
    private static func segmentioContent() -> [SegmentioItem] {
        return [
            SegmentioItem(title: "DEV", image: UIImage(named: "tornado")),
            SegmentioItem(title: "TEST", image: UIImage(named: "earthquakes")),
            SegmentioItem(title: "UAT", image: UIImage(named: "heat")),
            SegmentioItem(title: "LOAD1", image: UIImage(named: "eruption")),
            SegmentioItem(title: "LOAD2", image: UIImage(named: "floods"))
            //SegmentioItem(title: "Wildfires", image: UIImage(named: "wildfires"))
        ]
    }
    
    private static func segmentioOptions(segmentioStyle: SegmentioStyle, segmentioPosition: SegmentioPosition = .fixed(maxVisibleItems: 3)) -> SegmentioOptions {
        var imageContentMode = UIViewContentMode.center
        switch segmentioStyle {
        case .imageBeforeLabel, .imageAfterLabel:
            imageContentMode = .scaleAspectFit
        default:
            break
        }
        
        let indicatorOptions = SegmentioIndicatorOptions(
            type: .bottom,
            ratio: 1,
            height: 5,
//            colorsForIndexes: [[.red, .red], [.orange, .red], [.yellow, .red], [.green, .red], [.blue, .red]]
            colorsForIndexes: [[.yellow, .red], [.green, .red], [.blue, .red]]
        )
        
        let horizontalSeparatorOptions = SegmentioHorizontalSeparatorOptions(
            type: .none,
            height: 0,
            color: .clear
        )
        
        let states = SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium),
                titleTextColor: .white
            ),
            selectedState: SegmentioState(
                backgroundColor: .clear,
                titleFont:  UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium),
                titleTextColor: .white
            ),
            highlightedState: SegmentioState(
                backgroundColor: .clear,
                titleFont:  UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium),
                titleTextColor: .white
            )
        )
        
        return SegmentioOptions(
            backgroundColor: .black,
            segmentPosition: .fixedByLargest,
            scrollEnabled: true,
            indicatorOptions: indicatorOptions,
            horizontalSeparatorOptions: horizontalSeparatorOptions,
            verticalSeparatorOptions: nil,
            imageContentMode: .center,
            labelTextAlignment: .center,
            segmentStates: states
        )
    }
    
    private static func segmentioStates() -> SegmentioStates {
        let font = UIFont.exampleAvenirMedium(ofSize: 13)
        return SegmentioStates(
            defaultState: segmentioState(
                backgroundColor: .clear,
                titleFont: font,
                titleTextColor: ColorPalette.grayChateau
            ),
            selectedState: segmentioState(
                backgroundColor: .cyan,
                titleFont: font,
                titleTextColor: ColorPalette.black
            ),
            highlightedState: segmentioState(
                backgroundColor: ColorPalette.whiteSmoke,
                titleFont: font,
                titleTextColor: ColorPalette.grayChateau
            )
        )
    }
    
    private static func segmentioState(backgroundColor: UIColor, titleFont: UIFont, titleTextColor: UIColor) -> SegmentioState {
        return SegmentioState(
            backgroundColor: backgroundColor,
            titleFont: titleFont,
            titleTextColor: titleTextColor
        )
    }
    
    private static func segmentioIndicatorOptions() -> SegmentioIndicatorOptions {
        return SegmentioIndicatorOptions(
            type: .bottom,
            ratio: 1,
            height: 5,
            colorsForIndexes: [[.orange, .black], [.orange, .red]]
        )
    }
    
    private static func segmentioHorizontalSeparatorOptions() -> SegmentioHorizontalSeparatorOptions {
        return SegmentioHorizontalSeparatorOptions(
            type: .topAndBottom,
            height: 1,
            color: ColorPalette.whiteSmoke
        )
    }
    
    private static func segmentioVerticalSeparatorOptions() -> SegmentioVerticalSeparatorOptions {
        return SegmentioVerticalSeparatorOptions(
            ratio: 1,
            color: ColorPalette.whiteSmoke
        )
    }
    
}
