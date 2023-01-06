#
# Be sure to run `pod lib lint TTAssistKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTAssistKit'
  s.version          = '1.0.0'
  s.summary          = 'Assist-Kit'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/imbaTao/TTAssistKit.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'imbatao@outlook.com' => 'imbatao@outlook.com' }
  s.source           = { :git => 'https://github.com/imbaTao/TTAssistKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.source_files = 'TTAssisKit.swift'
  
  s.ios.deployment_target = '10.0'
  s.dependency 'RxSwift',"6.5.0"
  s.dependency 'RxCocoa',"6.5.0"
  s.dependency 'NSObject+Rx',"5.2.2"
  s.dependency 'RxOptional',"5.0.2"
#  s.dependency 'RxGesture',"4.0.4"
  s.dependency 'RxRelay',"6.5.0"

  s.subspec 'TTNetObserver' do |ttNetObserver|
    ttNetObserver.source_files = 'TTAssistKit/TTNetObserver/**/*'
    ttNetObserver.dependency 'ReachabilitySwift'
  end

  s.subspec 'TTDevice' do |ttDevice|
      ttDevice.source_files = 'TTAssistKit/TTDevice/**/*'
  end
end
