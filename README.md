# SwiftAudioManager

[![CI Status](https://img.shields.io/travis/sunming@udel.edu/SwiftAudioManager.svg?style=flat)](https://travis-ci.org/sunming@udel.edu/SwiftAudioManager)
[![Version](https://img.shields.io/cocoapods/v/SwiftAudioManager.svg?style=flat)](https://cocoapods.org/pods/SwiftAudioManager)
[![License](https://img.shields.io/cocoapods/l/SwiftAudioManager.svg?style=flat)](https://cocoapods.org/pods/SwiftAudioManager)
[![Platform](https://img.shields.io/cocoapods/p/SwiftAudioManager.svg?style=flat)](https://cocoapods.org/pods/SwiftAudioManager)

## SwiftAudioManager RoadMap
- 0.1.0 Foundation features
- 0.2.0 Downloading & Local storage
- 0.3.0 Key - Url - Music system
- 0.4.0 List of keys of stored music
- 0.5.0 BGM Fading
- 0.6.0 Auto play next in the list

## Open issue
+ Multiple SFX players, but share one common buffer?

## Usage
- ### Step1: preparation
Every audio resource has an URL, it can be a local file URL, or a online file link.
#### For local file URL:
If means, the audio comes with the bundle - saved with the code base, so to speak - then you can retrive the complete address by this line of code:
```
Bundle.main.url(forResource: "audio name", withExtension: "mp3")
```
#### For online file link:
	- A valid link - one that will work on browser - is require:
[https://www.example.com/sounds/1/example.mp3 link](https://www.example.com/sounds/1/example.mp3)
	- Then you need to download and save the audio file locally by using this line of code:
```
SwiftAudioManager.shared.prepareAssets(_ urlList: ["local url/link"]) { outcomeList in
		for outcome in outcomeList {
			// outcome is a typealias: (url: URL, success: Bool)
			if !outccome.success {
				// handle file retrieve/download failure for current local url/link
			}
		}
}
```
	- Note: the downloaded sound files will be persistantly cached in disk.

- ### Step2: how to play
	- Play as BGM(background music):

	A BMG that will constantly be playing. The song will be played again if it ends. The new song will override the old song, one BGM at a time.
```
SwiftAudioManager.shared.playAsBGM("local url/link")
```
	- Play as SFX(sound effect)

	Sounds like a click, swipe, or a clap. The new SFX will be played instantly, overlapping the current SFX, even if they are the same sound.
```
SwiftAudioManager.shared.playAsSFX("local url/link")
```

- ### Other useful methods:
	- Stop all sound effect:
	```
	SwiftAudioManager.shared.enabled = false
	```

## Working Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 10.0+, Swift 4

## Installation

SwiftAudioManager is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod 'SwiftAudioManager'
```

## Author

mingsun.nolan@gmail.com

## License

SwiftAudioManager is available under the MIT license. See the LICENSE file for more info.
