import Foundation

private let BadgeCounterMaxValue = 99
private let BadgeCounterOverMaxValueText = "99+"
private let standardSizedNibName = "BadgeWithCounterViewStandardSized"
private let bigSizedNibName = "BadgeWithCounterViewBigSized"

enum BadgeSize {
    
    case standard
    case big
    
}

class BadgeWithCounterView: UIView {
    
    @IBOutlet fileprivate weak var counterValueLabel: UILabel!
    @IBOutlet fileprivate weak var backgroundImageView: UIImageView!
    private var areSubviewsLayouted = false
    private var gradientColors: [UIColor]?
    
    class func instanceFromNib(size: BadgeSize) -> BadgeWithCounterView {
        let nibName = nibNameForSize(size)
        let podBundle = Bundle(for: self.classForCoder())
        
        if let bundleURL = podBundle.url(forResource: "Segmentio", withExtension: "bundle"),
            let bundle = Bundle(url: bundleURL) {
            return UINib(nibName: nibName, bundle: bundle)
                .instantiate(withOwner: nil, options: nil)[0] as! BadgeWithCounterView
        }
        return BadgeWithCounterView(frame: .zero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if areSubviewsLayouted == false {
            print("layoutSubviews")
            print("backgroundImageView frame - \(backgroundImageView.frame)")
            if gradientColors != nil {
                let gradient = CAGradientLayer()
                gradient.frame = backgroundImageView.bounds
                gradient.colors = gradientColors!.map({ $0.cgColor })
                gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
                
                let testLayer = CALayer()
                testLayer.frame = backgroundImageView.bounds
                testLayer.backgroundColor = gradientColors![1].cgColor
                
                let maskLayer = CAShapeLayer()
                maskLayer.path = UIBezierPath(roundedRect: backgroundImageView.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: backgroundImageView.bounds.height / 2.0, height: backgroundImageView.bounds.height / 2.0)).cgPath
                gradient.mask = maskLayer
                
                backgroundImageView.layer.insertSublayer(gradient, at: 0)
                areSubviewsLayouted = true
            }
        }
        
    }

    func setBadgeCounterValue(_ counterValue: Int) {
        var counterText: String!
        if counterValue > BadgeCounterMaxValue {
            counterText = BadgeCounterOverMaxValueText
        } else {
            counterText = String(counterValue)
        }
        counterValueLabel.text = counterText
    }
    
    func setBadgeBackgroundColor(_ color: UIColor) {
        backgroundImageView.backgroundColor = color
        if let gradientLayer = backgroundImageView.layer.sublayers?[0] as? CAGradientLayer {
            gradientLayer.removeFromSuperlayer()
        }
    }
    
    func setBadgeBackgroundColors(_ gradientColors: [UIColor]) {
        self.gradientColors = gradientColors
        
        //backgroundImageView.backgroundColor = gradientColors[0]
    }
    
    fileprivate class func nibNameForSize(_ size: BadgeSize) -> String {
        return size == .standard ? standardSizedNibName : bigSizedNibName
    }
}
