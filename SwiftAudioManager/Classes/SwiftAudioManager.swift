//
//	SwiftAudioManager.swift
//	Pods-SwiftAudioManager
//
//	Created by Ming Sun on 11/19/18.
//
//	Copyright (c) 2018 sunming@udel.edu <mingsun.nolan@gmail.com>
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

import Foundation

public class SwiftAudioManager {
	public static let shared = SwiftAudioManager()

	public typealias PrepareOutcome = (url: URL, success: Bool)

	public var enabled: Bool = true {
		didSet {
			if !enabled { stopAll() }
		}
	}

	public var isBGMPlaying: Bool {
		get {
			if let url = currentBGM, let sound = SwiftAudioManager.sounds[url], sound.isPlaying {
				return true
			} else {
				return false
			}
		}
	}

	private static var sounds: [URL:Sound] = [:]
	private lazy var cachingManager = CachingManager()
	private var currentBGM: URL?

	private init() {}

	public func prepareAssets(_ urlList: [URL], completion: @escaping (_ outcomeList: [PrepareOutcome]) -> Void) {
		var tempStatus = Dictionary<URL,Bool>()
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			let group = DispatchGroup()
			for url in urlList {
				group.enter()
				tempStatus[url] = self?.cachingManager.downloadANDcahce(url)
				group.leave()
			}
			group.notify(queue: .main, execute: {
				print("dispatch: all done")
				var tempOutcomeList = [PrepareOutcome]()
				for url in urlList {
					let outcome = PrepareOutcome(url: url, success: tempStatus[url] ?? false)
					tempOutcomeList.append(outcome)
				}
				completion(tempOutcomeList)
			})
		}
	}

	public func playAsBGM(_ sourceURL: URL, loop: Bool = true, completion: PlayerCompletion? = nil) {
		if !enabled { return }
		if isBGMPlaying {
			if currentBGM!.path.elementsEqual(sourceURL.path) {
				return
			} else {
				stop(for: currentBGM!)
			}
		}
		let numberOfLoops = (loop) ? (-1):(0)
		let localURL = cachingManager.soundFileLocalURL(sourceURL)
		if let sound = findSound(for: sourceURL) {
			sound.play(numberOfLoops: numberOfLoops, completion: nil)
		} else {
			createSound(for: sourceURL, maxPlayers: 1)?.play(numberOfLoops: numberOfLoops, completion: completion)
		}
		currentBGM = localURL
	}

	public func playAsSFX(_ sourceURL: URL) {
		if !enabled { return }
		if let sound = findSound(for: sourceURL) {
			sound.play()
		} else {
			createSound(for: sourceURL)?.play()
		}
	}

	/// Stop playing sound for given url.
	///
	/// - Parameter url: Sound file url.
	public func stop(for sourceURL: URL) {
		findSound(for: sourceURL)?.stop()
	}

	public func stopAll() {
		for (_,v) in SwiftAudioManager.sounds {
			v.stop()
		}
	}

	private func createSound(for sourceURL: URL) -> Sound? {
		let localURL = cachingManager.soundFileLocalURL(sourceURL)
		let sound = Sound(url: localURL)
		SwiftAudioManager.sounds[localURL] = sound
		return sound
	}

	private func createSound(for sourceURL: URL, maxPlayers: Int) -> Sound? {
		let localURL = cachingManager.soundFileLocalURL(sourceURL)
		let sound = Sound(url: localURL, maxPlayers: maxPlayers)
		SwiftAudioManager.sounds[localURL] = sound
		return sound
	}

	private func findSound(for sourceURL: URL) -> Sound? {
		let localURL = cachingManager.soundFileLocalURL(sourceURL)
		if let sound = SwiftAudioManager.sounds[localURL] {
			return sound
		} else {
			return nil
		}
	}
}
