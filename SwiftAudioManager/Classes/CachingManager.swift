//
//	CachingManager.swift
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

internal class CachingManager {
	private let baseDirectory: URL = {
		if #available(iOS 10.0, *) {
			return FileManager.default.temporaryDirectory.appendingPathComponent("SwiftAudioManager", isDirectory: true)
		} else {
			return URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("SwiftAudioManager", isDirectory: true)
		}
	}()

	internal init() {
		if !FileManager.default.fileExists(atPath: baseDirectory.path) {
			try? FileManager.default.createDirectory(atPath: baseDirectory.path, withIntermediateDirectories: true, attributes: nil)
		}
	}

	internal func downloadANDcahce(_ sourceURL: URL) -> Bool {
		if isURLUnderBunble(sourceURL) { return true }

		do {
			let data = try Data(contentsOf: sourceURL)
			saveSoundCache(sourceURL, data: data)
			return true
		} catch let error {
			print("Sound file \(sourceURL) init error: \(error)")
			return false
		}
	}

	internal func isSoundCacheExist(_ sourceURL: URL) -> Bool {
		return FileManager.default.fileExists(atPath: soundFileLocalPath(sourceURL))
	}

	internal func soundFileLocalURL(_ sourceURL: URL) -> URL {
		if isURLUnderBunble(sourceURL) {
			return sourceURL
		} else {
			let fileURL = baseDirectory.appendingPathComponent(sourceURL.lastPathComponent)
			return fileURL
		}
	}

	internal func isURLUnderBunble(_ sourceURL: URL) -> Bool {
		if sourceURL.isFileURL {
			let sourceURLComps = sourceURL.pathComponents
			let bundleURLEndIndex = Bundle.main.bundleURL.pathComponents.endIndex - 1
			let bundleURLLastComp = Bundle.main.bundleURL.lastPathComponent
			return sourceURLComps[bundleURLEndIndex].elementsEqual(bundleURLLastComp)
		} else {
			return false
		}
	}

	internal func soundFileLocalPath(_ sourceURL: URL) -> String {
		return soundFileLocalURL(sourceURL).path
	}

	internal func saveSoundCache(_ sourceURL: URL, data: Data) {
		FileManager.default.createFile(atPath: soundFileLocalPath(sourceURL), contents: data, attributes: nil)
	}

	internal func loadSoundCache(_ sourceURL: URL) -> Data? {
		return FileManager.default.contents(atPath: soundFileLocalPath(sourceURL))
	}
}
