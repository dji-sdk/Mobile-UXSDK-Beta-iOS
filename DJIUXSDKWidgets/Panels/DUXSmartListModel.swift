//
//  DUXSmartListModel.swift
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

public typealias widgetID = String

@objc open class DUXSmartListModel : NSObject {
    open var modelClassnameList: [String] = [String]()

    fileprivate var containerModel: DUXListPanelWidgetBaseModel? = nil
    fileprivate var activeWidgetCount = 0
    fileprivate var totalWidgetCount = 0
    fileprivate var totalWidgetArray: [DUXBetaBaseWidget] = []
    fileprivate var activeWidgetArray: [DUXBetaBaseWidget] = []
    
    fileprivate var blacklist: [widgetID] = [widgetID]()

    public override init() {
        // This method sets up anything needed by the SmartModel and is invoked during creation, before injection happens
        super.init()
        // Set up all the default models here and install key listeners to
        // monitor for changes
        buildModelLists()
    }
    
    @objc public init(blacklist: [widgetID]) {
        // This method sets up anything needed by the SmartModel and is invoked during creation, before injection happens
        super.init()
        // Set up all the default models here and install key listeners to
        // monitor for changes
        self.blacklist = blacklist
        buildModelLists()
    }

    
    deinit {
        for widget in totalWidgetArray {
            widget.removeObserver(self, forKeyPath: "view.hidden")
        }
        unbindRKVOModel(self)
    }
    
    @objc public func setListPanelModel(_ lpwm : DUXListPanelWidgetBaseModel) -> Void {
        // This method should ideally be private and protected if possible, allowing only
        // the ListPanelWidget to access it as a friend (in C++ terminology)
        containerModel = lpwm
        
        // Now that we have the model to store and display our widgets, we need to instantiate and populate them.
        buildAndInstallWidgets()
        containerModel!.setWidgetsArray(activeWidgetArray)
    }
    
    // MARK: - Widget and count finding for visible and full lists
    @objc open func activeCount() -> Int {     // How many widgets are actually being shown in the list
        return activeWidgetCount
    }
    
    @objc open func totalCount() -> Int  {
        // How many widgets are alive, even any hidden widgets
        return totalWidgetCount
    }
    
    @objc open func activeWidgetAtIndex(index: Int) -> DUXBetaBaseWidget?  {
        // Fetch the widget from the list of displayed widgets. This will throw an exception if the
        // index is out of range
        return activeWidgetArray[index]
    }
    
    @objc open func widgetAtIndex(index: Int) -> DUXBetaBaseWidget? {
        // Fetch the widget from the list of all widgets, even hidden. This will throw an exception
        // if the index is out of range
        return totalWidgetArray[index]
    }
    
    @objc open func findActiveWidgetWithID(widgetID: String) -> DUXBetaBaseWidget? {
        // Search for a particular widget and return it if it exists and is shown or nil
        let (found, index) = findIndexByWidgetID(widgetID: widgetID, list: activeWidgetArray)
        if found {
            return activeWidgetArray[index]
        }
        return nil
    }
    
    @objc open func findWidgetWithID(widgetID: String) -> DUXBetaBaseWidget? {
        // Search for a particular widget and return it or nil
        let (found, index) = findIndexByWidgetID(widgetID: widgetID, list: totalWidgetArray)
        if found {
            return totalWidgetArray[index]
        }
        return nil
    }
    
    @objc open func findActiveWidgetIndexWithID(widgetID: String) -> Int {
        // Search for a particular widget and return it if it exists and is shown or nil
        let (found, index) = findIndexByWidgetID(widgetID: widgetID, list: activeWidgetArray)
        if found {
            return index
        }
        return NSNotFound
    }
    
    @objc open func findWidgetIndexWithID(widgetID: String) -> Int {
        // Search for a particular widget and return it or nil
        let (found, index) = findIndexByWidgetID(widgetID: widgetID, list: totalWidgetArray)
        if found {
            return index
        }
        return NSNotFound
    }
    
    /**
     IMPORTANT: The move functionality only works on the full widget list
     */
    @objc open func move(identifier: widgetID, toFullIndex: Int) {
    // This moves actual widgets in the display list order. Hidden widgets are included in the ordering
        let indexTuple = findIndexByWidgetID(widgetID: identifier, list: totalWidgetArray)
        if indexTuple.0 {
            let widget = totalWidgetArray.remove(at:indexTuple.1)
            totalWidgetArray.insert(widget, at:toFullIndex)
        }
    }
    
    @objc open func move(fromFullIndex: Int, toFullIndex: Int) {
        let widget = totalWidgetArray.remove(at:fromFullIndex)
        totalWidgetArray.insert(widget, at:toFullIndex)
    }
    
    // Implment the key binding code needed specifically for the smart model here
    // These are called by the DUXListPanelWidgetBaseModel from its setup/cleanup methods
    @objc open func setup() {
        
    }

    // Teardown the key bindings.
    @objc open func cleanup() {
        
    }

    // MARK: - List Crafting and Construction
    @objc open func buildModelLists() {
        // In concrete class, use the KeyManager to monitor which product you are connected to and adjust this list as needed, then call buildAndInstallWidgets to replace the currently list of widgets
        modelClassnameList = [
            DUXSDCardRemainingCapacityListItemWidget.duxbeta_className(),
            DUXRCStickModeListItemWidget.duxbeta_className(),
            DUXMaxAltitudeListItemWidget.duxbeta_className(),
            DUXFlightModeListItemWidget.duxbeta_className(),
//            self.className(DUXPreflightMaxDistanceWidget.self)
//            DUXPreflightCompassWidget,
//            DUXPreflightIMUWidget,
//            DUXPreflightESCWidget,
//            DUXPreflightVisionWidget
//            DUXRadioQualityChecklistItem
//            DUXAircraftBatteryChecklistItem
//            DUXAircraftBatteryTemperatureChecklistItem
//            DUXGimbalChecklistItem
//            DUXStorageCapacityChecklistItem
//            DUXStorageCapacityChecklistItem
//            DUXTravelModeChecklistItem
        ]
    }

    // MARK: - Widget Custom Initialization
    @objc open func customizeWidgetSetup(widget: DUXBetaBaseWidget) {
        // For custom customizations of differnt widgets, this method can be overridden
        // and any additional customization for select widgets can be done after they are created
    }
    
    // MARK: - Internal functions which may be overridden
    @objc open func buildAndInstallWidgets() {
        // Decide which list to use. Base class just uses the modelClassnameList. Specialized
        // ListSmartModels may overide this method to select different lists based on connected
        // aircraft or other customizations
        for className in modelClassnameList {
            let classInst = NSClassFromString(className) as? NSObject.Type
            // See if in blacklist and prevent adding if it is in there
            if !self.blacklist.contains(className) {
                if let widget = classInst!.init() as? DUXBetaBaseWidget {
                    customizeWidgetSetup(widget: widget)
                    totalWidgetArray.append(widget)
                    // Need to do standard KVO for this since we aren't holding the widget in
                    // a path accessible manner for this model class so there is no valid
                    // key path from this object to the widget property
                    widget.addObserver(self, forKeyPath: "view.hidden", options: .new, context: nil)

                    activeWidgetArray.append(widget)
                }
            }
        }

    }

    @objc open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let _ = object as? DUXBetaBaseWidget {
            if keyPath == "view.hidden" {
                // Visibility changed. Update the visible widget list
                self.buildVisibleWidgetList()
                if let cm = containerModel {
                    cm.setWidgetsArray(activeWidgetArray)
                }
            } else {
                print("Bad keyPath observed (\(String(describing: keyPath))) in ListSmartModel")
            }
        } else {
            print("Bad observing for non-widget (\(String(describing:object)) in ListSmartModel")
        }
    }
    
    // This is a shorter rebuild version of the buildAndInstallWidgets which only rebuilds
    // the visible widdet list.
    @objc open func buildVisibleWidgetList() {
        var newVisibleList: [DUXBetaBaseWidget] = [DUXBetaBaseWidget]()
        for widget in totalWidgetArray {
            if !widget.view.isHidden {
                newVisibleList.append(widget)
            }
        }
        activeWidgetArray = newVisibleList
    }
    
    // MARK: - Internal functions to not be overridden
    internal func findIndexByWidgetID(widgetID : String, list: [DUXBetaBaseWidget]) -> (Bool, Int) {
        for (index, aWidget) in list.enumerated() {
            let fullString = aWidget.duxbeta_className()
            let className = String(fullString.split(separator: ".").last!)
            if className == widgetID {
                return (true, index)
            }
        }
        return (false, NSNotFound)
    }
    
    // This method returns the class name with no module attached to the name
    internal func className(_ some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }

}
