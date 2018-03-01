# SJVideoPlayer

如果缺少API, 可以邮箱联系我 changsanjiang@gmail.com

### installation
```ruby
# 有默认控制层的播放器
pod 'SJVideoPlayer'

# 基础播放器, 不含控制层, 如果需要自定义控制层, 可以使用它.
pod 'SJBaseVideoPlayer'
```
- [基础播放器, 不含控制层](https://github.com/changsanjiang/SJBaseVideoPlayer)

如果大家有好的控制层, 可以推上来, 我合并到播放器里.
___

## interface
<img src="https://github.com/changsanjiang/SJBaseVideoPlayer/blob/master/Project/SJBaseVideoPlayer.png" />

___

# example
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/preview.gif" /> <img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/nested.gif" width=350 />

___

# 抽离出的控件, 可单独使用
### [加载视图](https://github.com/changsanjiang/SJLoadingView)
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/loading.gif" />

### [全屏返回手势](https://github.com/changsanjiang/SJFullscreenPopGesture)<br/>
- 手势在UIScrollView和UIPageViewController中完美处理。
- 可指定盲区。指定的区域不会触发手势。它不会影响其他ViewControllers。
- 可在指定页面禁用手势。指定ViewController禁用手势。它不会影响其他ViewControllers。
- WKWebView返回上一个网页。

### [亮度和音量调整](https://github.com/changsanjiang/SJVolBrigControl)

### [播放资源载体](https://github.com/changsanjiang/SJVideoPlayerAssetCarrier)

### [屏幕旋转观察者](https://github.com/changsanjiang/SJOrentationObserver)

### [滑动条](https://github.com/changsanjiang/SJSlider)
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/slider.gif" />

### [提示](https://github.com/changsanjiang/SJPrompt)

### [便捷创建UI的工厂](https://github.com/changsanjiang/SJUIFactory)

### [便捷绘制border线](https://github.com/changsanjiang/SJBorderLineView)

### 其他组件陆续抽离中...

___
