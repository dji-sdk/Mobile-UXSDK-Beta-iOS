//
//  DUXBetaBaseTelemetryWidget.swift
//  DJIUXSDKWidgets
//
//  MIT License
//  
//  Copyright © 2020 DJI
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

import Foundation

/**
 * Enum that defines the type of the widget.
 */
@objc public enum DUXBetaBaseTelemetryType: UInt {
    /**
     * The type represents
     * | LABEL | VALUE | UNIT |
     */
    case Text
    
    /**
    * The type represents
    * | IMAGE | LABEL | VALUE | UNIT |
    */
    case TextImageLeft
    
    /**
    * The type represents
    * | LABEL | VALUE | UNIT | IMAGE |
    */
    case TextImageRight
}

/**
 * Base class for the telemetry widgets.
 */
@objcMembers open class DUXBetaBaseTelemetryWidget: DUXBetaBaseWidget {
    /// The text color of the value in an normal state.
    public var normalValueColor = UIColor.uxsdk_white()
    /// The text color of the value in an error state.
    public var errorValueColor = UIColor.uxsdk_errorDanger()
    /// The topMargin for insetting the content
    public var topMargin: CGFloat = 1.0 {
        didSet {
            updatetMarginConstraints(top: true)
        }
    }
    /// The bottomMargin for insetting the content
    public var bottomMargin: CGFloat = 1.0 {
        didSet {
            updatetMarginConstraints(bottom: true)
        }
    }
    /// The leftMargin for insetting the content
    public var leftMargin: CGFloat = 1.0 {
        didSet {
            updatetMarginConstraints(left: true)
        }
    }
    /// The rightMargin for insetting the content
    public var rightMargin: CGFloat = 1.0 {
        didSet {
            updatetMarginConstraints(right: true)
        }
    }
    /// The space between the elements.
    dynamic public var spacing: CGFloat = 2.0 {
        didSet {
            stackview.spacing = spacing
        }
    }
    /// The type of the layout.
    dynamic public var type: DUXBetaBaseTelemetryType = .TextImageLeft {
        didSet {
            updateType()
        }
    }
    /// The image of the icon.
    dynamic public var image: UIImage? = .duxbeta_image(withAssetNamed: "UpArrow", for: DUXBetaBaseTelemetryWidget.self) {
        didSet {
            updateImage()
        }
    }
    /// The tint color of the icon.
    dynamic public var imageTintColor: UIColor = .uxsdk_whiteAlpha60() {
        didSet {
            imageview.tintColor = imageTintColor
        }
    }
    /// The background color of the icon.
    dynamic public var imageBackgroundColor: UIColor = .uxsdk_clear() {
        didSet {
            imageview.backgroundColor = imageBackgroundColor
        }
    }
    /// The visibility of the icon.
    dynamic public var imageVisibility: Bool = true {
        didSet {
            imageview.isHidden = !imageVisibility
        }
    }
    /// The string value of the label.
    dynamic public var labelText: String = "" {
        didSet {
            label.text = labelText
        }
    }
    /// The font of the label.
    dynamic public var labelFont: UIFont = .systemFont(ofSize: kFontSize) {
        didSet {
            label.font = labelFont
        }
    }
    /// The text color of the label.
    dynamic public var labelTextColor: UIColor = .uxsdk_whiteAlpha60() {
        didSet {
            label.textColor = labelTextColor
        }
    }
    /// The background color of the label.
    dynamic public var labelBackgroundColor: UIColor = .uxsdk_clear() {
        didSet {
            label.backgroundColor = labelBackgroundColor
        }
    }
    /// The visibility of the label.
    dynamic public var labelVisibility: Bool = true {
        didSet {
            label.isHidden = !labelVisibility
        }
    }
    /// The string value of the value.
    dynamic public var valueText: String = "" {
        didSet {
            value.text = valueText
            updateValueMinWidth()
            view.setNeedsLayout()
        }
    }
    /// The alignment of the value.
    dynamic public var valueAlignment: NSTextAlignment = .center {
        didSet {
            value.textAlignment = valueAlignment
        }
    }
    /// The font of the value.
    dynamic public var valueFont: UIFont = .systemFont(ofSize: kFontSize) {
        didSet {
            value.font = valueFont
            valueMinWidth = computeValueMinWidth(for: valueTextMask)
        }
    }
    /// The text color of the value.
    dynamic public var valueTextColor: UIColor = .uxsdk_white() {
        didSet {
            value.textColor = valueTextColor
        }
    }
    /// The background color of the value.
    dynamic public var valueBackgroundColor: UIColor = .uxsdk_clear() {
        didSet {
            value.backgroundColor = valueBackgroundColor
        }
    }
    /// The visibility of the value.
    dynamic public var valueVisibility: Bool = true {
        didSet {
            value.isHidden = !valueVisibility
        }
    }
    /// The string value of the unit.
    dynamic public var unitText: String = "" {
        didSet {
            unit.text = unitText
        }
    }
    /// The font of the unit.
    dynamic public var unitFont: UIFont = .systemFont(ofSize: kFontSize) {
        didSet {
            unit.font = unitFont
        }
    }
    /// The text color of the unit.
    dynamic public var unitTextColor: UIColor = .uxsdk_whiteAlpha60() {
        didSet {
            unit.textColor = unitTextColor
        }
    }
    /// The background color of the unit.
    dynamic public var unitBackgroundColor: UIColor = .uxsdk_clear() {
        didSet {
            unit.backgroundColor = unitBackgroundColor
        }
    }
    /// The visibility of the unit.
    dynamic public var unitVisibility: Bool = true {
        didSet {
            unit.isHidden = !unitVisibility
        }
    }
    
    /// The background color of the widget.
    dynamic public var backgroundColor: UIColor = .uxsdk_clear() {
        didSet {
            view.backgroundColor = backgroundColor
        }
    }
    
    /// The standard widgetSizeHint indicating the minimum size for this widget and preferred aspect ratio.
    public override var widgetSizeHint : DUXBetaWidgetSizeHint {
        get { return DUXBetaWidgetSizeHint(preferredAspectRatio: minWidgetSize.width/minWidgetSize.height,
                                       minimumWidth: minWidgetSize.width,
                                       minimumHeight: minWidgetSize.height)}
        set {
        }
    }
    
    var imageview = UIImageView()
    var label = UILabel()
    var value = UILabel()
    var unit = UILabel()
    var valueTextMask: String = "" {
        didSet {
            valueMinWidth = computeValueMinWidth(for: valueTextMask)
        }
    }
    
    static let kFontSize: CGFloat = UIDevice.duxbeta_isiPad ? 18.0 : 15.0
    fileprivate var minWidgetSize: CGSize = .init(width: 90, height: 30)
    
    fileprivate let stackview = UIStackView()
    fileprivate var topConstraint: NSLayoutConstraint?
    fileprivate var leftConstraint: NSLayoutConstraint?
    fileprivate var rightConstraint: NSLayoutConstraint?
    fileprivate var bottomConstraint: NSLayoutConstraint?
    fileprivate var valueWidthConstraint: NSLayoutConstraint?
    
    fileprivate var valueMinWidth: CGFloat = 0 {
        didSet {
            valueWidthConstraint?.constant = valueMinWidth
            view.setNeedsLayout()
        }
    }
    
    /**
    * Override of viewDidLoad creates all the container values needed by the base implementation.
    */
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    /**
     * The setupUI method instantiates the visual components.
     */
    open func setupUI() {
        view.backgroundColor = backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false

        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.spacing = spacing
        stackview.axis = .horizontal
        stackview.alignment = .fill
        stackview.distribution = .fill
        
        updateImage()
        imageview.tintColor = imageTintColor
        imageview.isHidden = !imageVisibility
        imageview.contentMode = .scaleAspectFit
        imageview.backgroundColor = imageBackgroundColor
        addShadow(view: imageview)
        
        label.font = labelFont
        label.numberOfLines  = 1
        label.textColor = labelTextColor
        label.isHidden = !imageVisibility
        label.backgroundColor = labelBackgroundColor
        addShadow(view: label)
        
        value.font = valueFont
        value.numberOfLines  = 1
        value.textColor = valueTextColor
        value.isHidden = !valueVisibility
        value.textAlignment = valueAlignment
        value.backgroundColor = valueBackgroundColor
        value.translatesAutoresizingMaskIntoConstraints = false
        addShadow(view: value)
        
        unit.font = unitFont
        unit.numberOfLines  = 1
        unit.textColor = unitTextColor
        unit.isHidden = !unitVisibility
        unit.backgroundColor = unitBackgroundColor
        addShadow(view: unit)
        
        stackview.addArrangedSubview(label)
        stackview.addArrangedSubview(value)
        stackview.addArrangedSubview(unit)
        
        updateType()
        
        view.addSubview(stackview)
        
        topConstraint = stackview.topAnchor.constraint(equalTo: view.topAnchor, constant: topMargin)
        leftConstraint = stackview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: leftMargin)
        rightConstraint = stackview.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -rightMargin)
        bottomConstraint = stackview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomMargin)
        valueWidthConstraint = value.widthAnchor.constraint(equalToConstant: valueMinWidth)
        
        NSLayoutConstraint.activate([
            topConstraint!,
            leftConstraint!,
            rightConstraint!,
            bottomConstraint!,
            valueWidthConstraint!
        ])
        
        valueTextMask = "888.8"
    }
    
    /**
     * The updateUI method populates the values displayed by the visual components.
     */
    open func updateUI() {
        label.text = labelText
        value.text = valueText
        unit.text = unitText
        
        updateImage()
    }
    
    func formattedValue(value: Double, for unitType: MeasureUnitType) -> String {
        return String(format: DUXBetaUnitTypeModule.stringFormat(for: unitType), value)
    }
    
    fileprivate func updateType() {
        switch type {
        case .Text:
            stackview.removeArrangedSubview(imageview)
        case .TextImageLeft:
            stackview.insertArrangedSubview(imageview, at: 0)
        case .TextImageRight:
            stackview.addArrangedSubview(imageview)
            break
        }
    }
    
    fileprivate func updateImage() {
        if let size = image?.size {
            minWidgetSize.height = size.height
        }
        imageview.image = image
    }
    
    fileprivate func updatetMarginConstraints(top: Bool = false, left: Bool = false, bottom: Bool = false, right: Bool = false) {
        if top {
            // Set the top margin
            if let oldConstraint = topConstraint {
                oldConstraint.isActive = false
            }
            topConstraint = stackview.topAnchor.constraint(equalTo: view.topAnchor, constant: topMargin)
            topConstraint?.isActive = true
        }
        
        if left {
            // Set the left margin
            if let oldConstraint = leftConstraint {
                oldConstraint.isActive = false
            }
            leftConstraint = stackview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: leftMargin)
            leftConstraint?.isActive = true
        }
        
        if bottom {
            // Set the bottom margin
            if let oldConstraint = bottomConstraint {
                oldConstraint.isActive = false
            }
            bottomConstraint = stackview.bottomAnchor.constraint(equalTo:view.bottomAnchor, constant: -bottomMargin)
            bottomConstraint?.isActive = true
        }

        if right {
            // Set the right margin
            if let oldConstraint = rightConstraint {
                oldConstraint.isActive = false
            }
            rightConstraint = stackview.rightAnchor.constraint(equalTo:view.rightAnchor, constant: -rightMargin)
            rightConstraint?.isActive = true
        }
    }
    
    fileprivate func addShadow(view: UIView) {
        view.layer.shadowColor = UIColor.uxsdk_blackAlpha50().cgColor
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shouldRasterize = true
    }
    
    fileprivate func computeValueMinWidth(for text: String) -> CGFloat {
        return text.size(withAttributes: [.font: valueFont]).width
    }
    
    fileprivate func updateValueMinWidth() {
        let valueWidth = computeValueMinWidth(for: valueText)
        if valueWidth > valueMinWidth {
            valueWidthConstraint?.constant = valueWidth
            view.setNeedsLayout()
        }
    }
}
