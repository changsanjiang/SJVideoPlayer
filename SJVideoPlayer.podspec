
Pod::Spec.new do |s|
s.name         = 'SJVideoPlayer'
s.version      = '0.0.8'
s.summary      = 'video player.'
s.description  = 'https://github.com/changsanjiang/SJVideoPlayer/blob/master/README.md'
s.homepage     = 'https://github.com/changsanjiang/SJVideoPlayer'
s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
s.author       = { 'SanJiang' => 'changsanjiang@gmail.com' }
s.platform     = :ios, '8.0'
s.source       = { :git => 'https://github.com/changsanjiang/SJVideoPlayer.git', :tag => "v#{s.version}" }
s.resource     = 'SJVideoPlayer/Resource/SJVideoPlayer.bundle'
s.framework  = 'UIKit'
s.requires_arc = true
s.dependency 'Masonry'
s.dependency 'SJSlider'
s.dependency 'SJBorderLineView'
s.dependency 'SJPrompt'
s.dependency 'SJVideoPlayerBackGR'

s.source_files = 'SJVideoPlayer/SJPlayer.h'


s.subspec 'Category' do |ss|
    ss.source_files = 'SJVideoPlayer/Category/*.{h,m}'
end


s.subspec 'Constant' do |ss|
    ss.source_files = 'SJVideoPlayer/Constant/*.{h,m}'
end


s.subspec 'Control' do |ss|
    ss.source_files = 'SJVideoPlayer/Control/*.{h,m}'
    ss.dependency 'SJVideoPlayer/Model'
    ss.dependency 'SJVideoPlayer/Category'
    ss.dependency 'SJVideoPlayer/Loading'
    ss.dependency 'SJVideoPlayer/Constant'
end


s.subspec 'Loading' do |ss|
    ss.source_files = 'SJVideoPlayer/Loading/*.{h,m}'
end


s.subspec 'Model' do |ss|
    ss.source_files = 'SJVideoPlayer/Model/*.{h,m}'
end


s.subspec 'Present' do |ss|
    ss.source_files = 'SJVideoPlayer/Present/*.{h,m}'
    ss.dependency 'SJVideoPlayer/Category'
    ss.dependency 'SJVideoPlayer/Control'
    ss.dependency 'SJVideoPlayer/Constant'
end


s.subspec 'VideoPlayer' do |ss|
    ss.source_files = 'SJVideoPlayer/VideoPlayer/*.{h,m}'
    ss.dependency 'SJVideoPlayer/Control'
    ss.dependency 'SJVideoPlayer/Loading'
    ss.dependency 'SJVideoPlayer/Model'
    ss.dependency 'SJVideoPlayer/Present'
    ss.dependency 'SJVideoPlayer/Constant'
end


end















