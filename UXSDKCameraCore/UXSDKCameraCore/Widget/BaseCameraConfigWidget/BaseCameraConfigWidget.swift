//
//  BaseCameraConfigWidget.swift
//  UXSDKCameraCore
//
//  MIT License
//  
//  Copyright © 2021 DJI
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

/// Default suggested minimum widget size
fileprivate let kMinCameraConfigWidgetWidth: CGFloat = 100.0
/// Default Toolbar panel height
fileprivate let kMinCameraConfigWidgetHeight: CGFloat = 30.0


/**
 * DUXBetaBaseCameraConfigWidget is the base class for most of the camera configuration widgets. It supplies a stacked label and value
 * and an optional divider between the two. The label and value are manipulated using:
 * label[String | Color | BackgroundColor | Font] properties
 * value[String | Color | ColorDisabled| BackgroundColor | Font] properties
 * Setting the isConnected flag will use the normal or disabled color for the value label.
 * This widget will resize width dynamically to fit label and/or value strings, with a minimum width of 100 (kMinCameraConfigWidgetWidth).
 */
@objcMembers open class DUXBetaBaseCameraConfigWidget : DUXBetaBaseWidget {
    // MARK: - Public Variables
    static let kLabelFontSize: CGFloat = UIDevice.duxbeta_isiPad ? 14.0 : 12.0
    static let kValueFontSize: CGFloat = UIDevice.duxbeta_isiPad ? 18.0 : 16.0

    /// The top (name) label for the camera config widget
    public var label = UILabel()
    // The string to put in the name label
    public var labelString : String = "Label" {
        didSet {
            label.text = labelString
        }
    }
    /// The color for the name label when widget is enabled
    public var labelColor : UIColor = .uxsdk_whiteAlpha80() {
        didSet {
            label.textColor = isConnected ? labelColor : labelColorDisabled
        }
    }
    /// The color for the name label when widget is disabled
    public var labelColorDisabled : UIColor = .uxsdk_disabledGrayWhite58() {
        didSet {
            label.textColor = isConnected ? labelColor : labelColorDisabled
        }
    }

    /// The background color for the name label
    public var labelBackgroundColor : UIColor = .uxsdk_clear() {
        didSet {
            label.backgroundColor = labelBackgroundColor
        }
    }
    /// The font and size for the name label
    public var labelFont: UIFont = UIFont.systemFont(ofSize: kLabelFontSize) {
        didSet {
            label.font = labelFont
        }
    }

    /// The label to display the value setting for this widget
    public var value = UILabel()
    public var valueString : String = "Value" {
        didSet {
            value.text = valueString
        }
    }
    /// The color to use for the value text when the widget is enabled
    public var valueColor : UIColor = .uxsdk_white() {
        didSet {
            value.textColor = isConnected ? valueColor : valueColorDisabled
        }
    }
    /// The color to use for the value text when the widget is disabled
    public var valueColorDisabled : UIColor = .uxsdk_disabledGrayWhite58() {
        didSet {
            value.textColor = isConnected ? valueColor : valueColorDisabled
        }
    }
    /// The background color for the value label
    public var valueBackgroundColor : UIColor = .uxsdk_clear() {
        didSet {
            value.backgroundColor = valueBackgroundColor
        }
    }
    /// The font and size for the value label
    public var valueFont: UIFont = UIFont.systemFont(ofSize: kValueFontSize) {
        didSet {
            value.font = valueFont
        }
    }
    /// The color to user for the divider between top and bottom
    public var dividerColor = UIColor.uxsdk_clear() {
        didSet {
            dividerView.backgroundColor = dividerColor
        }
    }
    /// Flag which controls and updates the value appearance when connected or disconnected
    public var isConnected: Bool = true {
        didSet {
            value.textColor = isConnected ? valueColor : valueColorDisabled
        }
    }
    /// The widgetSizeHint defines the minimum size for this widget
    public override var widgetSizeHint : DUXBetaWidgetSizeHint {
        get { return DUXBetaWidgetSizeHint(preferredAspectRatio: (kMinCameraConfigWidgetWidth / kMinCameraConfigWidgetHeight), minimumWidth: kMinCameraConfigWidgetWidth, minimumHeight: kMinCameraConfigWidgetHeight)}
        set {
        }
    }

    // MARK: - Private Variables
    /// The view used to draw the divider line between top and bottom if desired.
    fileprivate var dividerView = UIView()
    

    /**
     * Override of viewDidLoad to set up text settings, and set obvious label and value strings to be overwritten. The override of this
     * method should be structured:
     *      super.viewDidLoad()
     *      model setup
     *      Setup any specific strings and colors for display to override defaults.
     */
    open override func viewDidLoad() {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = labelString
        label.font = labelFont
        label.textColor = labelColor
        label.backgroundColor = labelBackgroundColor
        value.text = valueString
        value.font = valueFont
        value.textColor = valueColor
        value.backgroundColor = valueBackgroundColor
        
        label.numberOfLines = 1
        value.numberOfLines = 1

        setupUI()
    }
    
    open func setupUI() {
        label.translatesAutoresizingMaskIntoConstraints = false
        value.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = dividerColor
        
        view.addSubview(label)
        view.addSubview(dividerView)
        view.addSubview(value)

        let heightConstraint = view.heightAnchor.constraint(greaterThanOrEqualToConstant: widgetSizeHint.minimumHeight)
        let widthConstraint1 = view.widthAnchor.constraint(greaterThanOrEqualToConstant: widgetSizeHint.minimumWidth)
        let widthConstraint2 = view.widthAnchor.constraint(greaterThanOrEqualTo:label.widthAnchor)
        let widthConstraint3 = view.widthAnchor.constraint(greaterThanOrEqualTo:value.widthAnchor)

        heightConstraint.priority = .defaultHigh
        widthConstraint1.priority = .defaultHigh
        widthConstraint2.priority = .defaultLow
        widthConstraint3.priority = .defaultLow

        NSLayoutConstraint.activate([
            heightConstraint,
            widthConstraint1,
            widthConstraint2,
            widthConstraint3,
            label.leadingAnchor.constraint(equalTo:view.leadingAnchor, constant: 8.0),
            label.trailingAnchor.constraint(equalTo:view.trailingAnchor, constant: -8.0),
            label.bottomAnchor.constraint(equalTo:view.centerYAnchor, constant: 1.0),
            dividerView.leadingAnchor.constraint(equalTo:view.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo:view.trailingAnchor),
            dividerView.topAnchor.constraint(equalTo:label.bottomAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1.0),
            value.leadingAnchor.constraint(equalTo:view.leadingAnchor, constant: 8.0),
            value.trailingAnchor.constraint(equalTo:view.trailingAnchor, constant: -8.0),
            value.topAnchor.constraint(equalTo:dividerView.bottomAnchor, constant: -1.0)
        ])
        
    }
    
}
