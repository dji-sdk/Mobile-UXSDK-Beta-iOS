//
//  DUXBetaSlideAlertView.swift
//  UXSDKCore
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
 * An object that displays an alert message that has
 * a customtizable slide view control as the main action.
 */
@objcMembers public class DUXBetaSlideAlertView: DUXBetaAlertView {
    
    /**
     * Struct that encapsulates all the customization properties
     * that can be set on a sliding alert view instance.
    */
    @objc(DUXBetaSlideAlertViewAppearance) public class DUXBetaSlideAlertViewAppearance: DUXBetaAlertViewAppearance {
        /// The vertical spacing between the checkbox details and the slider view.
        @objc public var verticalSpacing: CGFloat = 10.0
        /// The horizontal spacing between the checkbox buttons and the checkbox details label.
        @objc public var checkboxSpacing: CGFloat = 10.0
        /// The visibility of the checkbox button and details label.
        @objc public var isCheckboxVisible = true
        /// The image displayed by the checkbox button when selected.
        @objc public var checkboxSelectedImage = UIImage.duxbeta_image(withAssetNamed: "CheckboxSelected")
        /// The image displayed by the checkbox button when not selected.
        @objc public var checkboxUnselectedImage = UIImage.duxbeta_image(withAssetNamed: "Checkbox")
        /// The tint color of the image displayed by the checkbox button when selected.
        @objc public var checkboxTintColor = UIColor.uxsdk_selectedBlue()
        /// The text displayed in the checkbox label.
        @objc public var checkboxText = "Precisely record takeoff point"
        /// The color of text displayed in the checkbox label.
        @objc public var checkboxTextColor = UIColor.uxsdk_white()
        /// The font of the text displayed in the checkbox label.
        @objc public var checkboxTextFont = UIFont.systemFont(ofSize: 17.0)
        /// The background color of the checkbox label.
        @objc public var checkboxTextBackgroundColor = UIColor.uxsdk_clear()
        /// The image used for the slider thumb icon.
        @objc public var slideIconImage = UIImage.duxbeta_image(withAssetNamed: "Slider")
        /// The image tint color used for the slider thumb icon for the normal state.
        @objc public var slideIconTintColor = UIColor.uxsdk_white()
        /// The image tint color used for the slider thumb icon for the selected state.
        @objc public var slideIconSelectedTintColor = UIColor.uxsdk_white85()
        /// The image for the on state of the slide control.
        @objc public var slideOnImage = UIImage.duxbeta_image(withAssetNamed: "SlideOn")
        /// The image tint color for the on state of the slide control.
        @objc public var slideOnTintColor = UIColor.uxsdk_success()
        /// The image for the off state of the slide control.
        @objc public var slideOffImage = UIImage.duxbeta_image(withAssetNamed: "SlideOff")
        /// The image tint color for the off state of the slide control.
        @objc public var slideOffTintColor = UIColor.uxsdk_warning()
        /// The text displayed into the label positioned in the slide off area.
        @objc public var slideMessageText = "Slide to Take Off"
        /// The font for text displayed into the label positioned in the slide off area.
        @objc public var slideMessageFont = UIFont.systemFont(ofSize: 12.0)
        /// The text color displayed into the label positioned in the slide off area.
        @objc public var slideMessageTextColor = UIColor.uxsdk_slideText()
        /// The image displayed in the slide off area.
        @objc public var slideMessageImage = UIImage.duxbeta_image(withAssetNamed: "SliderChevron")
        /// The tint color of the image displayed in the slide off area.
        @objc public var slideMessageTintColor = UIColor.uxsdk_slideText()
        /// The color of the line separator displayed below the slide view.
        @objc public var separatorColor = UIColor.uxsdk_darkGray()
    }
    
    // MARK:- Public Properties
    
    /// The callback invoked when the slide action is completed.
    public var onSlideCompleted: ((Bool) -> ())?
    /// The callback invoked when the checkbox selection state changes.
    public var onCheckboxChanged: ((Bool) -> ())?
    /// The boolean value indicating if the checkbox is selected or not.
    public var isChecked: Bool { isSelected }
    /// The appearance structure that encloses all the customization properties for the sliding alert.
    public var slideAppearance = DUXBetaSlideAlertViewAppearance() {
        didSet {
            applySlidingAppearance()
        }
    }
    
    // MARK:- Private Properties
    
    fileprivate let checkboxButton = UIButton()
    fileprivate let checkboxLabel = UILabel()
    fileprivate let slideView = DUXBetaSlideView()
    fileprivate let separatorView = UIView()
    fileprivate let checkboxStackView  = UIStackView()
    fileprivate let customStackView  = UIStackView()
    
    fileprivate var isSelected = false
    
    // MARK:- Static Method
    
    /// The alert appearance specific to the take off and return home widgets.
    @objc public static var slideAlertAppearance: DUXBetaSlideAlertViewAppearance {
        let appearance = DUXBetaSlideAlertViewAppearance()
        appearance.backgroundColor = .uxsdk_darkGrayWhite25()
        appearance.titleColor = .uxsdk_warning()
        appearance.imageTintColor = .uxsdk_warning()
        appearance.titleFont = .boldSystemFont(ofSize: 17.0)
        appearance.messageFont = .systemFont(ofSize: 17.0)
        appearance.headerLayoutType = .horizontal
        appearance.headerLayoutSpacing = 10.0
        appearance.bodyLayoutSpacing = 5.0
        appearance.alertLayoutSpacing = 10.0
        appearance.verticalOffset = 20.0
        appearance.horizaontalOffset = 20.0
        return appearance
    }
    
    /// The default appearance of the cancel actions specific to sliding alerts.
    public static var cancelActionAppearance: DUXBetaAlertActionAppearance {
        let cancelActionAppearance = DUXBetaAlertActionAppearance()
        cancelActionAppearance.actionColor = .uxsdk_white()
        return cancelActionAppearance
    }
    
    // MARK:- Private Methods
    
    override func setupUI() {
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        slideView.onSlideCompleted = onSlideCompleted
        
        checkboxStackView.axis = .horizontal
        checkboxStackView.alignment = .center
        checkboxStackView.distribution = .fillProportionally
        
        checkboxStackView.addArrangedSubview(checkboxButton)
        checkboxStackView.addArrangedSubview(checkboxLabel)
        
        customStackView.axis = .vertical
        customStackView.alignment = .center
        customStackView.distribution = .fillProportionally
        
        customStackView.addArrangedSubview(checkboxStackView)
        customStackView.addArrangedSubview(slideView)
        customStackView.addArrangedSubview(separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(equalToConstant: 1.0),
            separatorView.leadingAnchor.constraint(equalTo: customStackView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: customStackView.trailingAnchor)
        ])
        
        customizedView = customStackView
        
        super.setupUI()
        
        applySlidingAppearance()
    }
    
    fileprivate func applySlidingAppearance() {
        // Update stackviews customization properties
        checkboxStackView.isHidden = !slideAppearance.isCheckboxVisible
        checkboxStackView.spacing = slideAppearance.checkboxSpacing
        customStackView.spacing = slideAppearance.verticalSpacing
        
        // Update checkbox customization properties
        checkboxLabel.text = slideAppearance.checkboxText
        checkboxLabel.font = slideAppearance.checkboxTextFont
        checkboxLabel.textColor =  slideAppearance.checkboxTextColor
        checkboxLabel.backgroundColor = slideAppearance.checkboxTextBackgroundColor
        checkboxButton.tintColor = slideAppearance.checkboxTintColor
        checkboxButton.setImage(slideAppearance.checkboxUnselectedImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        // Update slideView customization properties
        slideView.slideOnImage = slideAppearance.slideOnImage
        slideView.slideOnTintColor = slideAppearance.slideOnTintColor
        slideView.slideOffImage = slideAppearance.slideOffImage
        slideView.slideOffTintColor = slideAppearance.slideOffTintColor
        slideView.slideIconImage = slideAppearance.slideIconImage
        slideView.slideIconTintColor = slideAppearance.slideIconTintColor
        slideView.slideIconSelectedTintColor = slideAppearance.slideIconSelectedTintColor
        slideView.slideMessageText = slideAppearance.slideMessageText
        slideView.slideMessageFont = slideAppearance.slideMessageFont
        slideView.slideMessageTextColor = slideAppearance.slideMessageTextColor
        slideView.slideMessageImage = slideAppearance.slideMessageImage
        slideView.slideMessageTintColor = slideAppearance.slideMessageTintColor
        
        // Update separator view
        separatorView.backgroundColor = slideAppearance.separatorColor
    }
    
    @IBAction func checkboxTapped() {
        isSelected = !isSelected
        
        // Trigger callback
        onCheckboxChanged?(isSelected)
        
        // Update checkbox image
        checkboxButton.setImage((isSelected ? slideAppearance.checkboxSelectedImage : slideAppearance.checkboxUnselectedImage)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
}
