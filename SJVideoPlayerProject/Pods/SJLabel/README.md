# SJLabel

### 可匹配点击的Label:
<img src="https://github.com/changsanjiang/SJLabel/blob/master/Demo/SJLabel/ex2.gif" />

<img src="https://github.com/changsanjiang/SJAttributesFactory/blob/master/Demo/SJAttributesFactory/action.gif" />

<img src="https://github.com/changsanjiang/SJLabel/blob/master/Demo/SJLabel/ex1.png" />

### Use

```ruby
pod 'SJLabel'
```

### Sample
```Objective-C

/// add `attributedString` some action
- (void)addAction {
    attrStr.actionDelegate = self;
    attrStr.addAction(@"我们"); // 所有的`我们`添加点击事件, 回调将在代理方法中回调.
    attrStr.addAction(@"[活动链接]"); // 所有的`[活动链接]`添加点击事件, 回调将在代理方法中回调.
}

/// delegate method
- (void)attributedString:(NSAttributedString *)attrStr action:(NSAttributedString *)action {
    NSLog(@"%@", action.string);
}
```


