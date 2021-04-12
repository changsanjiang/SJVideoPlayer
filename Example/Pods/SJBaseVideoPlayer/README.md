![readme](https://user-images.githubusercontent.com/37614260/43947531-922a0712-9cb2-11e8-8f8d-4823a21308d3.png)

[![Build Status](https://travis-ci.org/changsanjiang/SJVideoPlayer.svg?branch=master)](https://travis-ci.org/changsanjiang/SJVideoPlayer)
[![Version](https://img.shields.io/cocoapods/v/SJVideoPlayer.svg?style=flat)](https://cocoapods.org/pods/SJVideoPlayer)
[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)](https://github.com/changsanjiang)
[![License](https://img.shields.io/github/license/changsanjiang/SJVideoPlayer.svg)](https://github.com/changsanjiang/SJVideoPlayer/blob/master/LICENSE.md)

## Installation
```ruby
# Player with default control layer.
pod 'SJVideoPlayer'

# The base player, without the control layer, can be used if you need a custom control layer.
pod 'SJBaseVideoPlayer'
```

## 天朝
```ruby
# 如果网络不行安装不了, 可改成以下方式进行安装
pod 'SJBaseVideoPlayer', :git => 'https://gitee.com/changsanjiang/SJBaseVideoPlayer.git'
pod 'SJVideoPlayer', :git => 'https://gitee.com/changsanjiang/SJVideoPlayer.git'
$ pod update --no-repo-update   (不要用 pod install 了, 用这个命令安装)
```

##  [Wiki](https://github.com/changsanjiang/SJVideoPlayer/wiki)

### FAQs
- 旋转
    - [点击旋转卡死或者旋转出现异常?](https://github.com/changsanjiang/SJVideoPlayer/wiki/%E7%82%B9%E5%87%BB%E6%97%8B%E8%BD%AC%E5%8D%A1%E6%AD%BB%E6%88%96%E8%80%85%E6%97%8B%E8%BD%AC%E5%87%BA%E7%8E%B0%E5%BC%82%E5%B8%B8%3F)
    - [怎样直接弹出全屏的播放器?](https://github.com/changsanjiang/SJVideoPlayer/wiki/%E5%A6%82%E4%BD%95%E7%9B%B4%E6%8E%A5%E5%BC%B9%E5%87%BA%E5%85%A8%E5%B1%8F%E7%9A%84%E6%92%AD%E6%94%BE%E5%99%A8%3F)
- 控制层
    - [怎样一直显示控制层?](https://github.com/changsanjiang/SJVideoPlayer/wiki/%E5%A6%82%E4%BD%95%E4%B8%80%E7%9B%B4%E6%98%BE%E7%A4%BA%E6%8E%A7%E5%88%B6%E5%B1%82%3F)
    - [控制层上的按钮 怎样添加 删除 修改?](https://github.com/changsanjiang/SJVideoPlayer/wiki/%E6%8E%A7%E5%88%B6%E5%B1%82%E4%B8%8A%E7%9A%84%E6%8C%89%E9%92%AE%E5%A6%82%E4%BD%95-%E6%B7%BB%E5%8A%A0-%E5%88%A0%E9%99%A4-%E4%BF%AE%E6%94%B9%3F)
    - [控制层上的标题 怎样居中显示?](https://github.com/changsanjiang/SJVideoPlayer/wiki/%E5%A6%82%E4%BD%95%E4%BD%BF%E6%A0%87%E9%A2%98%E5%B1%85%E4%B8%AD%E6%98%BE%E7%A4%BA%3F)
    - [控制层上 Adapter 的视图约束 怎样修改? (如何 在控制层的其他区域添加自定义视图?)](https://github.com/changsanjiang/SJVideoPlayer/wiki/%E5%A6%82%E4%BD%95%E4%BF%AE%E6%94%B9%E6%8E%A7%E5%88%B6%E5%B1%82%E4%B8%8A%60Adapter%60%E7%9A%84%E8%A7%86%E5%9B%BE%E7%BA%A6%E6%9D%9F%3F-(%E5%A6%82%E4%BD%95%E5%9C%A8%E6%8E%A7%E5%88%B6%E5%B1%82%E7%9A%84%E5%85%B6%E4%BB%96%E5%8C%BA%E5%9F%9F%E6%B7%BB%E5%8A%A0%E8%87%AA%E5%AE%9A%E4%B9%89%E8%A7%86%E5%9B%BE%3F))
    - [控制层上的按钮点击事件 如何监听?](https://github.com/changsanjiang/SJVideoPlayer/wiki/%E5%A6%82%E4%BD%95%E7%9B%91%E5%90%AC%E6%8E%A7%E5%88%B6%E5%B1%82%E4%B8%8A%E7%9A%84%E6%8C%89%E9%92%AE%E7%82%B9%E5%87%BB%E4%BA%8B%E4%BB%B6%3F)
- 其他
    - [怎样隐藏亮度和音量的提示视图?](https://github.com/changsanjiang/SJVideoPlayer/wiki/%E5%A6%82%E4%BD%95-%E9%9A%90%E8%97%8F%E4%BA%AE%E5%BA%A6%E5%92%8C%E9%9F%B3%E9%87%8F%E7%9A%84%E6%8F%90%E7%A4%BA%E8%A7%86%E5%9B%BE%3F)
    - [在 iOS 14 播放 m3u8 时, 从后台进入前台后无法继续播放](https://github.com/changsanjiang/SJVideoPlayer/wiki/%E5%9C%A8-iOS-14-%E6%92%AD%E6%94%BE-m3u8-%E6%97%B6,-%E4%BB%8E%E5%90%8E%E5%8F%B0%E8%BF%9B%E5%85%A5%E5%89%8D%E5%8F%B0%E5%90%8E%E6%97%A0%E6%B3%95%E7%BB%A7%E7%BB%AD%E6%92%AD%E6%94%BE)

### 介绍 
- [文档](https://github.com/changsanjiang/SJVideoPlayer/wiki/Documents)
- [快速开始](https://github.com/changsanjiang/SJVideoPlayer/wiki/%E5%BF%AB%E9%80%9F%E5%BC%80%E5%A7%8B)
- [旋转和直接全屏](https://github.com/changsanjiang/SJVideoPlayer/wiki/旋转和直接全屏)
- [播放记录](https://github.com/changsanjiang/SJVideoPlayer/wiki/%E6%92%AD%E6%94%BE%E8%AE%B0%E5%BD%95)
- [长按快进](https://github.com/changsanjiang/SJVideoPlayer/wiki/%E9%95%BF%E6%8C%89%E5%BF%AB%E8%BF%9B)
- [弹幕](https://github.com/changsanjiang/SJVideoPlayer/wiki/%E5%BC%B9%E5%B9%95)
- [画中画(iOS 14.0)](https://github.com/changsanjiang/SJVideoPlayer/wiki/iOS-14-%E7%94%BB%E4%B8%AD%E7%94%BB)
- [水印视图](https://github.com/changsanjiang/SJVideoPlayer/wiki/水印视图)
- [切换清晰度](https://github.com/changsanjiang/SJVideoPlayer/wiki/%E5%88%87%E6%8D%A2%E6%B8%85%E6%99%B0%E5%BA%A6)
- [UITableView及UICollectionView中播放的解决方案](https://github.com/changsanjiang/SJVideoPlayer/wiki/UITableView%E5%8F%8AUICollectionView%E4%B8%AD%E6%92%AD%E6%94%BE%E7%9A%84%E8%A7%A3%E5%86%B3%E6%96%B9%E6%A1%88v2)
- 切换到第三方SDK
    - [切换至 ijkplayer](https://github.com/changsanjiang/SJVideoPlayer/wiki/Use-ijkplayer)
    - [切换至 AliPlayer](https://github.com/changsanjiang/SJVideoPlayer/wiki/Use-AliPlayer)
    - [切换至 AliyunVodPlayer](https://github.com/changsanjiang/SJVideoPlayer/wiki/Use-AliVodPlayer)
    - [切换至 PLPlayerKit](https://github.com/changsanjiang/SJVideoPlayer/wiki/Use-PLPlayerKit)
- 控制层介绍
    - [控制层视图介绍](https://github.com/changsanjiang/SJVideoPlayer/wiki/Control-Layer-Views)
    - [控制层上的item介绍](https://github.com/changsanjiang/SJVideoPlayer/wiki/Setup-Control-Layer-View)
- [设置占位图](https://github.com/changsanjiang/SJVideoPlayer/wiki/Setup-Placeholder-Image)
- [设置进度条](https://github.com/changsanjiang/SJVideoPlayer/wiki/Setup-Progress-Slider)

## Author

Email: changsanjiang@gmail.com

QQGroup: 930508201 (iOS 开发)

## 赞助
如果对您有所帮助，欢迎您的赞赏

<img src="https://github.com/changsanjiang/SJBaseVideoPlayer/blob/master/Project/Project/imgs/thanks_zfb.JPG?raw=true" width="200">
<img src="https://github.com/changsanjiang/SJBaseVideoPlayer/blob/master/Project/Project/imgs/thanks_wechat.JPG?raw=true" width="200">
