# SJFullscreenPopGesture
Fullscreen pop gesture. It is very suitable for the application of the video player.    
全屏返回手势.  对带有视频播放器的App非常适用.

### Use
```ruby
pod 'SJFullscreenPopGesture'
```

### Features
- Fullscreen Pop Gesture. Gestures are perfectly handled in UIScrollView And UIPageViewController.
- Fade Area. The specified area does not trigger gestures. It does not affect other ViewControllers.
- Disable Gesture. Designate ViewController disable pop gesture. It does not affect other ViewControllers.


### Example
Please wait for the example load, or download the project directly.

<img src="https://github.com/changsanjiang/SJVideoPlayerBackGR/blob/master/SJBackGRProject/SJBackGRProject/ex1.gif" />

### Disable 
```Objective-C
// If you want to disable the gestures, you can do the same as below. It does not affect other ViewControllers.
#import "UIViewController+SJVideoPlayerAdd.h"
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sj_DisableGestures = YES; // 如果想在某个页面禁用全屏手势, 可以这样做. 不影响其他页面. 离开页面时, 也无需恢复.
}
```

### Fade Area
```Objective-C
// If you want an area to not trigger gestures, you can do the same as below. It does not affect other ViewControllers.
#import "UIViewController+SJVideoPlayerAdd.h"
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sj_fadeAreaViews = @[_btn, _view2]; // 如果想某个区域不触发手势, 可以这样做.
    // or
    self.sj_fadeArea = @[@(_btn.frame), @(_view2.frame)]; // 如果想某个区域不触发手势, 可以这样做.
}
```
### Common Method
```Objective-C
@interface UIViewController (SJVideoPlayerAdd)

/*!
 *  The specified area does not trigger gestures. It does not affect other ViewControllers.
 *  In the array is subview frame.
 *  @[@(self.label.frame)]
 *
 *  指定区域不触发手势. see `sj_fadeAreaViews` method
 **/
@property (nonatomic, strong, readwrite, nullable) NSArray<NSValue *> *sj_fadeArea;

/*!
 *  The specified area does not trigger gestures. It does not affect other ViewControllers.
 *  In the array is subview.
 *  @[@(self.label)]
 *
 *  指定区域不触发手势.
 **/
@property (nonatomic, strong, readwrite, nullable) NSArray<UIView *> *sj_fadeAreaViews;

/*!
 *  disable pop Gestures. default is NO. It does not affect other ViewControllers.
 *
 *  禁用全屏手势. 默认是 NO.
 **/
@property (nonatomic, assign, readwrite) BOOL sj_DisableGestures;


@property (nonatomic, copy, readwrite, nullable) void(^sj_viewWillBeginDragging)(__kindof UIViewController *vc);
@property (nonatomic, copy, readwrite, nullable) void(^sj_viewDidDrag)(__kindof UIViewController *vc);
@property (nonatomic, copy, readwrite, nullable) void(^sj_viewDidEndDragging)(__kindof UIViewController *vc);

@end
```

### 天朝
https://juejin.im/post/5a150c166fb9a04524057832
