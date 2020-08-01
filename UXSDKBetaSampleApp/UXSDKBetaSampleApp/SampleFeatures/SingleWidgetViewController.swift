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
import DJIUXSDKBeta

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
        let palette = self.borderColorPalette()
        return palette[level % palette.count]
    }
}

class SingleWidgetViewController: UIViewController {

    @IBOutlet var noWidgetSelectedLabel: UILabel!
    @IBOutlet var infoView: UIView!
    @IBOutlet var pinchToResizeLabel: UILabel!
    @IBOutlet var aspectRatioLabel: UILabel!
    @IBOutlet var currentSizeLabel: UILabel!
    
    @IBOutlet var widgetDescriptionLabel: UILabel!
    var showCustomizationViewButton: UIButton?
    
    private var pinchStartHeight: CGFloat = 0.0
    private var heightConstraint: NSLayoutConstraint?
    private var additionalControlsView: UIView?
    
    private var doubleSizeControlAction: ControlAction?
    private var showCustomizationViewAction: ControlAction?
    
    internal var shouldShowCustomizationView: Bool = false
    
    // MARK: Widget Setup / Teardown
    var widget: DUXBetaBaseWidget? {
        willSet {
            // Cleanup old widget from parent
            self.tearDownCurrentWidget()
        }
        
        didSet {
            if let nonNilWidget = self.widget {
                self.setupViewHierarchyFor(widget: nonNilWidget)
            } else {
                self.setupEmptyViewHierarchy()
            }
        }
    }
    
    public func tearDownCurrentWidget() {
        self.widget?.removeFromParent()
        self.widget?.view.removeFromSuperview()
    }
    
    public func setupViewHierarchyFor(widget:DUXBetaBaseWidget) {
        self.noWidgetSelectedLabel.isHidden = true
        self.infoView.isHidden = false
        self.additionalControlsView?.isHidden = false
        self.pinchToResizeLabel.isHidden = false
        self.showCustomizationViewButton?.isHidden = !self.shouldShowCustomizationView
        
        widget.install(in: self)
        
        if let rtkWidget = widget as? DUXBetaRTKWidget {
            // Show RTK Widget
            rtkWidget.view.isHidden = false;
        }
        self.configureConstraints()
        self.recursivelySetBorderForView(view: widget.view, borderEnabled: true, level: 0)
    
        self.aspectRatioLabel.text = String(format: "%.1f", widget.widgetSizeHint.preferredAspectRatio)
        self.currentSizeLabel.text = String(format: "[%.1f, %.1f]", widget.view.frame.size.width, widget.view.frame.size.height)
    }
    
    public func setupEmptyViewHierarchy() {
        self.noWidgetSelectedLabel.isHidden = false
        self.infoView.isHidden = true
        self.additionalControlsView?.isHidden = true
        self.pinchToResizeLabel.isHidden = true
        self.aspectRatioLabel.text = "1.0"
        self.currentSizeLabel.text = "[40.0, 40.0]"
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureControlViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let widget = self.widget {
            currentSizeLabel.text = String(format: "[%.1f, %.1f]", widget.view.frame.size.width, widget.view.frame.size.height)
        }
        self.view.bringSubviewToFront(self.infoView)
        self.view.bringSubviewToFront(self.pinchToResizeLabel)
        if let v = self.additionalControlsView {
            self.view.bringSubviewToFront(v)
        }
    }
    
    // MARK: Construct View and Constraint Hierarchy
    
    func configureControlViews() {
        let doubleSizeButton = UIButton(type: .system)
        doubleSizeButton.translatesAutoresizingMaskIntoConstraints = false
        doubleSizeButton.setTitle("Double Size", for: .normal)
        doubleSizeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 25.0).isActive = true
        self.doubleSizeControlAction = doubleSizeButton.duxbeta_connect(action: {
            if let hc = self.heightConstraint {
                hc.constant = hc.constant * 2
                self.view.setNeedsLayout()
            }
        }, for: .touchUpInside)
        
        let showCustomizationViewButton = UIButton(type: .system)
        showCustomizationViewButton.translatesAutoresizingMaskIntoConstraints = false
        showCustomizationViewButton.setTitle("Show Customization", for: .normal)
        showCustomizationViewButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 25.0).isActive = true
        self.showCustomizationViewAction = showCustomizationViewButton.duxbeta_connect(action: {
            self.showMapCustomizationView()
        }, for: .touchUpInside)
        self.showCustomizationViewButton = showCustomizationViewButton
        
        let subviews:[UIView] = [doubleSizeButton, showCustomizationViewButton]
        let stackview = UIStackView(arrangedSubviews: subviews)
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.axis = .vertical
        stackview.distribution = .equalSpacing
        stackview.spacing = UIStackView.spacingUseSystem
        stackview.isLayoutMarginsRelativeArrangement = true
        stackview.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 5,
                                                                     leading: 5,
                                                                     bottom: 5,
                                                                     trailing: 5)
        
        let additionalControlsView = UIView()
        additionalControlsView.translatesAutoresizingMaskIntoConstraints = false
        additionalControlsView.addSubview(stackview)
        
        let effect = UIBlurEffect(style: .regular)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        additionalControlsView.addSubview(effectView)
        additionalControlsView.sendSubviewToBack(effectView)
        additionalControlsView.addConstraints([
            effectView.leadingAnchor.constraint(equalTo: additionalControlsView.leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: additionalControlsView.trailingAnchor),
            effectView.topAnchor.constraint(equalTo: additionalControlsView.topAnchor),
            effectView.bottomAnchor.constraint(equalTo: additionalControlsView.bottomAnchor),
        ])

        stackview.leadingAnchor.constraint(equalTo: additionalControlsView.leadingAnchor).isActive = true
        stackview.trailingAnchor.constraint(equalTo: additionalControlsView.trailingAnchor).isActive = true
        stackview.topAnchor.constraint(equalTo: additionalControlsView.topAnchor).isActive = true
        stackview.bottomAnchor.constraint(equalTo: additionalControlsView.bottomAnchor).isActive = true
        
        self.view.addSubview(additionalControlsView)
        self.view.addConstraints([
            self.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: additionalControlsView.topAnchor, constant: 10.0),
            self.infoView.trailingAnchor.constraint(equalTo: additionalControlsView.leadingAnchor, constant: -8.0)
        ])
        
        self.additionalControlsView = additionalControlsView
        
        self.setupEmptyViewHierarchy()
    }
    
    func configureConstraints() {
        if let widget = self.widget {
            
            widget.view.translatesAutoresizingMaskIntoConstraints = false
            
            widget.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            widget.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            
            var constraint = widget.view.widthAnchor.constraint(lessThanOrEqualTo: self.view.widthAnchor, multiplier: 0.95)
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
            
            if widget.isKind(of: DUXBetaAltitudeWidget.self) ||
               widget.isKind(of: DUXBetaCompassWidget.self) ||
               widget.isKind(of: DUXBetaDashboardWidget.self) ||
               widget.isKind(of: DUXBetaHomeDistanceWidget.self) ||
               widget.isKind(of: DUXBetaMapWidget.self) ||
               widget.isKind(of: DUXBetaRCDistanceWidget.self) ||
               widget.isKind(of: DUXBetaRemainingFlightTimeWidget.self) ||
               widget.isKind(of: DUXBetaVPSWidget.self) {
                constraint = widget.view.widthAnchor.constraint(equalTo: widget.view.heightAnchor, multiplier: widget.widgetSizeHint.preferredAspectRatio)
                constraint.priority = .required
                constraint.isActive = true
            }
            
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
    
    // MARK: Widget Customization View
    
    func showMapCustomizationView() {
        if let mapWidget = self.widget as? DUXBetaMapWidget {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: type(of: self)))
            let mapCustomizationViewController = storyboard.instantiateViewController(withIdentifier: "CustomMapViewController") as! CustomMapViewController
            mapCustomizationViewController.mapWidget = mapWidget
            
            self.addChild(mapCustomizationViewController)
            self.view.addSubview(mapCustomizationViewController.view)
            mapCustomizationViewController.didMove(toParent: self)
            
            mapCustomizationViewController.view.translatesAutoresizingMaskIntoConstraints = false
            mapCustomizationViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
            mapCustomizationViewController.view.topAnchor.constraint(equalTo: self.widgetDescriptionLabel.bottomAnchor, constant: 16.0).isActive = true
            mapCustomizationViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
            mapCustomizationViewController.view.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 1.0/3.0).isActive = true
            mapCustomizationViewController.view.setNeedsLayout()
            mapCustomizationViewController.view.layoutIfNeeded()
        }
    }
    
    // MARK: User Interaction Handlers
    
    @IBAction func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if let hc = self.heightConstraint {
            if (recognizer.state == .began) {
                self.pinchStartHeight = hc.constant
            }
            hc.constant = self.pinchStartHeight * recognizer.scale
            self.view.setNeedsLayout()
        }
    }
    
    @IBAction func doubleTap(recognizer: UITapGestureRecognizer) {
        if let nonNilWidget = self.widget {
            let borderEnabled = nonNilWidget.view.layer.borderWidth == 0
            self.recursivelySetBorderForView(view: nonNilWidget.view, borderEnabled: borderEnabled, level: 0)
        }
    }
    
    func recursivelySetBorderForView(view: UIView, borderEnabled: Bool, level: Int) {
        if (borderEnabled) {
            view.layer.borderColor = UIColor.borderColor(for: level).cgColor
            view.layer.borderWidth = 1
        } else {
            view.layer.borderColor = UIColor.clear.cgColor
            view.layer.borderWidth = 0
        }
        for subView in view.subviews {
            self.recursivelySetBorderForView(view: subView, borderEnabled: borderEnabled, level: level + 1)
        }
    }
}

extension SingleWidgetViewController: WidgetSelectionDelegate {
    func widgetSelected(_ newWidget: DUXBetaBaseWidget?, shouldShowCustomizationView:Bool) {
        self.shouldShowCustomizationView = shouldShowCustomizationView
        self.widget = newWidget
    }
}
