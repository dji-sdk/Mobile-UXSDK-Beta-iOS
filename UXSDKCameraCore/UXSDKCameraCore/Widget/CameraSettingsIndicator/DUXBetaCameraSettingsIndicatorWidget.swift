//
//  DUXBetaCameraSettingsIndicatorWidget.swift
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

import UXSDKCore

/**
* Widget that indicates the current exposure mode.
*/
@objcMembers public class DUXBetaCameraSettingsIndicatorWidget: DUXBetaBaseWidget {
    
    // MARK: - Public Properties
    
    /// The widget model that contains the underlying logic and communication.
    public var widgetModel = DUXBetaCameraSettingsIndicatorWidgetModel()
    
    /// The widgetSizeHint indicates the actual widget size and its aspect ratio.
    public override var widgetSizeHint : DUXBetaWidgetSizeHint {
        get { return DUXBetaWidgetSizeHint(preferredAspectRatio: minWidgetSize.width/minWidgetSize.height, minimumWidth: minWidgetSize.width, minimumHeight: minWidgetSize.height)}
        set {}
    }
    
    /// The image for the product or camera disconnected state.
    public var disconnectedImage: UIImage = UIImage.duxbeta_image(withAssetNamed: "CameraSettingsIndicatorUnknown", for: DUXBetaCameraSettingsIndicatorWidget.self) {
        didSet {
            updateUI()
        }
    }
    
    /// The image tint color for the product or camera disconnected state.
    public var disconnectedTintColor: UIColor = .uxsdk_grayWhite50() {
        didSet {
            updateUI()
        }
    }
    
    /// Index of the camera the widget model is communicating with.
    dynamic public var cameraIndex: Int {
        set {
            widgetModel.cameraIndex = newValue
        }
        get {
            widgetModel.cameraIndex
        }
    }
    
    /// The background color of the widget.
    dynamic public var backgroundColor: UIColor = .uxsdk_clear() {
        didSet {
            view.backgroundColor = backgroundColor
        }
    }
    
    // MARK: - Private Properties
    
    fileprivate var imageMap: [DJICameraExposureMode : UIImage] = [
        DJICameraExposureMode.program : UIImage.duxbeta_image(withAssetNamed: "CameraSettingsIndicatorProgram", for: DUXBetaCameraSettingsIndicatorWidget.self),
        DJICameraExposureMode.shutterPriority : UIImage.duxbeta_image(withAssetNamed: "CameraSettingsIndicatorShutter", for: DUXBetaCameraSettingsIndicatorWidget.self),
        DJICameraExposureMode.aperturePriority : UIImage.duxbeta_image(withAssetNamed: "CameraSettingsIndicatorAperture", for: DUXBetaCameraSettingsIndicatorWidget.self),
        DJICameraExposureMode.manual : UIImage.duxbeta_image(withAssetNamed: "CameraSettingsIndicatorManual", for: DUXBetaCameraSettingsIndicatorWidget.self),
        DJICameraExposureMode.unknown : UIImage.duxbeta_image(withAssetNamed: "CameraSettingsIndicatorUnknown", for: DUXBetaCameraSettingsIndicatorWidget.self),
    ] {
        didSet {
            updateUI()
        }
    }
    
    fileprivate var imageTintColorMap: [DJICameraExposureMode : UIColor] = [
        DJICameraExposureMode.program : UIColor.uxsdk_white(),
        DJICameraExposureMode.shutterPriority : UIColor.uxsdk_white(),
        DJICameraExposureMode.aperturePriority : UIColor.uxsdk_white(),
        DJICameraExposureMode.manual : UIColor.uxsdk_white(),
        DJICameraExposureMode.unknown : UIColor.uxsdk_white(),
    ] {
        didSet {
            updateUI()
        }
    }
    
    fileprivate var button = UIButton()
    fileprivate var imageview = UIImageView()
    fileprivate var aspectRatioConstraint: NSLayoutConstraint?
    fileprivate var minWidgetSize = CGSize.zero {
        didSet {
            aspectRatioConstraint?.duxbeta_updateMultiplier(widgetSizeHint.preferredAspectRatio)
        }
    }
    
    // MARK: - Public Methods
    
    /**
     * Override of viewDidLoad to set up widget model and
     * to instantiate all the user interface elements.
    */
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        widgetModel.setup()
        setupUI()
    }
    
    /**
     * Override of viewWillAppear to establish bindings to the widgetModel.
     */
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add RKVO bindings
        bindRKVOModel(self, #selector(updateIsConnected),
                      (\DUXBetaCameraSettingsIndicatorWidget.widgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateState),
                      (\DUXBetaCameraSettingsIndicatorWidget.widgetModel.state.isProductDisconnected).toString,
                      (\DUXBetaCameraSettingsIndicatorWidget.widgetModel.state.isCameraDisconnected).toString,
                      (\DUXBetaCameraSettingsIndicatorWidget.widgetModel.state.cameraSettingsExposureMode).toString)
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
    
    
    /// Method for customizing the image to be displayed for the given exposure mode.
    ///
    /// - Parameters:
    ///   - image: The custom image
    ///   - exposureMode: The given exposure mode
    public func setImage(_ image: UIImage?, for exposureMode: DJICameraExposureMode) {
        imageMap[exposureMode] = image
        updateMinImageDimensions()
    }
    
    
    /// Method for retrieving the image displayed for the expopsure mode.
    ///
    /// - Parameter exposureMode: The given exposure mode
    /// - Returns: The UIImage currently displayed by the widget for the given exposure mode
    public func getImage(for exposureMode: DJICameraExposureMode) -> UIImage? {
        return imageMap[exposureMode]
    }
    
    /// Method for customizing the image tint color to be displayed for the given exposure mode.
    ///
    /// - Parameters:
    ///   - tintColor: The tint color value
    ///   - exposureMode: The given exposure mode
    public func setTintColor(_ tintColor: UIColor?, for exposureMode: DJICameraExposureMode) {
        imageTintColorMap[exposureMode] = tintColor
    }
    
    /// Method for retrieving the image displayed for the expopsure mode.
    ///
    /// - Parameter exposureMode: The given exposure mode
    /// - Returns: The UIColor currently displayed by the widget for the given exposure mode
    public func getTintColor(for exposureMode: DJICameraExposureMode) -> UIColor? {
        return imageTintColorMap[exposureMode]
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupUI() {
        view.backgroundColor = backgroundColor
        
        imageview.contentMode = .scaleAspectFit
        imageview.translatesAutoresizingMaskIntoConstraints = false
        updateIcon(image: getImage(for: .unknown), tintColor: getTintColor(for: .unknown))
        updateMinImageDimensions()
        
        button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(onTap), for: .touchUpInside)
        
        view.addSubview(imageview)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.topAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            button.leftAnchor.constraint(equalTo: view.leftAnchor),
            button.rightAnchor.constraint(equalTo: view.rightAnchor),
            imageview.topAnchor.constraint(equalTo: view.topAnchor),
            imageview.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageview.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageview.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        aspectRatioConstraint = view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: widgetSizeHint.preferredAspectRatio)
        aspectRatioConstraint?.isActive = true
    }
    
    func updateState() {
        // Forward the camera settings indicator state updates
        DUXBetaStateChangeBroadcaster.send(CameraSettingsIndicatorModelState.cameraSettingsIndicatorStateUpdated(widgetModel.state))
        
        updateUI()
    }
    
    func updateUI() {
        if widgetModel.state.isCameraDisconnected || widgetModel.state.isProductDisconnected {
            updateIcon(image: disconnectedImage, tintColor: disconnectedTintColor)
        } else {
            let mode = widgetModel.state.cameraSettingsExposureMode
            updateIcon(image: getImage(for: mode), tintColor: getTintColor(for: mode))
        }
    }
    
    @IBAction func onTap() {
        DUXBetaStateChangeBroadcaster.send(CameraSettingsIndicatorUIState.widgetTapped())
    }
    
    fileprivate func updateIcon(image: UIImage? = nil, tintColor: UIColor? = nil) {
        if let image = image {
            imageview.image = image.withRenderingMode(.alwaysTemplate)
        }
        if let color = tintColor {
            imageview.tintColor = color
        }
    }
    
    func updateMinImageDimensions() {
        minWidgetSize = maxSize(inImageArray: imageMap.map({ $0.value }))
        aspectRatioConstraint?.duxbeta_updateMultiplier(widgetSizeHint.preferredAspectRatio)
    }
    
    @objc func updateIsConnected() {
        //Forward the model change
        DUXBetaStateChangeBroadcaster.send(CameraSettingsIndicatorModelState.productConnected(widgetModel.isProductConnected))
    }
}

// MARK: - Hooks

/**
 * CameraSettingsIndicatorModelState contains the hooks for the model changes in the
 * DUXBetaCameraSettingsIndicatorWidget implementation.
 *
 * Key: productConnected                        Type: NSNumber - Sends a boolean value as an NSNumber
 *                                              when product connection state changes.
 *
 * Key: cameraSettingsIndicatorStateUpdated     Type: DUXBetaCameraSettingsIndicatorState - Sends the camera settings
 *                                              indicator state when it's updated.
*/
@objc public class CameraSettingsIndicatorModelState: DUXBetaStateChangeBaseData {

    @objc public static func productConnected(_ isConnected: Bool) -> CameraSettingsIndicatorModelState {
        return CameraSettingsIndicatorModelState(key: "productConnected", number: NSNumber(value: isConnected))
    }
    
    @objc public static func cameraSettingsIndicatorStateUpdated(_ state: DUXBetaCameraSettingsIndicatorState) -> CameraSettingsIndicatorModelState {
        return CameraSettingsIndicatorModelState(key: "cameraSettingsIndicatorStateUpdated", object: state)
    }
}

/**
 * CameraSettingsIndicatorUIState contains the hooks for the UI changes in the
 * DUXBetaCameraSettingsIndicatorWidget implementation.
 *
 * Key: widgetTapped                        Type: NSNumber - Sends true as an NSNumber when the widget is tapped.
*/
@objc public class CameraSettingsIndicatorUIState: DUXBetaStateChangeBaseData {
    
    @objc public static func widgetTapped() -> CameraSettingsIndicatorUIState {
        return CameraSettingsIndicatorUIState(key: "widgetTapped", number: NSNumber(value: true))
    }
}

