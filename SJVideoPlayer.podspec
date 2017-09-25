
Pod::Spec.new do |s|
s.name         = 'SJVideoPlayer'
s.version      = '0.0.6'
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


s.source_files = 'SJVideoPlayer/*.{h,m}'

    s.subspec 'Category' do |ss|
        ss.source_files = 'SJVideoPlayer/Category/*.{h,m}'
    ss.public_header_files = 'SJVideoPlayer/Category/*.{h}'
    end

    s.subspec 'Control' do |ss|
        ss.source_files = 'SJVideoPlayer/Control/***/**/*.{h,m}'
        ss.public_header_files = 'SJVideoPlayer/Control/***/**/*.{h}'
    end

    s.subspec 'Loading' do |ss|
        ss.source_files = 'SJVideoPlayer/Loading/*.{h,m}'
        ss.public_header_files = 'SJVideoPlayer/Loading/*.{h}'
    end

    s.subspec 'Model' do |ss|
        ss.source_files = 'SJVideoPlayer/Model/*.{h,m}'
        ss.public_header_files = 'SJVideoPlayer/Model/*.{h}'
    end

    s.subspec 'Present' do |ss|
        ss.source_files = 'SJVideoPlayer/Present/*.{h,m}'
        ss.public_header_files = 'SJVideoPlayer/Present/*.{h}'
    end

    s.subspec 'Prompt' do |ss|
        ss.source_files = 'SJVideoPlayer/Prompt/*.{h,m}'
        ss.public_header_files = 'SJVideoPlayer/Prompt/*.{h}'
    end



end















