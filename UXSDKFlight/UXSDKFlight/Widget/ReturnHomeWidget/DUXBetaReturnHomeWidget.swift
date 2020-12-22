//
//  DUXBetaReturnHomeWidget.swift
//  UXSDKFlight
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
import UXSDKCore

let kReturnToHomeDistanceThreshold = 20.0
let kReturnToHomeAtCurrentAltitudeMinimum = 3.0

/**
 * Enum that defines the type of the shown dialog.
 */
@objc public enum DUXBetaReturnHomeWidgetDialogType: Int {
    /**
     * The return to home dialog, which is shown when widget is clicked and the aircraft is ready
     * to return to home.
     */
    case ReturnHomeDialog
}

/**
* A button that performs actions related to returning home. There are two possible states for the
* widget: ready to return home, and returning home in progress. Clicking the button when the
* aircraft is ready to return home will open a dialog to confirm returning to home.
*/

@objcMembers public class DUXBetaReturnHomeWidget: DUXBetaBaseWidget {
    /// The widget model that contains the underlying logic and communication.
    public var widgetModel = DUXBetaReturnHomeWidgetModel()
    /// The image for the return to home action.
    public var returnHomeActionImage = UIImage.duxbeta_image(withAssetNamed: "ReturnHome", for: DUXBetaReturnHomeWidget.self) {
        didSet {
            updateMinimumSize()
            updateActionIcon(image: returnHomeActionImage)
        }
    }
    /// The image for the cancel return to home action.
    public var cancelReturnHomeActionImage = UIImage.duxbeta_image(withAssetNamed: "ReturnHomeStop", for: DUXBetaReturnHomeWidget.self) {
        didSet {
            updateMinimumSize()
            updateActionIcon(image: cancelReturnHomeActionImage)
        }
    }
    /// The image for the cancel return to home action disabled.
    public var cancelReturnHomeActionDisabledImage = UIImage.duxbeta_image(withAssetNamed: "ReturnHomeStopDisabled", for: DUXBetaReturnHomeWidget.self) {
        didSet {
            updateMinimumSize()
            updateActionIcon(image: cancelReturnHomeActionDisabledImage)
        }
    }
    /// The background color of the control.
    public var backgroundColor = UIColor.uxsdk_clear() {
        didSet {
            view.backgroundColor = backgroundColor
        }
    }
    /// The image tint color for the return to home action.
    public var returnHomeActionTintColor = UIColor.uxsdk_white() {
        didSet {
            updateActionIcon(tintColor: returnHomeActionTintColor)
        }
    }
    /// The image tint color for the cancel return to home action.
    public var cancelReturnHomeActionTintColor = UIColor.uxsdk_clear() {
        didSet {
            updateActionIcon(tintColor: cancelReturnHomeActionTintColor)
        }
    }
    /// The image tint color for the cancel return to home action disabled.
    public var cancelReturnHomeActionDisabledTintColor = UIColor.uxsdk_grayWhite50() {
        didSet {
            updateActionIcon(tintColor: cancelReturnHomeActionDisabledTintColor)
        }
    }
    /// The image for the return to home alert.
    public var returnHomeAlertImage = UIImage.duxbeta_image(withAssetNamed: "ReturnHomeAlert", for: DUXBetaReturnHomeWidget.self)
    /// The image tint color for the return to home alert.
    public var returnHomeAlertTintColor = UIColor.uxsdk_warning()
    /// The customization instance that controls the appearance of the alert.
    public var alertAppearance = DUXBetaSlideAlertView.slideAlertAppearance
    /// The customization instance that controls the appearance of the dialog cancel action.
    public var alertCancelActionAppearance = DUXBetaSlideAlertView.cancelActionAppearance
    /// The standard widgetSizeHint indicating the minimum size for this widget and preferred aspect ratio.
    public override var widgetSizeHint : DUXBetaWidgetSizeHint {
        get { return DUXBetaWidgetSizeHint(preferredAspectRatio: minWidgetSize.width/minWidgetSize.height,
                                       minimumWidth: minWidgetSize.width,
                                       minimumHeight: minWidgetSize.height)}
        set {
        }
    }
    /// The alpha of the image when the widget is disabled.
    var disabledAlpha: CGFloat = 0.38
    /// The alpha of the image when the widget is enabled.
    var enabledAlpha: CGFloat = 1.0
    
    fileprivate var minWidgetSize = CGSize.zero {
        didSet {
            aspectRatioConstraint?.duxbeta_updateMultiplier(widgetSizeHint.preferredAspectRatio)
        }
    }
    fileprivate var aspectRatioConstraint: NSLayoutConstraint?
    fileprivate var button: UIButton!
    fileprivate var imageView: UIImageView!
    fileprivate var alertView: DUXBetaSlideAlertView?
    fileprivate var alertMessage: String {
        let distanceToHome = widgetModel.distanceToHome
        if distanceToHome < kReturnToHomeDistanceThreshold {
            if distanceToHome > kReturnToHomeAtCurrentAltitudeMinimum && widgetModel.isRTHAtCurrentAltitudeEnabled {
                return NSLocalizedString("The distance between the aircraft and Home Point is less than 65.6 ft (20 m). The aircraft will return home at its current altitude if RTH is initiated.", comment: "Return To Home Alert at current altitude")
            } else {
                return NSLocalizedString("The aircraft is less than 20 m (65.6 ft) from the Home Point. The aircraft will land if Return to Home is initiated.", comment: "Return To Home Alert at current altitude minimum")
            }
        } else {
            if widgetModel.rthFlyzoneState == .nearNoFlyZone {
                return NSLocalizedString("Approaching a No-Fly Zone. Current RTH route may be distorted. Monitor the aircraft\'s flight path on the map or visually to ensure safety.", comment: "Return To Home Alert Near No-Fly Zone")
            } else if ProductUtil.isProductWiFiConnected() {
                return NSLocalizedString("Aircraft will head to home point and set RTH route. Use virtual joystick to adjust flight direction. Tap Cancel RTH button to stop RTH.", comment: "Return To Home Alert when Wifi connected")
            } else {
                return NSLocalizedString("Aircraft will adjust its nose direction to face the home point, and its altitude to \(widgetModel.unitModule.meters(toUnitString: widgetModel.currentGoHomeHeightInMeters)). Current aircraft altitude is \(widgetModel.unitModule.meters(toUnitString: widgetModel.currentAircraftAltitudeInMeters)). Press Return to Home button directly on your remote to cancel this procedure, or take over control sticks.", comment: "Return To Home Default Alert")
            }
        }
    }
    
    /**
     * Override of viewDidLoad to set up widget model and
     * to instantiate all the user interface elements.
    */
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        setupUI()
        widgetModel.setup()
    }
    
    /**
     * Override of viewWillAppear to establish bindings to the widgetModel.
     */
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaReturnHomeWidget.widgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateUI), (\DUXBetaReturnHomeWidget.widgetModel.state).toString)
    }
    
    /**
     * Override of viewWillDisappear to clean up bindings to the widgetModel
     */
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unbindRKVOModel(self)
    }
    
    /**
     * Standard dealloc method that performs cleanup of the widget model.
     */
    deinit {
        widgetModel.cleanup()
    }
    
    @objc func updateIsConnected() {
        //Forward the model change
        DUXBetaStateChangeBroadcaster.send(ReturnHomeModelState.productConnected(widgetModel.isProductConnected))
    }
    
    fileprivate func setupUI() {
        updateMinimumSize()
        
        view.backgroundColor = backgroundColor
        view.isUserInteractionEnabled = true
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        updateActionIcon(image: cancelReturnHomeActionImage, tintColor: cancelReturnHomeActionTintColor)
        
        button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
        view.addSubview(imageView)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.topAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            button.leftAnchor.constraint(equalTo: view.leftAnchor),
            button.rightAnchor.constraint(equalTo: view.rightAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: widgetSizeHint.preferredAspectRatio)
        ])
        aspectRatioConstraint = view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: widgetSizeHint.preferredAspectRatio)
    }
    
    func buttonPressed() {
        DUXBetaStateChangeBroadcaster.send(ReturnHomeUIState.widgetTapped())
        
        switch widgetModel.state {
            case .ReadyToReturnHome:
                showReturnHomeDialog()
            default:
                performCancelReturnHomeAction()
        }
    }
    
    func updateUI() {
        let actionEnabled = !(widgetModel.state == .ReturnHomeDisabled || widgetModel.state == .ForcedReturningToHome)

        var shouldApplyAlpha = true
        switch widgetModel.state {
            case .ReadyToReturnHome:
                fallthrough
            case .ReturnHomeDisabled:
                updateActionIcon(image: returnHomeActionImage, tintColor: returnHomeActionTintColor)
                break
            case .ReturningHome:
                fallthrough
            case .ForcedReturningToHome:
                if actionEnabled {
                    updateActionIcon(image: cancelReturnHomeActionImage, tintColor: cancelReturnHomeActionTintColor)
                } else {
                    shouldApplyAlpha = false
                    updateActionIcon(image: cancelReturnHomeActionDisabledImage, tintColor: cancelReturnHomeActionDisabledTintColor)
                }
                break
            default:
                break
        }

        button.isEnabled = actionEnabled
        view.alpha = actionEnabled ? enabledAlpha : disabledAlpha
        view.isHidden = widgetModel.state == .AutoLanding || widgetModel.state == .Disconnected
        
        if !shouldApplyAlpha {
            view.alpha = enabledAlpha
        }
        
        DUXBetaStateChangeBroadcaster.send(ReturnHomeModelState.returnHomeStateUpdated(widgetModel.state))
    }
    
    fileprivate func updateMinimumSize() {
        var images = [UIImage]()
        if let image = returnHomeActionImage {
            images.append(image)
        }
        if let image = cancelReturnHomeActionDisabledImage {
            images.append(image)
        }
        if let image = cancelReturnHomeActionImage {
            images.append(image)
        }
        minWidgetSize = maxSize(inImageArray: images)
    }
    
    fileprivate func updateActionIcon(image: UIImage? = nil, tintColor: UIColor? = nil) {
        if let image = image {
            if image == cancelReturnHomeActionImage {
                imageView.image = image
            } else {
                imageView.image = image.withRenderingMode(.alwaysTemplate)
            }
        }
        if let color = tintColor {
            imageView.tintColor = color
        }
    }
    
    fileprivate func showReturnHomeDialog() {
        alertView = DUXBetaSlideAlertView()
        alertView?.image = returnHomeAlertImage
        alertView?.titleText = NSLocalizedString("Return home and land?", comment: "Return home and land?")
        alertView?.slideAppearance.slideMessageText = NSLocalizedString("Slide to Return Home", comment: "Slide to Return Home")
        alertView?.message = alertMessage
        alertView?.slideAppearance.isCheckboxVisible = false
        alertView?.onSlideCompleted = { [weak self] (completed) in
            self?.alertView?.close(withCompletion: { [weak self] in
                DUXBetaStateChangeBroadcaster.send(ReturnHomeUIState.dialogActionConfirmed(.ReturnHomeDialog))
                self?.performReturnHomeAction()
                self?.alertView = nil
            })
        }
        
        let cancelAction = DUXBetaAlertAction.action(actionTitle: NSLocalizedString("Cancel", comment: "Cancel"),
                                                 style: .default,
                                                 actionType: .closure)
        cancelAction.appearance = alertCancelActionAppearance
        
        let dismissCompletion = { [weak self] () in
            self?.alertView = nil
            DUXBetaStateChangeBroadcaster.send(ReturnHomeUIState.dialogDismissed(.ReturnHomeDialog))
        }
        
        let cancelCompletion = { [weak self] () in
            self?.alertView = nil
            DUXBetaStateChangeBroadcaster.send(ReturnHomeUIState.dialogActionCanceled(.ReturnHomeDialog))
        }

        alertView?.dissmissCompletion = dismissCompletion
        cancelAction.action = cancelCompletion
        
        alertView?.add(cancelAction)
        
        alertView?.appearance = alertAppearance
        alertView?.appearance.imageTintColor = returnHomeAlertTintColor
        alertView?.show(withCompletion: {
            DUXBetaStateChangeBroadcaster.send(ReturnHomeUIState.dialogDisplayed(.ReturnHomeDialog))
        })
    }
    
    fileprivate func performReturnHomeAction() {
        widgetModel.performReturnHomeAction({ (error) in
            if let err = error {
                DUXBetaStateChangeBroadcaster.send(ReturnHomeModelState.returnHomeStartFailed(err))
            } else {
                DUXBetaStateChangeBroadcaster.send(ReturnHomeModelState.returnHomeStartSucceeded())
            }
        })
    }
    
    fileprivate func performCancelReturnHomeAction() {
        widgetModel.performCancelReturnHomeAction { (error) in
            if let err = error {
                DUXBetaStateChangeBroadcaster.send(ReturnHomeModelState.returnHomeCancelFailed(err))
            } else {
                DUXBetaStateChangeBroadcaster.send(ReturnHomeModelState.returnHomeCancelSucceeded())
            }
        }
    }
}

/**
 * ReturnHomeModelState contains the hooks for the model changes in the
 * ReturnHomeWidget implementation.
 *
 * Key: productConnected                    Type: NSNumber - Sends a boolean value as an NSNumber
 *                                          when product connection state changes.
 *
 * Key: returnHomeStartSucceeded            Type: NSNumber - Sends an NSNumber value when widget
 *                                          state is updated.
 *
 * Key: dialogDisplayed                     Type: NSNumber - Sends true as an NSNumber value when
 *                                          return home started successfully.
 *
 * Key: returnHomeStartFailed               Type: NSError - Sends an NSError as an object when
 *                                          return home has not started due to an error.
 *
 * Key: returnHomeCancelSucceeded           Type: NSNumber - Sends true as an NSNumber value when
 *                                          return home cancellation started successfully.
 *
 * Key: returnHomeCancelFailed              Type: NSError - Sends an NSError as an object when
 *                                          return home cancellation has not started due to an error.
*/
@objc public class ReturnHomeModelState: DUXBetaStateChangeBaseData {

    @objc public static func productConnected(_ isConnected: Bool) -> ReturnHomeModelState {
        return ReturnHomeModelState(key: "productConnected", number: NSNumber(value: isConnected))
    }

    @objc public static func returnHomeStateUpdated(_ state: DUXBetaReturnHomeState) -> ReturnHomeModelState {
        return ReturnHomeModelState(key: "returnHomeStateUpdated", number: NSNumber(value: state.rawValue))
    }
    
    @objc public static func returnHomeStartSucceeded() -> ReturnHomeModelState {
        return ReturnHomeModelState(key: "returnHomeStartSucceeded", number: NSNumber(value: true))
    }
    
    @objc public static func returnHomeStartFailed(_ error: Error) -> ReturnHomeModelState {
        return ReturnHomeModelState(key: "returnHomeStartFailed", object: error)
    }
    
    @objc public static func returnHomeCancelSucceeded() -> ReturnHomeModelState {
        return ReturnHomeModelState(key: "returnHomeCancelSucceeded", number: NSNumber(value: true))
    }
    
    @objc public static func returnHomeCancelFailed(_ error: Error) -> ReturnHomeModelState {
        return ReturnHomeModelState(key: "returnHomeCancelFailed", object: error)
    }
}

/**
 * ReturnHomeUIState contains the hooks for the UI changes in the
 * ReturnHomeWidget implementation.
 *
 * Key: widgetTapped                            Type: NSNumber - Sends true as an NSNumber when
 *                                              the widget is tapped.
 *
 * Key: dialogDisplayed                         Type: NSNumber - Sends dialogType as an NSNumber
 *                                              when dialog is shown.
 *
 * Key: dialogDismissed                         Type: NSNumber - Sends dialogType as an NSNumber
 *                                              when dialog is canceled.
 *
 * Key: dialogActionConfirmed                   Type: NSNumber - Sends dialogType as an NSNumber
 *                                              when dialog sliding action is completed.
 *
 * Key: dialogActionCanceled                    Type: NSNumber - Sends dialogType as an NSNumber
 *                                              when is cancelled.
*/
@objc public class ReturnHomeUIState: DUXBetaStateChangeBaseData {
    
    @objc public static func widgetTapped() -> ReturnHomeUIState {
        return ReturnHomeUIState(key: "widgetTapped", number: NSNumber(value: true))
    }
    
    @objc public static func dialogDisplayed(_ dialogType: DUXBetaReturnHomeWidgetDialogType) -> ReturnHomeUIState {
        return ReturnHomeUIState(key: "dialogDisplayed", number: NSNumber(value: dialogType.rawValue))
    }
    
    @objc public static func dialogDismissed(_ dialogType: DUXBetaReturnHomeWidgetDialogType) -> ReturnHomeUIState {
        return ReturnHomeUIState(key: "dialogDismissed", number: NSNumber(value: dialogType.rawValue))
    }
    
    @objc public static func dialogActionConfirmed(_ dialogType: DUXBetaReturnHomeWidgetDialogType) -> ReturnHomeUIState {
        return ReturnHomeUIState(key: "dialogActionConfirmed", number: NSNumber(value: dialogType.rawValue))
    }
    
    @objc public static func dialogActionCanceled(_ dialogType: DUXBetaReturnHomeWidgetDialogType) -> ReturnHomeUIState {
        return ReturnHomeUIState(key: "dialogActionCanceled", number: NSNumber(value: dialogType.rawValue))
    }

}

