//
//  SingleWidgetViewController.swift
//  UXSDKSampleApp
//
// Copyright © 2018-2020 DJI
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
import DJIUXSDK

extension UIColor {
    static func borderColorPalette() -> [UIColor] {
        return [UIColor.red,
                UIColor.green,
                UIColor.blue,
                UIColor.orange,
                UIColor.yellow,
                UIColor.magenta,
                UIColor.cyan,
                UIColor.purple,
                UIColor.brown]
    }
    
    static func borderColor(for level:Int) -> UIColor {
        let palette = borderColorPalette()
        return palette[level % palette.count]
    }
}

class SingleWidgetViewController: UIViewController {
    @IBOutlet var infoView: UIView!
    
    @IBOutlet var aspectRatioLabel: UILabel!
    @IBOutlet var currentSizeLabel: UILabel!
    @IBOutlet var pinchToResizeLabel: UILabel!
    @IBOutlet var noWidgetSelectedLabel: UILabel!
    @IBOutlet var widgetDescriptionLabel: UILabel!
    
    @IBOutlet var doubleSizeButton: UIButton!
    @IBOutlet var showCustomizationButton: UIButton!
    
    private var pinchStartHeight: CGFloat = 0.0
    private var heightConstraint: NSLayoutConstraint?

    internal var shouldShowCustomizationView: Bool = false
    
    // MARK: Widget Setup / Teardown
    var widget: DUXBetaBaseWidget? {
        willSet {
            // Cleanup old widget from parent
            tearDownCurrentWidget()
        }
        
        didSet {
            if let nonNilWidget = widget {
                setupViewHierarchyFor(widget: nonNilWidget)
            } else {
                setupEmptyViewHierarchy()
            }
        }
    }
    
    public func tearDownCurrentWidget() {
        widget?.removeFromParent()
        widget?.view.removeFromSuperview()
    }
    
    public func setupViewHierarchyFor(widget:DUXBetaBaseWidget) {
        widget.install(in: self)
        
        noWidgetSelectedLabel.isHidden = true
        
        infoView.isHidden = false
        doubleSizeButton.isHidden = false
        pinchToResizeLabel.isHidden = false
        
        showCustomizationButton.isHidden = !shouldShowCustomizationView
        
        if let rtkWidget = widget as? DUXBetaRTKWidget {
            // Show RTK Widget
            rtkWidget.view.isHidden = false
        }
        configureConstraints()
        recursivelySetBorderForView(view: widget.view, borderEnabled: true, level: 0)
    
        aspectRatioLabel.text = String(format: "%.1f", widget.widgetSizeHint.preferredAspectRatio)
        currentSizeLabel.text = String(format: "[%.1f, %.1f]", widget.view.frame.size.width, widget.view.frame.size.height)
    }
    
    public func setupEmptyViewHierarchy() {
        noWidgetSelectedLabel.isHidden = false
        
        infoView.isHidden = true
        doubleSizeButton.isHidden = true
        pinchToResizeLabel.isHidden = true
        showCustomizationButton.isHidden = true
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEmptyViewHierarchy()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let widget = widget {
            currentSizeLabel.text = String(format: "[%.1f, %.1f]", widget.view.frame.width, widget.view.frame.height)
        }
    }
    
    // MARK: Constraints Hierarchy
    
    func configureConstraints() {
        if let widget = widget {
            
            widget.view.translatesAutoresizingMaskIntoConstraints = false
            
            var constraint = widget.view.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.95)
            constraint.priority = .required
            constraint.isActive = true

            constraint = widget.view.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.95)
            constraint.priority = .required
            constraint.isActive = true
            
            constraint = widget.view.centerXAnchor.constraint(lessThanOrEqualTo: view.centerXAnchor)
            constraint.priority = .required
            constraint.isActive = true
            
            constraint = widget.view.centerYAnchor.constraint(lessThanOrEqualTo: view.centerYAnchor)
            constraint.priority = .required
            constraint.isActive = true
            
            constraint = widget.view.widthAnchor.constraint(greaterThanOrEqualToConstant: widget.widgetSizeHint.minimumWidth)
            constraint.priority = .required
            constraint.isActive = true

            constraint = widget.view.heightAnchor.constraint(greaterThanOrEqualToConstant: widget.widgetSizeHint.minimumHeight)
            constraint.priority = .required
            constraint.isActive = true
            
            if widget.isKind(of: DUXBetaCompassWidget.self) ||
               widget.isKind(of: DUXBetaMapWidget.self) {
                constraint = widget.view.widthAnchor.constraint(equalTo: widget.view.heightAnchor, multiplier: widget.widgetSizeHint.preferredAspectRatio)
                constraint.priority = .required
                constraint.isActive = true
            }
            
            if widget.isKind(of: DUXBetaRemainingFlightTimeWidget.self) {
                constraint = widget.view.widthAnchor.constraint(equalTo: widget.view.heightAnchor, multiplier: widget.widgetSizeHint.preferredAspectRatio)
                constraint.priority = .defaultLow
                constraint.isActive = true
            }
            
            heightConstraint?.isActive = false
            
            let heightConstraintConstant = widget.widgetSizeHint.minimumHeight
            if heightConstraintConstant < 60 {
                heightConstraint = widget.view.heightAnchor.constraint(equalToConstant: 2 * heightConstraintConstant)
            } else {
                heightConstraint = widget.view.heightAnchor.constraint(equalToConstant: heightConstraintConstant)
            }
            
            heightConstraint?.priority = .required
            heightConstraint?.isActive = true
        }
    }
    
    // MARK: Widget Customization View
    
    @IBAction func showMapCustomizationView() {
        if let mapWidget = widget as? DUXBetaMapWidget {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: type(of: self)))
            let mapCustomizationViewController = storyboard.instantiateViewController(withIdentifier: "CustomMapViewController") as! CustomMapViewController
            mapCustomizationViewController.mapWidget = mapWidget
            
            addChild(mapCustomizationViewController)
            view.addSubview(mapCustomizationViewController.view)
            mapCustomizationViewController.didMove(toParent: self)
            
            mapCustomizationViewController.view.translatesAutoresizingMaskIntoConstraints = false
            mapCustomizationViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
            mapCustomizationViewController.view.topAnchor.constraint(equalTo: widgetDescriptionLabel.bottomAnchor, constant: 16.0).isActive = true
            mapCustomizationViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
            mapCustomizationViewController.view.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1.0/3.0).isActive = true
            mapCustomizationViewController.view.setNeedsLayout()
            mapCustomizationViewController.view.layoutIfNeeded()
        }
    }
    
    // MARK: User Interaction Handlers
    
    @IBAction func doubleSizeAction() {
        if let hc = heightConstraint {
            hc.constant = hc.constant * 2
            view.setNeedsLayout()
        }
    }
    
    @IBAction func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if let hc = heightConstraint {
            if (recognizer.state == .began) {
                pinchStartHeight = hc.constant
            }
            hc.constant = pinchStartHeight * recognizer.scale
            view.setNeedsLayout()
        }
    }
    
    @IBAction func doubleTap(recognizer: UITapGestureRecognizer) {
        if let nonNilView = widget?.view {
            let borderEnabled = (nonNilView.layer.borderWidth == 0)
            recursivelySetBorderForView(view: nonNilView, borderEnabled: borderEnabled, level: 0)
        }
    }
    
    func recursivelySetBorderForView(view: UIView, borderEnabled: Bool, level: Int) {
        if !view.layer.isKind(of: CATransformLayer.self) {
            if (borderEnabled) {
                view.layer.borderColor = UIColor.borderColor(for: level).cgColor
                view.layer.borderWidth = 1
            } else {
                view.layer.borderColor = UIColor.clear.cgColor
                view.layer.borderWidth = 0
            }
        }

        for subView in view.subviews {
            recursivelySetBorderForView(view: subView, borderEnabled: borderEnabled, level: level + 1)
        }
    }
}

extension SingleWidgetViewController: WidgetSelectionDelegate {
    
    func widgetSelected(_ newWidget: DUXBetaBaseWidget?, shouldShowCustomizationView:Bool) {
        self.shouldShowCustomizationView = shouldShowCustomizationView
        widget = newWidget
    }
}
