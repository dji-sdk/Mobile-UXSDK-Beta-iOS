//
//  DUXBetaSystemStatusListWidget.swift
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
 * DUXBetaSystemStatusListWidget is the ListPanel using a SmartModel to construct
 * and display a standardized system status list. This current release displays
 * the following widgets:
 *
 * - DUXBetaFlightModeWidget
 * - DUXBetaRCStickModeListItemWidget
 * - DUXBetaSDCardStatusListItemWidget
 * - DUXBetaMaxAltitudeListItemWidget
 *
*/
@objc public class DUXBetaSystemStatusListWidget: DUXBetaListPanelWidget {

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        let _ = self.setupSmartModel(DUXBetaSystemStatusListSmartModel())
    }

    override public init() {
        super.init()
        let _ = self.setupSmartModel(DUXBetaSystemStatusListSmartModel())
    }
    
    override public init(smartModel: DUXBetaSmartListModel) {
        super.init(smartModel: smartModel)
    }

    public override func defaultConfigurationSetup() {
        // Must configure this here before parent viewDidLoad since we are internally configuring
        // And must have the list type set properly
        let config = DUXBetaPanelWidgetConfiguration(type: .list, listKind: .widgets)
            .configureTitlebar(visible: true, withCloseBox: true, title: NSLocalizedString("System Status", comment: "System Status"))
            .configureColors(background: .duxbeta_listPanelBackground(), border: .duxbeta_clear(), titleBarBackground: .duxbeta_listPanelBackground())
        let _ = configure(config)
    }
    
}
