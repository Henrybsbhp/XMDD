# coding: utf-8
Pod::Spec.new do |s|

  s.name         = "ckkit"
  s.version      = "0.0.1"
  s.summary      = "一个扩展类库，提供一些简便功能"
  s.homepage     = "https://stash.jtang.cn/projects/IOSLIB/repos/ckkit/"
  s.license      = 'MIT'
  s.author             = { "jiangjunchen" => "jjc@jtang.cn" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "ssh://git@stash.jtang.cn:7999/IOSLIB/ckkit.git", :tag => "0.0.1" }
  s.source_files  = 'Classes/**/*.{h,m}'
  s.resource = 'Classes/**/*'


end
