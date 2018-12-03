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
	/// The one and only instance object of SwiftAudioManager
	public static let shared = SwiftAudioManager()

	/// This variable indicates whether SwiftAudioManager can play sound or not.
	/// Set it to false will disable SwiftAudioManager, and stop all currently playing sounds.
	public var enabled: Bool = true {
		didSet {
			if !enabled { stopAll() }
		}
	}

	/// This variable is used to indicate whether there is a BGM playing
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

	/**
	Use this method to prepare online audio resource.
	It's OK to also pass in local assets URL. SwiftAudioManager won't start downloading if this is a local resource.
	- Parameters:
	- urlList: the list of online resource URL
	- completion: the callback handler will be called after all resources have been downloaded. The argument outcomeDictionary is used to indicate whether a specific resource has been successfully downloaded. For an given URL, if the download failed, the Boolean value will be false.
	- Note: local URL will always return success, because there is no need to download.
	**/
	public func prepareAssets(_ urlList: [URL], completion: @escaping (_ outcomeDictionary: Dictionary<URL,Bool>) -> Void) {
		var tempStatus = Dictionary<URL,Bool>()
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			let group = DispatchGroup()
			for url in urlList {
				group.enter()
				tempStatus[url] = self?.cachingManager.downloadANDcahce(url)
				group.leave()
			}
			group.notify(queue: .main, execute: {
				print("SwiftAudioManager resource download finished")
				completion(tempStatus)
			})
		}
	}

	/**
	Use this method to play local audio or cached audio as a BackGround Music.
	- Parameters:
	- sourceURL: Bundle URL or online URL
	- loop: if true, then the BGM will loop
	- completion: the callback handler will be called after the audio finished. It can be just nil
	**/
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

	/**
	Use this method to play local audio or cached audio as a Sound Effect.
	- Parameters:
	- sourceURL: Bundle URL or online URL
	**/
	public func playAsSFX(_ sourceURL: URL) {
		if !enabled { return }
		if let sound = findSound(for: sourceURL) {
			sound.play()
		} else {
			createSound(for: sourceURL)?.play()
		}
	}

	/**
	Stop playing sound for a given url.
	- Parameter url: Sound file url.
	**/
	public func stop(for sourceURL: URL) {
		findSound(for: sourceURL)?.stop()
	}

	/**
	Stop playing all sounds.
	**/
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
