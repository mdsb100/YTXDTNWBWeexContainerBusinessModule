#
# Be sure to run `pod lib lint YTXDTNWBWeexContainerBusinessModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YTXDTNWBWeexContainerBusinessModule'
  s.version          = '0.1.11'
  s.summary          = 'YTXDTNWBWeexContainerBusinessModule.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
YTXDTNWBWeexContainerBusinessModule
Weex若业务组件的容器，初始化和提供容器。
                       DESC

  s.homepage         = "https://github.com/mdsb100/YTXDTNWBWeexContainerBusinessModule"
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'caojun' => '78612846@qq.com' }

  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source           = { :git => "https://github.com/mdsb100/YTXDTNWBWeexContainerBusinessModule.git", :tag => s.version.to_s }


  s.source_files = 'YTXDTNWBWeexContainerBusinessModule/Classes/**/*'
  
  s.dependency 'YTXModule', '~> 1.2'
  
  s.dependency 'WeexSDK', '~> 0.17'
  s.dependency 'Kingfisher', '~> 4.0'
  
  s.dependency 'ReactiveCocoa', '~> 2.5'
  s.dependency 'Mantle', '~> 1.5'
  s.dependency 'SSZipArchive', '~> 2.1'
  
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'SWIFT_VERSION' => '3.2', 'DEFINES_MODULE' => 'YES' }

  s.resource_bundles = {
    'YTXDTNWBWeexContainerBusinessModule' => ['YTXDTNWBWeexContainerBusinessModule/Assets/**']
  }

  s.prefix_header_contents = "#define #{s.name}_Directory " + '@"' "#{s.name}" + '"'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
