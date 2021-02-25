//
//  DUXBetaPhotoVideoSwitchWidget.swift
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
*  Widget used to switch between shoot photo mode and record video mode.
*/
@objcMembers public class DUXBetaPhotoVideoSwitchWidget: DUXBetaBaseWidget {
    
    // MARK: - Public Properties
    
    /// The widget model that contains the underlying logic and communication.
    public var widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()

    /// The widgetSizeHint indicates the actual widget size and its aspect ratio.
    public override var widgetSizeHint : DUXBetaWidgetSizeHint {
        get { return DUXBetaWidgetSizeHint(preferredAspectRatio: minWidgetSize.width/minWidgetSize.height, minimumWidth: minWidgetSize.width, minimumHeight: minWidgetSize.height)}
        set {
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
    /// The tint color of the icon when product disconnected or camera disabled.
    dynamic public var disconnectedTintColor: UIColor = .uxsdk_disabledGrayWhite58()
    /// The image of the icon when in photo mode.
    dynamic public var photoModeImage: UIImage? = .duxbeta_image(withAssetNamed: "PhotoMode", for: DUXBetaPhotoVideoSwitchWidget.self)
    /// The tint color of the icon when in video mode.
    dynamic public var photoModeTintColor: UIColor = .uxsdk_white()
    /// The image of the icon when in video mode.
    dynamic public var videoModeImage: UIImage? = .duxbeta_image(withAssetNamed: "VideoMode", for: DUXBetaPhotoVideoSwitchWidget.self)
    /// The tint color of the icon when in video mode.
    dynamic public var videoModeTintColor: UIColor = .uxsdk_white()
    /// The background color of the widget.
    dynamic public var backgroundColor: UIColor = .uxsdk_clear() {
        didSet {
            view.backgroundColor = backgroundColor
        }
    }
    
    // MARK: - Private Properties
    
    var button = UIButton()
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
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaPhotoVideoSwitchWidget.widgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateState), (\DUXBetaPhotoVideoSwitchWidget.widgetModel.state).toString)
        bindRKVOModel(self, #selector(updateMinImageDimensions),
                      (\DUXBetaPhotoVideoSwitchWidget.photoModeImage).toString,
                      (\DUXBetaPhotoVideoSwitchWidget.videoModeImage).toString)
        bindRKVOModel(self, #selector(updateUI),
                      (\DUXBetaPhotoVideoSwitchWidget.disconnectedTintColor).toString,
                      (\DUXBetaPhotoVideoSwitchWidget.photoModeImage).toString,
                      (\DUXBetaPhotoVideoSwitchWidget.photoModeTintColor).toString,
                      (\DUXBetaPhotoVideoSwitchWidget.videoModeImage).toString,
                      (\DUXBetaPhotoVideoSwitchWidget.videoModeTintColor).toString)
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
    
    // MARK: - Private Methods
    
    fileprivate func setupUI() {
        view.backgroundColor = backgroundColor
        
        imageview.image = photoModeImage?.withRenderingMode(.alwaysTemplate)
        minWidgetSize = photoModeImage!.size
        imageview.contentMode = .scaleAspectFit
        imageview.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    func updateUI() {
        if widgetModel.state == .ProductDisconnected || widgetModel.state == .Disabled {
            imageview.isUserInteractionEnabled = false
            updateIcon(tintColor: disconnectedTintColor)
        } else if widgetModel.state == .PhotoMode {
            imageview.isUserInteractionEnabled = true
            updateIcon(image: photoModeImage, tintColor: photoModeTintColor)
        } else if widgetModel.state == .VideoMode {
            imageview.isUserInteractionEnabled = true
            updateIcon(image: videoModeImage, tintColor: videoModeTintColor)
        }
    }
    
    func updateState() {
        //Forward the model state change
        DUXBetaStateChangeBroadcaster.send(PhotoVideoSwitchModelState.photoVideoStateUpdated(widgetModel.state))
        
        updateUI()
    }
    
    func updateMinImageDimensions() {
        guard let photoModeImage = photoModeImage else { return }
        guard let videoModeImage = videoModeImage else { return }
        minWidgetSize = maxSize(inImageArray: [photoModeImage, videoModeImage])
        aspectRatioConstraint?.duxbeta_updateMultiplier(widgetSizeHint.preferredAspectRatio)
    }
    
    @IBAction func onTap() {
        DUXBetaStateChangeBroadcaster.send(PhotoVideoSwitchUIState.widgetTapped())
        
        if widgetModel.state == .VideoMode || widgetModel.state == .PhotoMode {
            widgetModel.toggleCameraMode { (error) in
                
            }
        }
    }
    
    fileprivate func updateIcon(image: UIImage? = nil, tintColor: UIColor? = nil) {
        if let image = image {
            imageview.image = image.withRenderingMode(.alwaysTemplate)
        }
        if let color = tintColor {
            imageview.tintColor = color
        }
    }
    
    @objc func updateIsConnected() {
        //Forward the model change
        DUXBetaStateChangeBroadcaster.send(PhotoVideoSwitchModelState.productConnected(widgetModel.isProductConnected))
    }
}

// MARK: - Hooks

/**
 * PhotoVideoSwitchModelState contains the hooks for the model changes in the
 * DUXBetaPhotoVideoSwitchWidget implementation.
 *
 * Key: productConnected                    Type: NSNumber - Sends a boolean value as an NSNumber
 *                                          when product connection state changes.
 *
 * Key: photoVideoStateUpdated              Type: NSNumber - Sends an integer value as an NSNumber
 *                                          when the mode of the camera changes.
*/
@objc public class PhotoVideoSwitchModelState: DUXBetaStateChangeBaseData {

    @objc public static func productConnected(_ isConnected: Bool) -> PhotoVideoSwitchModelState {
        return PhotoVideoSwitchModelState(key: "productConnected", number: NSNumber(value: isConnected))
    }
    
    @objc public static func photoVideoStateUpdated(_ state: DUXBetaPhotoVideoSwitchState) -> PhotoVideoSwitchModelState {
        return PhotoVideoSwitchModelState(key: "photoVideoStateUpdated", number: NSNumber(value: state.rawValue))
    }
}

/**
 * PhotoVideoSwitchUIState contains the hooks for the UI changes in the
 * DUXBetaPhotoVideoSwitchWidget implementation.
 *
 * Key: widgetTapped                        Type: NSNumber - Sends true as an NSNumber when the widget is tapped.
*/
@objc public class PhotoVideoSwitchUIState: DUXBetaStateChangeBaseData {
    
    @objc public static func widgetTapped() -> PhotoVideoSwitchUIState {
        return PhotoVideoSwitchUIState(key: "widgetTapped", number: NSNumber(value: true))
    }
}

