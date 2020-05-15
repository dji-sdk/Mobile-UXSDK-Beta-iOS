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
    /**
     *  Preferred widget size
    */
    let kDesignSize = CGSize(width: 230, height: 100)
    
    /**
     *  The widgetSizeHint indicates the actual widget size and its aspect ratio
    */
    public override var widgetSizeHint : DUXBetaWidgetSizeHint {
        get { return DUXBetaWidgetSizeHint(preferredAspectRatio: kDesignSize.width/kDesignSize.height, minimumWidth: kDesignSize.width, minimumHeight: kDesignSize.height)}
        set {
        }
    }
    
    /**
    *   The view displaying a custom center point image.
    */
    @objc public var centerView: DUXBetaFPVCenterView!

    /**
    *  The view displaying the customized grid lines.
    */
    @objc public var gridView: DUXBetaFPVGridView!
    
    /**
    *   The preferred camera index used when displaying the feed.
    */
    @objc public var preferredCameraIndex = 0 {
        didSet {
            widgetModel?.preferredCameraIndex = preferredCameraIndex
        }
    }
    
    /**
    *   The vertical offset in percentage used when positioning the camera name and camera side details relative to the top margin.
    */
    @objc public var cameraDetailsVerticalAlignment: CGFloat = 0.2 {
        didSet {
            cameraStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: cameraDetailsVerticalAlignment * view.frame.height).isActive = true
            view.setNeedsLayout()
        }
    }
    
    /**
    *   Controls the visibility of the displayed camera name
    */
    @objc public var isCameraNameVisible: Bool = true {
        didSet {
            cameraNameLabel.isHidden = !isCameraNameVisible
        }
    }
    
    /**
    *   The font used to display the camera name.
    */
    @objc public var cameraNameFont: UIFont = UIFont.systemFont(ofSize: 10.0) {
        didSet {
            cameraNameLabel.font = cameraNameFont
        }
    }
    
    /**
    *   The text color used to display the camera name.
    */
    @objc public var cameraNameTextColor: UIColor = UIColor.duxbeta_white() {
        didSet {
            cameraNameLabel.textColor = cameraNameTextColor
        }
    }
    
    /**
    *   The background color of the displayed camera name.
    */
    @objc public var cameraNameBackgroundColor: UIColor = UIColor.duxbeta_fpvTextBackground() {
        didSet {
            cameraNameLabel.backgroundColor = cameraNameBackgroundColor
        }
    }
    
    /**
    *    Controls the visibility of the displayed camera side.
    */
    @objc public var isCameraSideVisible: Bool = true {
        didSet {
            cameraSideLabel.isHidden = !isCameraSideVisible
        }
    }
    
    /**
    *   The font used to display the camera side.
    */
    @objc public var cameraSideFont: UIFont = UIFont.systemFont(ofSize: 10.0) {
        didSet {
            cameraSideLabel.font = cameraSideFont
        }
    }
    
    /**
    *   The text color used to display the camera side.
    */
    @objc public var cameraSideTextColor: UIColor = UIColor.duxbeta_white() {
        didSet {
            cameraSideLabel.textColor = cameraSideTextColor
        }
    }
    
    /**
    *   The background color of the displayed camera side.
    */
    @objc public var cameraSideBackgroundColor = UIColor.duxbeta_fpvTextBackground() {
        didSet {
            cameraSideLabel.backgroundColor = cameraSideBackgroundColor
        }
    }
    
    /**
    *   Controls the visibility of the grid line view.
    */
    @objc public var isGridViewVisible = true {
        didSet {
            gridView.isHidden = !isGridViewVisible
        }
    }
    
    /**
    *   Controls the visibility of the center point view.
    */
    @objc public var isCenterViewVisible = true {
        didSet {
            centerView.isHidden = !isCenterViewVisible
        }
    }
    
    /**
    *   Controls the height of the center point view by specifying a height percentage related to the wideget's center point.
    */
    @objc public var centerViewHeightPercentage: CGFloat = 0.1 {
        didSet {
            centerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: centerViewHeightPercentage).isActive = true
            view.setNeedsLayout()
        }
    }
    
    /**
    *   Controls the width of the center point view by specifying a height percentage related to the widget's center point.
    */
    @objc public var centerViewWidthPercentage: CGFloat = 0.1 {
        didSet {
            centerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: centerViewWidthPercentage).isActive = true
            view.setNeedsLayout()
        }
    }
    
    @objc public var decodeAdapter: DUXBetaFPVDecodeAdapter?
    @objc public var widgetModel: DUXBetaFPVWidgetModel?
    
    fileprivate var fpvView: UIView!
    fileprivate var cameraNameLabel: UILabel!
    fileprivate var cameraSideLabel: UILabel!
    fileprivate var cameraStackView: UIStackView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        setupUI()
        if let videoFeed = DJISDKManager.videoFeeder()?.primaryVideoFeed {
            //Initialize and setup the widget's model
            widgetModel = DUXBetaFPVWidgetModel(withVideoFeed: videoFeed)
            widgetModel?.setup()
                
            //Initialize and setup the decoding model
            decodeAdapter = DUXBetaFPVDecodeAdapter(videoFeed: videoFeed)
            decodeAdapter?.widgetModel = widgetModel
            decodeAdapter?.start()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Bind widget to react to model updates
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaFPVWidget.widgetModel?.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateCameraName), (\DUXBetaFPVWidget.widgetModel?.displayedCameraName).toString)
        bindRKVOModel(self, #selector(updateCameraSide), (\DUXBetaFPVWidget.widgetModel?.displayedCameraSide).toString)
        bindRKVOModel(self, #selector(updateGridFrame), (\DUXBetaFPVWidget.widgetModel?.cameraMode).toString, (\DUXBetaFPVWidget.widgetModel?.photoAspectRatio).toString, (\DUXBetaFPVWidget.widgetModel?.videoResolutionAndFrameRate).toString)
        
        decodeAdapter?.setRenderingView(fpvView)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        decodeAdapter?.stop()
        decodeAdapter?.removeRenderingView()
        
        unbindRKVOModel(self)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        activateConstraints()
        decodeAdapter?.adjustPreviewer()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateGridFrame()
    }
    
    deinit {
        widgetModel?.cleanup()
    }
    
    @objc func updateIsConnected() {
        guard let widgetModel = widgetModel else {
            return
        }
        
        //Forward the model change
        DUXStateChangeBroadcaster.send(DUXFPVWidgetModelState.productConnected(widgetModel.isProductConnected))
    }
    
    @objc func updateCameraName() {
        guard let widgetModel = widgetModel else {
            return
        }
        cameraNameLabel.text = widgetModel.displayedCameraName
        
        //Forward the model change
        DUXStateChangeBroadcaster.send(DUXFPVWidgetModelState.cameraNameUpdate(widgetModel.displayedCameraName))
    }
    
    @objc func updateCameraSide() {
        guard let widgetModel = widgetModel else {
            return
        }
        
        cameraSideLabel.text = widgetModel.displayedCameraSide
        
        //Forward the model change
        if let cameraSide = widgetModel.displayedCameraSide {
            DUXStateChangeBroadcaster.send(DUXFPVWidgetModelState.cameraSideUpdate(cameraSide))
        }
    }
    
    @objc func updateGridFrame() {
        guard let widgetModel = widgetModel else {
            return
        }
        
        //Set the container frame in the widget model in order to compute the gridFrame
        widgetModel.containerFrame  = fpvView.bounds
        
        //Update the grid frame only if it has changed
        if !gridView.frame.equalTo(widgetModel.gridFrame) {
            gridView.frame = widgetModel.gridFrame
            gridView.redraw()
            
            //Forward the user interface change
            DUXStateChangeBroadcaster.send(DUXFPVWidgetUIState.gridFrameUpdate(widgetModel.gridFrame))
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
        
        centerView = DUXBetaFPVCenterView(frame: CGRect.zero)
        centerView.isHidden = !isCenterViewVisible
        centerView.translatesAutoresizingMaskIntoConstraints = false
        
        gridView = DUXBetaFPVGridView()
        gridView.isHidden = !isGridViewVisible
        gridView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(fpvView)
        view.addSubview(gridView)
        view.addSubview(centerView)
        view.addSubview(cameraStackView)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            fpvView.topAnchor.constraint(equalTo: view.topAnchor),
            fpvView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fpvView.leftAnchor.constraint(equalTo: view.leftAnchor),
            fpvView.rightAnchor.constraint(equalTo: view.rightAnchor),
            cameraStackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            cameraStackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            cameraStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: cameraDetailsVerticalAlignment * view.frame.height),
            centerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: centerViewWidthPercentage),
            centerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: centerViewHeightPercentage),
            view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: widgetSizeHint.preferredAspectRatio)
        ])
    }
}

/*
 * Abstraction that provides hooks in events received by the fpv widget from the widget model.
 */
@objc public class DUXFPVWidgetModelState: DUXStateChangeBaseData {
    
    /*
     *  Event sent when product is connected or disconnected.
     */
    @objc public static func productConnected(_ isConnected: Bool) -> DUXFPVWidgetModelState {
        return DUXFPVWidgetModelState(key: "productConnected", number: NSNumber(value: isConnected))
    }
    
    /*
    *  Event sent when camera name is updated.
    */
    @objc public static func cameraNameUpdate(_ cameraName: String) -> DUXFPVWidgetModelState {
        return DUXFPVWidgetModelState(key: "cameraNameUpdate", string: cameraName)
    }
    
    /*
    *  Event sent when camera side is updated.
    */
    @objc public static func cameraSideUpdate(_ cameraSide: String) -> DUXFPVWidgetModelState {
        return DUXFPVWidgetModelState(key: "cameraSideUpdate", string: cameraSide)
    }
    
    /*
    *  Event sent when encoding type is updated.
    */
    @objc public static func encodeTypeUpdate(_ encodeType: H264EncoderType) -> DUXFPVWidgetModelState {
        return DUXFPVWidgetModelState(key: "encodeTypeUpdate", number: NSNumber(value: encodeType.rawValue))
    }
    
    /*
    *  Event sent when decoding is successful for a given timestamp.
    */
    @objc public static func decodingDidSucceedWithTimestamp(_ timestamp: UInt32) -> DUXFPVWidgetModelState {
        return DUXFPVWidgetModelState(key: "decodingDidSucceedWithTimestamp", number: NSNumber(value: timestamp))
    }
    
    /*
    *  Event sent when decoding failed.
    */
    @objc public static func decodingDidFail() -> DUXFPVWidgetModelState {
        return DUXFPVWidgetModelState(key: "decodingDidFail", number: NSNumber(value: 0))
    }
    
    /*
    *  Event sent when the physical source is updated.
    */
    @objc public static func physicalSourceUpdate(_ physicalSource: DJIVideoFeedPhysicalSource) -> DUXFPVWidgetModelState {
        return DUXFPVWidgetModelState(key: "physicalSourceUpdate", number: NSNumber(value: physicalSource.rawValue))
    }
}

/*
* Abstraction that provides hooks in events received by the fpv widget from the user interface.
*/
@objc public class DUXFPVWidgetUIState: DUXStateChangeBaseData {
    /*
    *  Event sent when the grid line view frame is updated.
    */
    @objc public static func gridFrameUpdate(_ gridFrame: CGRect) -> DUXFPVWidgetModelState {
        return DUXFPVWidgetModelState(key: "gridFrameUpdated", value: NSValue(cgRect: gridFrame))
    }
    
    /*
    *  Event sent when the fpv content view frame is updated
    */
    @objc public static func contentFrameUpdate(_ contentFrame: CGRect) -> DUXFPVWidgetModelState {
        return DUXFPVWidgetModelState(key: "contentFrameUpdate", value: NSValue(cgRect: contentFrame))
    }
}
