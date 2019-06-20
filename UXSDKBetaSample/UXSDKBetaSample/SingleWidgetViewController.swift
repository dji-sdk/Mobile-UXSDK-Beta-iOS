//
//  SingleWidgetViewController.swift
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

class SingleWidgetViewController: UIViewController {

    @IBOutlet var noWidgetSelectedLabel: UILabel!
    @IBOutlet var infoView: UIView!
    @IBOutlet var pinchToResizeLabel: UILabel!
    @IBOutlet var aspectRatioLabel: UILabel!
    @IBOutlet var currentSizeLabel: UILabel!
    @IBOutlet var widgetDescriptionLabel: UILabel!
    
    private var pinchStartHeight: CGFloat = 0.0
    private var heightConstraint: NSLayoutConstraint?
    
    private var _widget: DUXBetaBaseWidget? = nil
    var widget: DUXBetaBaseWidget? {
        set {
            // Cleanup old widget from parent
            self.tearDownCurrentWidget()
            
            _widget = newValue
            if let nonNilWidget = _widget {
                self.setupViewHierarchyFor(widget: nonNilWidget)
            } else {
                self.setupEmptyViewHierarchy()
            }
        }
        get { return _widget }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let widget = self.widget {
            currentSizeLabel.text = String(format: "[%.1f, %.1f]", widget.view.frame.size.width, widget.view.frame.size.height)
        }
    }
    
    public func tearDownCurrentWidget() {
        _widget?.removeFromParent()
        _widget?.view.removeFromSuperview()
    }
    
    public func setupViewHierarchyFor(widget:DUXBetaBaseWidget) {
        self.noWidgetSelectedLabel.isHidden = true
        self.infoView.isHidden = false
        self.pinchToResizeLabel.isHidden = false
    
        widget.install(in: self)
        self.configureConstraints()
        self.recursivelySetBorderForView(view: widget.view, borderEnabled: true, level: 0)
    
        self.aspectRatioLabel.text = String(format: "%.1f", widget.widgetSizeHint.preferredAspectRatio)
        self.currentSizeLabel.text = String(format: "[%.1f, %.1f]", widget.view.frame.size.width, widget.view.frame.size.height)
    }
    
    public func setupEmptyViewHierarchy() {
        self.noWidgetSelectedLabel.isHidden = false
        self.infoView.isHidden = true
        self.pinchToResizeLabel.isHidden = true
        self.aspectRatioLabel.text = "1.0"
        self.currentSizeLabel.text = "[40.0, 40.0]"
    }
    
    func configureConstraints () {
        if let widget = self.widget {
            
            widget.view.translatesAutoresizingMaskIntoConstraints = false
            
            widget.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            widget.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            
            var constraint = widget.view.widthAnchor.constraint(equalTo: widget.view.heightAnchor, multiplier: widget.widgetSizeHint.preferredAspectRatio)
            constraint.priority = .required
            constraint.isActive = true
            
            constraint = widget.view.widthAnchor.constraint(lessThanOrEqualTo: self.view.widthAnchor, multiplier: 0.95)
            constraint.priority = .required
            constraint.isActive = true

            constraint = widget.view.heightAnchor.constraint(lessThanOrEqualTo: self.view.heightAnchor, multiplier: 0.95)
            constraint.priority = .required
            constraint.isActive = true
            
            constraint = widget.view.widthAnchor.constraint(greaterThanOrEqualToConstant: widget.widgetSizeHint.minimumWidth)
            constraint.priority = .required
            constraint.isActive = true

            constraint = widget.view.heightAnchor.constraint(greaterThanOrEqualToConstant: widget.widgetSizeHint.minimumHeight)
            constraint.priority = .required
            constraint.isActive = true
            
            let heightConstraintConstant = widget.widgetSizeHint.minimumHeight
            
            if heightConstraintConstant < 60 {
                self.heightConstraint = widget.view.heightAnchor.constraint(equalToConstant: 2 * heightConstraintConstant)
            } else {
                self.heightConstraint = widget.view.heightAnchor.constraint(equalToConstant: heightConstraintConstant)
            }
            
            self.heightConstraint?.priority = .required
            self.heightConstraint?.isActive = true
        }
    }
    
    @IBAction func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if let hc = self.heightConstraint {
            if (recognizer.state == .began) {
                self.pinchStartHeight = hc.constant
                print("Pinch Zoom Height: \(hc.constant)")
            }
            hc.constant = self.pinchStartHeight * recognizer.scale
            self.view.setNeedsLayout()
        }
    }
    
    @IBAction func doubleTap(recognizer: UITapGestureRecognizer) {
        if let nonNilWidget = _widget {
            let borderEnabled = nonNilWidget.view.layer.borderWidth == 0
            self.recursivelySetBorderForView(view: nonNilWidget.view, borderEnabled: borderEnabled, level: 0)
        }
    }
    private let colors: [UIColor] = [UIColor.red,
                                     UIColor.green,
                                     UIColor.blue,
                                     UIColor.orange,
                                     UIColor.yellow,
                                     UIColor.magenta,
                                     UIColor.cyan,
                                     UIColor.purple,
                                     UIColor.brown]
    func recursivelySetBorderForView(view: UIView, borderEnabled: Bool, level: Int) {
        if (borderEnabled) {
            view.layer.borderColor = colors[level % colors.count].cgColor
            view.layer.borderWidth = 1
        } else {
            view.layer.borderColor = UIColor.clear.cgColor
            view.layer.borderWidth = 0
        }
        for subView in view.subviews {
            self.recursivelySetBorderForView(view: subView, borderEnabled: borderEnabled, level: level + 1)
        }
    }
    
    func closeButtonPressed(for widget: DUXBetaBaseWidget!) {
        self.widget?.removeFromParent()
        self.widget?.view.removeFromSuperview()
    }
    
    func currentScreenChanged(to newScreen: DUXBetaBaseWidget) {
        if let widget = self.widget {
            widget.view.removeConstraints(widget.view.constraints)
        }
        self.configureConstraints()
    }
}

extension SingleWidgetViewController: WidgetSelectionDelegate {
    func widgetSelected(_ newWidget: DUXBetaBaseWidget?) {
        self.widget = newWidget
    }
}
