# SJPrompt

### Use
```ruby
pod 'SJPrompt'
```

### Sample

```Objective-C
self.prompt = [SJPrompt promptWithPresentView:self.view];

// update config
self.prompt.update(^(SJPromptConfig * _Nonnull config) {
    config.font = [UIFont systemFontOfSize:12];
    config.backgroundColor = [UIColor orangeColor];
    config.insets = UIEdgeInsetsMake(8, 8, 8, 8);
    config.maxWidth = 200;
});
```
<img src="https://github.com/changsanjiang/SJPrompt/blob/master/SJPromptProject/SJPromptProject/ex2.gif" />
