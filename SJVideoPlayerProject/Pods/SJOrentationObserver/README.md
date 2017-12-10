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
