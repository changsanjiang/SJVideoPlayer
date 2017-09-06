
Pod::Spec.new do |s|
s.name         = 'SJVideoPlayer'
s.version      = '0.0.1'
s.summary      = 'video player.'
s.description  = 'https://github.com/changsanjiang/SJVideoPlayer/blob/master/README.md'
s.homepage     = 'https://github.com/changsanjiang/SJVideoPlayer'
s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
s.author       = { 'SanJiang' => 'changsanjiang@gmail.com' }
s.platform     = :ios, '8.0'
s.source       = { :git => 'https://github.com/changsanjiang/SJVideoPlayer.git', :tag => "v#{s.version}" }
s.source_files = 'SJVideoPlayer/**/*.{h,m}'
s.resource     = 'SJVideoPlayer/Resource/SJVideoPlayer.bundle'
s.framework  = 'UIKit'
s.requires_arc = true
s.dependency 'Masonry'
end
