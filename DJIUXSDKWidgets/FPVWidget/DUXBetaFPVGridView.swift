//
//  DUXBetaFPVGridView.swift
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

import UIKit
import DJIUXSDKCommunication

/**
 *  Displays a grid centered in the view.
*/
@objc public class DUXBetaFPVGridView: UIView {
    
    /**
     *  The grid view type enum value that is read and stored into the DefaultGlobalPreferences.
     *  Default value .unkwnown
    */
    @objc public var gridViewType = DUXBetaSingleton.sharedGlobalPreferences().gridViewType() {
        didSet {
            DUXBetaSingleton.sharedGlobalPreferences().set(gridViewType: gridViewType)
            redraw()
        }
    }
    
    /**
     *  The number of rows displayed by the grid view.
     *  Default value 3
    */
    @objc public var rowCount: Int = 3 {
        didSet {
            if rowCount < 1 { rowCount = 1 }
            redraw()
        }
    }
    
    /**
     *  The number of columns displayed by the grid view.
     *  Default value 3
    */
    @objc public var columnCount: Int = 3 {
        didSet {
            if columnCount < 1 { columnCount = 1 }
            redraw()
        }
    }
    
    /**
     *  The line thickness used for drawing the lines.
     *  Default value 0.5.
    */
    @objc public var lineWidth: CGFloat = 0.5 {
        didSet {
            redraw()
        }
    }
    
    /**
     *  The line color used for drawing the lines.
     *  Default value 0.5
    */
    @objc public var lineColor: UIColor = UIColor.duxbeta_fpvGridLine() {
        didSet {
            redraw()
        }
    }
    
    /**
     *  The line shadow's visibility.
     *  Visible by default
    */
    @objc public var isShadowVisible = true {
        didSet {
            redraw()
        }
    }
    
    /**
     *  The line shadow's blue value.
     *  Default value 1.0
    */
    @objc public var shadowBlur: CGFloat = 1.0 {
        didSet {
            redraw()
        }
    }
    
    /**
     *  The line shadow's color value.
    */
    @objc public var shadowColor: UIColor = UIColor.duxbeta_fpvGridLineShadow() {
        didSet {
            redraw()
        }
    }
    
    /**
     *  The line shadow's offset as a translation in the rendering context.
     *  Default value (0.0, 0.0) size
    */
    @objc public var shadowOffset: CGSize = CGSize(width: 0.0, height: 0.0) {
        didSet {
            redraw()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let context = UIGraphicsGetCurrentContext() {
            //Set line properties
            context.setLineWidth(lineWidth)
            context.setStrokeColor(lineColor.cgColor)
            
            //Draw the shadow if needed
            drawShadow(inContext: context)
            
            switch gridViewType {
            case .Parallel:
                drawParallelLines(inContext: context)
                drawBoundingBox(inContext: context)
            case .ParallelDiagonal:
                drawParallelLines(inContext: context)
                drawDiagonalLines(inContext: context)
                drawBoundingBox(inContext: context)
            default:
                break
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        redraw()
    }
    
    func redraw() {
        setNeedsDisplay()
    }
    
    fileprivate func setupUI() {
        clipsToBounds = true
        backgroundColor = .clear
    }
    
    fileprivate func drawBoundingBox(inContext context: CGContext) {
        context.stroke(bounds.inset(by: UIEdgeInsets(top: lineWidth, left: lineWidth, bottom: lineWidth, right: lineWidth)))
    }
    
    fileprivate func drawParallelLines(inContext context: CGContext) {
        let width = bounds.width
        let height = bounds.height
        
        //Compute the column width
        let columnWidth = (width - CGFloat(columnCount + 1) * lineWidth) / CGFloat(columnCount)
        
        //Start drawing the inner columns
        for i in 1..<columnCount {
            let index = CGFloat(i)
            context.move(to: CGPoint(x: (columnWidth + lineWidth) * index, y: lineWidth))
            context.addLine(to: CGPoint(x: (columnWidth + lineWidth) * index, y: height - lineWidth))
            drawShadow(inContext: context)
            context.setFillColor(lineColor.cgColor)
            context.strokePath()
        }
        
        //Compute the row height
        let rowHeight = (height - CGFloat(rowCount + 1) * lineWidth) / CGFloat(rowCount)
        
        //Start drawing the inner rows
        for i in 1..<rowCount {
            let index = CGFloat(i)
            context.move(to: CGPoint(x: lineWidth, y: (rowHeight + lineWidth) * index))
            context.addLine(to: CGPoint(x: width - lineWidth, y: (rowHeight + lineWidth) * index))
            drawShadow(inContext: context)
            context.setFillColor(lineColor.cgColor)
            context.strokePath()
        }
    }
    
    fileprivate func drawDiagonalLines(inContext context: CGContext) {
        //Draw the first diagonal line
        context.move(to: CGPoint(x: lineWidth, y: lineWidth))
        context.addLine(to: CGPoint(x: bounds.width - lineWidth, y: bounds.height - lineWidth))
        drawShadow(inContext: context)
        context.setFillColor(lineColor.cgColor)
        context.strokePath()
        
        //Draw the second diagonal line
        context.move(to: CGPoint(x: lineWidth, y: bounds.height - lineWidth))
        context.addLine(to: CGPoint(x: bounds.width - lineWidth, y: lineWidth))
        drawShadow(inContext: context)
        context.setFillColor(lineColor.cgColor)
        context.strokePath()
    }
    
    fileprivate func drawShadow(inContext context: CGContext) {
        if isShadowVisible {
            context.setShadow(offset: shadowOffset, blur: shadowBlur, color: shadowColor.cgColor)
        }
    }
}
