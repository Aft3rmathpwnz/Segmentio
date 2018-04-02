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
        let gradient = CAGradientLayer()
        gradient.frame = backgroundImageView.bounds
        gradient.colors = gradientColors
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        backgroundImageView.layer.insertSublayer(gradient, at: 0)
    }
    
    fileprivate class func nibNameForSize(_ size: BadgeSize) -> String {
        return size == .standard ? standardSizedNibName : bigSizedNibName
    }
}
