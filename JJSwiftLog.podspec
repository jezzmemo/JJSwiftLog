#
# Be sure to run `pod lib lint JJSwiftLog.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JJSwiftLog'
  s.version          = '0.0.1'
  s.summary          = 'High performance swift log module.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
High performance swift log,support customer log.
                       DESC

  s.homepage         = 'https://github.com/jezzmemo/JJSwiftLog'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jezz' => 'lijie250@gmail.com' }
  s.source           = { :git => 'https://github.com/jezzmemo/JJSwiftLog.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_versions = ['4.0','4.2','5.0']
  s.default_subspec = 'Main'

  s.static_framework = true

  s.subspec 'Main' do |spec|
    spec.source_files = 'JJSwiftLog/Source/*.{swift}'
  end

  s.subspec 'Bugly' do |spec|
    spec.source_files = 'JJSwiftLog/Source/Vendor/BuglyOutput.swift'
    spec.dependency 'Bugly'
    spec.dependency 'JJSwiftLog/Main'
  end

  s.subspec 'Umeng' do |spec|
    spec.source_files = 'JJSwiftLog/Source/Vendor/UmengOutput.swift'
    spec.public_header_files = "JJSwiftLog/Source/Vendor/_UmengBridging.h"
    spec.dependency 'JJSwiftLog/Main'
    spec.dependency 'UMCAnalytics'
  end

end
