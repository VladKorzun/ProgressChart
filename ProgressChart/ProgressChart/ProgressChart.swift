//
//  ProgressChart.swift
//  ProgressChart
//
//  Created by Vlad Korzun on 7/26/18.
//  Copyright © 2018 Vlad Korzun. All rights reserved.
//

import UIKit

open class ProgressChart: UIView {
	
	// MARK: Interface methods
	
	public var maxValue: CGFloat = 10.0
	public var value: CGFloat = 1.0
	public var radius: CGFloat = 50.0
	public var labelFont: UIFont?
	public var labelOffsetRatio: CGPoint?
	public var labelOffset: CGSize?
	public var labelFormat: String?
	public var labelColor: UIColor?
	public var lineWidth: CGFloat = 17.0
	public var progressBackgroundColor: UIColor = UIColor.lightGray
	public var progressGradientColor: [UIColor] = [UIColor.red, UIColor.purple]
	public var startAngle: CGFloat = 135
	public var endAngle: CGFloat = 45
	public enum GradientCurve {
		case x, y
	}
	public var gradientCurve: GradientCurve = .x
	public var arcRange: (min: CGFloat, max: CGFloat) {
		return (min: endAngle.degreesToRadians, max: startAngle.degreesToRadians)
	}
	
	public func draw(animated: Bool, duration: TimeInterval?) {
		canvas.chart = self
		canvas.drawChart()
//		if animated {
//			canvas.animateWithDuration(duration: duration!)
//		}
	}
	
	public func drawLinear(animated: Bool, duration: TimeInterval?) {
		canvas.chart = self
		canvas.drawLinearChart()
		if animated {
			canvas.animateWithDuration(duration: duration!)
		}
	}
	
	// MARK: Instance initialization
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		initialize()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		initialize()
	}
	
	private func initialize() {
		canvas.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
		canvas.chart = self
		layer.addSublayer(canvas)
	}
	
	// MARK: UIView methods
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		canvas.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
	}
	
	// MARK: Private methods
	
	private let canvas = Canvas()
	
	
	
}

fileprivate extension BinaryInteger {
	var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

fileprivate extension FloatingPoint {
	var degreesToRadians: Self { return self * .pi / 180 }
	var radiansToDegrees: Self { return self * 180 / .pi }
}
