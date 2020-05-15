//
//  DUXListPanelWidgetBaseModel.swift
//  DJIUXSDKWidgets
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

import Foundation

@objc open class DUXListPanelWidgetBaseModel : DUXBetaBaseWidgetModel {
    @objc dynamic var count: Int {
        get { return widgetList.count }
        // No setter as this is a dynamic read only property
    }
    
    fileprivate var smartModel: DUXSmartListModel? = nil
    
    @objc open func set(smartModel: DUXSmartListModel) {
        self.smartModel = smartModel
        self.smartModel?.setListPanelModel(self)
    }

    // This list will be replaced every time a change is made. That allows us to receive
    // a KVO notification and update the UI
    @objc dynamic public var widgetList: [DUXBetaBaseWidget] = [DUXBetaBaseWidget]()

    @objc open override func setup() {
        super.setup()
        self.smartModel?.setup()
    }

    @objc open override func cleanup() {
        super.cleanup()
        self.smartModel?.cleanup()
    }

    @objc func setWidgetsArray(_ inWidgetList: [DUXBetaBaseWidget]) {
        self.widgetList = [DUXBetaBaseWidget](inWidgetList)
    }

    @objc func addWidgetsArray(_ inWidgetList: [DUXBetaBaseWidget]) {
        var workList = self.widgetList
        workList.append(contentsOf:inWidgetList)
        self.widgetList = workList
    }
    
    @objc func addWidget(_ inWidget: DUXBetaBaseWidget) {
        var workList = self.widgetList
        workList.append(inWidget)
        self.widgetList = workList
    }
    
    @objc func insertWidget(inWidget: DUXBetaBaseWidget, at index:Int) {
        var workList = self.widgetList
        workList.insert(inWidget, at: index)
        self.widgetList = workList
    }

    @objc func removeWidget(atIndex: Int) {
        var workList = self.widgetList
        workList.remove(at: atIndex)
        self.widgetList = workList
    }
    
    @objc func removeAllWidgets() {
        self.widgetList = [DUXBetaBaseWidget]()
    }

    
    @objc func widget(at index: Int) -> DUXBetaBaseWidget {
        return widgetList[index]
    }
}
