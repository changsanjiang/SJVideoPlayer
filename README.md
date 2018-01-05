# SJVideoPlayer
```ruby
pod 'SJVideoPlayer' 
```

# 抽离出的组件
### [加载视图](https://github.com/changsanjiang/SJLoadingView)
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/loading.gif" />

### [全屏返回手势](https://github.com/changsanjiang/SJFullscreenPopGesture)<br/>
1. 适配 scrollView.
2. 支持盲区. 指定区域不触发全屏手势. 可指定Frame或者View.
3. 支持切换. 系统边缘手势与全屏手势随意切换.
4. 支持禁用手势.

### [亮度和音量调整](https://github.com/changsanjiang/SJVolBrigControl)

### [播放资源载体](https://github.com/changsanjiang/SJVideoPlayerAssetCarrier)

### [屏幕旋转观察者](https://github.com/changsanjiang/SJOrentationObserver)

### [滑动条](https://github.com/changsanjiang/SJSlider)
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/slider.gif" />

### [提示](https://github.com/changsanjiang/SJPrompt)

### [便捷创建UI的工厂](https://github.com/changsanjiang/SJUIFactory)

### [便捷绘制border线](https://github.com/changsanjiang/SJBorderLineView)

### 其他组件陆续抽离中...

### Sample

<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/IMG_0472.PNG" />
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/IMG_0473.PNG" />
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/IMG_0478.PNG" />
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/IMG_0479.PNG" />
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/IMG_0480.PNG" />
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/IMG_0481.PNG" />


### Use
```Objective-C
 Player.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:[NSURL URLWithString:@"http://....."] beginTime:10];
```
