//
//  InternalWidgetsListViewController.swift
//  UXSDKSampleApp
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

import UIKit
import UXSDKVisualCamera

protocol InternalWidgetSelectionDelegate: class {
    func widgetSelected(_ widget: DUXBetaBaseWidget?)
}

class InternalWidgetsListViewController: UITableViewController, DJIVideoFeedListener {
    
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData rawData: Data) {
        let videoData = rawData as NSData
        let videoBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: videoData.length)
        videoData.getBytes(videoBuffer, length: videoData.length)
        DJIVideoPreviewer.instance().push(videoBuffer, length: Int32(videoData.length))
    }
    
    weak var delegate: InternalWidgetSelectionDelegate?
    var widgetsClassNames:[String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.widgetsClassNames = DUXBetaRuntimeUtility.listOfSubclasses(ofClassName: "DUXBetaBaseWidget")
    }
    
    @IBAction func close () {
        self.dismiss(animated: true) { }
    }
    
    // MARK: UITableViewDelegate
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let className = widgetsClassNames[indexPath.row]
        if let klass = NSClassFromString(className),
            let widget = DUXBetaRuntimeUtility.instance(of: klass) as? DUXBetaBaseWidget {
            delegate?.widgetSelected(widget)
            if let singleWidgetViewController = delegate as? InternalSingleWidgetViewController {
                singleWidgetViewController.title = className;
                if widget.isKind(of: DUXBetaColorWaveFormWidget.self) {
                    if let waveFormWidget = widget as? DUXBetaColorWaveFormWidget {
                        singleWidgetViewController.configureFPV()
                        waveFormWidget.previewer.type = .autoAdapt
                        waveFormWidget.previewer.start()
                        waveFormWidget.previewer.reset()
                        DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
                        DJIVideoPreviewer.instance()?.setView(singleWidgetViewController.videoView)
                    }
                }
                else if widget.isKind(of: DUXBetaBarPanelWidget.self) {
                    singleWidgetViewController.configureBarPanel()
                } else if widget.isKind(of: DUXBetaToolbarPanelWidget.self) {
                    singleWidgetViewController.configureToolbarPanel()
                } else if widget.isKind(of: DUXBetaListPanelWidget.self) {
                    singleWidgetViewController.configureListPanel()
                } else if widget.isKind(of: DUXBetaListItemRadioButtonWidget.self) {
                    singleWidgetViewController.configureListItemRadiosButtonWidget()
                }
                else if widget.isKind(of:DUXBetaListItemSwitchWidget.self) {
                    if let singleWidgetViewController = delegate as? InternalSingleWidgetViewController {
                        singleWidgetViewController.configureGenericOptionSwitchWidget()
                    }
                }
                splitViewController?.showDetailViewController(singleWidgetViewController, sender: nil)
                
            }
        }
    }
    
    // MARK: UITableViewDataSource
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return widgetsClassNames.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WidgetsListCellIdentifier", for: indexPath)
        var className = widgetsClassNames[indexPath.row]
        if className.hasPrefix("DJIUXSDKWidgets") {
            className = className.replacingOccurrences(of: "DJIUXSDKWidgets", with: "1")
        }
        cell.textLabel?.text = className
        return cell
    }
    
}
