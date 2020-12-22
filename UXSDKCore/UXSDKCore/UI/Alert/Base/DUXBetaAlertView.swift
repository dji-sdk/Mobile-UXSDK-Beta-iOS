//
//  DUXBetaAlertView.swift
//  UXSDKCore
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

public typealias DUXBetaAlertActionCompletionBlock = () -> Void

/**
 * Enum that defines the animation types
 * which will be used when showing or closing
 * an alert view instance.
 */
@objc public enum DUXBetaAlertViewAnimation: Int {
    case standard, fade
}

/**
 * Enum that defines the possible orientations
 * supported by the alert view.
 */
@objc public enum DUXBetaAlertViewLayout: Int {
    case horizontal, vertical
}

/**
 * An object that displays an alert message to the user.
 * Use this class to configure alerts with the title and message that you want to display and the actions to choose from.
*/
@objcMembers public class DUXBetaAlertView: UIViewController {
    
    /**
     * Struct that encapsulates all the customization properties
     * that can be set on an alert view instance.
    */
    @objc(DUXBetaAlertViewAppearance) public class DUXBetaAlertViewAppearance: NSObject {
        
        /// The tint color for the image icon.
        @objc public var imageTintColor: UIColor?
        /// The font to be used for the title text.
        @objc public var titleFont: UIFont? = .boldSystemFont(ofSize: 17.0)
        /// The color to be used for the title text.
        @objc public var titleColor: UIColor? = .uxsdk_white()
        /// The alignment to be used for the title text.
        @objc public var titleTextAlignment: NSTextAlignment = .left
        /// The color to be used for the title background.
        @objc public var titleBackgroundColor: UIColor? = .uxsdk_clear()
        /// The font to be used for the details.
        @objc public var messageFont: UIFont? = .systemFont(ofSize: 15.0)
        /// The color to be used for the details text.
        @objc public var messageColor: UIColor? = .uxsdk_white()
        /// The alignment to be used for the details text.
        @objc public var messageTextAlignment: NSTextAlignment = .left
        /// The color to be used for the details background.
        @objc public var messageBackgroundColor: UIColor? = .uxsdk_clear()
        /// The spacing between the message text and any custom view, if one is available.
        @objc public var bodyLayoutSpacing: CGFloat = 2.0
        /// The color to be used for the alert mask view container.
        @objc public var maskViewColor: UIColor? = .uxsdk_blackAlpha40()
        /// The border corner radius for the alert view container.
        @objc public var borderCornerRadius: CGFloat = 0.0
        /// The border width for the alert view container.
        @objc public var borderWidth: CGFloat = 0.0
        /// The border color for the alert view container.
        @objc public var borderColor: UIColor?
        /// The background color for the alert view container.
        @objc public var backgroundColor: UIColor = .uxsdk_darkGrayWhite25()
        /// The top and bottom vertical offset of the view.
        @objc public var verticalOffset: CGFloat = 20.0
        /// The left and right horizontal offsets of the view.
        @objc public var horizaontalOffset: CGFloat = 10.0
        /// Show/hide animation type.
        @objc public var animationType: DUXBetaAlertViewAnimation = .standard
        /// Show/hide animation duration in seconds.
        @objc public var animationDuration: Double = 0.3
        /// The layout type of the header components: the image icon and the title.
        @objc public var headerLayoutType: DUXBetaAlertViewLayout = .horizontal
        /// The spacing between the header components: the image icon and the title.
        @objc public var headerLayoutSpacing: CGFloat = 2.0
        /// The layout type of the alerts actions.
        @objc public var actionsLayoutType: DUXBetaAlertViewLayout = .horizontal
        /// The spacing between the action buttons.
        @objc public var actionLayoutSpacing: CGFloat = 2.0
        /// The spacing between the header, body and action containers.
        @objc public var alertLayoutSpacing: CGFloat = 10.0
        /// The boolean value that controls if the alert view
        /// should close when tapping outside the alert.
        public var shouldDismissOnTap: Bool? = true
    }
    /// The image to be displayed into the left side of the header.
    public var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    /// The text to be displayed as a title in the header.
    public var titleText: String? {
        didSet {
            titleLabel.text = titleText
        }
    }
    /// The text to be displayed in the details section.
    public var message: String? {
        didSet {
            messageLabel.text = message
        }
    }
    /// The appearance structure that encloses all the customization properties.
    public var appearance = DUXBetaAlertViewAppearance() {
        didSet {
            applyAppearance()
        }
    }
    /// Indicates if the alert view is visible.
    public var isVisible: Bool = false
    /// Indicates if the alert view shoud hide when tapping outside the alert.
    public var shouldHideOnTap: Bool = false
    /// Customizable view that will be added under the message.
    public var customizedView: UIView?
    /// The X center constraint of the alert.
    public var centerXConstraint: NSLayoutConstraint?
    /// The Y center constraint of the alert.
    public var centerYConstraint: NSLayoutConstraint?
    
    /// The stack controller that keeps track of the visible alerts currently displayed on screen.
    public let stackController = DUXBetaAlertStackController.defaultStack
    
    /// The layout controller responsible for managing the position of the alert.
    public let layoutController = DUXBetaAlertLayoutController()

    /// The mask view placed under the current alert view.
    public var maskView = DUXBetaAlertViewMask(frame: UIScreen.main.bounds)
    /// The callback invoked when the alert is dismissed by tapping outside its content.
    public var dissmissCompletion: (() -> ())?
    
    // MARK: - Private properties
    
    fileprivate var imageView = UIImageView()
    fileprivate var titleLabel = UILabel()
    fileprivate var messageLabel = UILabel()
    fileprivate var actionButtons = [DUXBetaAlertAction]()
    
    fileprivate var scrollView = UIScrollView()
    fileprivate var stackView = UIStackView()
    fileprivate var headerStackView = UIStackView()
    fileprivate var bodyStackView = UIStackView()
    fileprivate var actionsStackView = UIStackView()
    
    fileprivate var topConstraint: NSLayoutConstraint?
    fileprivate var leadingConstraint: NSLayoutConstraint?
    fileprivate var traillingConstraint: NSLayoutConstraint?
    fileprivate var bottomConstraint: NSLayoutConstraint?
    
    fileprivate var heightConstraint: NSLayoutConstraint?
    
    // MARK: - Private static constants
    
    fileprivate static let kPopupAnimationKey = "DUXBetaAlertView_kPopupAnimationKey"
    fileprivate static let kAlphaAnimationKey = "DUXBetaAlertView_kAlphaAnimationKey"
    
    // MARK: - Private computed properties
    
    fileprivate var defaultWidth: CGFloat {
        return UIDevice.duxbeta_logicWidthLandscape * UIDevice.duxbeta_widthScale
    }
    
    fileprivate var defaultHeight: CGFloat {
        return UIDevice.duxbeta_logicHeightLandscape
    }
    
    // MARK: - Initialization Mehods

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        applyAppearance()
        maskView.alertView = self
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateLayout()
    }
    
    // MARK: - Public Mehods
    
    /**
     * This method attaches an action object to the alert.
     *
     * - Parameters:
     *      - action: The action object to disaplay as part of the alert. Actions are displayed as buttons.
     */
    public func add(_ action: DUXBetaAlertAction) {
        action.addTarget(self, action: #selector(buttonTapped(action:)), for: .touchUpInside)
        actionButtons.append(action)
        actionsStackView.addArrangedSubview(action)
    }
    
    /**
     * This method shows the alert object in the view hierarchy.
     *
     * - Parameters:
     *      - completion: The callback method when the show action is done.
     */
    public func show(withCompletion completion: (() -> ())? = nil) {
        guard let topViewController = topMostViewController else {
            completion?()
            return
        }
        guard canShowOnTop(of: topViewController) else {
            completion?()
            return
        }
        guard !stackController.contains(alertView: self) else {
            completion?()
            return
        }
        
        if stackController.contains(alertView: self) {
            completion?()
        } else {
            internalShow(withCompletion: completion)
        }
    }
    
    /**
     * This method verifies if the current alert can be displayed over the given view controller.
     *
     * - Parameters:
     *      - viewController: The viewcontroller on top of which the alert needs to be shown.
     *
     * - Returns: A boolean value indicating if the current alert can be displayed on top of the given view controller.
     */
    public func canShowOnTop(of viewController: UIViewController) -> Bool {
        return !(viewController is UIAlertController)
    }
    
    /**
     * This method hides the alert instance.
     *
     * - Parameters:
     *      - completion: The callback method when the close action is done.
     */
    public func close(withCompletion completion: (() -> ())? = nil) {
        if isVisible {
            internalClose(withCompletion: completion)
        }
    }
    
    // MARK: - Module Methods
    
    func setupUI() {
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = titleText
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        
        messageLabel.text = message
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 0
        messageLabel.sizeToFit()

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        
        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.distribution = .fill
        
        bodyStackView.axis = .vertical
        bodyStackView.alignment = .fill
        bodyStackView.distribution = .fill
        bodyStackView.setContentHuggingPriority(.defaultLow, for: .vertical)
        bodyStackView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        actionsStackView.alignment = .center
        actionsStackView.distribution = .fillProportionally
        actionsStackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        actionsStackView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        headerStackView.addArrangedSubview(imageView)
        headerStackView.addArrangedSubview(titleLabel)
        
        let imageSize = imageView.image?.size ?? .zero
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: headerStackView.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: imageSize.height),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: appearance.headerLayoutSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerStackView.centerYAnchor)
        ])
        
        bodyStackView.addArrangedSubview(messageLabel)
        
        // Insert the custom view if available
        if let v = customizedView {
            bodyStackView.addArrangedSubview(v)
        }
        
        stackView.addArrangedSubview(headerStackView)
        stackView.addArrangedSubview(bodyStackView)
        stackView.addArrangedSubview(actionsStackView)
        
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
                
        topConstraint = scrollView.topAnchor.constraint(equalTo: view.topAnchor)
        leadingConstraint = scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        traillingConstraint = scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        bottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        heightConstraint = view.heightAnchor.constraint(equalToConstant: defaultHeight)
        
        guard let _ = topConstraint, let _ = leadingConstraint, let _ = traillingConstraint, let _ = bottomConstraint else { return }
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: defaultWidth),
            heightConstraint!,
            
            topConstraint!,
            leadingConstraint!,
            traillingConstraint!,
            bottomConstraint!,
            
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
    
    fileprivate func updateLayout() {
        //Update view height based on stackview frame
        let contentHeight = stackView.frame.height + 2 * appearance.verticalOffset
        let actualheight = contentHeight < defaultHeight ? contentHeight : defaultHeight
        
        heightConstraint?.isActive = false
        heightConstraint = view.heightAnchor.constraint(equalToConstant: actualheight)
        heightConstraint?.isActive = true
    }

    // MARK:- Private Methods
    
    fileprivate func applyAppearance() {
        // Update container properties
        view.layer.borderWidth = appearance.borderWidth
        view.layer.cornerRadius = appearance.borderCornerRadius
        view.layer.borderColor = appearance.borderColor?.cgColor
        view.backgroundColor = appearance.backgroundColor
        
        // Update title label properties
        imageView.tintColor = appearance.imageTintColor
        titleLabel.font = appearance.titleFont
        titleLabel.textColor = appearance.titleColor
        titleLabel.textAlignment = appearance.titleTextAlignment
        titleLabel.backgroundColor = appearance.titleBackgroundColor
        
        // Update message label properties
        messageLabel.font = appearance.messageFont
        messageLabel.textColor = appearance.messageColor
        messageLabel.textAlignment = appearance.messageTextAlignment
        messageLabel.backgroundColor = appearance.messageBackgroundColor
        
        // Update DUXBetaAlertViewMask background color
        maskView.maskColor = appearance.maskViewColor
        maskView.shouldDismissAlertOnTap = appearance.shouldDismissOnTap
        
        // Update spacing used by all the stacks views
        stackView.spacing = appearance.alertLayoutSpacing
        headerStackView.spacing = appearance.headerLayoutSpacing
        bodyStackView.spacing = appearance.bodyLayoutSpacing
        actionsStackView.spacing = appearance.actionLayoutSpacing
        
        // Update stack orientation
        headerStackView.axis = appearance.headerLayoutType == .horizontal ? .horizontal : .vertical
        actionsStackView.axis = appearance.actionsLayoutType == .horizontal ? .horizontal : .vertical
        
        // Adjust margins
        topConstraint?.constant = appearance.verticalOffset
        leadingConstraint?.constant = appearance.horizaontalOffset
        traillingConstraint?.constant = -appearance.horizaontalOffset
        bottomConstraint?.constant = -appearance.verticalOffset
    }
    
    fileprivate func internalShow(withCompletion completion: (() -> ())? = nil) {
        view.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        view.alpha = 1.0
        
        var animationObject: CABasicAnimation?
        switch appearance.animationType {
        case .standard:
            animationObject = CABasicAnimation(keyPath: "transform")
            animationObject?.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(0.1, 0.1, 0.1))
            animationObject?.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0))
            animationObject?.duration = appearance.animationDuration
        case .fade:
            animationObject = CABasicAnimation(keyPath: "opacity")
            animationObject?.fromValue = NSNumber(0)
            animationObject?.toValue = NSNumber(1)
            animationObject?.duration = appearance.animationDuration
        default:
            break
        }
        
        if let keyView = UIApplication.shared.keyWindow, keyView != view.superview {
            view.removeFromSuperview()
            keyView.addSubview(maskView)
            keyView.addSubview(view)
            
            // Dispatch position control to the layout instance
            layoutController.layout(alertView: self, inView: keyView)
        }
        
        isVisible = true
        
        view.layer.removeAllAnimations()
        maskView.removeAnimations()
        
        if let animation = animationObject {
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = NSNumber(0)
            opacityAnimation.toValue = NSNumber(1)
            opacityAnimation.duration = appearance.animationDuration
            
            CATransaction.begin()
            CATransaction.setCompletionBlock { completion?() }
            view.layer.add(animation, forKey: Self.kPopupAnimationKey)
            view.layer.add(opacityAnimation, forKey: Self.kAlphaAnimationKey)
            maskView.addShowAnimation()
            CATransaction.commit()
            
        } else {
            completion?()
        }
        
        stackController.push(alertView: self)
    }
    
    fileprivate func internalClose(withCompletion completion: (() -> ())? = nil) {
        switch appearance.animationType {
        case .standard:
            UIView.animate(withDuration: appearance.animationDuration,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
                self.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.maskView.alpha = 0
            }) { [weak self] (completed) in
                self?.view.removeFromSuperview()
                self?.maskView.removeFromSuperview()
                completion?()
            }
        case .fade:
            UIView.animate(withDuration: appearance.animationDuration,
               animations: {
                self.view.alpha = 0
                self.maskView.alpha = 0
            }) { [weak self] (completed) in
                self?.view.removeFromSuperview()
                self?.maskView.removeFromSuperview()
                completion?()
            }
        default:
            view.removeFromSuperview()
            maskView.removeFromSuperview()
            completion?()
            break
        }
        
        isVisible = false
        stackController.pop()
    }
    
    @IBAction func buttonTapped(action: DUXBetaAlertAction) {
        switch action.actionType {
        case .closure:
            action.action?()
        case .selector:
            guard let selector = action.selector else { return }
            UIControl().sendAction(selector, to: action.target, for: nil)
        default:
            break
        }
        close()
    }
}

/**
 * Enum that defines how the alert action callbacks
 * are being handled when the button is tapped.
 */
@objc public enum DUXBetaAlertActionType: Int {
    case none, selector, closure
}

/**
 * Class that encapsulates all the customization properties
 * that can be set on an alert view action object.
*/
@objc public class DUXBetaAlertActionAppearance: NSObject {
    /// The font to be used for the button text.
    @objc public var actionFont = UIFont.systemFont(ofSize: 17.0)
    /// The color to be used for the button text.
    @objc public var actionColor = UIColor.uxsdk_selectedBlue()
    /// The border color to be used for the button.
    @objc public var actionBorderColor: UIColor?
    /// The border width to be used for the button.
    @objc public var actionBorderWidth: CGFloat = 0
    /// The corner radius to be used for the button.
    @objc public var actionCornerRadius: CGFloat = 0
    /// The background color to be used for the button.
    @objc public var actionBackgroundColor: UIColor?
    /// The background image to be used for the button in normal state.
    @objc public var actionNormalBackgroundImage: UIImage?
    /// The background image to be used for the button in selected state.
    @objc public var actionSelectedBackgroundImage: UIImage?
}

/**
 The action object to display as part of the alert.
 Actions are displayed as buttons in the alert.
 The action object provides the button text and the action to be
 performed when that button is tapped, along with customization properties.
 */
@objcMembers public class DUXBetaAlertAction: UIButton {
    /// The style that is applied to the action.
    @objc public var style: UIAlertAction.Style = .default
    /// The appearance object that encloses all the customization properties.
    @objc public var appearance = DUXBetaAlertActionAppearance() {
        didSet {
            applyAppearance()
        }
    }
    /// The completion block that gets called on button tap.
    public var action: DUXBetaAlertActionCompletionBlock?
    /// The action type applied to the alert action.
    public var actionType = DUXBetaAlertActionType.none
    /// The title to be used as the button title.
    public var actionTitle: String?
    /// The target instance that gets used on button tap.
    public var target: AnyObject?
    /// The selector that gets called on button tap.
    public var selector: Selector?

    public static func action(actionTitle: String?, style: UIAlertAction.Style, actionType: DUXBetaAlertActionType, target: AnyObject? = nil, selector: Selector? = nil,  completionAction: DUXBetaAlertActionCompletionBlock? = nil) -> DUXBetaAlertAction {
        let action = DUXBetaAlertAction()
        action.style = style
        action.target = target
        action.selector = selector
        action.actionType = actionType
        action.actionTitle = actionTitle
        action.action = completionAction
        
        action.applyAppearance()
        return action
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        applyAppearance()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        applyAppearance()
    }
    
    override public init(frame:CGRect) {
        super.init(frame:frame)
        applyAppearance()
    }
    
    fileprivate func applyAppearance() {
        setTitle(actionTitle, for: .normal)
        titleLabel?.font = appearance.actionFont
        setTitleColor(appearance.actionColor, for: .normal)
        titleLabel?.backgroundColor = appearance.actionBackgroundColor
        layer.cornerRadius = appearance.actionCornerRadius
        layer.borderWidth = appearance.actionBorderWidth
        layer.borderColor = appearance.actionBorderColor?.cgColor
        setImage(appearance.actionNormalBackgroundImage, for: .normal)
        setImage(appearance.actionSelectedBackgroundImage, for: .selected)
    }
}
