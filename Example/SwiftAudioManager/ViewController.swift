//
//  ViewController.swift
//  SwiftAudioManager
//
//  Created by sunming@udel.edu on 11/19/2018.
//  Copyright (c) 2018 sunming@udel.edu. All rights reserved.
//

import UIKit
import SwiftAudioManager

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func music1(_ sender: UIButton) {
		SwiftAudioManager.shared.playAsBGM(Bundle.main.url(forResource: "music1", withExtension: "mp3")!)
	}
	@IBAction func music2(_ sender: UIButton) {
		SwiftAudioManager.shared.playAsBGM(Bundle.main.url(forResource: "music2", withExtension: "mp3")!)
	}
	@IBAction func sfx1(_ sender: UIButton) {
		SwiftAudioManager.shared.playAsSFX(Bundle.main.url(forResource: "sfx1", withExtension: "mp3")!)
	}
	@IBAction func sfx2(_ sender: UIButton) {
		SwiftAudioManager.shared.playAsSFX(Bundle.main.url(forResource: "sfx2", withExtension: "mp3")!)
	}
	@IBAction func onlinesfx() {
		SwiftAudioManager.shared.playAsSFX(URL(string: onlineSFX)!)
	}
}

