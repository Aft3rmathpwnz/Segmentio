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
            segmentioView.addBadge(
                at: index,
                count: (index + 1)*10,
                gradientColors: [ColorPalette.coral, .green]
            )
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
            SegmentioItem(title: "Посты", image: UIImage(named: "ic_news"), font: UIFont.systemFont(ofSize: 34.0, weight: UIFont.Weight.bold)),
            SegmentioItem(title: "Пользователи", image: UIImage(named: "ic_sp"), font: UIFont.systemFont(ofSize: 34.0, weight: UIFont.Weight.bold))
//            SegmentioItem(title: "Лента", image: UIImage(named: "ic_feed"), font: UIFont.systemFont(ofSize: 34.0, weight: UIFont.Weight.bold)),
//            SegmentioItem(title: "Лента", image: UIImage(named: "ic_feed"), font: UIFont.systemFont(ofSize: 34.0, weight: UIFont.Weight.bold))
        ]
    }
    
    private static func segmentioOptions(segmentioStyle: SegmentioStyle, segmentioPosition: SegmentioPosition = .fixed(maxVisibleItems: 3)) -> SegmentioOptions {
        let states = SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.systemFont(ofSize: 34.0, weight: UIFont.Weight.bold),
                titleTextColor: .black
            ),
            selectedState: SegmentioState(
                backgroundColor: .clear,
                titleFont:  UIFont.systemFont(ofSize: 34.0, weight: UIFont.Weight.bold),
                titleTextColor: .black
            ),
            highlightedState: SegmentioState(
                backgroundColor: .clear,
                titleFont:  UIFont.systemFont(ofSize: 34.0, weight: UIFont.Weight.bold),
                titleTextColor: .black
            )
        )
        
        return SegmentioOptions(
            backgroundColor: .clear,
            segmentPosition: .dynamic,
            scrollEnabled: true,
            indicatorOptions: nil,
            horizontalSeparatorOptions: segmentioHorizontalSeparatorOptions(),
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
            type: .none,
            height: 0,
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
