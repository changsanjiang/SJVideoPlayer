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

### play
```Objective-C
#pragma mark - 播放

@interface SJBaseVideoPlayer (Play)

@property (nonatomic, strong, readwrite, nullable) NSURL *assetURL;

@property (nonatomic, strong, readwrite, nullable) SJVideoPlayerURLAsset *URLAsset;

- (void)playWithURL:(NSURL *)playURL;

- (void)playWithURL:(NSURL *)playURL jumpedToTime:(NSTimeInterval)time;

- (void)refresh;

@end
```
___

### time
```Objective-C
#pragma mark - 时间

@interface SJBaseVideoPlayer (Time)

- (NSString *)timeStringWithSeconds:(NSInteger)secs; // format: 00:00:00

@property (nonatomic, readonly) float progress;

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval totalTime;

@property (nonatomic, strong, readonly) NSString *currentTimeStr;
@property (nonatomic, strong, readonly) NSString *totalTimeStr;

- (void)jumpedToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler; // unit is sec. 单位是秒.

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

@end
```
___

### control
```Objective-C
#pragma mark - 控制

@interface SJBaseVideoPlayer (Control)

@property (nonatomic, readwrite) BOOL mute; // default is no. 静音.

@property (nonatomic, readwrite, getter=isLockedScreen) BOOL lockedScreen; // 锁定播放器. 所有交互事件将不会触发.

@property (nonatomic, readwrite, getter=isAutoPlay) BOOL autoPlay; // 自动播放. default is YES.

- (BOOL)play;

- (BOOL)pause;                                           // 调用此方法, 表示开发者暂停.
- (void)pauseForUser;                                    // 调用此方法, 表示用户暂停.
@property (nonatomic, assign, readonly) BOOL userPaused; // 区分是用户暂停的, 还是开发者暂停的

- (void)stop;

- (void)stopAndFadeOut; // 停止播放并淡出

- (void)replay;

@property (nonatomic, readwrite) float volume;

@property (nonatomic, readwrite) float brightness;

@property (nonatomic, readwrite) float rate; // 0.5...2

@property (nonatomic, copy, readwrite, nullable) void(^rateChanged)(__kindof SJBaseVideoPlayer *player);

- (void)resetRate;

@property (nonatomic, copy, readwrite, nullable) void(^playDidToEnd)(__kindof SJBaseVideoPlayer *player); // 播放完毕

@end
```
___

### control layer
```Objective-C
#pragma mark - 控制层

@interface SJBaseVideoPlayer (ControlLayer)

@property (nonatomic, readwrite) BOOL enableControlLayerDisplayController; // default is YES. 是否开启控制层[显示/隐藏]的管理器
@property (nonatomic, readonly) BOOL controlLayerAppeared; // 控制层是否显示
@property (nonatomic, copy, readwrite, nullable) void(^controlLayerAppearStateChanged)(__kindof SJBaseVideoPlayer *player, BOOL state);

- (void)controlLayerNeedAppear;
- (void)controlLayerNeedDisappear;

// 控制层是否显示
@property (nonatomic, readonly) BOOL controlViewDisplayed NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "use `controlLayerAppeared`");

/*!
 *  Call when the control view is appear or disappear.
 *
 *  控制视图隐藏或显示的时候调用.
 **/
@property (nonatomic, copy, readwrite, nullable) void(^controlViewDisplayStatus)(__kindof SJBaseVideoPlayer *player, BOOL displayed) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "use `controlLayerAppearStateChanged`");

@end
```
___

### rotation
```Objective-C
#pragma mark - 屏幕旋转

@interface SJBaseVideoPlayer (Rotation)

@property (nonatomic, readwrite) SJSupportedRotateViewOrientation supportedRotateViewOrientation; // 播放器旋转支持的方向, 默认为`SJSupportedRotateViewOrientation_All`

@property (nonatomic, readwrite) SJRotateViewOrientation rotateOrientation; // 直接旋转到指定方向, 可指定为`横屏播放`. 默认是`竖屏`.

- (void)rotation; // 旋转

@property (nonatomic, readwrite) BOOL disableRotation; // 禁止播放器旋转

@property (nonatomic, copy, readwrite, nullable) void(^willRotateScreen)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen); // 将要旋转的时候调用

@property (nonatomic, copy, readwrite, nullable) void(^rotatedScreen)(__kindof SJBaseVideoPlayer *player, BOOL isFullScreen);    // 已旋转

@property (nonatomic, readonly) BOOL isFullScreen;  // 是否全屏

@end
```
___

### screenshot
```Objective-C
#pragma mark - 截图

@interface SJBaseVideoPlayer (Screenshot)

@property (nonatomic, copy, readwrite, nullable) void(^presentationSize)(__kindof SJBaseVideoPlayer *videoPlayer, CGSize size);

- (UIImage * __nullable)screenshot;

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block;

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block;

- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(__kindof SJBaseVideoPlayer *player, NSArray<id<SJVideoPlayerPreviewInfo>> *__nullable images, NSError *__nullable error))block;

@end
```
___

### prompt
```Objective-C
#pragma mark - 提示

@interface SJBaseVideoPlayer (Prompt)

/*!
 *  prompt.update(^(SJPromptConfig * _Nonnull config) {
        config.cornerRadius = 4;                    // default cornerRadius.
        config.font = [UIFont systemFontOfSize:12]; // default font.
    });
 *
 **/
@property (nonatomic, strong, readonly) SJPrompt *prompt;

- (void)showTitle:(NSString *)title; // duration default is 1.0

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration; // duration if value set -1, promptView will always show.

- (void)hiddenTitle;

@end
```
___

### control layer protocol
```Objective-C
#pragma mark - Protocol

@protocol SJVideoPlayerControlLayerDataSource <NSObject>

@required

- (UIView *)controlView;

/// 控制层需要隐藏之前会调用这个方法, 如果返回NO, 将不调用`controlLayerNeedDisappear:`.
- (BOOL)controlLayerDisappearCondition;

/// 触发手势之前会调用这个方法, 如果返回NO, 将不调用水平手势相关的代理方法.
- (BOOL)triggerGesturesCondition:(CGPoint)location;

@optional
/// 安装完控制层的回调.
- (void)installedControlViewToVideoPlayer:(SJBaseVideoPlayer *)videoPlayer;

@end


@protocol SJVideoPlayerControlLayerDelegate <NSObject>

@optional

#pragma mark - 播放之前/状态
/// 当设置播放资源时调用.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset;

/// 播放状态改变.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer stateChanged:(SJVideoPlayerPlayState)state;

/// 播放报错
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer playFailed:(NSError *)error;

#pragma mark - 进度
/// 播放进度回调.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer
        currentTime:(NSTimeInterval)currentTime currentTimeStr:(NSString *)currentTimeStr
          totalTime:(NSTimeInterval)totalTime totalTimeStr:(NSString *)totalTimeStr;

/// 缓冲的进度.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer loadedTimeProgress:(float)progress;

/// 开始缓冲.
- (void)startLoading:(SJBaseVideoPlayer *)videoPlayer;

/// 缓冲完成.
- (void)loadCompletion:(SJBaseVideoPlayer *)videoPlayer;

#pragma mark - 显示/消失
/// 控制层需要显示.
- (void)controlLayerNeedAppear:(SJBaseVideoPlayer *)videoPlayer;

/// 控制层需要隐藏.
- (void)controlLayerNeedDisappear:(SJBaseVideoPlayer *)videoPlayer;

///  在`tableView`或`collectionView`上将要显示的时候调用.
- (void)videoPlayerWillAppearInScrollView:(SJBaseVideoPlayer *)videoPlayer;

///  在`tableView`或`collectionView`上将要消失的时候调用.
- (void)videoPlayerWillDisappearInScrollView:(SJBaseVideoPlayer *)videoPlayer;

#pragma mark - 锁屏
/// 播放器被锁屏, 此时将不旋转, 不触发手势相关事件.
- (void)lockedVideoPlayer:(SJBaseVideoPlayer *)videoPlayer;

/// 播放器解除锁屏.
- (void)unlockedVideoPlayer:(SJBaseVideoPlayer *)videoPlayer;

#pragma mark - 屏幕旋转
/// 播放器将要旋转屏幕, `isFull`如果为`YES`, 则全屏.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull;

/// 旋转完毕.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer didEndRotation:(BOOL)isFull;

#pragma mark - 音量 / 亮度 / 播放速度
/// 静音开关变更
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer muteChanged:(BOOL)mute;

/// 声音被改变.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer volumeChanged:(float)volume;

/// 亮度被改变.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer brightnessChanged:(float)brightness;

/// 播放速度被改变.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer rateChanged:(float)rate;

#pragma mark - 水平手势
/// 水平方向开始拖动.
- (void)horizontalDirectionWillBeginDragging:(SJBaseVideoPlayer *)videoPlayer;

/// 水平方向拖动中. `translation`为此次增加的值.
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer horizontalDirectionDidDrag:(CGFloat)translation;

/// 水平方向拖动结束.
- (void)horizontalDirectionDidEndDragging:(SJBaseVideoPlayer *)videoPlayer;

#pragma mark - size
- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer presentationSize:(CGSize)size;

@end
```
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
