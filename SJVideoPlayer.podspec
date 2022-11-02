
Pod::Spec.new do |s|
    s.name         = 'SJVideoPlayer'
    s.version      = '3.4.3'
    s.summary      = 'video player.'
    s.description  = 'https://github.com/changsanjiang/SJVideoPlayer/blob/master/README.md'
    s.homepage     = 'https://github.com/changsanjiang/SJVideoPlayer'
    s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
    s.author       = { 'SanJiang' => 'changsanjiang@gmail.com' }
    s.platform     = :ios, '9.0'
    s.source       = { :git => 'https://github.com/changsanjiang/SJVideoPlayer.git', :tag => "v#{s.version}" }
    s.requires_arc = true
    s.dependency 'SJBaseVideoPlayer', '>= 3.7.5'

    s.source_files = 'SJVideoPlayer/*.{h,m}'
    
    s.subspec 'Common' do |ss|
      ss.source_files = 'SJVideoPlayer/Common/**/*'
      ss.dependency 'Masonry'
      ss.dependency 'SJBaseVideoPlayer'
      ss.dependency 'SJUIKit/AttributesFactory'
      ss.dependency 'SJVideoPlayer/ResourceLoader'
    end
    
    s.subspec 'ControlLayers' do |ss|
      ss.source_files = 'SJVideoPlayer/ControlLayers/**/*'
      ss.dependency 'SJVideoPlayer/Common'
    end
    
    s.subspec 'ResourceLoader' do |ss|
      ss.source_files = 'SJVideoPlayer/ResourceLoader/*.{h,m}'
      ss.resource = 'SJVideoPlayer/ResourceLoader/SJVideoPlayer.bundle'
    end
end
