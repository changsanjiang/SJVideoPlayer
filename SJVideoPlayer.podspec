
Pod::Spec.new do |s|
s.name         = 'SJVideoPlayer'
s.version      = '2.0.3.6'
s.summary      = 'video player.'
s.description  = 'https://github.com/changsanjiang/SJVideoPlayer/blob/master/README.md'
s.homepage     = 'https://github.com/changsanjiang/SJVideoPlayer'
s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
s.author       = { 'SanJiang' => 'changsanjiang@gmail.com' }
s.platform     = :ios, '8.0'
s.source       = { :git => 'https://github.com/changsanjiang/SJVideoPlayer.git', :tag => "v#{s.version}" }
s.resource     = 'SJVideoPlayer/Resource/SJVideoPlayer.bundle'
s.frameworks  = "UIKit", "AVFoundation"
s.requires_arc = true
s.dependency 'Masonry'
s.dependency 'SJSlider'
s.dependency 'SJBaseVideoPlayer'
s.dependency 'SJAttributesFactory'
s.dependency 'SJLoadingView'

s.source_files = 'SJVideoPlayer/*.{h,m}'

s.subspec 'Resource' do |ss|
    ss.source_files = 'SJVideoPlayer/Resource/*.{h,m}'
end

s.subspec 'ControlView' do |ss|
    ss.source_files = 'SJVideoPlayer/ControlView/*.{h,m}'
    ss.dependency 'SJVideoPlayer/Resource'
    ss.dependency 'SJVideoPlayer/MoreSetting'
end

s.subspec 'MoreSetting' do |ss|
    ss.source_files = 'SJVideoPlayer/MoreSetting/*.{h,m}'
    ss.dependency 'SJVideoPlayer/Resource'
end

s.subspec 'Download' do |ss|
ss.source_files = 'SJVideoPlayer/Download/*.{h,m}'
ss.ios.library = 'sqlite3'
end

end
