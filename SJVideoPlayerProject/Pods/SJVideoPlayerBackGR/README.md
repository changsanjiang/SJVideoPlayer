# SJVideoPlayerBackGR
自定义全屏返回手势. 系统原生手势和自定义手势随意切换. 适用于带有视频播放器的App.    
Customize full-screen return gestures. System native gestures and custom gestures are free to switch. App for App with video player.    
可以查看 [SJVideoPlayer](https://github.com/changsanjiang/SJVideoPlayer) 这个播放器项目用了这个手势. 

### Use
```
pod SJVideoPlayerBackGR
```

如果好用, 兄弟, 给个 Star 吧.

### Disable 
```
// 如果想使用系统手势，可以像下面那样. 
// If you want to use the system gestures, you can do the same as below.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // use system 
    self.navigationController.useNativeGesture = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // use custom 
    self.navigationController.useNativeGesture = NO;
}
```
### Example
<img src="https://github.com/changsanjiang/SJVideoPlayerBackGR/blob/master/SJBackGRProject/SJBackGRProject/GestrueSample.gif" width="40%">    



