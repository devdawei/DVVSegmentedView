
Pod::Spec.new do |s|

s.name         = 'DVVSegmentedView'
s.summary      = 'iOS 自定义的分段控制器，可通过简单配置实现多种样式'
s.version      = '1.0.0'
s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.authors      = { 'devdawei' => '2549129899@qq.com' }
s.homepage     = 'https://github.com/devdawei'

s.platform     = :ios
s.ios.deployment_target = '9.0'
s.requires_arc = true

s.source       = { :git => 'https://github.com/devdawei/DVVSegmentedView.git', :tag => s.version.to_s }

s.source_files = 'DVVSegmentedView/DVVSegmentedView/*.{h,m}'

s.frameworks = 'Foundation', 'UIKit'

s.dependency 'PureLayout'

end
