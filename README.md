# SJVideoPlayer
```ruby
pod 'SJVideoPlayer' 
```

### 抽离出的组件
[加载视图](https://github.com/changsanjiang/SJLoadingView)</br>
[全屏返回手势](https://github.com/changsanjiang/SJVideoPlayerBackGR)</br>
[亮度和音量调整](https://github.com/changsanjiang/SJVolBrigControl)</br>
[播放资源载体Helper](https://github.com/changsanjiang/SJVideoPlayerAssetCarrier)</br>
[屏幕旋转观察者](https://github.com/changsanjiang/SJOrentationObserver)</br>
[自定义的滑动条](https://github.com/changsanjiang/SJSlider)</br>
[提示视图](https://github.com/changsanjiang/SJPrompt)</br>
[便捷创建UI的工厂](https://github.com/changsanjiang/SJUIFactory)</br>
[便捷绘制border线的视图](https://github.com/changsanjiang/SJBorderLineView)</br>

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
