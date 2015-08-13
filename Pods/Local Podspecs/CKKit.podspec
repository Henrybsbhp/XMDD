# coding: utf-8
#
# Be sure to run `pod lib lint CKKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CKKit"
  s.version          = "0.1.0"
  s.summary          = "就是个库"
  s.description      = <<-DESC
                       没啥好说的

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://stash.jtang.cn/projects/IOSLIB/repos/ckkit/browse"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "jjc" => "jjc@jtang.cn" }
  s.source           = { :git => "ssh://git@stash.jtang.cn:7999/IOSLIB/ckkit.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'CKKit' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'MobileCoreServices'
  # s.dependency 'AFNetworking', '~> 2.3'
end
