# SJSlider
滑块视图    
```Ruby   
    pod 'SJSlider'    
```    
___

### 进度(支持 AutoLayout)
<img src = "https://github.com/changsanjiang/SJSlider/blob/master/SJSliderProjectFile/SJSlider/WechatIMG86.jpeg" >    

```Objective-C    

    SJSlider *slider = [SJSlider new];
    [self.view addSubview:slider];
    slider.frame = CGRectMake(20, 100, 200, 10);
    slider.value = 0.5;      
    
```    

___   

### 滑块 + 不切圆角
<img src = "https://github.com/changsanjiang/SJSlider/blob/master/SJSliderProjectFile/SJSlider/WechatIMG88.jpeg">    

```Objective-C    
    SJSlider *slider = [SJSlider new];
    [self.view addSubview:slider];
    slider.isRound = NO;
    slider.frame = CGRectMake(20, 100, 200, 10);
    slider.thumbImageView.image = [UIImage imageNamed:@"thumb"];
    slider.value = 0.5;
```
___    

### 缓冲
<img src = "https://github.com/changsanjiang/SJSlider/blob/master/SJSliderProjectFile/SJSlider/WechatIMG87.jpeg">    

```Objective-C    
    SJSlider *slider = [SJSlider new];
    [self.view addSubview:slider];
    slider.frame = CGRectMake(20, 100, 200, 10);
    slider.value = 0.5;
    slider.enableBufferProgress = YES;
    slider.bufferProgress = 0.8;
```
___    

### 左右标签
<img src = "https://github.com/changsanjiang/SJSlider/blob/master/SJSliderProjectFile/SJSlider/WechatIMG89.jpeg">    

```Objective-C    
    SJButtonSlider *b_slider = [SJButtonSlider new];
    b_slider.frame = CGRectMake(50, 300, 300, 40);
    b_slider.slider.value = 0.3;
    b_slider.slider.thumbImageView.image = [UIImage imageNamed:@"thumb"];
    b_slider.leftText = @"00:00";
    b_slider.rightText = @"12:00";
    b_slider.titleColor = [UIColor whiteColor];
    [self.view addSubview:b_slider];
```
___

## Contact
* Email: changsanjiang@gmail.com
* QQ: 1779609779
* QQGroup: 719616775 
<img src="https://github.com/changsanjiang/SJVideoPlayer/blob/master/SJVideoPlayerProject/SJVideoPlayerProject/Group.jpeg" width="200"  />
