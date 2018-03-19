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
    [[SJVideo alloc] initWithId:1 title:@"DIY心情转盘 #手工##手工制作#" playURLStr:@"http://vod.lanwuzhe.com/fc93d786c46545d89e1f2b57d39ea047/195f1740d70c452f94d7312896068779-5287d2089db37e62345123a1be272f8b.mp4"],
    [[SJVideo alloc] initWithId:2 title:@"#手工#彤居居给我的第二份礼物🙈@SLIMETCk 我最喜欢的硬身史莱姆和平遥牛肉🐷" playURLStr:@"http://vod.lanwuzhe.com/e975570ec911480d8548edd7b499f29d/85ce1aed509e4bb8858016499d65145f-5287d2089db37e62345123a1be272f8b.mp4"],
    [[SJVideo alloc] initWithId:3 title:@"猛然感觉我这个桌垫玩slime还挺好看🤓#辰叔slime##手工##史莱姆slime#" playURLStr:@"http://vod.lanwuzhe.com/fb90fd70e9b748998d7db8145744265d/b9289c7bf40b48c7a995478ee8c2d95f-5287d2089db37e62345123a1be272f8b.mp4"],
    [[SJVideo alloc] initWithId:4 title:@"马卡龙&蓝莓蛋糕#手工#💓日常更新🙆🙆#美拍手工挑战#" playURLStr:@"http://vod.lanwuzhe.com/289727a3ef2541a7bdabc72a4c89de91/850508a9e4d7425082e85bc3e9c3c7e4-5287d2089db37e62345123a1be272f8b.mp4"],
    [[SJVideo alloc] initWithId:5 title:@"凤兮凤兮归故乡，遨游四海求其凰。" playURLStr:@"http://vod.lanwuzhe.com/db25c44fc20f4028891a6ec4ac461203/1737d09f340f4160911cd2778d1e7c4f-5287d2089db37e62345123a1be272f8b.mp4?video="],
    [[SJVideo alloc] initWithId:6 title:@"时未遇兮无所将，何悟今兮升斯堂！" playURLStr:@"http://video.cdn.lanwuzhe.com/1494489547442fa74"],
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
