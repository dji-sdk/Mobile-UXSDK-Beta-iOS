//
//  DUXBetaSystemStatusListSmartModel.swift
//  UXSDKCore
//
//  MIT License
//
//  Copyright © 2019-2020 DJI
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
 * DUXBetaSystemStatusListSmartModel is the concrete class for implementing the SystemStatusSmartListModel. It defines
 * the widgets which will be included in the SmartList.
 */
@objc open class DUXBetaSystemStatusListSmartModel : DUXBetaSmartListModel {

    /**
     * Override of buildModelLists to set up the widgts to display in the SystemStatusListWidget.
     */
    @objc open override func buildModelLists() {
            if (self.internalModel.isProductConnected) {
                var isInternalStorageSupported = false
                if let camKey = DJICameraKey(index: 0, andParam: DJICameraParamIsInternalStorageSupported) {
                    if let  internalStorageValue = DJISDKManager.keyManager()?.getValueFor(camKey) {
                        isInternalStorageSupported = internalStorageValue.boolValue
                    }
                }
                let isInspire2 = self.internalModel.aircraftModel == DJIAircraftModelNameInspire2
                let isInspireSeries = isInspire2 || ProductUtil.isInspire1Series()
                
                modelClassnameList = [
                    DUXBetaOverviewListItemWidget.duxbeta_className(),
                    DUXBetaReturnToHomeAltitudeListItemWidget.duxbeta_className(),
                    DUXBetaMaxAltitudeListItemWidget.duxbeta_className(),
                    DUXBetaMaxFlightDistanceListItemWidget.duxbeta_className(),
                    DUXBetaFlightModeListItemWidget.duxbeta_className(),
                    DUXBetaRCStickModeListItemWidget.duxbeta_className(),
                    DUXBetaRCBatteryListItemWidget.duxbeta_className(),
                    DUXBetaSDCardStatusListItemWidget.duxbeta_className(),
                ]
                if (isInternalStorageSupported) {
                    modelClassnameList.append(DUXBetaEMMCStatusListItemWidget.duxbeta_className())
                }
                if (isInspire2) {
                    modelClassnameList.append(DUXBetaSSDStatusListItemWidget.duxbeta_className())
                }
                if (isInspireSeries) {
                    modelClassnameList.append(DUXBetaTravelModeListItemWidget.duxbeta_className())
                }
                modelClassnameList.append(contentsOf:[
                    DUXBetaNoviceModeListItemWidget.duxbeta_className(),
                     DUXBetaUnitModeListItemWidget.duxbeta_className(),
                ])
            } else {
                modelClassnameList = [
                    DUXBetaOverviewListItemWidget.duxbeta_className(),
                    DUXBetaReturnToHomeAltitudeListItemWidget.duxbeta_className(),
                    DUXBetaMaxAltitudeListItemWidget.duxbeta_className(),
                    DUXBetaMaxFlightDistanceListItemWidget.duxbeta_className(),
                    DUXBetaFlightModeListItemWidget.duxbeta_className(),
                    DUXBetaRCStickModeListItemWidget.duxbeta_className(),
                    DUXBetaRCBatteryListItemWidget.duxbeta_className(),
                    DUXBetaSDCardStatusListItemWidget.duxbeta_className(),
                    DUXBetaNoviceModeListItemWidget.duxbeta_className(),
                    DUXBetaUnitModeListItemWidget.duxbeta_className(),
        //            self.className(DUXBetaPreflightMaxDistanceWidget.self)
        //            DUXBetaPreflightCompassWidget,
        //            DUXBetaPreflightIMUWidget,
        //            DUXBetaPreflightESCWidget,
        //            DUXBetaPreflightVisionWidget
        //            DUXBetaRadioQualityChecklistItem
        //            DUXBetaAircraftBatteryChecklistItem
        //            DUXBetaAircraftBatteryTemperatureChecklistItem
        //            DUXBetaGimbalChecklistItem
        //            DUXBetaStorageCapacityChecklistItem
        //            DUXBetaStorageCapacityChecklistItem
                ]
            }
    }
}
