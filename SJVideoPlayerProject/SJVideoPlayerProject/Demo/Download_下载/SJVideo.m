//
//  SJVideo.m
//  SJMediaDownloader
//
//  Created by BlueDancer on 2018/3/16.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideo.h"

@implementation SJVideo

+ (NSArray<SJVideo *> *)testVideos {
    return
  @[
    [[SJVideo alloc] initWithId:1 title:@"DIY心情转盘 #手工##手工制作#" playURLStr:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"],
//    [[SJVideo alloc] initWithId:2 title:@"#手工#彤居居给我的第二份礼物🙈@SLIMETCk 我最喜欢的硬身史莱姆和平遥牛肉🐷" playURLStr:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"],
//    [[SJVideo alloc] initWithId:3 title:@"猛然感觉我这个桌垫玩slime还挺好看🤓#辰叔slime##手工##史莱姆slime#" playURLStr:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"],
//    [[SJVideo alloc] initWithId:4 title:@"马卡龙&蓝莓蛋糕#手工#💓日常更新🙆🙆#美拍手工挑战#" playURLStr:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"],
//    [[SJVideo alloc] initWithId:5 title:@"凤兮凤兮归故乡，遨游四海求其凰。" playURLStr:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"],
//    [[SJVideo alloc] initWithId:6 title:@"时未遇兮无所将，何悟今兮升斯堂！" playURLStr:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"],
    ];
}

- (instancetype)initWithId:(NSInteger)Id title:(NSString *)title playURLStr:(NSString *)playURLStr {
    self = [super init];
    if ( !self ) return nil;
    _mediaId = Id;
    _title = title;
    _playURLStr = playURLStr;
    _testCoverImage = @"helun";
    return self;
}
@end
