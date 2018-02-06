
Pod::Spec.new do |s|
s.name         = 'SJVideoPlayer'
s.version      = '2.0.0.1'
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
s.dependency 'SJAttributesFactory'
s.dependency 'SJBorderLineView'
s.dependency 'SJPrompt'
s.dependency 'SJUIFactory'
s.dependency 'SJFullscreenPopGesture'
s.dependency 'SJOrentationObserver'
s.dependency 'SJLoadingView'
s.dependency 'SJVideoPlayerAssetCarrier'
s.dependency 'SJVolBrigControl'
s.dependency 'SJObserverHelper'

#s.source_files = 'SJVideoPlayer/*.{h,m}'

s.subspec 'Header' do |ss|
    ss.source_files = 'SJVideoPlayer/Header/*.{h}'
end

s.subspec 'Present' do |ss|
    ss.source_files = 'SJVideoPlayer/Present/*.{h,m}'
    ss.dependency 'SJVideoPlayer/Header'
end

s.subspec 'Category' do |ss|
    ss.source_files = 'SJVideoPlayer/Category/*.{h,m}'
end

s.subspec 'Registrar' do |ss|
    ss.source_files = 'SJVideoPlayer/Registrar/*.{h,m}'
end

s.subspec 'GestureControl' do |ss|
    ss.source_files = 'SJVideoPlayer/GestureControl/*.{h,m}'
end

s.subspec 'TimerControl' do |ss|
    ss.source_files = 'SJVideoPlayer/TimerControl/*.{h,m}'
end

s.subspec 'Model' do |ss|
    ss.source_files = 'SJVideoPlayer/Model/*.{h,m}'
    ss.dependency 'SJVideoPlayerAssetCarrier'
end

s.subspec 'Resource' do |ss|
    ss.source_files = 'SJVideoPlayer/Resource/*.{h,m}'
end

s.subspec 'ControlView' do |ss|
    ss.source_files = 'SJVideoPlayer/ControlView/*.{h,m}'
    ss.dependency 'SJVideoPlayer/Resource'
    ss.dependency 'SJVideoPlayer/MoreSetting'
    ss.dependency 'SJVideoPlayer/Header'
    ss.dependency 'SJVideoPlayer/Model'
end

s.subspec 'MoreSetting' do |ss|
    ss.source_files = 'SJVideoPlayer/MoreSetting/*.{h,m}'
    ss.dependency 'SJVideoPlayer/Resource'
end

end
