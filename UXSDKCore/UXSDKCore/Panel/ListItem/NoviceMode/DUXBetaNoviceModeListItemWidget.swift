//
//  DUXBetaNoviceModeListItemWidget.swift
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
 * Widget for display in the SystemStatusList which shows the current setting for the Novice/Beginner Mode setting
 * for the aircraft and also allows editing the height within the limits shown in the hint text.
 *
 * The widget has 2 alerts which show, one when Novice Mode is activated, and a confirmation dialog when it is deactivated.
 * Deactivation can be canceled by the dialog. Each alert can be configured by setting the appropriate setting
 * properties of the appropriate DUXBetaAlertViewAppearance object below.
*/
@objcMembers public class DUXBetaNoviceModeListItemWidget : DUXBetaListItemSwitchWidget {
    /// The appearance configuration object for the activation dialog for Novice/Beginner mode
    var noviceModeOnAlertAppearance = DUXBetaAlertView.systemAlertAppearanceSuccess
    /// The appearance configuration object for the deactivation confirmation dialog for Novice/Beginner mode
    var noviceModeOffAlertAppearance = DUXBetaAlertView.systemAlertAppearanceWarning
    /// The widgetModel for KVO monitoriing connection and noviceMode key.
    @objc fileprivate lazy var widgetModel = DUXBetaListItemSwitchWidgetModel()
    /// This is used to prevent showing of the novice mode on dialog when bindings are first activated.
    fileprivate var bindingsAreLive = false

    /**
     * Override of the standard viewDidLoad. This method sets up the model and key for the novice mode. It implements the
     * action method to be called when the novice mode switch is changed.
     */
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
    
        if let noviceModeKey =  DJIFlightControllerKey(index: 0, andParam:DJIFlightControllerParamNoviceModeEnabled) {
            widgetModel = DUXBetaListItemSwitchWidgetModel(key:noviceModeKey)

            setSwitchAction( { [weak self] newSwitchValue in
                if let self = self {
                    if self.widgetModel.genericBool == false {
                        // Turn the setting on if it was false before. If there was an error, set the slider back to the off state
                        self.widgetModel.toggleSetting(completionBlock: { [weak self] error in
                            if let _ = error, let self = self {
                                self.onOffSwitch.isOn = false
                           }
                        })
                    } else {
                        // Turning off novice mode. Present confirmation dialog and actually turn it off after the confirmation.
                        self.presentBeginnerModeOff()
                    }
                }
            })
        }
        setTitle(NSLocalizedString("Beginner Mode", comment: "List Item Widget Title"), andIconName:"SystemStatusNoviceMode")
    }
    
    deinit {
        widgetModel.cleanup()
    }
    
    /**
     * Override of viewWillAppear to establish KVO bindings.
     */
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindRKVOModel(self, #selector(valueForSwitchChanged), (\DUXBetaNoviceModeListItemWidget.widgetModel.genericBool).toString)
        bindRKVOModel(self, #selector(updateEnabledStates), (\DUXBetaNoviceModeListItemWidget.widgetModel.isProductConnected).toString)
        bindingsAreLive = true
    }

    /**
     * Override of viewWillDisappear to symetrically remove KVO bindings when the view disappears.
     */
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unbindRKVOModel(self)
        bindingsAreLive = false
    }

    /**
     * The method valueForSwitchChanged is the selector called by the KVO for the noviceMode setting.
     */
    public func valueForSwitchChanged() {
        DUXBetaStateChangeBroadcaster.send(NoviceModeItemModelState.noviceModeStateUpdated(widgetModel.genericBool))
        onOffSwitch.setOn(widgetModel.genericBool, animated: true)
        
        if widgetModel.genericBool == true && bindingsAreLive {
            presentBeginnerModeOn()
        }
    }
    
    /**
     * The method updateEnabledStates is the selector called by the KVO for the when the aircraft connects or disconnects.
     */
    public func updateEnabledStates() {
        onOffSwitch.isEnabled = widgetModel.isProductConnected
        if onOffSwitch.isEnabled {
            // The device may have just gone offline and back online. If dialog was up, switch may be inconsistent. Reset it.
            onOffSwitch.setOn(widgetModel.genericBool, animated: true)
        } else {
            onOffSwitch.setOn(false, animated: false)
        }
        
        DUXBetaStateChangeBroadcaster.send(NoviceModeItemModelState.productConnected(widgetModel.isProductConnected));
    }

    func presentBeginnerModeOn() {
        let dialogIdentifier = "NoviceModeEnabled"
        let alert = DUXBetaAlertView.successAlert(title: NSLocalizedString("Beginner Mode", comment: "Beginner Mode"),
                                                message:NSLocalizedString("Beginner mode enabled. Altitude and distance will both be limited to 100ft / 30m.", comment: "Beginner mode enabled. Altitude and distance will both be limited to 100ft / 30m."))
        
        let cancelAction = DUXBetaAlertAction.action(actionTitle: NSLocalizedString("OK", comment: "OK"),
                                                 style: .cancel,
                                                 actionType: .closure,
                                                 target: nil,
                                                 selector: nil,
                                                 completionAction: {
                                                    DUXBetaStateChangeBroadcaster.send(NoviceModeItemUIState.dialogActionCanceled(dialogIdentifier))
                                                })
        alert.dissmissCompletion = {
            DUXBetaStateChangeBroadcaster.send(NoviceModeItemUIState.dialogDismissed(dialogIdentifier))
        }
        alert.add(cancelAction)
        alert.appearance = noviceModeOnAlertAppearance
        alert.show(withCompletion: {
            DUXBetaStateChangeBroadcaster.send(NoviceModeItemUIState.dialogDisplayed(dialogIdentifier))
        })
    }
    
    func presentBeginnerModeOff() {
        let dialogIdentifier = "NoviceModeDisableConfirmation"
        let alert = DUXBetaAlertView.warningAlert(title: NSLocalizedString("Beginner Mode", comment: "Beginner Mode"),
                                                message:NSLocalizedString("Flight speed and sensitivity will be substantially increased when you turn off Beginner mode. Fly with caution.", comment: "Flight speed and sensitivity will be substantially increased when you turn off Beginner mode. Fly with caution."))
        let okAction = DUXBetaAlertAction.action(actionTitle: NSLocalizedString("OK", comment: "OK"),
                                             style: .default,
                                             actionType: .closure,
                                             target: nil,
                                             selector: nil,
                                             completionAction:{ [weak self] in
                                                self?.widgetModel.toggleSetting(completionBlock: { error in
                                                })
                                                DUXBetaStateChangeBroadcaster.send(NoviceModeItemUIState.dialogActionConfirmed(dialogIdentifier))
                                                                    
        })

        let cancelAction = DUXBetaAlertAction.action(actionTitle: NSLocalizedString("Cancel", comment: "Cancel"),
                                                 style: .default,
                                                 actionType: .closure,
                                                 target: nil,
                                                 selector: nil,
                                                 completionAction:{ [weak self] in
                                                    // Reset the switch if the user rejects the change from the dialog
                                                    self?.onOffSwitch.isOn = true
                                                    DUXBetaStateChangeBroadcaster.send(NoviceModeItemUIState.dialogActionCanceled(dialogIdentifier))
        })
                                                                    
        alert.dissmissCompletion = {
            DUXBetaStateChangeBroadcaster.send(NoviceModeItemUIState.dialogDismissed(dialogIdentifier))
        }
        alert.add(cancelAction)
        alert.add(okAction)
        alert.appearance = noviceModeOffAlertAppearance
        alert.show(withCompletion: {
            DUXBetaStateChangeBroadcaster.send(NoviceModeItemUIState.dialogDisplayed(dialogIdentifier))
        })
    }
}

/**
 * NoviceModeWidgetModelState contains the hooks for the model changes in the DUXBetaNoviceModeListItemWidget implementation.
 *
 * NoviceModeItemUIState is an subclass of ListItemTitleUIState used to map the hook class appropriately for
 * sending dialog hooks. It has no additional hooks.
 */
@objc public class NoviceModeItemUIState : ListItemTitleUIState {
    
}

/**
 * NoviceModeItemModelState contains the hooks for the model changes in the DUXBetaNoviceModeListItemWidget implementation.
 *
 * Key: noviceModeStateUpdated  Type: NSNumber - Sends a boolean value as an NSNumber when the novice mode state changes.
 *
 */
@objc public class NoviceModeItemModelState: ListItemTitleModelState {
    @objc public static func noviceModeStateUpdated(_ isNoviceMode: Bool) -> NoviceModeItemModelState {
        return NoviceModeItemModelState(key: "noviceModeStateUpdated", number: NSNumber(value: isNoviceMode))
    }
}
