//
//  DUXBetaFPVWidget.swift
//  DJIUXSDKWidgets
//
//  MIT License
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

/**
 *  This widget shows the video feed from the camera.
*/
@objc public class DUXBetaFPVWidget: DUXBetaBaseWidget {
    
    /// Preferred widget size
    let kDesignSize = CGSize(width: 230, height: 100)
    
    /// The widgetSizeHint indicates the actual widget size and its aspect ratio.
    public override var widgetSizeHint : DUXBetaWidgetSizeHint {
        get { return DUXBetaWidgetSizeHint(preferredAspectRatio: kDesignSize.width/kDesignSize.height, minimumWidth: kDesignSize.width, minimumHeight: kDesignSize.height)}
        set {
        }
    }
    
    /// The camera feed currently being rendered on screen.
    @objc public var videoFeed: DJIVideoFeed? = DJISDKManager.videoFeeder()?.primaryVideoFeed {
        didSet {
            widgetModel.videoFeed = videoFeed
            decodeAdapter.videoFeed = videoFeed
        }
    }
    
    /// The view displaying a custom center point image.
    @objc public var centerView: DUXBetaFPVCenterView!

    /// The view displaying the customized grid lines.
    @objc public var gridView: DUXBetaFPVGridView!
    
    /// The preferred camera index used when displaying the feed.
    @objc public var preferredCameraIndex = 0 {
        didSet {
            widgetModel.preferredCameraIndex = preferredCameraIndex
        }
    }
    
    /// The vertical offset in percentage used when positioning the camera name and camera side details relative to the top margin.
    @objc public var cameraDetailsVerticalAlignment: CGFloat = 0.2 {
        didSet {
            cameraDetailsVerticalConstraint.isActive = false
            cameraDetailsVerticalConstraint = cameraStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: cameraDetailsVerticalAlignment * view.frame.height)
            cameraDetailsVerticalConstraint.isActive = true
            view.setNeedsLayout()
        }
    }
    

    /// The horizontal offset in percentage used when positioning the camera name and camera side details relative to the left margin.
    @objc public var cameraDetailsHorizontalAlignment: CGFloat = 0.0 {
        didSet {
            cameraDetailsHorizontalConstraint.isActive = false
            cameraDetailsHorizontalConstraint = cameraStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: cameraDetailsHorizontalAlignment * view.frame.width)
            cameraDetailsHorizontalConstraint.isActive = true
            view.setNeedsLayout()
        }
    }
    
    /// Controls the visibility of the displayed camera name.
    @objc public var isCameraNameVisible: Bool = true {
        didSet {
            cameraNameLabel.isHidden = !isCameraNameVisible
        }
    }

    ///  The font used to display the camera name.
    @objc public var cameraNameFont: UIFont = UIFont.systemFont(ofSize: 10.0) {
        didSet {
            cameraNameLabel.font = cameraNameFont
        }
    }
    
    /// The text color used to display the camera name.
    @objc public var cameraNameTextColor: UIColor = UIColor.duxbeta_white() {
        didSet {
            cameraNameLabel.textColor = cameraNameTextColor
        }
    }
    
    /// The background color of the displayed camera name.
    @objc public var cameraNameBackgroundColor: UIColor = UIColor.duxbeta_fpvTextBackground() {
        didSet {
            cameraNameLabel.backgroundColor = cameraNameBackgroundColor
        }
    }
    
    /// Controls the visibility of the displayed camera side.
    @objc public var isCameraSideVisible: Bool = true {
        didSet {
            cameraSideLabel.isHidden = !isCameraSideVisible
        }
    }

    /// The font used to display the camera side.
    @objc public var cameraSideFont: UIFont = UIFont.systemFont(ofSize: 10.0) {
        didSet {
            cameraSideLabel.font = cameraSideFont
        }
    }

    ///  The text color used to display the camera side.
    @objc public var cameraSideTextColor: UIColor = UIColor.duxbeta_white() {
        didSet {
            cameraSideLabel.textColor = cameraSideTextColor
        }
    }

    /// The background color of the displayed camera side.
    @objc public var cameraSideBackgroundColor = UIColor.duxbeta_fpvTextBackground() {
        didSet {
            cameraSideLabel.backgroundColor = cameraSideBackgroundColor
        }
    }
    
    /// Controls the visibility of the grid line view.
    @objc public var isGridViewVisible = true {
        didSet {
            gridView.isHidden = !isGridViewVisible
        }
    }
    
    /// Controls the visibility of the center point view.
    @objc public var isCenterViewVisible = true {
        didSet {
            centerView.isHidden = !isCenterViewVisible
        }
    }
    
    /// Controls the height of the center point view by specifying a height percentage related to the wideget's center point.
    @objc public var centerViewHeightPercentage: CGFloat = 0.1 {
        didSet {
            centerViewHeightConstraint.isActive = false
            centerViewHeightConstraint = centerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: centerViewHeightPercentage)
            centerViewHeightConstraint.isActive = true
            view.setNeedsLayout()
        }
    }
    
    /// Controls the width of the center point view by specifying a height percentage related to the widget's center point.
    @objc public var centerViewWidthPercentage: CGFloat = 0.1 {
        didSet {
            centerViewWidthConstraint.isActive = false
            centerViewWidthConstraint = centerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: centerViewWidthPercentage)
            centerViewWidthConstraint.isActive = true
            view.setNeedsLayout()
        }
    }
    
    /// Controls if the stream decoding is done using the software decoder or the hardware decoder of the device.
    @objc public var enableHardwareDecode: Bool = true {
        didSet {
            updateHardwareDecoding()
        }
    }
    
    @objc public var widgetModel = DUXBetaFPVWidgetModel()
    @objc public var decodeAdapter = DUXBetaFPVDecodeAdapter()
    
    fileprivate var fpvView: UIView!
    fileprivate var cameraNameLabel: UILabel!
    fileprivate var cameraSideLabel: UILabel!
    fileprivate var cameraStackView: UIStackView!
    
    fileprivate var centerViewWidthConstraint: NSLayoutConstraint!
    fileprivate var centerViewHeightConstraint: NSLayoutConstraint!
    fileprivate var cameraDetailsVerticalConstraint: NSLayoutConstraint!
    fileprivate var cameraDetailsHorizontalConstraint: NSLayoutConstraint!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        setupUI()
        
        //Setup the widget's model
        widgetModel.videoFeed = videoFeed
        widgetModel.setup()
        
        //Setup the decoding model
        decodeAdapter.widgetModel = widgetModel
        decodeAdapter.enableHardwareDecode = enableHardwareDecode
        if let videoFeed = videoFeed {
            decodeAdapter.start(with: videoFeed)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Bind widget to react to model updates
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaFPVWidget.widgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateCameraName), (\DUXBetaFPVWidget.widgetModel.displayedCameraName).toString)
        bindRKVOModel(self, #selector(updateCameraSide), (\DUXBetaFPVWidget.widgetModel.displayedCameraSide).toString)
        bindRKVOModel(self, #selector(updateGridFrame), (\DUXBetaFPVWidget.widgetModel.cameraMode).toString, (\DUXBetaFPVWidget.widgetModel.photoAspectRatio).toString, (\DUXBetaFPVWidget.widgetModel.videoResolutionAndFrameRate).toString)
        
        decodeAdapter.setRenderingView(fpvView)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
                
        decodeAdapter.stop()
        decodeAdapter.removeRenderingView()
        
        unbindRKVOModel(self)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        activateConstraints()
        decodeAdapter.adjustPreviewer()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateGridFrame()
    }
    
    deinit {
        widgetModel.cleanup()
    }
    
    @objc func updateIsConnected() {
        //Forward the model change
        DUXBetaStateChangeBroadcaster.send(DUXBetaFPVWidgetModelState.productConnected(widgetModel.isProductConnected))
    }
    
    func updateHardwareDecoding() {
        decodeAdapter.enableHardwareDecode = enableHardwareDecode
    }
    
    @objc func updateCameraName() {
        cameraNameLabel.text = widgetModel.displayedCameraName
        
        //Forward the model change
        DUXBetaStateChangeBroadcaster.send(DUXBetaFPVWidgetModelState.cameraNameUpdate(widgetModel.displayedCameraName))
    }
    
    @objc func updateCameraSide() {
        cameraSideLabel.text = widgetModel.displayedCameraSide
        
        //Forward the model change
        if let cameraSide = widgetModel.displayedCameraSide {
            DUXBetaStateChangeBroadcaster.send(DUXBetaFPVWidgetModelState.cameraSideUpdate(cameraSide))
        }
    }
    
    @objc func updateGridFrame() {
        //Set the container frame in the widget model in order to compute the gridFrame
        widgetModel.containerFrame  = fpvView.bounds
        
        //Update the grid frame only if it has changed
        if !gridView.frame.equalTo(widgetModel.gridFrame) {
            gridView.frame = widgetModel.gridFrame
            gridView.redraw()
            
            //Forward the user interface change
            DUXBetaStateChangeBroadcaster.send(DUXBetaFPVWidgetUIState.gridFrameUpdate(widgetModel.gridFrame))
        }
    }
    
    private func setupUI() {
        fpvView = UIView()
        fpvView.translatesAutoresizingMaskIntoConstraints = false
        fpvView.isOpaque = true
        fpvView.clipsToBounds = true
        fpvView.backgroundColor = UIColor.duxbeta_fpvBackground()
        fpvView.clearsContextBeforeDrawing = true
        
        cameraNameLabel = UILabel()
        cameraNameLabel.font = cameraNameFont
        cameraNameLabel.isHidden = !isCameraNameVisible
        cameraNameLabel.textColor = cameraNameTextColor
        cameraNameLabel.backgroundColor = cameraNameBackgroundColor
        
        cameraSideLabel = UILabel()
        cameraSideLabel.font = cameraSideFont
        cameraSideLabel.isHidden = !isCameraSideVisible
        cameraSideLabel.textColor = cameraSideTextColor
        cameraSideLabel.backgroundColor = cameraSideBackgroundColor
        
        cameraStackView = UIStackView(arrangedSubviews: [cameraNameLabel, cameraSideLabel])
        cameraStackView.translatesAutoresizingMaskIntoConstraints = false
        cameraStackView.axis = .vertical
        cameraStackView.spacing = 2.0
        cameraStackView.alignment = .center
        cameraStackView.distribution = .fillProportionally
        cameraStackView.backgroundColor = .clear
        
        if DUXBetaSingleton.sharedGlobalPreferences().centerViewType() == .Unknown {
            DUXBetaSingleton.sharedGlobalPreferences().set(centerViewType: .None)
        }
        if DUXBetaSingleton.sharedGlobalPreferences().centerViewColor() == .Unknown {
            DUXBetaSingleton.sharedGlobalPreferences().set(centerViewColor: .None)
        }
        centerView = DUXBetaFPVCenterView(frame: CGRect.zero)
        centerView.isHidden = !isCenterViewVisible
        centerView.translatesAutoresizingMaskIntoConstraints = false
        
        if DUXBetaSingleton.sharedGlobalPreferences().gridViewType() == .Unknown {
            DUXBetaSingleton.sharedGlobalPreferences().set(gridViewType: .None)
        }
        gridView = DUXBetaFPVGridView()
        gridView.isHidden = !isGridViewVisible
        gridView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(fpvView)
        view.addSubview(gridView)
        view.addSubview(centerView)
        view.addSubview(cameraStackView)
    }
    
    private func activateConstraints() {
        centerViewWidthConstraint = centerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: centerViewWidthPercentage)
        centerViewHeightConstraint = centerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: centerViewHeightPercentage)
        cameraDetailsVerticalConstraint = cameraStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: cameraDetailsVerticalAlignment * view.frame.height)
        cameraDetailsHorizontalConstraint = cameraStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: cameraDetailsHorizontalAlignment * view.frame.width)
        
        NSLayoutConstraint.activate([
            fpvView.topAnchor.constraint(equalTo: view.topAnchor),
            fpvView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fpvView.leftAnchor.constraint(equalTo: view.leftAnchor),
            fpvView.rightAnchor.constraint(equalTo: view.rightAnchor),
            cameraDetailsVerticalConstraint,
            cameraDetailsHorizontalConstraint,
            cameraStackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            centerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerViewWidthConstraint,
            centerViewHeightConstraint,
            view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: widgetSizeHint.preferredAspectRatio)
        ])
    }
}

/**
 * DUXBetaFPVWidgetModelState contains the hooks for the model changes in the
 * DUXBetaFPVWidget implementation.
 *
 * Key: productConnected                                     Type: NSNumber - Sends a boolean value as an NSNumber
 *                                      when the product connection state changes.
 *
 * Key: cameraNameUpdate                                 Type: NSString - Sends a NSString value when camera name is updated.
 *
 * Key: cameraSideUpdate                                    Type: NSString - Sends a NSString value when camera side is updated.
 *
 * Key: encodeTypeUpdate                                    Type: NSNumber - Sends the encode type as an NSNumber
 *                                       when encoding type is updated.
 *
 * Key: decodingDidSucceedWithTimestamp        Type: NSNumber - Sends the timestamp as an NSNumber
 *                                       when decoding is successful for a given timestamp.
 *
 * Key: decodingDidFail                                         Type: NSNumber - Sends 0 as an NSNumber when decoding fails.
 *
 * Key: physicalSourceUpdate                               Type: NSNumber - Sends the video physical value as an NSNumber
 *                                       when the physical source is updated.
*/

@objc public class DUXBetaFPVWidgetModelState: DUXBetaStateChangeBaseData {

    @objc public static func productConnected(_ isConnected: Bool) -> DUXBetaFPVWidgetModelState {
        return DUXBetaFPVWidgetModelState(key: "productConnected", number: NSNumber(value: isConnected))
    }

    @objc public static func cameraNameUpdate(_ cameraName: String) -> DUXBetaFPVWidgetModelState {
        return DUXBetaFPVWidgetModelState(key: "cameraNameUpdate", string: cameraName)
    }
    
    @objc public static func cameraSideUpdate(_ cameraSide: String) -> DUXBetaFPVWidgetModelState {
        return DUXBetaFPVWidgetModelState(key: "cameraSideUpdate", string: cameraSide)
    }
    
    @objc public static func encodeTypeUpdate(_ encodeType: H264EncoderType) -> DUXBetaFPVWidgetModelState {
        return DUXBetaFPVWidgetModelState(key: "encodeTypeUpdate", number: NSNumber(value: encodeType.rawValue))
    }
    
    @objc public static func decodingDidSucceedWithTimestamp(_ timestamp: UInt32) -> DUXBetaFPVWidgetModelState {
        return DUXBetaFPVWidgetModelState(key: "decodingDidSucceedWithTimestamp", number: NSNumber(value: timestamp))
    }
    
    @objc public static func decodingDidFail() -> DUXBetaFPVWidgetModelState {
        return DUXBetaFPVWidgetModelState(key: "decodingDidFail", number: NSNumber(value: 0))
    }
    
    @objc public static func physicalSourceUpdate(_ physicalSource: DJIVideoFeedPhysicalSource) -> DUXBetaFPVWidgetModelState {
        return DUXBetaFPVWidgetModelState(key: "physicalSourceUpdate", number: NSNumber(value: physicalSource.rawValue))
    }
}

/**
 * DUXBetaFPVWidgetUIState contains the hooks for the UI changes in the
 * DUXBetaFPVWidget implementation.
 *
 * Key: gridFrameUpdate                                     Type: NSValue - Sends a CGRrect as an NSValue
 *                                      when the grid line view frame is updated.
 *
 * Key: contentFrameUpdate                                 Type: NSString - Sends a CGRrect as an NSValue
 *                                      when the fpv content view frame is updated.
 */
@objc public class DUXBetaFPVWidgetUIState: DUXBetaStateChangeBaseData {
    
    @objc public static func gridFrameUpdate(_ gridFrame: CGRect) -> DUXBetaFPVWidgetModelState {
        return DUXBetaFPVWidgetModelState(key: "gridFrameUpdated", value: NSValue(cgRect: gridFrame))
    }
    
    @objc public static func contentFrameUpdate(_ contentFrame: CGRect) -> DUXBetaFPVWidgetModelState {
        return DUXBetaFPVWidgetModelState(key: "contentFrameUpdate", value: NSValue(cgRect: contentFrame))
    }
}
