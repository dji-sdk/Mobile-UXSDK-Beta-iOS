//
//  WidgetsListViewController.swift
//  DJIUXSDK
//
// Copyright © 2018-2019 DJI
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import UIKit
import DJIUXSDKBeta

protocol WidgetSelectionDelegate: class {
    func widgetSelected(_ widget: DUXBetaBaseWidget?)
}

class WidgetsListViewController: UITableViewController {
    
    weak var delegate: WidgetSelectionDelegate?
    
    static let widgetDescriptions:[String:String] = [
                                                    "Map Widget":"Widget that displays the aircraft's state and information on the map this includes aircraft location, home location, aircraft trail path, aircraft heading, and No Fly Zones.",
                                                    "Battery Widget" : "Widget that displays aircraft battery level.",
                                                    "Compass Widget" : "Displays the position of the aircraft in relation to the home point and pilot location.",
                                                    "Dashboard Widget" : "Compound widget that aggregates important information about the aircraft into a dashboard.",
                                                    "Vision Widget" : "Widget to display the vision status/collision avodance status, of the aircraft. It's state depends on sensors availability, flight mode, and aircraft type.",
    ]
    
    static let widgets:[DUXBetaBaseWidget] = [DUXBetaMapWidget(),
                                          DUXBetaBatteryWidget(),
                                          DUXBetaCompassWidget(),
                                          DUXBetaDashboardWidget(),
                                          DUXBetaVisionWidget()]
    static let widgetTitles:[String] = ["Map Widget",
                                        "Battery Widget",
                                        "Compass Widget",
                                        "Dashboard Widget",
                                        "Vision Widget"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func close () {
        self.dismiss(animated: true) { }
    }
    
    // MARK: UITableViewDelegate
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let widget = WidgetsListViewController.widgets[indexPath.row]
        delegate?.widgetSelected(widget)
        if let singleWidgetViewController = delegate as? SingleWidgetViewController {
            let title = WidgetsListViewController.widgetTitles[indexPath.row]
            singleWidgetViewController.title = title
            singleWidgetViewController.widgetDescriptionLabel.text = WidgetsListViewController.widgetDescriptions[title]
            splitViewController?.showDetailViewController(singleWidgetViewController, sender: nil)
            
        }
    }
    
    // MARK: UITableViewDataSource
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WidgetsListViewController.widgets.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WidgetsListCellIdentifier", for: indexPath)
        cell.textLabel?.text = WidgetsListViewController.widgetTitles[indexPath.row]
        return cell
    }
    
}
