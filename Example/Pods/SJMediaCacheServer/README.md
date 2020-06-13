
# SJMediaCacheServer

```ruby
pod 'SJUIKit/SQLite3', :podspec => 'https://gitee.com/changsanjiang/SJUIKit/raw/master/SJUIKit-YYModel.podspec'
pod 'SJMediaCacheServer'
```

___

# Usage

```Objective-C
#import <SJMediaCacheServer/SJMediaCacheServer.h>

    NSURL *URL = [NSURL URLWithString:@"http://.../auido.mp3"];
    NSURL *playbackURL = [SJMediaCacheServer.shared playbackURLWithURL:URL];
    AVPlayer *player = [AVPlayer playerWithURL:playbackURL];
    [player play];
```
