//
//  NumberRenderer.swift
//  ProgressChart
//
//  Created by Vlad Korzun on 7/26/18.
//  Copyright © 2018 Vlad Korzun. All rights reserved.
//

import UIKit

final class NumberRenderer {
	
	// MARK: Instance initialization
	
	init() {
		font = UIFont.systemFont(ofSize: 12)
		color = UIColor.black
		format = "%.2f%"
	}
	
	// MARK: Interface methods
	
	public var fromNumber: CGFloat = 0.0
	public var toNumber: CGFloat? {
		didSet {
			if let value = oldValue {
				fromNumber = value
			}
		}
	}
	public var fromPoint: CGPoint?
	public var toPoint: CGPoint? {
		didSet {
			fromPoint = oldValue
		}
	}
	public var font: UIFont {
		didSet {
			attributes[.font] = font
		}
	}
	public var color: UIColor {
		didSet {
			attributes[.foregroundColor] = color
		}
	}
	public var offsetRatio = CGPoint(x: 0.0, y: 0.0)
	public var format: String {
		didSet {
			isInteger = false
			if let range = format.range(of: "%(.*)d", options: .regularExpression, range: nil, locale: nil), !range.isEmpty {
				isInteger = true
			}
			if let range = format.range(of: "%(.*)i", options: .regularExpression, range: nil, locale: nil), !range.isEmpty {
				isInteger = true
			}
		}
	}
	public var offset = CGSize(width: 0.0, height: 0.0)
	public var isHidden: Bool = false
	public var sum: CGFloat?
	
	public func drawToNumberAndPoint() {
		currentNumber = toNumber
		currentPoint = toPoint
	}
	
	public func startUpdateWith(_ progress: CGFloat) {
		startUpdateNumberWith(progress)
		startUpdatePointWith(progress)
	}
	
	public func startUpdateNumberWith(_ progress: CGFloat) {
		currentNumber = fromNumber + (toNumber! - fromNumber) * progress
	}
	
	public func startUpdatePointWith(_ progress: CGFloat) {
		if let start = fromPoint, let end = toPoint {
			let length = self.length(from: start, to: end)
			let newLength = length * progress
			let line = move(start: start, end: end, value: newLength)
			currentPoint = line.start
		}
	}
	
	public func draw(context: CGContext) {
		if isHidden {
			return
		}
		
		guard let currentPoint = self.currentPoint else {
			return
		}
		
		let center = CGPoint(x: currentPoint.x + offset.width, y: currentPoint.y + offset.height)
		let numberRatio = ratio(from: offsetRatio)
		let drawText = isInteger ? NSString(format: format as NSString, Int(currentNumber!)) : NSString(format: format as NSString, currentNumber!)
		let size = drawText.size(withAttributes: attributes)
		let drawPoint = CGPoint(x: center.x + size.width * numberRatio.x, y: center.y + size.height * numberRatio.y)
		UIGraphicsPushContext(context)
		drawText.draw(at: drawPoint, withAttributes: attributes)
		UIGraphicsPopContext()
	}

	// MARK: Private methods
	
	private var attributes = [NSAttributedStringKey : Any]()
	private var currentNumber: CGFloat?
	private var currentPoint: CGPoint?
	private var isInteger: Bool = false
	
	private func length(from start: CGPoint, to end: CGPoint) -> CGFloat {
		let width = start.x - end.y
		let height = start.y - end.y
		return CGFloat(sqrtf(Float(height * height + width * width)))
	}
	
	private func move(start: CGPoint, end: CGPoint, value: CGFloat) -> (start: CGPoint, end: CGPoint) {
		let x = start.x + value * CGFloat(cosf(Float(circular(start: start, end: end))))
		let y = start.y + value * CGFloat(sinf(Float(circular(start: start, end: end))))
		return (start: CGPoint(x: x, y: y), end: end)
	}
	
	private func circular(start: CGPoint, end: CGPoint) -> CGFloat{
		let x = end.x - start.x
		let y = end.y - start.y
		return atan2(x, y)
	}
	
	private func pureDecimal(from value: CGFloat) -> CGFloat {
		return value - 1 > 0 ? 1 : (value - 1 < -2 ? -1 : value)
	}
	
	private func ratio(from point: CGPoint) -> CGPoint {
		return CGPoint(x: (-1 + pureDecimal(from: point.x)) / 2, y: (-1 + pureDecimal(from: point.y)) / 2)
	}
	
}
