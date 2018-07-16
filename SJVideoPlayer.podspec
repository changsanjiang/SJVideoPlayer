
Pod::Spec.new do |s|
    s.name         = 'SJVideoPlayer'
    s.version      = '2.1.1'
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
    s.dependency 'SJFullscreenPopGesture'

    s.source_files = 'SJVideoPlayer/*.{h,m}'

    s.subspec 'SJEdgeControlLayer' do |e|
        e.source_files = 'SJVideoPlayer/SJEdgeControlLayer/*.{h,m}'
        e.dependency 'SJBaseVideoPlayer'
        e.dependency 'SJSlider'
        e.dependency 'SJAttributesFactory'
        e.dependency 'SJLoadingView'

        e.subspec 'Asset' do |a|
          a.source_files = 'SJVideoPlayer/SJEdgeControlLayer/Asset/*'
          a.resource = 'SJVideoPlayer/SJEdgeControlLayer/Asset/SJEdgeControlLayer.bundle'
        end

        e.subspec 'MaskView' do |mk|
          mk.source_files = 'SJVideoPlayer/SJEdgeControlLayer/MaskView/*'
        end

        e.subspec 'EdgeViews' do |ev|
          ev.source_files = 'SJVideoPlayer/SJEdgeControlLayer/EdgeViews/*'
          ev.dependency 'SJVideoPlayer/SJEdgeControlLayer/MaskView'
          ev.dependency 'SJVideoPlayer/SJEdgeControlLayer/Asset'
        end

        e.subspec 'MoreSetting' do |ms|
          ms.source_files = 'SJVideoPlayer/SJEdgeControlLayer/MoreSetting/*'
          ms.dependency 'SJVideoPlayer/SJEdgeControlLayer/Asset'
        end
    end

    s.subspec 'SJEdgeLightweightControlLayer' do |l|
        l.source_files = 'SJVideoPlayer/SJEdgeLightweightControlLayer/*.{h,m}'
        l.dependency 'SJBaseVideoPlayer'
        l.dependency 'SJSlider'
        l.dependency 'SJLoadingView'
        l.dependency 'SJVideoPlayer/SJEdgeControlLayer/Asset'
        l.dependency 'SJVideoPlayer/SJEdgeControlLayer/MaskView'

        l.subspec 'LightweightControlView' do |view|
            view.source_files = 'SJVideoPlayer/SJEdgeLightweightControlLayer/LightweightControlView/*.{h,m}'
        end
    end

    s.subspec 'SJFilmEditingControlLayer' do |f|
        f.source_files = 'SJVideoPlayer/SJFilmEditingControlLayer/*.{h,m}'
        f.dependency 'SJBaseVideoPlayer'
        f.dependency 'SJSlider'
        f.dependency 'SJAttributesFactory'

        f.subspec 'Asset' do |a|
            a.source_files = 'SJVideoPlayer/SJFilmEditingControlLayer/Asset/*'
            a.dependency 'SJVideoPlayer/SJFilmEditingControlLayer/Header'
            a.resource = 'SJVideoPlayer/SJFilmEditingControlLayer/Asset/SJFilmEditing.bundle'
        end

        f.subspec 'Category' do |c|
            c.source_files = 'SJVideoPlayer/SJFilmEditingControlLayer/Category/*'
        end

        f.subspec 'Result' do |r|
            r.source_files = 'SJVideoPlayer/SJFilmEditingControlLayer/Result/*'
            r.dependency 'SJVideoPlayer/SJFilmEditingControlLayer/Header'
        end

        f.subspec 'Header' do |h|
            h.source_files = 'SJVideoPlayer/SJFilmEditingControlLayer/Header/*'
        end

        f.subspec 'View' do |v|
            v.source_files = 'SJVideoPlayer/SJFilmEditingControlLayer/View/*'
            v.dependency 'SJVideoPlayer/SJFilmEditingControlLayer/Header'
        end
    end

    s.subspec 'Settings' do |ss|
        ss.source_files = 'SJVideoPlayer/Settings/*.{h,m}'
        ss.dependency 'SJVideoPlayer/SJFilmEditingControlLayer/Asset'
        ss.dependency 'SJVideoPlayer/SJEdgeControlLayer/Asset'
    end

    s.subspec 'Switcher' do |ss|
        ss.source_files = 'SJVideoPlayer/Switcher/*.{h,m}'
        ss.dependency 'SJBaseVideoPlayer'
    end
    
end
