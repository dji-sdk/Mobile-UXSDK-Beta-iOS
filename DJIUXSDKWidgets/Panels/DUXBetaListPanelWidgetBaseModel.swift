//
//  DUXBetaListPanelWidgetBaseModel.swift
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

import Foundation

/**
 * DUXBetaListPanelWidgetBaseModel is the base widget model for DUXBetaListPanelWidgets. It contains the widgets to display in the ListPanel.
 */
@objc open class DUXBetaListPanelWidgetBaseModel : DUXBetaBaseWidgetModel {
    // MARK: - Public Variables
    /// The number of widgets contained in this model
    @objc dynamic var count: Int {
        get { return widgetList.count }
        // No setter as this is a dynamic read only property
    }
    
    // The widgetList array will be replaced every time a change is made. That allows us to receive
    // a KVO notification and update the UI
    @objc dynamic public var widgetList: [DUXBetaBaseWidget] = [DUXBetaBaseWidget]()
    
    // MARK: - Private Variables
    // Internal variable used to support SmartListModels
    fileprivate var smartModel: DUXBetaSmartListModel? = nil
    
    // MARK: - Public Methods
    /**
     * The method setSmartModel is used to add a SmartListModel into this model when it is first created.
     *
     * - Parameter smartModel: The DUXBetaSmartListModel to be used to changes this list for a normal ListPanel to a SmartListPanel
     */
    @objc open func set(smartModel: DUXBetaSmartListModel) {
        self.smartModel = smartModel
        self.smartModel?.setListPanelModel(self)
    }

    /**
     * The method setup is an override of the setup method for the DUXBetaBaseModelWidget which also sets up the smartModel if it exists.
     */
    @objc open override func setup() {
        super.setup()
        self.smartModel?.setup()
    }

    /**
     * The method setup is an override of the cleanup method for the DUXBetaBaseModelWidget which also cleans up the smartModel if it exists.
     */
    @objc open override func cleanup() {
        super.cleanup()
        self.smartModel?.cleanup()
    }

    /**
     * The method setWidgetsArray is used to set all the widgets to be displayed in the ListPanel if this is not a SmartListPanel.
     *
     * - Parameter inWidgetList: An array of DUXBetaBaseWidgets to set or replace the existing widgets in this model.
     */
    @objc func setWidgetsArray(_ inWidgetList: [DUXBetaBaseWidget]) {
        self.widgetList = [DUXBetaBaseWidget](inWidgetList)
    }

    /**
     * The method addWidgetsArray is used to add widgets to be displayed in the ListPanel if this is not a SmartListPanel.
     *
     * - Parameter inWidgetList: An array of DUXBetaBaseWidgets to be added to the existing widgets in the model.
     */
    @objc func addWidgetsArray(_ inWidgetList: [DUXBetaBaseWidget]) {
        var workList = self.widgetList
        workList.append(contentsOf:inWidgetList)
        self.widgetList = workList
    }
    
    /**
     * The method addWidget appends a single widget to be displayed in the ListPanel if this is not a SmartListPanel.
     *
     * - Parameter inWidget: A widget to be added to the existing widgets in the model.
     */
    @objc func addWidget(_ inWidget: DUXBetaBaseWidget) {
        var workList = self.widgetList
        workList.append(inWidget)
        self.widgetList = workList
    }
    
    /**
     * The method insertWidget inserts a single widget to be displayed in the ListPanel at the given index.
     *
     * - Parameter inWidget: A widget to be added to the existing widgets in the model.
     * - Parameter at: The location where the widget is to be inserted.
     */
    @objc func insertWidget(inWidget: DUXBetaBaseWidget, at index:Int) {
        var workList = self.widgetList
        workList.insert(inWidget, at: index)
        self.widgetList = workList
    }

    /**
     * The method removeWidget removes a single widget from the list of widgets.
     *
     * - Parameter atIndex: The index in the widget list to remove the widget from.
     */
    @objc func removeWidget(atIndex: Int) {
        var workList = self.widgetList
        workList.remove(at: atIndex)
        self.widgetList = workList
    }
    
    /**
     * The method removeAllWidgets removes all the widgets from the widget list, leaving an empty list.
     */
    @objc func removeAllWidgets() {
        self.widgetList = [DUXBetaBaseWidget]()
    }

    /**
     * The method widget is used to return the widget at a given index in the widget model list.
     */
    @objc func widget(at index: Int) -> DUXBetaBaseWidget {
        return widgetList[index]
    }
}
