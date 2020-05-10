//
//  SJVideoModel.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJVideoModel.h"
#import "SJSourceURLs.h"

@implementation SJVideoModel
+ (NSArray<SJVideoModel *> *)testItems {
    NSMutableArray<SJVideoModel *> *m = [[NSMutableArray alloc] initWithCapacity:20];
    for ( int i = 0 ; i < 20 ; ++ i ) {
        [m addObject:[SJVideoModel testItem]];
    }
    return m;
}

+ (NSArray<SJVideoModel *> *)testItemsWithCount:(NSInteger)count {
    NSMutableArray<SJVideoModel *> *m = [[NSMutableArray alloc] initWithCapacity:count];
    for ( int i = 0 ; i < count ; ++ i ) {
        [m addObject:[SJVideoModel testItem]];
    }
    return m;
}

+ (instancetype)testItem {
    SJVideoModel *item = [SJVideoModel new];
    
    static NSArray<NSString *> *mediaTitles;
    static NSArray<NSString *> *usernames;
    static NSArray<NSString *> *covers;
    static NSArray<NSString *> *avatars;
    static NSArray<NSURL *> *URLs;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediaTitles =
        @[@"打天梯遇到火力队，开场先被对面三炮轮番轰炸，主视角溃不成军。正当觉的失败钟声即将敲响时，主视角女鬼...",
          @"女鬼刚刚换了仙，队伍是三魔一炮一睡人，宝宝方面还是提升!以下是十五星首回合睡八录像一场，供大家欣赏。",
          @"天下第一比武大会全面升级 你敢来战吗？",
          @"白衣，妹纸，钢琴，给你换一种视听感受，陶冶一下情操!",
          @"昨天大家看了一场两回合杀魅影的录像，然后被多数玩家评论：“这才是效率队!”，然后今天小编再来分享场录像，孟极队一回合击杀录像，究竟谁更有效率呢？",
          @"谁说天下武功唯快不破!看这两支敏队的PK是否谁先起速，谁就能占据优势呢?要知道战场上什么情况都会发生，比如…",
          @"这个周年庆，对大话2的玩家们来说是充满喜悦与感动的。从苍山洱海边的大话西游全品牌发布会到8月15日情义上映的品牌宣传片《胡歌：致曾经的兄弟》，从线上周年庆大话节情义俱乐部福利内容到线下2016时光巡礼的玩家聚会，大话2与玩家一路相伴。现在，大话西游全品牌发布会花絮视频曝光，苍山之下洱海之边，新兄弟胡歌带你重温那些大话西游的重要时刻！",
          ];
        
        
        usernames =
        @[@"悲哀化身-内蒙专区", @"车迟国@最终幻想-剑侠风骨", @"老虎222-天竺国", @"今朝醉-云中殿", @"杀手阿七-五明宫", @"浅墨淋雨桥-剑胆琴心"];
        
        covers =
        @[@"https://xy2.res.netease.com/pc/zt/20151203150349/images/pic/b3_2a6166c.jpg",
          @"https://xy2.res.netease.com/pc/zt/20151203150349/images/pic/b4_ca39119.jpg",
          @"https://xy2.res.netease.com/pc/zt/20151203150349/images/pic/c2_c9e7cc0.jpg",
          @"https://xy2.res.netease.com/pc/zt/20151203150349/images/pic/b7_f9a43d6.jpg",
          @"https://xy2.res.netease.com/pc/zt/20151203150349/images/pic/b10_e52c929.jpg",
          @"https://xy2.res.netease.com/pc/zt/20151203150349/images/pic/b5_a9bc2f1.jpg"];
        
        avatars =
        @[@"https://xy2.res.netease.com/pc/zt/20160104090145/data/01.png",
          @"https://xy2.res.netease.com/pc/zt/20160104090145/data/02.png",
          @"https://xy2.res.netease.com/pc/zt/20160104090145/data/03.png",
          @"https://xy2.res.netease.com/pc/zt/20160104090145/data/04.png",
          @"https://xy2.res.netease.com/pc/zt/20160104090145/data/05.png",
          @"https://xy2.res.netease.com/pc/zt/20160104090145/data/06.png",
          @"https://xy2.res.netease.com/pc/zt/20160104090145/data/07.png",
          @"https://xy2.res.netease.com/pc/zt/20160104090145/data/08.png"];
        
        URLs = SourceURLs;
    });

    item.mediaTitle = mediaTitles[arc4random()%mediaTitles.count];
    item.cover = covers[arc4random()%covers.count];
    item.avatar = avatars[arc4random()%avatars.count];
    item.username = usernames[arc4random()%usernames.count];
    NSURL *URL = URLs[arc4random()%URLs.count];
    NSURLComponents *comp = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    static NSInteger idx;
    [comp setQuery:[NSString stringWithFormat:@"idx=%ld", ++idx]];
    item.URL = comp.URL;
    return item;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        static NSInteger __id;
        _id = __id++;
    }
    return self;
}
@end
