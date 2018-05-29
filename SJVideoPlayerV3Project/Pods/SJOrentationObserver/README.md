# SJOrentationObserver

### Use
```Objective-C
    _observer = [[SJOrentationObserver alloc] initWithTarget:targetView container:superview];
    _observer.rotationCondition = ^BOOL(SJOrentationObserver * _Nonnull observer) {
        if ( .... ) return NO;
        return YES;
    };
```

### Pod
```ruby
	pod 'SJOrentationObserver'
```

## Contact
* Email: changsanjiang@gmail.com
* QQ: 1779609779
* QQGroup: 719616775 
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/Group.jpeg" width="200"  />
