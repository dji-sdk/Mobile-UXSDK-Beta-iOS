//
//  CameraConfigShutterWidget.swift
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


/**
 * The class DUXBetaCameraConfigShutterWidget is a simple widget which displays the SHUTTER label and below that
 * shows the current shutter speed. Whole numbers are 1/number, number" are that shutter speed in seconds (>= 1).
 * This widget will show N/A if an aircraft isn't connected.
 */
@objcMembers open class DUXBetaCameraConfigShutterWidget : DUXBetaBaseCameraConfigWidget {
    // MARK: - Public Variables
    public var widgetModel = DUXBetaCameraConfigShutterWidgetModel()

    // MARK: - Private Variables
    fileprivate let speedNames = makeSpeedNamesDict()
    
    /**
     * Override of viewDidLoad to setup base widget, widget specific string settings, and the widget model
     */
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        labelString = NSLocalizedString("SHUTTER", comment:"SHUTTER speed for camera")
        valueColor = .uxsdk_selectedBlue()
        
        widgetModel.setup()

    }

    /**
     * Override of viewWillAppear to set up the model bindings for this widget
     */
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
        bindRKVOModel(self, #selector(updateProductConnected), (\DUXBetaCameraConfigShutterWidget.widgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateShutterSpeed), (\DUXBetaCameraConfigShutterWidget.widgetModel.shutterSpeed).toString)
    }
    
    /**
     * Override of viewWillDisappear to unbind the model
     */
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unbindRKVOModel(self)
    }

    deinit {
        widgetModel.cleanup()
    }
    
    open func updateProductConnected() {
        isConnected = widgetModel.isProductConnected
        updateShutterSpeed()
    }
    
    open func updateShutterSpeed() {
        if !isConnected {
            valueString = NSLocalizedString("N/A", comment: "N/A")
        } else {
            if let speedStr = speedNames[widgetModel.shutterSpeed] {
                valueString = speedStr
            } else {
                valueString = NSLocalizedString("Unknown", comment:"Unknown")
            }
        }
    }

    /// Method to build conversion dictionary for all the shutter speeds for display.
    static func makeSpeedNamesDict() -> [DJICameraShutterSpeed : String] {
        return [
            .speed1_20000 : "20000",
            .speed1_16000 : "16000",
            .speed1_12800 : "12800",
            .speed1_10000 : "10000",
            .speed1_8000  : "8000",
            .speed1_6400  : "6400",
            .speed1_6000  : "6000",
            .speed1_5000  : "5000",
            .speed1_4000  : "4000",
            .speed1_3200  : "3200",
            .speed1_3000  : "3000",
            .speed1_2500  : "2500",
            .speed1_2000  : "2000",
            .speed1_1500  : "1500",
            .speed1_1600  : "1600",
            .speed1_1250  : "1250",
            .speed1_1000  : "1000",
            .speed1_800   : "800",
            .speed1_750   : "750",
            .speed1_725   : "725",
            .speed1_640   : "640",
            .speed1_500   : "500",
            .speed1_400   : "400",
            .speed1_350   : "350",
            .speed1_320   : "320",
            .speed1_240   : "240",
            .speed1_200   : "200",
            .speed1_180   : "180",
            .speed1_160   : "160",
            .speed1_100   : "100",
            .speed1_90    : "90",
            .speed1_80    : "80",
            .speed1_60    : "60",
            .speed1_50    : "50",
            .speed1_45    : "45",
            .speed1_40    : "40",
            .speed1_30    : "30",
            .speed1_25    : "25",
            .speed1_20    : "20",
            .speed1_15    : "15",
            .speed1_12Dot5: "12.5",
            .speed1_8     : "8",
            .speed1_6Dot25: "6.25",
            .speed1_6     : "6",
            .speed1_5     : "5",
            .speed1_4     : "4",
            .speed1_3     : "3",
            .speed1_2Dot5 : "2.5",
            .speed0Dot3   : ".3",
            .speed1_2     : "2",
            .speed1_1Dot67: "1.67",
            .speed1_1Dot25: "1.25",
            .speed0Dot7   : "0.7",
            .speed1       : "1\"",
            .speed1Dot3   : "1.3\"",
            .speed1Dot4   : "1.4\"",
            .speed1Dot6   : "1.6\"",
            .speed2       : "2\"",
            .speed2Dot5   : "2.5\"",
            .speed3       : "3\"",
            .speed3Dot2   : "3.2\"",
            .speed4       : "4\"",
            .speed5       : "5\"",
            .speed6       : "6\"",
            .speed7       : "7\"",
            .speed8       : "8\"",
            .speed9       : "9\"",
            .speed10      : "10\"",
            .speed11      : "11\"",
            .speed13      : "13\"",
            .speed15      : "15\"",
            .speed16      : "16\"",
            .speed20      : "20\"",
            .speed23      : "23\"",
            .speed25      : "25\"",
            .speed30      : "30\"",
            //            Specifically do not include Unknown in the translation dictionary so we can do a localized "Unknown" value
            //            .speedUnknown : "Unknown"
        ]
    }
}
