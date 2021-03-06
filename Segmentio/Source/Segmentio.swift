//
//  Segmentio.swift
//  Segmentio
//
//  Created by Dmitriy Demchenko
//  Copyright © 2016 Yalantis Mobile. All rights reserved.
//

import UIKit
import QuartzCore

public typealias SegmentioSelectionCallback = ((_ segmentio: Segmentio, _ selectedSegmentioIndex: Int) -> Void)

open class Segmentio: UIView {
    
    internal struct Points {
        var startPoint: CGPoint
        var endPoint: CGPoint
    }
    
    internal struct Context {
        var isFirstCell: Bool
        var isLastCell: Bool
        var isLastOrPrelastVisibleCell: Bool
        var isFirstOrSecondVisibleCell: Bool
        var isFirstIndex: Bool
    }
    
    internal struct ItemInSuperview {
        var collectionViewWidth: CGFloat
        var cellFrameInSuperview: CGRect
        var shapeLayerWidth: CGFloat
        var startX: CGFloat
        var endX: CGFloat
    }
    
    open var valueDidChange: SegmentioSelectionCallback?
    fileprivate var latestSelectedSegmentioIndex = -1
    open var selectedSegmentioIndex = -1 {
        didSet {
            if selectedSegmentioIndex != oldValue {
                latestSelectedSegmentioIndex = oldValue
                reloadSegmentio()
                valueDidChange?(self, selectedSegmentioIndex)
            }
        }
    }
    
    open fileprivate(set) var segmentioItems = [SegmentioItem]()
    fileprivate var segmentioCollectionView: UICollectionView?
    fileprivate var segmentioOptions = SegmentioOptions()
    fileprivate var segmentioStyle = SegmentioStyle.imageOverLabel
    fileprivate var isPerformingScrollAnimation = false
    fileprivate var isCollectionViewScrolling = false
    
    fileprivate var topSeparatorView: UIView?
    fileprivate var bottomSeparatorView: UIView?
    fileprivate var indicatorLayer: CAShapeLayer?
    fileprivate var selectedLayer: CAShapeLayer?
    
    // MARK: - Lifecycle
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        reloadSegmentio()
    }
    
    fileprivate func commonInit() {
        setupSegmentedCollectionView()
    }
    
    fileprivate func setupSegmentedCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.zero
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)
        
        let collectionView = UICollectionView(
            frame: frameForSegmentCollectionView(),
            collectionViewLayout: layout
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = true
        collectionView.isScrollEnabled = segmentioOptions.scrollEnabled
        collectionView.backgroundColor = .clear
        collectionView.accessibilityIdentifier = "segmentio_collection_view"
        
        segmentioCollectionView = collectionView
        
        if let segmentioCollectionView = segmentioCollectionView {
            addSubview(segmentioCollectionView, options: .overlay)
        }
    }
    
    fileprivate func frameForSegmentCollectionView() -> CGRect {
        var separatorsHeight: CGFloat = 0
        var collectionViewFrameMinY: CGFloat = 0
        
        if let horizontalSeparatorOptions = segmentioOptions.horizontalSeparatorOptions {
            let separatorHeight = horizontalSeparatorOptions.height
            
            switch horizontalSeparatorOptions.type {
            case .none:
                separatorsHeight = 0
            case .top:
                collectionViewFrameMinY = separatorHeight
                separatorsHeight = separatorHeight
            case .bottom:
                separatorsHeight = separatorHeight
            case .topAndBottom:
                collectionViewFrameMinY = separatorHeight
                separatorsHeight = separatorHeight * 2
            }
        }
        
        return CGRect(
            x: 0,
            y: collectionViewFrameMinY,
            width: bounds.width,
            height: bounds.height - separatorsHeight
        )
    }
    
    // MARK: - Setups:
    // MARK: Main setup
    
    open func setup(content: [SegmentioItem], style: SegmentioStyle, options: SegmentioOptions?) {
        segmentioItems = content
        segmentioStyle = style
        
        selectedLayer?.removeFromSuperlayer()
        indicatorLayer?.removeFromSuperlayer()
        
        if let options = options {
            segmentioOptions = options
            segmentioCollectionView?.isScrollEnabled = segmentioOptions.scrollEnabled
            backgroundColor = options.backgroundColor
        }
        
        if segmentioOptions.states.selectedState.backgroundColor != .clear {
            selectedLayer = CAShapeLayer()
            if let selectedLayer = selectedLayer, let sublayer = segmentioCollectionView?.layer {
                setupShapeLayer(
                    shapeLayer: selectedLayer,
                    backgroundColors: [[segmentioOptions.states.selectedState.backgroundColor]],
                    height: bounds.height,
                    sublayer: sublayer
                )
            }
        }
        
        // Fill fradient colors boundaries to match items count if not enough
        if segmentioOptions.indicatorOptions != nil {
            let initialCount = segmentioOptions.indicatorOptions!.colorsForIndexes.count
            while segmentioOptions.indicatorOptions!.colorsForIndexes.count < segmentioItems.count {
                let colorsForIndexes = segmentioOptions.indicatorOptions!.colorsForIndexes
                segmentioOptions.indicatorOptions!.colorsForIndexes = colorsForIndexes + [colorsForIndexes[colorsForIndexes.count % initialCount]]
            }
        }
        
        if let indicatorOptions = segmentioOptions.indicatorOptions {
            indicatorLayer = CAShapeLayer()
            if let indicatorLayer = indicatorLayer {
                setupShapeLayer(
                    shapeLayer: indicatorLayer,
                    backgroundColors: nil,
                    height: indicatorOptions.height,
                    sublayer: layer
                )
                
                var gradient: CAGradientLayer
                if let gradientLayer = indicatorLayer.sublayers?[0] as? CAGradientLayer {
                    gradient = gradientLayer
                } else {
                    gradient = CAGradientLayer()
                    gradient.delegate = self
                    
                    gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
                    gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
                    
                    indicatorLayer.insertSublayer(gradient, at: 0)
                }
            }
        }
        
        setupHorizontalSeparatorIfPossible()
        setupCellWithStyle(segmentioStyle)
        segmentioCollectionView?.reloadData()
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setupHorizontalSeparatorIfPossible()
    }
    
    open func addBadge(at index: Int, count: Int, color: UIColor = .red) {
        segmentioItems[index].addBadge(count, color: color)
        segmentioCollectionView?.reloadData()
    }
    
    open func addBadge(at index: Int, count: Int, gradientColors: [UIColor]) {
        segmentioItems[index].addBadge(count, gradientColors: gradientColors)
        segmentioCollectionView?.reloadData()
    }
    
    open func removeBadge(at index: Int) {
        segmentioItems[index].removeBadge()
        segmentioCollectionView?.reloadData()
    }
    
    // MARK: Collection view setup
    
    fileprivate func setupCellWithStyle(_ style: SegmentioStyle) {
        var cellClass: SegmentioCell.Type {
            switch style {
            case .onlyLabel:
                return SegmentioCellWithLabel.self
            case .onlyImage:
                return SegmentioCellWithImage.self
            case .imageOverLabel:
                return SegmentioCellWithImageOverLabel.self
            case .imageUnderLabel:
                return SegmentioCellWithImageUnderLabel.self
            case .imageBeforeLabel:
                return SegmentioCellWithImageBeforeLabel.self
            case .imageAfterLabel:
                return SegmentioCellWithImageAfterLabel.self
            case .imageLabelToggle:
                return SegmentioCellLabelImageToggle.self
            }
        }
        
        let cellStyles = Set(segmentioItems.map { styleFor(item: $0) } )
        
        for cellStyle in cellStyles {
            segmentioCollectionView?.register(
                cellClassForStyle(cellStyle),
                forCellWithReuseIdentifier: cellStyle.rawValue
            )
        }
        
        
        
        segmentioCollectionView?.layoutIfNeeded()
    }
    
    fileprivate func cellClassForStyle(_ style: SegmentioStyle) -> SegmentioCell.Type {
        switch style {
        case .onlyLabel:
            return SegmentioCellWithLabel.self
        case .onlyImage:
            return SegmentioCellWithImage.self
        case .imageOverLabel:
            return SegmentioCellWithImageOverLabel.self
        case .imageUnderLabel:
            return SegmentioCellWithImageUnderLabel.self
        case .imageBeforeLabel:
            return SegmentioCellWithImageBeforeLabel.self
        case .imageAfterLabel:
            return SegmentioCellWithImageAfterLabel.self
        case .imageLabelToggle:
            return SegmentioCellLabelImageToggle.self
        }
    }
    
    // MARK: Horizontal separators setup
    
    fileprivate func setupHorizontalSeparatorIfPossible() {
        if superview != nil && segmentioOptions.horizontalSeparatorOptions != nil {
            setupHorizontalSeparator()
        }
    }
    
    fileprivate func setupHorizontalSeparator() {
        topSeparatorView?.removeFromSuperview()
        bottomSeparatorView?.removeFromSuperview()
        
        guard let horizontalSeparatorOptions = segmentioOptions.horizontalSeparatorOptions else {
            return
        }
        
        let height = horizontalSeparatorOptions.height
        let type = horizontalSeparatorOptions.type
        
        if type == .top || type == .topAndBottom {
            topSeparatorView = UIView(frame: CGRect.zero)
            setupConstraintsForSeparatorView(
                separatorView: topSeparatorView,
                originY: 0
            )
        }
        
        if type == .bottom || type == .topAndBottom {
            bottomSeparatorView = UIView(frame: CGRect.zero)
            setupConstraintsForSeparatorView(
                separatorView: bottomSeparatorView,
                originY: bounds.maxY - height
            )
        }
    }
    
    fileprivate func setupConstraintsForSeparatorView(separatorView: UIView?, originY: CGFloat) {
        guard let horizontalSeparatorOptions = segmentioOptions.horizontalSeparatorOptions,
            let separatorView = separatorView else {
                return
        }
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = horizontalSeparatorOptions.color
        addSubview(separatorView)
        
        let topConstraint = NSLayoutConstraint(
            item: separatorView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1,
            constant: originY
        )
        topConstraint.isActive = true
        
        let leadingConstraint = NSLayoutConstraint(
            item: separatorView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1,
            constant: 0
        )
        leadingConstraint.isActive = true
        
        let trailingConstraint = NSLayoutConstraint(
            item: separatorView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1,
            constant: 0
        )
        trailingConstraint.isActive = true
        
        let heightConstraint = NSLayoutConstraint(
            item: separatorView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: horizontalSeparatorOptions.height
        )
        heightConstraint.isActive = true
    }
    
    // MARK: CAShapeLayers setup
    
    fileprivate func setupShapeLayer(shapeLayer: CAShapeLayer, backgroundColors: [[UIColor]]?, height: CGFloat,
                                     sublayer: CALayer) {
        if backgroundColors != nil {
            shapeLayer.fillColor = backgroundColors![0][0].cgColor
            shapeLayer.strokeColor = backgroundColors![0][0].cgColor
        }
        shapeLayer.lineWidth = height
        layer.insertSublayer(shapeLayer, below: sublayer)
    }
    
    // MARK: - Actions:
    // MARK: Reload segmentio
    public func reloadSegmentio() {
        segmentioCollectionView?.collectionViewLayout.invalidateLayout()
        
        segmentioCollectionView?.reloadData()

//        segmentioCollectionView?.performBatchUpdates({
//            segmentioCollectionView?.reloadData()
//        }, completion: { [weak self] finished in
//            if finished {
//
//            }
//        })
        
//        segmentioCollectionView?.performBatchUpdates(
//            {
//                segmentioCollectionView?.reloadSections(IndexSet(integer: 0))
//        }, completion: { [weak self] finished in
//            if finished {
//                guard self?.selectedSegmentioIndex != -1 else { return }
//                self?.scrollToItemAtContext()
//                self?.moveShapeLayerAtContext()
//            }
//        })


      
    }
    
    // MARK: Move shape layer to item
    
    fileprivate func moveShapeLayerAtContext() {
        if let indicatorLayer = indicatorLayer, let options = segmentioOptions.indicatorOptions {
            let item = itemInSuperview(ratio: options.ratio)
            let context = contextForItem(item)
            
            let points = Points(
                context: context,
                item: item,
                atIndex: selectedSegmentioIndex,
                allItems: segmentioItems,
                pointY: indicatorPointY(),
                position: segmentioOptions.segmentPosition,
                style: segmentioStyle
            )
            
            moveShapeLayer(
                indicatorLayer,
                startPoint: points.startPoint,
                endPoint: points.endPoint,
                animated: true
            )
            if let gradientLayer = indicatorLayer.sublayers?[0] as? CAGradientLayer {
                moveGradientLayer(gradientLayer, startPoint: nil, endPoint: nil, animated: true)
            }
        }
        
        if let selectedLayer = selectedLayer {
            let item = itemInSuperview()
            let context = contextForItem(item)
            
            let points = Points(
                context: context,
                item: item,
                atIndex: selectedSegmentioIndex,
                allItems: segmentioItems,
                pointY: bounds.midY,
                position: segmentioOptions.segmentPosition,
                style: segmentioStyle
            )
            
            moveShapeLayer(
                selectedLayer,
                startPoint: points.startPoint,
                endPoint: points.endPoint,
                animated: true
            )
        }
    }

    /*
     -(void)resizeLayer:(CALayer*)layer to:(CGSize)size
     {
     // Prepare the animation from the old size to the new size
     CGRect oldBounds = layer.bounds;
     CGRect newBounds = oldBounds;
     newBounds.size = size;
     CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
     
     // NSValue/+valueWithRect:(NSRect)rect is available on Mac OS X
     // NSValue/+valueWithCGRect:(CGRect)rect is available on iOS
     // comment/uncomment the corresponding lines depending on which platform you're targeting
     
     // Mac OS X
     animation.fromValue = [NSValue valueWithRect:NSRectFromCGRect(oldBounds)];
     animation.toValue = [NSValue valueWithRect:NSRectFromCGRect(newBounds)];
     // iOS
     //animation.fromValue = [NSValue valueWithCGRect:oldBounds];
     //animation.toValue = [NSValue valueWithCGRect:newBounds];
     
     // Update the layer's bounds so the layer doesn't snap back when the animation completes.
     layer.bounds = newBounds;
     
     // Add the animation, overriding the implicit animation.
     [layer addAnimation:animation forKey:@"bounds"];
     }
     */
    
    
    
    // MARK: Scroll to item
    
    fileprivate func scrollToItemAtContext() {
        guard selectedSegmentioIndex != -1 else {
            return
        }
        
        let item = itemInSuperview()
        segmentioCollectionView?.scrollRectToVisible(centerRect(for: item), animated: true)
    }
    
    fileprivate func centerRect(for item: ItemInSuperview) -> CGRect {
        guard let collectionView = segmentioCollectionView else {
            fatalError("segmentioCollectionView should exist")
        }
        
        let item = itemInSuperview()
        var centerRect = item.cellFrameInSuperview
        
        if (item.startX + collectionView.contentOffset.x) - (item.collectionViewWidth - centerRect.width) / 2 < 0 {
            centerRect.origin.x = 0
            let widthToAdd = item.collectionViewWidth - centerRect.width
            centerRect.size.width += widthToAdd
        } else if collectionView.contentSize.width - item.endX < (item.collectionViewWidth - centerRect.width) / 2 {
            centerRect.origin.x = collectionView.contentSize.width - item.collectionViewWidth
            centerRect.size.width = item.collectionViewWidth
        } else {
            centerRect.origin.x = item.startX - (item.collectionViewWidth - centerRect.width) / 2
                + collectionView.contentOffset.x
            centerRect.size.width = item.collectionViewWidth
        }
        
        return centerRect
    }
    
    // MARK: Move shape layer
    
    fileprivate func moveShapeLayer(_ shapeLayer: CAShapeLayer, startPoint: CGPoint, endPoint: CGPoint,
                                    animated: Bool = false) {
        var endPointWithVerticalSeparator = endPoint
        let isLastItem = selectedSegmentioIndex + 1 == segmentioItems.count
        endPointWithVerticalSeparator.x = endPoint.x - (isLastItem ? 0 : 1)
        
        let shapeLayerPath = UIBezierPath()
        shapeLayerPath.move(to: startPoint)
        shapeLayerPath.addLine(to: endPointWithVerticalSeparator)
        
        if animated == true {
            isPerformingScrollAnimation = true
            isUserInteractionEnabled = false
            
            CATransaction.begin()
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = shapeLayer.path
            animation.toValue = shapeLayerPath.cgPath
            animation.duration = segmentioOptions.animationDuration
            CATransaction.setCompletionBlock() {
                self.isPerformingScrollAnimation = false
                self.isUserInteractionEnabled = true
            }
            shapeLayer.add(animation, forKey: "path")
            CATransaction.commit()
        }
        
        shapeLayer.path = shapeLayerPath.cgPath
    }
    
    // MARK: Move gradient layer
    
    fileprivate func moveGradientLayer(_ gradientLayer: CAGradientLayer, startPoint: CGPoint?, endPoint: CGPoint?, animated: Bool = false) {
        if let gradient = indicatorLayer?.sublayers?[0] as? CAGradientLayer {
            let colorsForIndexes = segmentioOptions.indicatorOptions?.colorsForIndexes

            if let rect = indicatorLayer?.path?.boundingBox {
                gradient.frame = rect
                gradient.frame.size.height = segmentioOptions.indicatorOptions?.height ?? 0.0
                gradient.frame.origin.y -= gradient.frame.size.height / 2.0

                if animated == true {
                    isPerformingScrollAnimation = true
                    isUserInteractionEnabled = false

                    var animations = [CABasicAnimation]()

                    let posAnimation = CABasicAnimation(keyPath: "position")
                    posAnimation.duration = segmentioOptions.animationDuration
                    posAnimation.fromValue = [NSValue(cgPoint: gradient.position)]
                    posAnimation.toValue = [NSValue(cgPoint: gradient.frame.origin)]
                    animations.append(posAnimation)

                    let widthAnimation = CABasicAnimation(keyPath: "bounds.size")

                    widthAnimation.duration = segmentioOptions.animationDuration
                    widthAnimation.fromValue =  [NSValue(cgSize: CGSize(width: gradient.bounds.size.width, height: gradient.bounds.size.height))]
                    widthAnimation.toValue = [NSValue(cgSize: CGSize(width: gradient.frame.width, height: gradient.frame.height))]
                    animations.append(widthAnimation)
                    
                    let colorAnimation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
                    
                    colorAnimation.duration = segmentioOptions.animationDuration * 2.0
                    colorAnimation.fromValue = gradientLayer.colors
                    colorAnimation.toValue = colorsForIndexes?[selectedSegmentioIndex >= 0 ? selectedSegmentioIndex : 0].map({ $0.cgColor })
                    colorAnimation.isRemovedOnCompletion = true
                    colorAnimation.fillMode = CAMediaTimingFillMode.forwards
                    colorAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
                    animations.append(colorAnimation)

                    let group = CAAnimationGroup()

                    group.duration = segmentioOptions.animationDuration * 2.0
                    group.animations = animations
                    gradientLayer.add(group, forKey: nil)
                }
                gradientLayer.colors = colorsForIndexes?[selectedSegmentioIndex >= 0 ? selectedSegmentioIndex : 0].map({ $0.cgColor })
            }
        }
    }
    
    // MARK: - Context for item
    
    fileprivate func contextForItem(_ item: ItemInSuperview) -> Context {
        let cellFrame = item.cellFrameInSuperview
        let cellWidth = cellFrame.width
        let lastCellMinX = floor(item.collectionViewWidth - cellWidth)
        let minX = floor(cellFrame.minX)
        let maxX = floor(cellFrame.maxX)
        
        let isLastVisibleCell = maxX >= item.collectionViewWidth
        let isLastVisibleCellButOne = minX < lastCellMinX && maxX > lastCellMinX
        
        let isFirstVisibleCell = minX <= 0
        let isNextAfterFirstVisibleCell = minX < cellWidth && maxX > cellWidth
        
        return Context(
            isFirstCell: selectedSegmentioIndex == 0,
            isLastCell: selectedSegmentioIndex == segmentioItems.count - 1,
            isLastOrPrelastVisibleCell: isLastVisibleCell || isLastVisibleCellButOne,
            isFirstOrSecondVisibleCell: isFirstVisibleCell || isNextAfterFirstVisibleCell,
            isFirstIndex: selectedSegmentioIndex > 0
        )
    }
    
    // MARK: - Item in superview
    
    fileprivate func itemInSuperview(ratio: CGFloat = 1) -> ItemInSuperview {
        var collectionViewWidth: CGFloat = 0
        var cellWidth: CGFloat = 0
        var cellRect = CGRect.zero
        var shapeLayerWidth: CGFloat = 0
        
        if let collectionView = segmentioCollectionView, selectedSegmentioIndex != -1 {
            collectionViewWidth = collectionView.frame.width
            cellWidth = segmentWidth(for: IndexPath(row: selectedSegmentioIndex, section: 0))
            var x: CGFloat = 0
            
            switch segmentioOptions.segmentPosition {
            case .fixed, .fixedByLargest:
                x = floor(CGFloat(selectedSegmentioIndex) * cellWidth - collectionView.contentOffset.x)
                
            case .dynamic:
                for i in 0..<selectedSegmentioIndex {
                    x += segmentWidth(for: IndexPath(item: i, section: 0))
                }
                
                x -= collectionView.contentOffset.x
            }
            
            cellRect = CGRect(
                x: x,
                y: 0,
                width: cellWidth,
                height: collectionView.frame.height
            )
            
            shapeLayerWidth = floor(cellWidth * ratio)
        }
        
        return ItemInSuperview(
            collectionViewWidth: collectionViewWidth,
            cellFrameInSuperview: cellRect,
            shapeLayerWidth: shapeLayerWidth,
            startX: floor(cellRect.midX - (shapeLayerWidth / 2)),
            endX: floor(cellRect.midX + (shapeLayerWidth / 2))
        )
    }
    
    // MARK: - Segment Width
    
    fileprivate func segmentWidth(for indexPath: IndexPath) -> CGFloat {
        guard let collectionView = segmentioCollectionView else {
            return 0
        }
        
        var width: CGFloat = 0
        let collectionViewWidth = collectionView.frame.width
        
        switch segmentioOptions.segmentPosition {
        case .fixed(let maxVisibleItems):
            let maxItems = maxVisibleItems > segmentioItems.count ? segmentioItems.count : maxVisibleItems
            width = maxItems == 0 ? 0 : floor(collectionViewWidth / CGFloat(maxItems))
            
        case .fixedByLargest:
            var biggestWidth: CGFloat = 0
            var dynamicWidth: CGFloat = 0
            for item in segmentioItems {
                let width = Segmentio.intrinsicWidth(for: item, style: styleFor(item: item), selected: selectedSegmentioIndex == indexPath.row)
                if width > biggestWidth {
                    biggestWidth = width
                }
                dynamicWidth += biggestWidth
            }
            biggestWidth = dynamicWidth > collectionViewWidth ? biggestWidth
                : biggestWidth + ((collectionViewWidth - dynamicWidth) / CGFloat(segmentioItems.count))
            return biggestWidth
            
        case .dynamic:
            guard !segmentioItems.isEmpty else {
                break
            }
            
            var dynamicWidth: CGFloat = 0
            for item in segmentioItems {
                let selected = selectedSegmentioIndex == segmentioItems.index(of: item)
                dynamicWidth += Segmentio.intrinsicWidth(for: item, style: styleFor(item: item), selected: selected)
            }
            let itemWidth = Segmentio.intrinsicWidth(for: segmentioItems[indexPath.row], style: styleFor(item: segmentioItems[indexPath.row]), selected: selectedSegmentioIndex == indexPath.row)
//            width = itemWidth
            let insets = (segmentioCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset
            let freeSpacePerItem = ((collectionViewWidth - dynamicWidth - insets.left - insets.right) / CGFloat(segmentioItems.count))
            width = dynamicWidth + insets.left + insets.right > collectionViewWidth ? itemWidth
                : itemWidth + freeSpacePerItem
        }
        
        return width
    }
    
    fileprivate static func intrinsicWidth(for item: SegmentioItem, style: SegmentioStyle, selected: Bool) -> CGFloat {
        var itemWidth: CGFloat = 0
        switch style {
        case .imageLabelToggle:
            if selected {
                itemWidth = style.isWithText() ? item.intrinsicWidth : (item.image?.size.width ?? 0)
            } else {
                itemWidth = (item.image?.size.width ?? 0)
            }
        default:
            itemWidth = style.isWithText() ? item.intrinsicWidth : (item.image?.size.width ?? 0)
        }
        itemWidth += style.layoutMargins
        
        if style == .imageAfterLabel || style == .imageBeforeLabel {
            itemWidth += SegmentioCell.segmentTitleLabelHeight
        }
        
        return itemWidth
    }
    
    // MARK: - Indicator point Y
    
    fileprivate func indicatorPointY() -> CGFloat {
        var indicatorPointY: CGFloat = 0
        
        guard let indicatorOptions = segmentioOptions.indicatorOptions else {
            return indicatorPointY
        }
        
        switch indicatorOptions.type {
        case .top:
            indicatorPointY = (indicatorOptions.height / 2)
        case .bottom:
            indicatorPointY = frame.height - (indicatorOptions.height / 2)
        }
        
        guard let horizontalSeparatorOptions = segmentioOptions.horizontalSeparatorOptions else {
            return indicatorPointY
        }
        
        let separatorHeight = horizontalSeparatorOptions.height
        let isIndicatorTop = indicatorOptions.type == .top
        
        switch horizontalSeparatorOptions.type {
        case .none:
            break
        case .top:
            indicatorPointY = isIndicatorTop ? indicatorPointY + separatorHeight : indicatorPointY
        case .bottom:
            indicatorPointY = isIndicatorTop ? indicatorPointY : indicatorPointY - separatorHeight
        case .topAndBottom:
            indicatorPointY = isIndicatorTop ? indicatorPointY + separatorHeight : indicatorPointY - separatorHeight
        }
        
        return indicatorPointY
    }
}

// MARK: - UICollectionViewDataSource

extension Segmentio: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return segmentioItems.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let content = segmentioItems[indexPath.row]

        let reuseIdentifier = styleFor(item: content).rawValue
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath) as! SegmentioCell
        
//        print("Cell at \(indexPath) SELECTED = \(cell.cellSelected))")
        cell.configure(
            content: content,
            style: SegmentioStyle(rawValue: reuseIdentifier)!,
            options: segmentioOptions,
            isLastCell: indexPath.row == segmentioItems.count - 1,
            wasSelected: indexPath.row == latestSelectedSegmentioIndex
        )
//        print("Cell at \(indexPath) SELECTED = \(cell.cellSelected))")

        
        let selected = indexPath.row == selectedSegmentioIndex
//        print("Cell at \(indexPath) was SELECTED = \(cell.cellSelected))")
        cell.configure(
            selected:selected,
            selectedImage: content.selectedImage,
            image: content.image,
            isFirstCell: indexPath.row == 0,
            isLastCell: indexPath.row == segmentioItems.count - 1
        )
        
//        print("cell at \(indexPath) is selected = \(collectionView.cellForItem(at: indexPath)?.isSelected)")

        
//        cell.setNeedsUpdateConstraints()
//        cell.updateConstraintsIfNeeded()
        
//        let finalCellFrame = cell.frame
//        let translation = collectionView.panGestureRecognizer.translation(in: collectionView.superview)
//        if translation.x > 0 {
//            cell.frame = CGRect(origin: finalCellFrame.origin, size: CGSize(width: segmentWidth(for: indexPath), height: collectionView.frame.height))
//        } else {
//            cell.frame = CGRect(x: finalCellFrame.origin.x + 1000, y: -500, width: 0, height: 0)
//        }
//
//        UIView.animate(withDuration: 0.5) {
//            cell.frame = finalCellFrame
//        }
        
  
//        collectionView.performBatchUpdates({})

        
        
     
        
//        print("Cell at \(indexPath) NOW SELECTED = \(cell.cellSelected))")
        
        return cell
    }
    
    fileprivate func styleFor(item: SegmentioItem) -> SegmentioStyle {
        var style = segmentioStyle
        if item.image == nil {
            style = SegmentioStyle.onlyLabel
        } else if item.title == nil || item.title?.count == 0 {
            style = SegmentioStyle.onlyImage
        }
        return style
    }
    
}

// MARK: - UICollectionViewDelegate

extension Segmentio: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSegmentioIndex = indexPath.row
//        let cell = collectionView.cellForItem(at: indexPath)
//        UIView.transition(with: collectionView, duration: 0.5, options: .curveEaseOut, animations: {
//            cell?.frame = CGRect(origin: cell!.frame.origin, size:  CGSize(width: self.segmentWidth(for: indexPath), height: collectionView.frame.height))
//        }) { completed in
//
//        }
//        print("Item selected at \(indexPath)")
//        print("didSelectItemAt cell at \(indexPath) is selected = \(collectionView.cellForItem(at: indexPath)?.isSelected)")
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension Segmentio: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: segmentWidth(for: indexPath), height: collectionView.frame.height)
    }
    
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets.zero
//    }
}

// MARK: - UIScrollViewDelegate

extension Segmentio: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isPerformingScrollAnimation {
            return
        }
        
        if let options = segmentioOptions.indicatorOptions, let indicatorLayer = indicatorLayer {
            let item = itemInSuperview(ratio: options.ratio)
            moveShapeLayer(
                indicatorLayer,
                startPoint: CGPoint(x: item.startX, y: indicatorPointY()),
                endPoint: CGPoint(x: item.endX, y: indicatorPointY()),
                animated: false
            )
            
            if let gradientLayer = indicatorLayer.sublayers?[0] as? CAGradientLayer {
                moveGradientLayer(gradientLayer, startPoint: nil, endPoint: nil, animated: false)
            }
        }
        
        if let selectedLayer = selectedLayer {
            let item = itemInSuperview()
            moveShapeLayer(
                selectedLayer,
                startPoint: CGPoint(x: item.startX, y: bounds.midY),
                endPoint: CGPoint(x: item.endX, y: bounds.midY),
                animated: false
            )
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isCollectionViewScrolling = false
    }
    
}

extension Segmentio.Points {
    
    init(context: Segmentio.Context, item: Segmentio.ItemInSuperview, atIndex index: Int, allItems: [SegmentioItem],
         pointY: CGFloat, position: SegmentioPosition, style: SegmentioStyle) {
        let cellWidth = item.cellFrameInSuperview.width
        
        var startX = item.startX
        var endX = item.endX
        
        switch position {
        case .fixed(_), .fixedByLargest:
            if context.isFirstCell == false && context.isLastCell == false {
                if context.isLastOrPrelastVisibleCell == true {
                    let updatedStartX = item.collectionViewWidth - (cellWidth * 2)
                        + ((cellWidth - item.shapeLayerWidth) / 2)
                    startX = updatedStartX
                    let updatedEndX = updatedStartX + item.shapeLayerWidth
                    endX = updatedEndX
                }
                
                if context.isFirstOrSecondVisibleCell == true {
                    let updatedEndX = (cellWidth * 2) - ((cellWidth - item.shapeLayerWidth) / 2)
                    endX = updatedEndX
                    let updatedStartX = updatedEndX - item.shapeLayerWidth
                    startX = updatedStartX
                }
            }
            
            if context.isFirstCell == true {
                startX = (cellWidth - item.shapeLayerWidth) / 2
                startX = 0
                endX = startX + item.shapeLayerWidth
            }
            
            if context.isLastCell == true {
                startX = item.collectionViewWidth - cellWidth + (cellWidth - item.shapeLayerWidth) / 2
                endX = startX + item.shapeLayerWidth
            }
            
        case .dynamic:
            // If the collection content view is not completely visible...
            // We have to calculate the final position of the item
            let dynamicWidth = allItems.map { Segmentio.intrinsicWidth(for: $0, style: style, selected: false) }.reduce(0, +)
            
            if item.collectionViewWidth < dynamicWidth {
                startX = 0
                endX = 0
                var spaceBefore: CGFloat = 0
                var spaceAfter: CGFloat = 0
                var i = 0
                for item in allItems {
                    if i < index {
                        spaceBefore += Segmentio.intrinsicWidth(for: item, style: style, selected: false)
                    } else if i > index {
                        spaceAfter += Segmentio.intrinsicWidth(for: item, style: style, selected: false)
                    }
                    
                    i += 1
                }
                // Cell will try to position itself in the middle, unless it can't because
                // the collection view has reached the beginning or end
                if spaceBefore < (item.collectionViewWidth - cellWidth) / 2 {
                    startX = spaceBefore
                } else if spaceAfter < (item.collectionViewWidth - cellWidth) / 2 {
                    startX = item.collectionViewWidth - spaceAfter - item.cellFrameInSuperview.width
                } else {
                    startX = (item.collectionViewWidth / 2) - (cellWidth / 2 )
                }
                endX = startX + cellWidth
            }
        }
        
        startPoint = CGPoint(x: startX, y: pointY)
        endPoint = CGPoint(x: endX, y: pointY)
    }
    
}
