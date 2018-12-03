//
//	Sound.swift
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
import AVFoundation

public typealias PlayerCompletion = ((Bool) -> ())
fileprivate var associatedCallbackKey = "swiftaudiomanager.associatedCallbackKey"
fileprivate typealias Player = AVAudioPlayer

public class Sound {
	/// Sound session. The default value is the shared `AVAudioSession` session.
	public static let session: AVAudioSession = AVAudioSession.sharedInstance()

	private let players: [Player]

	private var counter = 0

	/// Sound volume.
	/// A value in the range 0.0 to 1.0, with 0.0 representing the minimum volume and 1.0 representing the maximum volume.
	public var volume: Float {
		get {
			return players[counter].volume
		}
		set {
			for player in players {
				player.volume = newValue
			}
		}
	}

	/// Duration of the sound.
	public var duration: TimeInterval {
		get {
			return players[counter].duration
		}
	}

	/// Indicates if the sound is currently playing.
	public var isPlaying: Bool {
		get {
			return players[counter].isPlaying
		}
	}

	/// Indicates if the sound is paused.
	public private(set) var paused: Bool = false

	// MARK: - Initialization

	/// Create a sound object.
	///
	/// - Parameter url: Sound file URL.
	public init?(url: URL, maxPlayers: Int = 5) {
		try? Sound.session.setCategory(AVAudioSessionCategoryAmbient)
		let playersCount = max(maxPlayers, 1)
		var myPlayers: [Player] = []
		myPlayers.reserveCapacity(playersCount)
		for _ in 0..<playersCount {
			do {
				let player = try Player(contentsOf: url)
				myPlayers.append(player)
			} catch {
				print("Sound initialization error: \(error)")
			}
		}
		if myPlayers.count == 0 {
			return nil
		}
		players = myPlayers
	}

	// MARK: - Main play method

	/// Play the sound.
	///
	/// - Parameter numberOfLoops: Number of loops. Specify a negative number for an infinite loop. Default value of 0 means that the sound will be played once.
	/// - Returns: If the sound was played successfully the return value will be true. It will be false if sounds are disabled or if system could not play the sound.
	@discardableResult public func play(numberOfLoops: Int = 0, completion: PlayerCompletion? = nil) -> Bool {
		paused = false
		counter = (counter + 1) % players.count
		let player = players[counter]
		return player.play(numberOfLoops: numberOfLoops, completion: completion)
	}

	// MARK: - Stop playing

	/// Stop playing the sound.
	public func stop() {
		for player in players {
			player.stop()
		}
		paused = false
	}

	/// Pause current playback.
	public func pause() {
		players[counter].pause()
		paused = true
	}


	/// Resume playing.
	public func resume() {
		players[counter].play()
		paused = false
	}
}

extension Player: AVAudioPlayerDelegate {
	fileprivate func play(numberOfLoops: Int, completion: PlayerCompletion?) -> Bool {
		if let cmpl = completion {
			objc_setAssociatedObject(self, &associatedCallbackKey, cmpl, .OBJC_ASSOCIATION_COPY_NONATOMIC)
			self.delegate = self
		}
		self.numberOfLoops = numberOfLoops
		return play()
	}

	fileprivate func audioPlayerDidFinishPlaying(_ player: Player, successfully flag: Bool) {
		let cmpl = objc_getAssociatedObject(self, &associatedCallbackKey) as? PlayerCompletion
		cmpl?(flag)
		objc_removeAssociatedObjects(self)
		self.delegate = nil
	}

	fileprivate func audioPlayerDecodeErrorDidOccur(_ player: Player, error: Error?) {
		print("Sound playback error: \(String(describing: error))")
	}
}
