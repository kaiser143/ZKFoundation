#
# Be sure to run `pod lib lint ZKFoundation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZKFoundation'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ZKFoundation.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/kaiser143/ZKFoundation'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhangkai' => 'deyang143@126.com' }
  s.source           = { :git => 'https://github.com/kaiser143/ZKFoundation.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.requires_arc    = true
  s.source_files = 'ZKFoundation/Classes/Source/*.{h,m}'
  
  s.subspec 'LocationManager' do |ss|
      ss.ios.deployment_target = '8.0'
      ss.source_files = 'ZKFoundation/Classes/Source/LocationManager/*.{h,m}'
  end
  
  s.subspec 'UIKit' do |ss|
      ss.ios.deployment_target = '8.0'
      ss.source_files = 'ZKFoundation/Classes/Source/iOS/*.{h,m}'
  end
  
  s.subspec 'Helper' do |ss|
      ss.ios.deployment_target = '8.0'
      ss.source_files = 'ZKFoundation/Classes/Source/Helper/*.{h,m}'
  end
  
  s.subspec 'Categories' do |ss|
      ss.ios.deployment_target = '8.0'
      ss.source_files = 'ZKFoundation/Classes/Source/Categories/*.{h,m}'
  end
  
  s.subspec 'AuthContext' do |ss|
      ss.ios.deployment_target = '8.0'
      ss.source_files = 'ZKFoundation/Classes/Source/AuthContext/*.{h,m}'
  end
  
  # s.resource_bundles = {
  #   'ZKFoundation' => ['ZKFoundation/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
