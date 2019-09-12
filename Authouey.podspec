#
# Be sure to run `pod lib lint Authouey.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Authouey'
  s.version          = '0.1.0'
  s.summary          = 'Simple solution for Authentication for your iOS App'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Simple solution for Authentication for your iOS App.
                       DESC

  s.homepage         = 'https://github.com/yurovmd/Authouey'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yurovmd' => 'yurrrov@gmail.com' }
  s.source           = { :git => 'https://github.com/yurovmd/Authouey.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/no1profit'

  s.ios.deployment_target = '11.0'
  s.swift_versions = '4.2'

  s.source_files = 'Authouey/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Authouey' => ['Authouey/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
