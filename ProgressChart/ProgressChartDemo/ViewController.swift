//
//  ViewController.swift
//  ProgressChart
//
//  Created by Vlad Korzun on 7/26/18.
//  Copyright © 2018 Vlad Korzun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var progressChart: ProgressChart!
	@IBOutlet weak var linearProgressChart: ProgressChart!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		progressChart.value = 7
		progressChart.maxValue = 10
		progressChart.radius = 90
		progressChart.labelFont = UIFont.systemFont(ofSize: 30.0)
		progressChart.labelColor = UIColor.red
		progressChart.draw(animated: true, duration: 1.0)
		
		linearProgressChart.value = 75
		linearProgressChart.maxValue = 100
		linearProgressChart.labelColor = UIColor.red
		linearProgressChart.labelFont = UIFont.systemFont(ofSize: 25.0)
		linearProgressChart.labelOffset = CGSize(width: 70.0, height: 0.0)
		linearProgressChart.progressBackgroundColor = UIColor.gray
		linearProgressChart.progressGradientColor = [UIColor.blue, UIColor.red]
		linearProgressChart.drawLinear(animated: true, duration: 1.0)
		
	}
	
}

