#
# Be sure to run `pod lib lint ALInstaImageZoom.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'ALInstaImageZoom'
s.version          = '0.3.0'
s.summary          = 'Instagram Zoomable UIImageView '


s.description      = <<-DESC
Looking for instagram UIImageView zoom feature.
Here is the ALInstaImageZoom. Zoomable UIImageView.
DESC

s.homepage         = 'https://github.com/applogistdev/ALInstaImageZoom'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'sonifex' => 'sonerguler93@gmail.com' }
s.source           = { :git => 'https://github.com/applogistdev/ALInstaImageZoom.git', :tag => s.version.to_s }


s.ios.deployment_target = '9.3'
s.swift_version = '5.0'

s.source_files = 'ALInstaImageZoom/Classes/**/*'

s.frameworks = 'UIKit'
end
