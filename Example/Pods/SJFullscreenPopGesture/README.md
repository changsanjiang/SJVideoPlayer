# SJFullscreenPopGesture

[![CI Status](https://img.shields.io/travis/changsanjiang/SJFullscreenPopGesture.svg?style=flat)](https://travis-ci.org/changsanjiang/SJFullscreenPopGesture)
[![Version](https://img.shields.io/cocoapods/v/SJFullscreenPopGesture.svg?style=flat)](https://cocoapods.org/pods/SJFullscreenPopGesture)
[![License](https://img.shields.io/cocoapods/l/SJFullscreenPopGesture.svg?style=flat)](https://cocoapods.org/pods/SJFullscreenPopGesture)
[![Platform](https://img.shields.io/cocoapods/p/SJFullscreenPopGesture.svg?style=flat)](https://cocoapods.org/pods/SJFullscreenPopGesture)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

SJFullscreenPopGesture is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
    # ObjC 
    pod 'SJFullscreenPopGesture/ObjC'
    
    # Swift
    pod 'SJFullscreenPopGesture/Swift'
```

## Author

changsanjiang, changsanjiang@gmail.com

## License

SJFullscreenPopGesture is available under the MIT license. See the LICENSE file for more info.

## 手势功能介绍

这个手势返回库交换了导航控制器的push方法, 以便触发push操作时, 生成底部视图的snapshot.

1. [可设置手势类型: 全屏手势 || 边缘手势.](https://github.com/changsanjiang/SJFullscreenPopGesture/blob/cb1d5dae6713c4bf5962eb808416e67055d25058/SJFullscreenPopGesture/ObjC/SJFullscreenPopGesture.h#L29)
```
// default is `SJFullscreenPopGestureType_EdgeLeft`.
typedef NS_ENUM(NSUInteger, SJFullscreenPopGestureType) {
    SJFullscreenPopGestureType_EdgeLeft,    // 默认, 屏幕左边缘触发手势
    SJFullscreenPopGestureType_Full,        // 全屏触发手势
};
```
2. [可设置Pop返回时的动画效果](https://github.com/changsanjiang/SJFullscreenPopGesture/blob/a9ce97348e6ad3cbaf0e7f7586d1701823183bdf/SJFullscreenPopGesture/UINavigationController%2BSJVideoPlayerAdd.h#L24)
目前有两种: 
    - [类似腾讯视频返回.gif](https://upload-images.jianshu.io/upload_images/2318691-d5a992c40cfee5bb.gif?imageMogr2/auto-orient/strip)
    - [在1的基础上加上了一层遮罩.gif](https://upload-images.jianshu.io/upload_images/2318691-3dcd02f47b0dff4a.gif?imageMogr2/auto-orient/strip)

3. [可在某个ViewController禁用手势](https://github.com/changsanjiang/SJFullscreenPopGesture/blob/cb1d5dae6713c4bf5962eb808416e67055d25058/SJFullscreenPopGesture/ObjC/SJFullscreenPopGesture.h#L36)
4. [可兼容 WKWebView 手势返回](https://github.com/changsanjiang/SJFullscreenPopGesture/blob/cb1d5dae6713c4bf5962eb808416e67055d25058/SJFullscreenPopGesture/ObjC/SJFullscreenPopGesture.h#L44)
5. [可设置盲区, 在这个区域不触发手势](https://github.com/changsanjiang/SJFullscreenPopGesture/blob/cb1d5dae6713c4bf5962eb808416e67055d25058/SJFullscreenPopGesture/ObjC/SJFullscreenPopGesture.h#L37)
6. [可设置手势触发过程中的回调](https://github.com/changsanjiang/SJFullscreenPopGesture/blob/cb1d5dae6713c4bf5962eb808416e67055d25058/SJFullscreenPopGesture/ObjC/SJFullscreenPopGesture.h#L40)
```Objective-C
/// 将要拖拽
@property (nonatomic, copy, readwrite, nullable) void(^sj_viewWillBeginDragging)(__kindof UIViewController *vc);
/// 拖拽中
@property (nonatomic, copy, readwrite, nullable) void(^sj_viewDidDrag)(__kindof UIViewController *vc);
/// 结束拖拽
@property (nonatomic, copy, readwrite, nullable) void(^sj_viewDidEndDragging)(__kindof UIViewController *vc);
```
7. [可设置*返回界面*的显示模式, 目前有两种: 1. 使用快照(也可称截屏) 2. 使用原始视图(默认)](https://github.com/changsanjiang/SJFullscreenPopGesture/blob/cb1d5dae6713c4bf5962eb808416e67055d25058/SJFullscreenPopGesture/ObjC/SJFullscreenPopGesture.h#L35)
