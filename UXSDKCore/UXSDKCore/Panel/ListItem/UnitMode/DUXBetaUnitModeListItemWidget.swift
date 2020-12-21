//
//  UnitModeListItemWidget.swift
//  UXSDKCore
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
 *  The SystemStatusList widget to show and edit the measurement units for metric vs. imperial units
*/
@objcMembers open class DUXBetaUnitModeListItemWidget : DUXBetaListItemRadioButtonWidget {
    /// The model to read and hold the unit setting
    lazy var widgetModel: DUXBetaUnitModeListItemWidgetModel = DUXBetaUnitModeListItemWidgetModel()
    /// The appearance configuraton object used to customize the appearance of the dialog shown when switching to imperial units from metric units
    var imperialModeOnAlertAppearance = DUXBetaAlertView.systemAlertAppearance
    /// Optional custom font to use for the example text in the imperial dialog
    var imperialModeExampleTextFont: UIFont?
    /// Optional custom color to use for the example text in the imperial dialog
    var imperialModeOnExampleTextColor: UIColor?
    /// Optional custom font to use for the "Don't Show Again" checkbox text in the imperial dialog
    var imperialModeOnCheckboxTextFont: UIFont?
    /// Optional custom color to use for the "Don't Show Again" checkbox text in the imperial dialog
    var imperialModeOnCheckboxTextColor: UIColor?
    /// Option tint color to apply to the checkbox icon in the imperial dialog
    var imperialModeOnCheckboxTintColor: UIColor?
    /// Optional checkbox "on" image to use for the "Don't Show Again" checkbox. It should be white for tint application.
    var imperialModeCheckboxOnImage: UIImage?
    /// Optional checkbox "off" image to use for the "Don't Show Again" checkbox. It should be white for tint application.
    var imperialModeCheckboxOffImage: UIImage?
    /// Customizable string for the checkbox to prevent the imperial change dialog from being shown again
    var neverShowAgainCheckboxTitle = NSLocalizedString("Don't show again", comment: "Don't show again")

    // Key for the don't show again checkmark in user prefs
    fileprivate static let imperialDialogKey = "neverShowImperialMeasurementDialog"
    // The value for the don't show again Imperial units approximation dialog
    fileprivate var dontShowDialog = DUXBetaSingleton.sharedGlobalPreferences().bool(forKey: imperialDialogKey)
    /**
     * Override of viewDidLoad to set up the widget for use and install the handler for the radio control used by the widget.
     */
    public override func viewDidLoad() {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        setOptionTitles([NSLocalizedString("Imperial", comment: "Imperial"),
                         NSLocalizedString("Metric", comment: "Metric")])
        self.setTitle(NSLocalizedString("Unit Mode", comment: "List Item Widget Title"), andIconName:"UnitModeRuler")
        
        self.widgetModel.setup()

        setOptionSelectedAction({ [weak self] oldSelectedIndex, newSelectedIndex in
            guard let self = self else { return }
            var measureType: MeasureUnitType = .Metric
            
            switch newSelectedIndex {
                case 0: measureType = .Imperial
                case 1: measureType = .Metric
                
                default:
                    DUXBetaStateChangeBroadcaster.send(UnitModeItemUIState.optionSelected(newSelectedIndex, label:self.optionTitle(at: newSelectedIndex)))
                    DUXBetaStateChangeBroadcaster.send(UnitModeItemModelState.setUnitTypeFailed())
                    return
            }

            self.widgetModel.measurementUnit = measureType
            // oldSelectedIndex is -1 (not NSNotFound due to sign issues) when it first starts.
            if oldSelectedIndex != newSelectedIndex && (oldSelectedIndex != -1) {
                if measureType == .Imperial {
                    self.measurementsChanged()
                }
            }
            DUXBetaStateChangeBroadcaster.send(UnitModeItemUIState.optionSelected(newSelectedIndex, label:self.optionTitle(at: newSelectedIndex)))
            DUXBetaStateChangeBroadcaster.send(UnitModeItemModelState.setUnitTypeSucceeded())
            DUXBetaStateChangeBroadcaster.send(UnitModeItemModelState.unitTypeUpdated(newUnits: measureType))
        })

        super.viewDidLoad()
    }
    
    deinit {
        widgetModel.cleanup()
    }
    
    /**
     * Override of viewWillAppear to establish KVO bindings.
     */
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentValue: MeasureUnitType = DUXBetaSingleton.sharedGlobalPreferences().measurementUnitType
        selection = (currentValue == .Imperial) ? 0 : 1

        bindRKVOModel(self, #selector(productConnected), (\DUXBetaUnitModeListItemWidget.widgetModel.isProductConnected).toString)
        
        imperialModeOnAlertAppearance.backgroundColor = .uxsdk_black()
        imperialModeOnAlertAppearance.imageTintColor = .uxsdk_success()
}

    /**
     * Override of viewWillDisappear to symetrically remove KVO bindings when the view disappears.
     */
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unbindRKVOModel(self)
    }

    
    // Function to toggle "Don't show again" checkbox
    func toggleButton(_ pressedButton: UIButton) {
        pressedButton.isSelected = !pressedButton.isSelected
        dontShowDialog = pressedButton.isSelected
    }

    // Function to show the dialog about approximations in Imperial measurements if needed. Only call when switching to Imperial
    // Switching to metric does not give an alert becaue those values are exact.
    func measurementsChanged() {
        if dontShowDialog {
            return
        }
       let dialogIdentifier = "UnitModeImperialConfirmation"

        let alertView = DUXBetaAlertView.successAlert(title: NSLocalizedString("Unit Mode", comment: "List Item Alert"),
                                                message: NSLocalizedString("Imperial unit mode set successfully. All widgets will now display values in imperial units. Since the aircraft supports the metric unit system, the values seen are approximate conversions.", comment:"Explanation of why approximations will be used."))
        
        let defaultAction = DUXBetaAlertAction.action(actionTitle: NSLocalizedString("OK", comment:"OK"),
                                                  style: .default,
                                                  actionType:.closure,
                                                  target:nil,
                                                  selector:nil,
                                                  completionAction:{ [weak self] in
                                                    if let keyValue = self?.dontShowDialog {
                                                        DUXBetaSingleton.sharedGlobalPreferences().set(keyValue, forKey: DUXBetaUnitModeListItemWidget.imperialDialogKey)
                                                        if keyValue {
                                                            DUXBetaStateChangeBroadcaster.send(UnitModeItemUIState.neverShowAgainCheckChanged())
                                                        }
                                                    }
                                                    DUXBetaStateChangeBroadcaster.send(UnitModeItemUIState.dialogActionConfirmed(dialogIdentifier))
        })

        alertView.dissmissCompletion = {
            DUXBetaStateChangeBroadcaster.send(UnitModeItemUIState.dialogDismissed(dialogIdentifier))
        }
        alertView.customizedView = makeCheckboxView()
        alertView.add(defaultAction)
        
        alertView.appearance = imperialModeOnAlertAppearance
        alertView.show()
        DUXBetaStateChangeBroadcaster.send(UnitModeItemUIState.dialogDisplayed(dialogIdentifier))

    }
    
    /// Method called when the aircraft connection state changesb
    func productConnected() {
        setEnabled(widgetModel.isProductConnected)
        DUXBetaStateChangeBroadcaster.send(UnitModeItemModelState.productConnected(widgetModel.isProductConnected))
    }

    
    func makeCheckboxView() -> UIView {
        let exampleTextFont: UIFont = imperialModeExampleTextFont ?? imperialModeOnAlertAppearance.messageFont ?? .systemFont(ofSize: 15.0)
        let exampleTextColor: UIColor = imperialModeOnExampleTextColor ?? imperialModeOnAlertAppearance.messageColor ?? .uxsdk_white()
        let checkboxTextFont: UIFont = imperialModeOnCheckboxTextFont ?? imperialModeOnAlertAppearance.messageFont ?? .systemFont(ofSize: 15.0)
        let checkboxTextColor: UIColor = imperialModeOnCheckboxTextColor ?? imperialModeOnAlertAppearance.messageColor ?? .uxsdk_white()

        let checkboxView = UIView()
        checkboxView.translatesAutoresizingMaskIntoConstraints = false
        
        var onImage = imperialModeCheckboxOnImage ?? UIImage.duxbeta_image(withAssetNamed: "CheckboxSelected")
        var offImage = imperialModeCheckboxOffImage ?? UIImage.duxbeta_image(withAssetNamed: "Checkbox")
        if let tintColor = imperialModeOnCheckboxTintColor {
            onImage = UIImage.duxbeta_colorizeImage(onImage, with:tintColor)
            offImage = UIImage.duxbeta_colorizeImage(offImage, with:tintColor)
        }
        let imageSize = onImage?.size ?? CGSize(width: 18, height:18)
        let checkboxButton = UIButton()
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.addTarget(self, action: #selector(toggleButton), for: .touchUpInside)
        checkboxButton.setBackgroundImage(onImage, for:.selected)
        checkboxButton.setBackgroundImage(offImage, for:.normal)

        let checkboxTitle = UILabel()
        checkboxTitle.translatesAutoresizingMaskIntoConstraints = false
        checkboxTitle.text = neverShowAgainCheckboxTitle
        checkboxTitle.textColor = checkboxTextColor
        checkboxTitle.font = checkboxTextFont
        
        let exampleLabel = UILabel()
        exampleLabel.translatesAutoresizingMaskIntoConstraints = false
        exampleLabel.text = NSLocalizedString("Example: 10m ≈ 32ft - 34ft", comment: "Example approximate string")
        exampleLabel.textColor = exampleTextColor
        exampleLabel.textAlignment = .center
        exampleLabel.font = exampleTextFont
        

        checkboxView.addSubview(exampleLabel)
        checkboxView.addSubview(checkboxButton)
        checkboxView.addSubview(checkboxTitle)
        
         
        NSLayoutConstraint.activate([
            exampleLabel.topAnchor.constraint(equalTo: checkboxView.topAnchor, constant: 8.0),
            exampleLabel.leadingAnchor.constraint(equalTo: checkboxView.leadingAnchor),
            exampleLabel.trailingAnchor.constraint(equalTo: checkboxView.trailingAnchor),
            
            checkboxButton.topAnchor.constraint(equalTo: exampleLabel.bottomAnchor, constant: 12.0),
            checkboxButton.leadingAnchor.constraint(equalTo: checkboxView.leadingAnchor),
            checkboxButton.heightAnchor.constraint(equalToConstant: imageSize.height),
            checkboxButton.widthAnchor.constraint(equalToConstant: imageSize.width),
            checkboxTitle.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 8.0),
            checkboxTitle.centerYAnchor.constraint(equalTo: checkboxButton.centerYAnchor),
            checkboxView.trailingAnchor.constraint(greaterThanOrEqualTo: checkboxTitle.trailingAnchor),
            checkboxView.bottomAnchor.constraint(equalTo:checkboxButton.bottomAnchor, constant: 8.0),
            
        ])
        return checkboxView
    }
    
    // Convenience routine to just reseet the visibility flag
    func resetDialogBoxVisibility() {
        dontShowDialog = false
        DUXBetaSingleton.sharedGlobalPreferences().set(dontShowDialog, forKey: DUXBetaUnitModeListItemWidget.imperialDialogKey)
    }
}

/**
 * UnitModeItemUIState contains the model hooks for DUXBetaUnitModeListItemWidget
 * It inherits from ListItemRadioButtonUIState and adds:
 *
 * Key: neverShowAgainCheckChanged    Type: NSNumber - Sends a boolean true value when the "Don't Show Again" checkbox was checked and the dialog
 *                                                     dismissed. Will only be sent once since this setting can't normally be reversed without re-installing.
 */
class UnitModeItemUIState : ListItemRadioButtonUIState {
    @objc public static func neverShowAgainCheckChanged(_ state: Bool = true) -> UnitModeItemUIState {
        return UnitModeItemUIState(key: "neverShowAgainCheckChanged", number: NSNumber(value: state))
    }
}

/**
 * UnitModeItemModelState contains the model hooks for DUXBetaUnitModeListItemWidgetModel
 * It inherits from ListItemTitleModelState and adds:
 *
 * Key: setUnitTypeSucceded     Type: NSNumber - Sends a boolean true value when tmeasurement he unit type has been updated.
 *
 * Key: setUnitTypeFailed       Type: NSNumber - Sends a boolean false value when the measurement unit type has failed to update.
 *
 * Key: unitTypeUpdated         Type: NSNumber - The newly set measurement unit type as an NSNumber, from the enum MeasureUnitType.
 */
class UnitModeItemModelState : ListItemTitleModelState {
    @objc public static func setUnitTypeSucceeded() -> UnitModeItemModelState {
        return UnitModeItemModelState(key: "setUnitTypeSucceeded", number: NSNumber(value: true))
    }

    @objc public static func setUnitTypeFailed() -> UnitModeItemModelState {
        return UnitModeItemModelState(key: "setUnitTypeFailed", number: NSNumber(value: false))
    }

    @objc public static func unitTypeUpdated(newUnits: MeasureUnitType) -> UnitModeItemModelState {
        return UnitModeItemModelState(key: "unitTypeUpdated", number: NSNumber(value: newUnits.rawValue))
    }

}
