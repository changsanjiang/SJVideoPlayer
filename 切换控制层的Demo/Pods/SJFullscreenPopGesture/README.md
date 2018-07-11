# SJFullscreenPopGesture
Fullscreen pop gesture. It is very suitable for the application of the video player.    
全屏返回手势.  对带有视频播放器的App非常适用.

### Objective-C
```ruby
pod 'SJFullscreenPopGesture'
```
___

### Swift
```ruby
pod 'SJNavigationPopGesture'
// and install
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    // you need call it
    // app 启动的时候, 需要调用这个方法
    
    SJNavigationPopGesture.install()

    // ...

    return true
}
```
___


### Features
- Fullscreen Pop Gesture. Gestures are perfectly handled in UIScrollView And UIPageViewController.
- Fade Area. The specified area does not trigger gestures. It does not affect other ViewControllers.
- Disable Gesture. Designate ViewController disable pop gesture. It does not affect other ViewControllers.
- WKWebView.
___

### Example

- _
<img src="https://github.com/changsanjiang/SJVideoPlayerBackGR/blob/master/SJBackGRProject/SJBackGRProject/ex1.gif" />

- WKWebView:
<img src="https://github.com/changsanjiang/SJVideoPlayerBackGR/blob/master/SJBackGRProject/SJBackGRProject/ex2.gif" />

Please wait for the example load, or download the project directly.
___

### Disable Gesture

```Objective-C
// If you want to disable the gestures, you can do the same as below. It does not affect other ViewControllers.
// 1. `import header`
#import "UIViewController+SJVideoPlayerAdd.h"
- (void)viewDidLoad {
    [super viewDidLoad];
    // 2. `set this property`
    self.sj_DisableGestures = YES; // 如果想在某个页面禁用全屏手势, 可以这样做. 不影响其他页面. 离开页面时, 也无需恢复.
}
```
___

### Consider WKWebView

```Objective-C
// 1. `import header`
#import "UIViewController+SJVideoPlayerAdd.h"
- (void)viewDidLoad {
    [super viewDidLoad];
    // 2. `set this property`
    self.sj_considerWebView = self.webView; // when this property is set, will be enabled system gesture to back last web page, until it can't go back. 当设置这个属性后, 将会开启右滑返回上一个网页的手势. 最后才会触发全局pop手势.
}
```
___

### Fade Area

```Objective-C
// If you want an area to not trigger gestures, you can do the same as below. It does not affect other ViewControllers.
// 1. `import header`
#import "UIViewController+SJVideoPlayerAdd.h"
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 2. `set this property`
    self.sj_fadeAreaViews = @[_btn, _view2]; // 如果想某个区域不触发手势, 可以这样做.
    // or
    self.sj_fadeArea = @[@(_btn.frame), @(_view2.frame)]; // 如果想某个区域不触发手势, 可以这样做.
}
```
___

### Common Method
```Objective-C
@interface UIViewController (SJVideoPlayerAdd)

@property (nonatomic, readonly) UIGestureRecognizerState sj_fullscreenGestureState;

@property (nonatomic, weak, readwrite, nullable) WKWebView *sj_considerWebView;

@property (nonatomic, strong, readwrite, nullable) NSArray<NSValue *> *sj_fadeArea;

@property (nonatomic, strong, readwrite, nullable) NSArray<UIView *> *sj_fadeAreaViews;

@property (nonatomic, assign, readwrite) BOOL sj_DisableGestures;

@property (nonatomic, copy, readwrite, nullable) void(^sj_viewWillBeginDragging)(__kindof UIViewController *vc);

@property (nonatomic, copy, readwrite, nullable) void(^sj_viewDidDrag)(__kindof UIViewController *vc);

@property (nonatomic, copy, readwrite, nullable) void(^sj_viewDidEndDragging)(__kindof UIViewController *vc);

@end
```
___

## Contact
* Email: changsanjiang@gmail.com
* QQ: 1779609779
* QQGroup: 719616775 
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/Group.jpeg" width="200"  />

## License
SJFullscreenPopGesture is available under the MIT license. See the LICENSE file for more info.
