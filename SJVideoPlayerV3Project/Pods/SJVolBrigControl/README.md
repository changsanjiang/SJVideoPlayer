# SJVolBrigControl

```Objective-C
@property (nonatomic, strong, readonly) UIView *brightnessView;

/// 0..1
@property (nonatomic, assign, readwrite) float volume;
@property (nonatomic, copy, readwrite, nullable) void(^volumeChanged)(float volume);

/// 0.1..1
@property (nonatomic, assign, readwrite) float brightness;
@property (nonatomic, copy, readwrite, nullable) void(^brightnessChanged)(float brightness);

```

### Sample
<img src="https://github.com/changsanjiang/SJVolBrigControl/blob/master/SJVolBrigControlProject/ex2.gif" />
