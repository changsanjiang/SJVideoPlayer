
Pod::Spec.new do |s|
    s.name         = 'SJVideoPlayer'
    s.version      = '2.3.10'
    s.summary      = 'video player.'
    s.description  = 'https://github.com/changsanjiang/SJVideoPlayer/blob/master/README.md'
    s.homepage     = 'https://github.com/changsanjiang/SJVideoPlayer'
    s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
    s.author       = { 'SanJiang' => 'changsanjiang@gmail.com' }
    s.platform     = :ios, '8.0'
    s.source       = { :git => 'https://github.com/changsanjiang/SJVideoPlayer.git', :tag => "v#{s.version}" }
    s.requires_arc = true
    s.dependency 'Masonry'
    s.dependency 'SJBaseVideoPlayer'
    s.dependency 'SJUIFactory'
    s.dependency 'SJAttributesFactory'

    s.source_files = 'SJVideoPlayer/*.{h,m}'

    # 通用
    s.subspec 'Common' do |ss|
        ss.source_files = 'SJVideoPlayer/Common/*.{h,m}'
    end

    # 容器
    s.subspec 'Adapters' do |ss|
        ss.source_files = 'SJVideoPlayer/Adapters/**/*.{h,m}'
        ss.dependency 'SJVideoPlayer/Common'
    end

    # 切换器
    s.subspec 'Switcher' do |ss|
        ss.source_files = 'SJVideoPlayer/Switcher/**/*.{h,m}'
    end

    # 进度条
    s.subspec 'SJProgressSlider' do |ss|
        ss.source_files = 'SJVideoPlayer/SJProgressSlider/*.{h,m}'
    end

    # 加载圈圈
    s.subspec 'SJLoadingView' do |ss|
        ss.source_files = 'SJVideoPlayer/SJLoadingView/*.{h,m}'
    end

    s.subspec 'Settings' do |ss|
        ss.source_files = 'SJVideoPlayer/Settings/*.{h,m}'
        ss.dependency 'SJVideoPlayer/SJFilmEditingControlLayer/ResourceLoader'
        ss.dependency 'SJVideoPlayer/SJEdgeControlLayer/ResourceLoader'
    end

    # 边缘控制层
    s.subspec 'SJEdgeControlLayer' do |ss|
        ss.source_files = 'SJVideoPlayer/SJEdgeControlLayer/*.{h,m}'

        ss.subspec 'ResourceLoader' do |a|
            a.source_files = 'SJVideoPlayer/SJEdgeControlLayer/ResourceLoader/*.{h,m}'
            a.resource = 'SJVideoPlayer/SJEdgeControlLayer/ResourceLoader/SJEdgeControlLayer.bundle'
        end

        ss.subspec 'View' do |v|
            v.source_files = 'SJVideoPlayer/SJEdgeControlLayer/View/*.{h,m}'
            v.dependency 'SJVideoPlayer/SJEdgeControlLayer/ResourceLoader'
        end

        ss.dependency 'SJVideoPlayer/Adapters'
        ss.dependency 'SJVideoPlayer/Switcher'
        ss.dependency 'SJVideoPlayer/Common'
        ss.dependency 'SJVideoPlayer/SJProgressSlider'
        ss.dependency 'SJVideoPlayer/SJLoadingView'
    end

    s.subspec 'SJEdgeLightweightControlLayer' do |l|
        l.source_files = 'SJVideoPlayer/SJEdgeLightweightControlLayer/*.{h,m}'
        l.dependency 'SJVideoPlayer/SJEdgeControlLayer'

        l.subspec 'LightweightControlView' do |view|
            view.source_files = 'SJVideoPlayer/SJEdgeLightweightControlLayer/LightweightControlView/*.{h,m}'
        end
    end

    s.subspec 'SJFilmEditingControlLayer' do |f|
        f.source_files = 'SJVideoPlayer/SJFilmEditingControlLayer/*.{h,m}'
        f.dependency 'SJVideoPlayer/SJProgressSlider'
        f.dependency 'SJVideoPlayer/Switcher'
        f.dependency 'SJVideoPlayer/Adapters'
        
        f.subspec 'ResourceLoader' do |a|
            a.source_files = 'SJVideoPlayer/SJFilmEditingControlLayer/ResourceLoader/*'
            a.resource = 'SJVideoPlayer/SJFilmEditingControlLayer/ResourceLoader/SJFilmEditing.bundle'
        end

        f.subspec 'Core' do |a|
            a.source_files = 'SJVideoPlayer/SJFilmEditingControlLayer/Core/**/*.{h,m}'
            a.dependency 'SJVideoPlayer/SJFilmEditingControlLayer/ResourceLoader'
        end
    end

    s.subspec 'SJLoadFailedControlLayer' do |ss|
        ss.source_files = 'SJVideoPlayer/SJLoadFailedControlLayer/*.{h,m}'
        ss.dependency 'SJVideoPlayer/SJNotReachableControlLayer'
    end

    s.subspec 'SJNotReachableControlLayer' do |ss|
        ss.source_files = 'SJVideoPlayer/SJNotReachableControlLayer/*.{h,m}'
        ss.dependency 'SJVideoPlayer/SJEdgeControlLayer'
    end
    
    s.subspec 'SJMoreSettingControlLayer' do |ss|
        ss.source_files = 'SJVideoPlayer/SJMoreSettingControlLayer/*.{h,m}'
        ss.dependency 'SJVideoPlayer/SJEdgeControlLayer'

        ss.subspec 'Core' do |sss|
            sss.source_files = 'SJVideoPlayer/SJMoreSettingControlLayer/Core/*.{h,m}'
        end
    end

end
