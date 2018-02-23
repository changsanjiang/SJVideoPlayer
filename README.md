# SJVideoPlayer
### installation
```ruby
pod 'SJVideoPlayer' 
```
___

### [base video player](https://github.com/changsanjiang/SJBaseVideoPlayer)
```ruby
# a lightweight, non controlled player. 轻量级的, 没有控制层的播放器.
pod 'SJBaseVideoPlayer'
```
___

# example
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/ex.gif" />

___

### play
```Objective-C
    Player.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:[NSURL URLWithString:@"http://....."] beginTime:10];
```
___

### play on the table or collection view
```Objective-C
    Player.asset =
    [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:[NSURL URLWithString:cell.model.playURLStr]
                                             scrollView:self.tableView
                                              indexPath:[self.tableView indexPathForCell:cell]
                                           superviewTag:playerParentView.tag];
```
___

### play on the nested table or collection view
```Objective-C
    Player.asset =
    [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:playURL
                                              indexPath:indexPath
                                           superviewTag:playerParentView.tag
                                    scrollViewIndexPath:embeddedScrollViewIndexPath
                                          scrollViewTag:embeddedScrollView.tag
                                         rootScrollView:self.tableView];
```
___

### play method
```Objective-C
@property (nonatomic, strong, readwrite, nullable) SJVideoPlayerAssetCarrier *asset;

- (void)playWithURL:(NSURL *)playURL jumpedToTime:(NSTimeInterval)time;

@property (nonatomic, strong, readwrite, nullable) NSURL *assetURL;

- (void)playWithURL:(NSURL *)playURL;

- (UIImage *__nullable)screenshot;

- (NSTimeInterval)currentTime;

- (NSTimeInterval)totalTime;

```
___

### prompt method
```Objective-C

@property (nonatomic, strong, readonly) SJPrompt *prompt;

- (void)showTitle:(NSString *)title;

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration;

- (void)hiddenTitle;
```
___

### control method
```Objective-C

@property (nonatomic, assign, readonly) BOOL userPaused;

@property (nonatomic, assign, readwrite, getter=isAutoplay) BOOL autoplay;

- (BOOL)play;

- (BOOL)pause;

- (void)stop;

- (void)stopAndFadeOut;

@property (nonatomic, copy, readwrite, nullable) void(^playDidToEnd)(SJVideoPlayer *player);

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

```
___

### screen rotation method
```Objective-C

@property (nonatomic, assign, readwrite) BOOL disableRotation;

@property (nonatomic, copy, readwrite, nullable) void(^willRotateScreen)(SJVideoPlayer *player, BOOL isFullScreen);

@property (nonatomic, copy, readwrite, nullable) void(^rotatedScreen)(SJVideoPlayer *player, BOOL isFullScreen);

@property (nonatomic, assign, readonly) BOOL isFullScreen;

```
___

### setting method
```Objective-C

- (void)setPlaceholder:(UIImage *)placeholder;

@property (nonatomic, copy, readwrite) void(^clickedBackEvent)(SJVideoPlayer *player);

@property (class, nonatomic, copy, readonly) void(^update)(void(^block)(SJVideoPlayerSettings *commonSettings));

+ (void)resetSetting; // 重置配置, 恢复默认设置

@property (nonatomic, strong, readwrite, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

@property (nonatomic, assign, readwrite) BOOL generatePreviewImages;

```
___

### rate method
```Objective-C

@property (nonatomic, assign, readwrite) float rate; /// 0.5 .. 1.5
- (void)resetRate;

@property (nonatomic, copy, readwrite, nullable) void(^rateChanged)(SJVideoPlayer *player);

@property (nonatomic, copy, readwrite, nullable) void(^internallyChangedRate)(SJVideoPlayer *player, float rate);

```
___

# example
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/preview.gif" /> <img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/nested.gif" width=350 />

___

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

___
