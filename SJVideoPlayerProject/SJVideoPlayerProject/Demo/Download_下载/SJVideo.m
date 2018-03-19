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
    [[SJVideo alloc] initWithId:1 title:@"DIY心情转盘 #手工##手工制作#" playURLStr:@"http://video.cdn.lanwuzhe.com/14945858406905f0c"],
//    [[SJVideo alloc] initWithId:2 title:@"#手工#彤居居给我的第二份礼物🙈@SLIMETCk 我最喜欢的硬身史莱姆和平遥牛肉🐷" playURLStr:@"http://video.cdn.lanwuzhe.com/14945858406905f0c"],
//    [[SJVideo alloc] initWithId:3 title:@"猛然感觉我这个桌垫玩slime还挺好看🤓#辰叔slime##手工##史莱姆slime#" playURLStr:@"http://video.cdn.lanwuzhe.com/14945858406905f0c"],
//    [[SJVideo alloc] initWithId:4 title:@"马卡龙&蓝莓蛋糕#手工#💓日常更新🙆🙆#美拍手工挑战#" playURLStr:@"http://video.cdn.lanwuzhe.com/14945858406905f0c"],
//    [[SJVideo alloc] initWithId:5 title:@"凤兮凤兮归故乡，遨游四海求其凰。" playURLStr:@"http://video.cdn.lanwuzhe.com/14945858406905f0c"],
//    [[SJVideo alloc] initWithId:6 title:@"时未遇兮无所将，何悟今兮升斯堂！" playURLStr:@"http://video.cdn.lanwuzhe.com/14945858406905f0c"],
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
