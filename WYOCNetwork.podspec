#
# Be sure to run `pod lib lint WYOCNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WYOCNetwork'
  s.version          = '0.0.1'
  s.summary          = 'iOS 网络请求库。基于AFNetworking封装.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
iOS 网络请求库。基于AFNetworking封装.
                       DESC

  s.homepage         = 'https://github.com/wuyaGit/WYOCNetwork'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wuya' => '407671883@qq.com' }
  s.source           = { :git => 'https://github.com/wuyaGit/WYOCNetwork.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'WYOCNetwork/*'
  
  #s.resource_bundles = {
  #    'WYOCNetwork' => ['WYOCNetwork/Assets/*.png']
  #}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking'
  s.dependency 'YYCache'
  s.dependency 'YYModel'

end
