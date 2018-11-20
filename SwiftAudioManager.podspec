#
# Be sure to run `pod lib lint SwiftAudioManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftAudioManager'
  s.version          = '0.1.0'
  s.summary          = 'SwiftAudioManager is a toolkit that helps you to build sound effects.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'SwiftAudioManager is a toolkit that helps you to: play music as BGM(loop), or as SFX(stackable), manage local music storage and a lots more .'

  s.homepage         = 'https://github.com/supersun17/SwiftAudioManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sunming@udel.edu' => 'mingsun.nolan@gmail.com' }
  s.source           = { :git => 'https://github.com/sunming@udel.edu/SwiftAudioManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.swift_version = '4.0'

  s.source_files = 'SwiftAudioManager/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SwiftAudioManager' => ['SwiftAudioManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
