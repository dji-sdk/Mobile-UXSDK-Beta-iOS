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
        let palette = borderColorPalette()
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
        additionalControlsView?.isHidden = false
        pinchToResizeLabel.isHidden = false
        showCustomizationViewButton?.isHidden = !shouldShowCustomizationView
        
        if let rtkWidget = widget as? DUXBetaRTKWidget {
            // Show RTK Widget
            rtkWidget.view.isHidden = false;
        }
        configureConstraints()
        recursivelySetBorderForView(view: widget.view, borderEnabled: true, level: 0)
    
        aspectRatioLabel.text = String(format: "%.1f", widget.widgetSizeHint.preferredAspectRatio)
        currentSizeLabel.text = String(format: "[%.1f, %.1f]", widget.view.frame.size.width, widget.view.frame.size.height)
    }
    
    public func setupEmptyViewHierarchy() {
        noWidgetSelectedLabel.isHidden = false
        infoView.isHidden = true
        additionalControlsView?.isHidden = true
        pinchToResizeLabel.isHidden = true
        aspectRatioLabel.text = "1.0"
        currentSizeLabel.text = "[40.0, 40.0]"
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureControlViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let widget = widget {
            currentSizeLabel.text = String(format: "[%.1f, %.1f]", widget.view.frame.size.width, widget.view.frame.size.height)
        }
        view.bringSubviewToFront(infoView)
        view.bringSubviewToFront(pinchToResizeLabel)
        if let v = additionalControlsView {
            view.bringSubviewToFront(v)
        }
    }
    
    // MARK: Construct View and Constraint Hierarchy
    
    func configureControlViews() {
        let doubleSizeButton = UIButton(type: .system)
        doubleSizeButton.translatesAutoresizingMaskIntoConstraints = false
        doubleSizeButton.setTitle("Double Size", for: .normal)
        doubleSizeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 25.0).isActive = true
        doubleSizeControlAction = doubleSizeButton.duxbeta_connect(action: {
            if let hc = self.heightConstraint {
                hc.constant = hc.constant * 2
                self.view.setNeedsLayout()
            }
        }, for: .touchUpInside)
        
        let showCustomizationViewButton = UIButton(type: .system)
        showCustomizationViewButton.translatesAutoresizingMaskIntoConstraints = false
        showCustomizationViewButton.setTitle("Show Customization", for: .normal)
        showCustomizationViewButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 25.0).isActive = true
        showCustomizationViewAction = showCustomizationViewButton.duxbeta_connect(action: {
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
        
        view.addSubview(additionalControlsView)
        view.addConstraints([
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: additionalControlsView.topAnchor, constant: 10.0),
            infoView.trailingAnchor.constraint(equalTo: additionalControlsView.leadingAnchor, constant: -8.0)
        ])
        
        self.additionalControlsView = additionalControlsView
        
        setupEmptyViewHierarchy()
    }
    
    func configureConstraints() {
        if let widget = widget {
            
            widget.view.translatesAutoresizingMaskIntoConstraints = false
            
            widget.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            widget.view.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
            var constraint = widget.view.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.95)
            constraint.priority = .required
            constraint.isActive = true

            constraint = widget.view.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.95)
            constraint.priority = .required
            constraint.isActive = true
            
            constraint = widget.view.centerXAnchor.constraint(lessThanOrEqualTo: self.view.centerXAnchor)
            constraint.priority = .required
            constraint.isActive = true
            
            constraint = widget.view.centerYAnchor.constraint(lessThanOrEqualTo: self.view.centerYAnchor)
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
    
    func showMapCustomizationView() {
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
        if let nonNilWidget = widget {
            let borderEnabled = nonNilWidget.view.layer.borderWidth == 0
            recursivelySetBorderForView(view: nonNilWidget.view, borderEnabled: borderEnabled, level: 0)
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
