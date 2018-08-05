//
//  Canvas.swift
//  ProgressChart
//
//  Created by Vlad Korzun on 7/26/18.
//  Copyright © 2018 Vlad Korzun. All rights reserved.
//

import UIKit

final class Canvas: CALayer {
	
	// MARK: Interface methods
	
	weak var chart: ProgressChart?
	
	public func drawChart() {
		guard let chart = chart else {
			return
		}
		
		removeVisibleLayers()
		layoutIfNeeded()
		
		let center = CGPoint(x: chart.frame.width / 2, y: chart.frame.height / 2)
		let start = chart.arcRange.max
		let end = chart.arcRange.min
		let radius = chart.radius
		
		let path = CGMutablePath()
		
		path.addArc(center: center, radius: radius, start: start, end: end)
		let shapeLayer = shapeCanvas
		shapeLayer.lineCap = kCALineCapRound
		shapeLayer.lineWidth = chart.lineWidth
		shapeLayer.path = path
		shapeLayer.fillColor = UIColor.clear.cgColor
		shapeLayer.strokeColor = chart.progressBackgroundColor.cgColor

		let progressEnd = start + (end - start + .pi * 2) * (chart.value / chart.maxValue)
		let progressPath = CGMutablePath()
		progressPath.addArc(center: center, radius: radius, start: start, end: progressEnd)
		progressCanvas = shapeCanvas
		progressCanvas?.lineCap = kCALineCapRound
		progressCanvas?.lineWidth = chart.lineWidth
		progressCanvas?.path = progressPath
		progressCanvas?.fillColor = UIColor.clear.cgColor
		progressCanvas?.strokeColor = UIColor.white.cgColor
		
		if !chart.progressGradientColor.isEmpty {
			let layer = gradientLayer
			layer.mask = progressCanvas
			let startRatio = center.x - radius
			let endRatio = center.x + radius
			layer.colors = chart.progressGradientColor.map { $0.cgColor }
			if chart.gradientCurve == .x {
				layer.startPoint = CGPoint(x: startRatio / chart.frame.width, y: 0.5)
				layer.endPoint = CGPoint(x: endRatio / chart.frame.width, y: 0.5)
			} else {
				layer.startPoint = CGPoint(x: 0.5, y: startRatio / chart.frame.height)
				layer.endPoint = CGPoint(x: 0.5, y: endRatio / chart.frame.height)
			}
		}
		
		numberRenderer.toPoint = center
		numberRenderer.fromPoint = center
		numberRenderer.fromNumber = 0.0
		numberRenderer.toNumber = chart.value
		if let font = chart.labelFont {
			numberRenderer.font = font
		}
		if let offsetRatio = chart.labelOffsetRatio {
			numberRenderer.offsetRatio = offsetRatio
		}
		if let offset = chart.labelOffset {
			numberRenderer.offset = offset
		}
		
		if let format = chart.labelFormat {
			numberRenderer.format = format
		}
		if let color = chart.labelColor {
			numberRenderer.color = color
		}
		numberRenderer.drawToNumberAndPoint()
		
		setNeedsDisplay()
	}
	
	public func drawLinearChart() {
		guard let chart = chart else {
			return
		}
		
		removeVisibleLayers()
		layoutIfNeeded()
		
		let height = chart.frame.height
		let start = CGPoint(x: 20.0, y: height / 2)
		let end = CGPoint(x: chart.frame.width - 20.0, y: height / 2)
		
		let path = CGMutablePath()
		path.addLines(between: [start, end])
		let shapeLayer = shapeCanvas
		shapeLayer.lineCap = kCALineCapRound
		shapeLayer.lineWidth = height
		shapeLayer.path = path
		shapeLayer.fillColor = UIColor.clear.cgColor
		shapeLayer.strokeColor = chart.progressBackgroundColor.cgColor

		let progressEnd = CGPoint(x: frame.width / chart.maxValue * chart.value, y: height / 2)
		let progressPath = CGMutablePath()
		progressPath.addLines(between: [start, progressEnd])
		progressCanvas = shapeCanvas
		progressCanvas?.lineCap = kCALineCapRound
		progressCanvas?.lineWidth = height
		progressCanvas?.path = progressPath
		progressCanvas?.fillColor = UIColor.clear.cgColor
		progressCanvas?.strokeColor = UIColor.blue.cgColor
		
		if !chart.progressGradientColor.isEmpty {
			let layer = gradientLayer
			layer.mask = progressCanvas
			layer.colors = chart.progressGradientColor.map { $0.cgColor }
			if chart.gradientCurve == .x {
				layer.startPoint = CGPoint(x: 0.0, y: 1.0)
				layer.endPoint = CGPoint(x: 1.0, y: 1.0)
			} else {
				layer.startPoint = CGPoint(x: 0.5, y: 0)
				layer.endPoint = CGPoint(x: 0.5, y: 0.5)
			}
		}
		
		numberRenderer.toPoint = CGPoint(x: 20.0, y: height / 2)
		numberRenderer.fromPoint = CGPoint(x: 20.0, y: height / 2)
		numberRenderer.fromNumber = 0.0
		numberRenderer.toNumber = chart.value
		if let font = chart.labelFont {
			numberRenderer.font = font
		}
		if let offsetRatio = chart.labelOffsetRatio {
			numberRenderer.offsetRatio = offsetRatio
		}
		if let offset = chart.labelOffset {
			numberRenderer.offset = offset
		}
		
		if let format = chart.labelFormat {
			numberRenderer.format = format
		}
		if let color = chart.labelColor {
			numberRenderer.color = color
		}
		numberRenderer.drawToNumberAndPoint()
		
		setNeedsDisplay()
	}
	
	override func draw(in ctx: CGContext) {
		ctx.saveGState()
		super.draw(in: ctx)
		numberRenderer.draw(context: ctx)
		ctx.restoreGState()
	}
	
	private var numberRenderer = NumberRenderer()
	private var displayLink: CADisplayLink?
	
	public func animateWithDuration(duration: TimeInterval) {
		let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
		strokeAnimation.duration = duration
		strokeAnimation.fromValue = 0
		strokeAnimation.toValue = 1
		strokeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
		progressCanvas?.add(strokeAnimation, forKey: "strokeAnimation")
		startAnimation(with: duration)
	}
	
	// MARK: Private methods
	
	private var idleLayers = [CAShapeLayer]()
	private var visibleLayers = [CAShapeLayer]()
	private var idleGradientLayers = [CAGradientLayer]()
	private var visibleGradientLayers = [CAGradientLayer]()
	private var idleCanvas = [CALayer]()
	private var visibleCanvas = [CALayer]()
	private var idleNumberRenderer = [NumberRenderer]()
	private var visibleNumberRenderer = [NumberRenderer]()
	
	private var shapeCanvas: CAShapeLayer {
		var shapeCanvas: CAShapeLayer?
		if let shape = idleLayers.first {
			idleLayers.removeFirst()
			shapeCanvas = shape
		} else {
			shapeCanvas = CAShapeLayer()
		}
		
		shapeCanvas!.frame = CGRect(x: 0.0, y: 0.0, width: chart!.frame.width, height: chart!.frame.height)
		addSublayer(shapeCanvas!)
		visibleLayers.append(shapeCanvas!)
		return shapeCanvas!
	}
	
	private var gradientLayer: CAGradientLayer {
		var gradientLayer: CAGradientLayer?
		if let shape = idleGradientLayers.first {
			idleGradientLayers.removeFirst()
			gradientLayer = shape
		} else {
			gradientLayer = CAGradientLayer()
		}
		
		gradientLayer!.frame = CGRect(x: 0.0, y: 0.0, width: chart!.frame.width, height: chart!.frame.height)
		addSublayer(gradientLayer!)
		visibleGradientLayers.append(gradientLayer!)
		return gradientLayer!
	}
	
	private var progressCanvas: CAShapeLayer?
	
	private func removeVisibleLayers() {
		idleLayers.append(contentsOf: visibleLayers)
		for layer in visibleLayers {
			layer.removeFromSuperlayer()
		}
		visibleLayers.removeAll()
		
		idleGradientLayers.append(contentsOf: visibleGradientLayers)
		for layer in visibleGradientLayers {
			layer.removeFromSuperlayer()
		}
		visibleGradientLayers.removeAll()
		
		idleCanvas.append(contentsOf: visibleCanvas)
		for layer in visibleCanvas {
			layer.removeFromSuperlayer()
		}
		visibleCanvas.removeAll()
		
		idleNumberRenderer.append(contentsOf: visibleNumberRenderer)
		visibleNumberRenderer.removeAll()
	}
	
	private var progress: TimeInterval = 0.0
	private var maximumProgress: TimeInterval = 1.0
	private var lastUpdateTime: TimeInterval = 0.0
	
	private func startAnimation(with duration: TimeInterval) {
		displayLink?.invalidate()
		displayLink = nil
		if duration == 0.0 {
			return
		}
		
		progress = 0
		maximumProgress = duration
		lastUpdateTime = Date.timeIntervalSinceReferenceDate
		
		displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay(link:)))
		displayLink?.preferredFramesPerSecond = 60
		displayLink?.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
		displayLink?.add(to: RunLoop.main, forMode: .UITrackingRunLoopMode)
	}
	
	@objc private func updateDisplay(link: CADisplayLink) {
		let now = Date.timeIntervalSinceReferenceDate
		progress += now - lastUpdateTime
		lastUpdateTime = now
		
		if progress >= maximumProgress {
			displayLink?.invalidate()
			displayLink = nil
			progress = maximumProgress
		}
		
		let percent = CGFloat(progress / maximumProgress)
		numberRenderer.update(with: percent)
		self.setNeedsDisplay()
	}
	
}

fileprivate extension CGMutablePath {
	
	func addArc(center: CGPoint, radius: CGFloat, start: CGFloat, end: CGFloat) {
		if start == end {
			self.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
		} else {
			self.addArc(center: center, radius: radius, startAngle: start, endAngle: end, clockwise: false)
		}
	}
}
