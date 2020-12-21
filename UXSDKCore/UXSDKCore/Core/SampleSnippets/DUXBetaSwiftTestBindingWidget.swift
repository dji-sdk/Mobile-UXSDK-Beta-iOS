//
//  DUXBetaSwiftTestBindingWidget.swift
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
 Smaple snippet pseudo-widget to show how to bind and watch changes.
 */
import Foundation

@objc class DUXBetaSwiftTestModel: DUXBetaMaxAltitudeListItemWidgetModel {
    @objc dynamic var altitude = 0.0
        
    @objc func modelDidUpdate() {
        print(#file, #function)
    }
}

open class DUXBetaSwiftTestBindingWidget : DUXBetaBaseWidget {
    public override var widgetSizeHint : DUXBetaWidgetSizeHint {
        get { return DUXBetaWidgetSizeHint(preferredAspectRatio: (300 / 44), minimumWidth: 300, minimumHeight: 44)}
        set {
        }
    }

    @objc dynamic var maxAltitude:Double = 0
    @objc dynamic var model = DUXBetaSwiftTestModel()

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        model.setup()
        
        setupUI()
    }
    
    open override func viewWillAppear(_ animated: Bool) {

        let maxAltitudeKey = DJIFlightControllerKey(param: DJIFlightControllerParamMaxFlightHeight)
        self.bindSDKKey(maxAltitudeKey!, "maxAltitude")
        
        self.model.bindRKVOModel(self.model, #selector(DUXBetaSwiftTestModel.modelDidUpdate), (\DUXBetaSwiftTestModel.isProductConnected).toString, (\DUXBetaSwiftTestModel.rangeValue).toString)
//        bindRKVOModel(self, #selector(metaDataChanged), (\DUXBetaSwiftTestBindingWidget.model.isProductConnected).toString, (\DUXBetaSwiftTestBindingWidget.model.rangeValue).toString)
//        bindRKVOModel(self, #selector(altitudeChanged), (\DUXBetaSwiftTestBindingWidget.model.altitude).toString)
        bindRKVOModel(self, #selector(maxAltitudeChanged), (\DUXBetaSwiftTestBindingWidget.maxAltitude).toString)

        model.altitude = 1000
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        print(#file, #function)
        unbindSDK(self)
    }
    
    deinit {
        print(#file, #function)
    }
    
    @objc func setupUI() {
        
    }
    
    @objc open func metaDataChanged() {
        print(#file, #function)
        
        let hintRange = String.init(format: "%ld-%ldm", model.rangeValue.min.intValue, model.rangeValue.max.intValue)
        print(#file, #function, "\(hintRange)")
    }
    
    @objc open func maxAltitudeChanged() {
        print(#file, #function, "\(model.maxAltitude)")
    }

    @objc open func customMaxAltitudeChanged() {
        print(#file, #function, "\(model.maxAltitude)")
    }

    @objc open func altitudeChanged() {
        print(#file, #function, "\(model.altitude)")
    }
}
