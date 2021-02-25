//
//  ColorSetting.swift
//  UXSDKBetaSampleApp
//
//  MIT License
//  
//  Copyright © 2021 DJI
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
import DJIUXSDK
import iOS_Color_Picker

class ColorSetting: DUXBetaListItemTitleWidget {
    
    var controlView: UIView?
    var onValueChanged: ((UIColor?) -> ())?
    var onInitialValue: (() -> UIColor?)? {
        didSet {
            if #available(iOS 14.0, *) {
                updateColorWell()
            } else {
                controlView?.backgroundColor = onInitialValue?()
            }
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        if #available(iOS 14.0, *) {
            addColorWell()
        } else {
            addButton()
        }
        
        addConstraints()
    }
    
    func addConstraints() {
        if let controlView = controlView {
            NSLayoutConstraint.activate([
                controlView.widthAnchor.constraint(equalToConstant: 45.0),
                controlView.heightAnchor.constraint(equalToConstant: 45.0),
                controlView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
                controlView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let view = controlView {
            trailingMarginConstraint.isActive = false
            trailingMarginConstraint = trailingTitleGuide.trailingAnchor.constraint(equalTo: view.leadingAnchor)
            trailingMarginConstraint.isActive = true
        }
    }
    
    func addButton() {
        let button = UIButton()
        controlView = button
        button.backgroundColor = onInitialValue?() ?? .clear
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.white.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func buttonTapped() {
        let colorPicker = FCColorPickerViewController.colorPicker(with: controlView?.backgroundColor, delegate: self)
        present(colorPicker, animated: true, completion: nil)
    }
    
    @available(iOS 14.0, *)
    func addColorWell() {
        let colorWell = UIColorWell()
        controlView = colorWell
        colorWell.translatesAutoresizingMaskIntoConstraints = false
        colorWell.title = "Select Color"
        colorWell.addTarget(self, action: #selector(colorWellChanged(_:)), for: .valueChanged)
        view.addSubview(colorWell)
    }
    
    @available(iOS 14.0, *)
    func updateColorWell() {
        if let colorWell = controlView as? UIColorWell {
            colorWell.selectedColor = onInitialValue?()
        }
    }
    
    @available(iOS 14.0, *)
    @objc func colorWellChanged(_ sender: UIColorWell) {
        onValueChanged?(sender.selectedColor)
    }
}

extension ColorSetting: FCColorPickerViewControllerDelegate {
    
    func colorPickerViewController(_ colorPicker: FCColorPickerViewController, didSelect color: UIColor) {
        let selectedColor = colorPicker.color
        controlView?.backgroundColor = selectedColor
        onValueChanged?(selectedColor)
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func colorPickerViewControllerDidCancel(_ colorPicker: FCColorPickerViewController) {
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
}
