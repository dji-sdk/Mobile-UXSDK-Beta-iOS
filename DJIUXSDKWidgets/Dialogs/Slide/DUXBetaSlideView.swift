//
//  DUXBetaSlideView.swift
//  DJIUXSDKWidgets
//
//  MIT License
//  
//  Copyright © 2018-2020 DJI
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

/**
 * A custom slide view control.
 */
@objcMembers public class DUXBetaSlideView: UIView {
    static let kSpacing: CGFloat = 0.0
    static let kAlignment: CGFloat = 1.0
    static let kWidthPercent: CGFloat = 0.5
    static let kScrollThreshold: CGFloat = 0.6
    
    // MARK:- Public Properties
    
    /// The image used for the slider thumb icon.
    public var slideIconImage = UIImage.duxbeta_image(withAssetNamed: "Slider") {
        didSet {
            slideIcon.image = slideIconImage?.withRenderingMode(.alwaysTemplate)
        }
    }
    /// The image tint color used for the slider thumb icon for the normal state.
    public var slideIconTintColor = UIColor.white {
        didSet {
            slideIcon.tintColor = slideIconTintColor
        }
    }
    /// The image tint color used for the slider thumb icon for the selected state.
    public var slideIconSelectedTintColor = UIColor.white {
        didSet {
            slideIcon.tintColor = slideIconTintColor
        }
    }
    /// The image for the on state of the slide.
    public var slideOnImage = UIImage.duxbeta_image(withAssetNamed: "SlideOn") {
        didSet {
            slideOnImageView.image = slideOnImage?.withRenderingMode(.alwaysTemplate)
        }
    }
    /// The image tint color for the on state of the slide.
    public var slideOnTintColor = UIColor.duxbeta_success() {
        didSet {
            slideOnImageView.tintColor = slideOnTintColor
        }
    }
    /// The image for the off state of the slide.
    public var slideOffImage = UIImage.duxbeta_image(withAssetNamed: "SlideOff") {
        didSet {
            slideOffImageView.image = slideOffImage?.withRenderingMode(.alwaysTemplate)
        }
    }
    /// The image tint color for the off state of the slide.
    public var slideOffTintColor = UIColor.duxbeta_slideIconSelected() {
        didSet {
            slideOffImageView.tintColor = slideOffTintColor
        }
    }
    /// The text displayed into the label positioned in the slide off area.
    public var slideMessageText = "Slide to Take Off" {
        didSet {
            slideMessageLabel.text = slideMessageText
        }
    }
    /// The font for text displayed into the label positioned in the slide off area.
    public var slideMessageFont = UIFont.systemFont(ofSize: 12.0) {
        didSet {
            slideMessageLabel.font = slideMessageFont
        }
    }
    /// The text color displayed into the label positioned in the slide off area.
    public var slideMessageTextColor = UIColor.black {
        didSet {
            slideMessageLabel.textColor = slideMessageTextColor
        }
    }
    /// The image displayed in the slide off area.
    public var slideMessageImage = UIImage.duxbeta_image(withAssetNamed: "SliderChevron") {
        didSet {
            slideMessageImageView.image = slideMessageImage?.withRenderingMode(.alwaysTemplate)
        }
    }
    /// The tint color of the image displayed in the slide off area.
    public var slideMessageTintColor = UIColor.gray {
        didSet {
            slideMessageImageView.tintColor = slideMessageTintColor
        }
    }
    
    /// The callback invoked when the sliding action starts.
    public var onSlideStarted: (() -> ())?
    /// The callback invoked when the sliding action completes.
    public var onSlideCompleted: ((Bool) -> ())?
    
    // MARK:- Private Properties
    
    fileprivate var slideIcon: UIImageView!
    fileprivate var slideOnView: UIView!
    fileprivate var slideOnImageView: UIImageView!
    fileprivate var slideOffView: UIView!
    fileprivate var slideOffImageView: UIImageView!
    fileprivate var slideMessageLabel: UILabel!
    fileprivate var slideMessageImageView: UIImageView!
    
    fileprivate var minimSize = CGSize.zero
    fileprivate var slideOnSize = CGSize.zero
    fileprivate var slideIconStartX: CGFloat = 0.0
    fileprivate var slideIconDeltaX: CGFloat = 0.0 {
        didSet {
            UIView.animate(withDuration: 0.4) {
                self.slideIconCenterXConstraint?.constant = self.slideIconDeltaX
                self.setNeedsLayout()
            }
        }
    }
    fileprivate var slideIconInitialX: CGFloat { minimSize.width * Self.kWidthPercent - Self.kAlignment }
    fileprivate var slideIconCenterXConstraint: NSLayoutConstraint?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    fileprivate func setupUI() {
        clipsToBounds = true
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        slideOnView = UIView()
        slideOnView.translatesAutoresizingMaskIntoConstraints = false
        slideOnView.isOpaque = true
        slideOnView.clipsToBounds = true
        slideOnView.clearsContextBeforeDrawing = true
        slideOnView.backgroundColor = .clear
        
        if let size = slideOnImage?.size {
            slideOnSize = size
        }
        
        slideOnImageView = UIImageView(image: slideOnImage?.withRenderingMode(.alwaysTemplate))
        slideOnImageView.tintColor = slideOnTintColor
        slideOnImageView.clearsContextBeforeDrawing = true
        
        slideOnView.addSubview(slideOnImageView)
        
        if let size = slideIconImage?.size {
            minimSize = size
        }

        slideIcon = UIImageView(image: slideIconImage?.withRenderingMode(.alwaysTemplate))
        slideIcon.translatesAutoresizingMaskIntoConstraints = false
        slideIcon.tintColor = slideIconTintColor
        slideIcon.contentMode = .scaleAspectFit
        slideIcon.clearsContextBeforeDrawing = true
        slideIcon.backgroundColor = .clear
        slideIcon.isMultipleTouchEnabled = true
        slideIcon.isUserInteractionEnabled = true
        
        let panGestureRecongnizer = UIPanGestureRecognizer(target: self, action: #selector(onDrag(_:)))
        slideIcon.addGestureRecognizer(panGestureRecongnizer)
        
        slideOffView = UIView()
        slideOffView.translatesAutoresizingMaskIntoConstraints = false
        slideOffView.backgroundColor = .clear
        slideOffView.isOpaque = true
        slideOffView.clipsToBounds = true
        slideOffView.clearsContextBeforeDrawing = true
        
        slideOffImageView = UIImageView(image: slideOffImage?.withRenderingMode(.alwaysTemplate))
        slideOffImageView.tintColor = slideOffTintColor
        slideOffImageView.clearsContextBeforeDrawing = true
        
        slideMessageLabel = UILabel()
        slideMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        slideMessageLabel.text = slideMessageText
        slideMessageLabel.font = slideMessageFont
        slideMessageLabel.textColor = slideMessageTextColor
        slideMessageLabel.textAlignment = .right
        slideMessageLabel.numberOfLines = 1
        
        slideMessageImageView = UIImageView(image: slideMessageImage?.withRenderingMode(.alwaysTemplate))
        slideMessageImageView.translatesAutoresizingMaskIntoConstraints = false
        slideMessageImageView.tintColor = slideMessageTintColor
        slideMessageImageView.contentMode = .scaleAspectFit
        slideMessageImageView.clipsToBounds = true
        slideMessageImageView.clearsContextBeforeDrawing = true
        
        slideOffView.addSubview(slideOffImageView)
        slideOffView.addSubview(slideMessageLabel)
        slideOffView.addSubview(slideMessageImageView)
        
        addSubview(slideOffView)
        addSubview(slideOnView)
        addSubview(slideIcon)
        
        NSLayoutConstraint.activate([
            slideOnView.topAnchor.constraint(equalTo: topAnchor, constant: Self.kAlignment),
            slideOnView.bottomAnchor.constraint(equalTo: bottomAnchor),
            slideOnView.leftAnchor.constraint(equalTo: leftAnchor),
            slideOnView.rightAnchor.constraint(equalTo: slideIcon.centerXAnchor),
            slideOffView.topAnchor.constraint(equalTo: topAnchor, constant: Self.kAlignment),
            slideOffView.bottomAnchor.constraint(equalTo: bottomAnchor),
            slideOffView.leftAnchor.constraint(equalTo: leftAnchor),
            slideOffView.rightAnchor.constraint(equalTo: rightAnchor),
            slideMessageLabel.centerYAnchor.constraint(equalTo: slideOffView.centerYAnchor),
            slideMessageLabel.rightAnchor.constraint(equalTo: slideMessageImageView.leftAnchor, constant: -Self.kSpacing),
            slideMessageImageView.centerYAnchor.constraint(equalTo: slideOffView.centerYAnchor),
            slideMessageImageView.rightAnchor.constraint(equalTo: slideOffView.rightAnchor, constant: -Self.kSpacing),
            slideIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(equalToConstant: minimSize.height),
            widthAnchor.constraint(equalToConstant: slideOnSize.width)
        ])
        
        slideIconDeltaX = slideIconInitialX
        slideIconCenterXConstraint = slideIcon.centerXAnchor.constraint(equalTo: leadingAnchor, constant: slideIconDeltaX)
        slideIconCenterXConstraint?.isActive = true
    }
    
    @objc func onDrag(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            slideIconStartX = slideIcon.center.x
            slideIcon.tintColor = slideIconSelectedTintColor
            
            // Notify dragging start
            onSlideStarted?()
        }
        
        let dPoint = sender.translation(in: self)
        slideIconDeltaX = guarded(value: slideIconStartX + dPoint.x,
                                  byMin: slideIcon.frame.width * Self.kWidthPercent,
                                  andMax: frame.width - slideIcon.frame.width * Self.kWidthPercent)
        
        if sender.state == .ended {
            slideIcon.tintColor = slideIconTintColor
            if slideIconDeltaX > frame.width * Self.kScrollThreshold {
                slideIconDeltaX = frame.width - minimSize.width * Self.kWidthPercent
                
                // Trigger callback with a successful completion
                onSlideCompleted?(true)
            } else {
                slideIconDeltaX = slideIconInitialX
                
                // Trigger callback with an unsuccessful completion
                onSlideCompleted?(false)
            }
        }
    }
    
    fileprivate func guarded(value: CGFloat, byMin min: CGFloat, andMax max: CGFloat) -> CGFloat {
        if value < min {
            return min
        } else if value > max {
            return max
        }
        return value
    }
}
