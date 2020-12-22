//
//  DUXBetaTravelModeListItemWidget.swift
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
import DJISDK


/**
 * Widget for display in the SystemStatusList which allows moving an Inspire series aircraft in or out of travel mode.
 * When entering travel mode the aircraft automatically shuts down for storing.
 *
 * The widget will display a confirmation dialog before entering travel mode, a confirmation when entering travel mode
 * and possible error dialogs if a problem happens entering or exiting travel mode.
 */
@objcMembers open class DUXBetaTravelModeListItemWidget : DUXBetaListItemLabelButtonWidget {
    /// The appearance configuration object for the confirmation before entering travel mode dialog
    var confirmTravelModeDialogAppearance = DUXBetaAlertView.systemAlertAppearance
    /// The appearance configuration object for the entering travel mode dialog
    var enterTravelModeDialogAppearance = DUXBetaAlertView.systemAlertAppearance
    /// The appearance configuration object for the error dialog if needed while entering or exiting travel mode
    var travelModeErrorDialogAppearance = DUXBetaAlertView.systemAlertAppearance
    /// The list item icon to display when travel mode is off and may be entered
    var travelModeActiveIcon: UIImage? = UIImage.duxbeta_image(withAssetNamed: "TravelModeActiveIcon")?.withRenderingMode(.alwaysTemplate)
    /// The list item icon to display when travel mode is on and may be entered
    var travelModeInactiveIcon: UIImage? = UIImage.duxbeta_image(withAssetNamed: "TravelModeInactiveIcon")?.withRenderingMode(.alwaysTemplate)
    /// The widget model for KVO monitoring and manipulation of the travel mode state
    @objc fileprivate lazy var widgetModel = DUXBetaTravelModeListItemWidgetModel()

    /**
     * Override of the standard init method to show only the button in this widget
     */
    override public init() {
        super.init(.buttonOnly)
    }

    /**
     * Required init for Swift implemntation of list item subclass.
     */
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /**
     * Override of the standard viewDidLoad. This method sets up the model and keys for the travel mode mode. It implements the
     * action method to be called when the travel mode button is pushed.
     */
    override open func viewDidLoad() {
        widgetModel.setup()

        view.translatesAutoresizingMaskIntoConstraints = false;
        setTitle(NSLocalizedString("Travel Mode", comment: "Travel Mode"), andIconName: "TravelModeInactiveIcon")
        
        setButtonAction { [weak self] sendingWidget in
            guard let self = self else { return }
            if self.widgetModel.landingGearMode == .transport {
                // Exit transport mode
                self.updateButton()
                self.widgetModel.exitTravelMode({[weak self] error in
                    guard let self = self  else { return }
                    self.updateButton()
                    if let error = error {
                        self.presentErrorDialog(isEnteringTravelMode: false, errorMessage: error.localizedDescription)
                    }
                })
            } else {
                // Enter transport mode
                self.confirmTravelMode()
                // Force the hilighting off after triggering and before updating, or the button update has to happen in the alert code
                // which is an inappropriate and random seeming location.
                self.actionButton.isHighlighted = false
                self.updateButton()
            }
        }

        buttonBackgroundColors[NSNumber(value: UIControl.State.highlighted.rawValue)] = UIColor.uxsdk_selectedBlue()

        // The standard alerts need to be customized for tinting of the icon displayed
        confirmTravelModeDialogAppearance.imageTintColor = .uxsdk_warning()
        enterTravelModeDialogAppearance.imageTintColor = .uxsdk_success()
        travelModeErrorDialogAppearance.imageTintColor = .uxsdk_errorDanger()

        super.viewDidLoad()
    }
    
    /**
     * Override of viewWillAppear to establish KVO bindings.
     */
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buttonEnabled = true
        
        bindRKVOModel(self, #selector(productConnectedChanged), (\DUXBetaTravelModeListItemWidget.widgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(landingGearChanged), (\DUXBetaTravelModeListItemWidget.widgetModel.landingGearMode).toString)
        bindRKVOModel(self, #selector(travelModeSupportedChanged), (\DUXBetaTravelModeListItemWidget.widgetModel.isProductConnected).toString,
                                                                    (\DUXBetaTravelModeListItemWidget.widgetModel.isLandingGearMovable).toString,
                                                                    (\DUXBetaTravelModeListItemWidget.widgetModel.landingGearMode).toString)
    }
    
    /**
     * Override of viewWillDisappear to symetrically remove KVO bindings when the view disappears.
     */
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unbindRKVOModel(self)
    }
    
    func productConnectedChanged() {
        DUXBetaStateChangeBroadcaster.send(TravelModeItemModelState.productConnected(widgetModel.isProductConnected))
    }
    
    func landingGearChanged() {
        DUXBetaStateChangeBroadcaster.send(TravelModeItemModelState.travelModeStateUpdated(widgetModel.landingGearMode == .transport))
    }
    
    func travelModeSupportedChanged() {
        if widgetModel.isProductConnected && widgetModel.isLandingGearMovable && widgetModel.landingGearMode != .unknown {
            self.buttonEnabled = true
            if widgetModel.landingGearMode == .transport {
                setButtonTitle(NSLocalizedString("Exit", comment: "Exit"))
                if let icon = travelModeActiveIcon {
                    iconImage = icon
                }
            } else {
                setButtonTitle(NSLocalizedString("Enter", comment: "Enter"))
                if let icon = travelModeInactiveIcon {
                    iconImage = icon
                }
            }
        } else {
            self.buttonEnabled = false
            setButtonTitle(NSLocalizedString("N/A", comment:"N/A"))
            if let icon = travelModeInactiveIcon {
                iconImage = icon
            }
        }
    }
    
    func confirmTravelMode() {
        let dialogIdentifier = "EnterTravelModeConfirmation"
        
        let alertView = DUXBetaAlertView.warningAlert(title: NSLocalizedString("Travel Mode", comment: "Travel Mode"), message: NSLocalizedString("The aircraft will enter Travel Mode for easier transportation. Place the aircraft on a flat, hard surface and remove the gimbal. If the aircraft does not enter Travel Mode, adjust the landing gear manually.", comment: "Enter Travel Mode Instructions."))
        
        let okAction = DUXBetaAlertAction.action(actionTitle: NSLocalizedString("OK", comment:"OK"),
                                                  style: .default,
                                                  actionType:.closure,
                                                  target:nil,
                                                  selector:nil,
                                                  completionAction:{ [weak self] in
                                                    self?.widgetModel.enterTravelMode({ [weak self] error in
                                                        if let self = self {
                                                            self.updateButton()
                                                            if let _ = error {
                                                                self.presentErrorDialog(isEnteringTravelMode: true, errorMessage: error?.localizedDescription)
                                                            } else {
                                                                self.presentEnteringTravelModeDialog()
                                                            }
                                                        }
                                                    })

                                                    DUXBetaStateChangeBroadcaster.send(TravelModeItemUIState.dialogActionConfirmed(dialogIdentifier))
        })
        
        let cancelAction = DUXBetaAlertAction.action(actionTitle: NSLocalizedString("Cancel", comment:"Cancel"),
                                                  style: .default,
                                                  actionType:.closure,
                                                  target:nil,
                                                  selector:nil,
                                                  completionAction:{
                                                    DUXBetaStateChangeBroadcaster.send(TravelModeItemUIState.dialogActionCanceled(dialogIdentifier))
        })

        alertView.appearance = confirmTravelModeDialogAppearance
        alertView.dissmissCompletion = {
            DUXBetaStateChangeBroadcaster.send(UnitModeItemUIState.dialogDismissed(dialogIdentifier))
        }

        alertView.add(cancelAction)
        alertView.add(okAction)
        alertView.show(withCompletion: {
                DUXBetaStateChangeBroadcaster.send(TravelModeItemUIState.dialogDisplayed(dialogIdentifier))
        })
    }
    
    func presentEnteringTravelModeDialog() {
        let dialogIdentifier = "EnterTravelModeSuccess"
        
        let alertView = DUXBetaAlertView.successAlert(title: NSLocalizedString("Travel Mode", comment: "Travel Mode"), message: NSLocalizedString("The aircraft will automatically retract the landing gear and enter Travel Mode.", comment: "The aircraft will automatically retract the landing gear and enter Travel Mode."))
        
        let okAction = DUXBetaAlertAction.action(actionTitle: NSLocalizedString("OK", comment:"OK"),
                                                  style: .default,
                                                  actionType:.closure,
                                                  target:nil,
                                                  selector:nil,
                                                  completionAction:{ [weak self] in
                                                    self?.widgetModel.enterTravelMode({ [weak self] error in
                                                        if let self = self {
                                                            self.updateButton()
                                                            if let _ = error {
                                                                self.presentErrorDialog(isEnteringTravelMode: true, errorMessage: error?.localizedDescription)
                                                            }
                                                        }
                                                    })

                                                    DUXBetaStateChangeBroadcaster.send(TravelModeItemUIState.dialogActionConfirmed(dialogIdentifier))
        })
        alertView.appearance = enterTravelModeDialogAppearance
        alertView.dissmissCompletion = {
            DUXBetaStateChangeBroadcaster.send(UnitModeItemUIState.dialogDismissed(dialogIdentifier))
        }

        alertView.add(okAction)
        alertView.show(withCompletion: {
                DUXBetaStateChangeBroadcaster.send(TravelModeItemUIState.dialogDisplayed(dialogIdentifier))
        })
    }
    
    func presentErrorDialog(isEnteringTravelMode: Bool, errorMessage: String?) {
        let dialogIdentifier = isEnteringTravelMode ? "EnterTravelModeError" : "ExitTravelModeError"
        let message = isEnteringTravelMode ? NSLocalizedString("Failed to enter Travel Mode.", comment: "Failed to enter Travel Mode.") :
                                            NSLocalizedString("Failed to exit Travel Mode.", comment: "Failed to exit Travel Mode.")
        
        let alertView = DUXBetaAlertView.failAlert(title: NSLocalizedString("Travel Mode", comment: "Travel Mode"), message: message + " " + (errorMessage ?? ""))
        
        let defaultAction = DUXBetaAlertAction.action(actionTitle: NSLocalizedString("OK", comment:"OK"),
                                                  style: .default,
                                                  actionType:.closure,
                                                  target:nil,
                                                  selector:nil,
                                                  completionAction:{
                                                    DUXBetaStateChangeBroadcaster.send(TravelModeItemUIState.dialogActionConfirmed(dialogIdentifier))
        })
        
        alertView.dissmissCompletion = {
            DUXBetaStateChangeBroadcaster.send(UnitModeItemUIState.dialogDismissed(dialogIdentifier))
        }
        alertView.appearance = travelModeErrorDialogAppearance

        alertView.add(defaultAction)
        alertView.show(withCompletion: {
                DUXBetaStateChangeBroadcaster.send(TravelModeItemUIState.dialogDisplayed(dialogIdentifier))
        })

    }
}


/**
 * TravelModeItemUIState contains the model hooks for ListItemLabelButtonUIState
 * It inherits from ListItemRadioButtonUIState and adds no hooks.
 */
class TravelModeItemUIState : ListItemLabelButtonUIState {
}

/**
 * TravelModeItemModelState contains the model hooks for ListItemLabelButtonModelState
 * It inherits from ListItemRadioButtonUIState and adds:
 *
 * Key: travelModeStateUpdated    Type: NSNumber - Sends a boolean true value indicating if the aircraft is in travel/transport mode (TRUE).
 */
class TravelModeItemModelState : ListItemLabelButtonModelState {
    @objc public static func travelModeStateUpdated(_ isInTravelMode: Bool = true) -> UnitModeItemUIState {
        return UnitModeItemUIState(key: "travelModeStateUpdated", number: NSNumber(value: isInTravelMode))
    }
}
