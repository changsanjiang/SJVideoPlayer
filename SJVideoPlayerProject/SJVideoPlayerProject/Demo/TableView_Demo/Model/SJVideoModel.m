//
//  SJVideoModel.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/13.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoModel.h"
#import "SJVideoListTableViewCell.h"
#import "LightweightTableViewCell.h"
#import <SJAttributeWorker.h>
#import "YYTapActionLabel.h"

#pragma mark -

@implementation SJVideoModel

/// test test test test test
+ (NSArray<SJVideoModel *> *)testModelsWithTapActionDelegate:(id<NSAttributedStringTappedDelegate>)actionDelegate {
    return [self testModelsWithTapActionDelegate:actionDelegate size:100];
}

+ (NSArray<SJVideoModel *> *)testModelsWithTapActionDelegate:(id<NSAttributedStringTappedDelegate>)actionDelegate size:(NSInteger)size {
    NSArray<SJUserModel *> *users = [SJUserModel userModels];
    NSArray<NSString *> *titles =
    @[@"DIY心情转盘 #手工##手工制作#",
      @"#手工#彤居居给我的第二份礼物🙈@SLIMETCk 我最喜欢的硬身史莱姆和平遥牛肉🐷",
      @"猛然感觉我这个桌垫玩slime还挺好看🤓#辰叔slime##手工##史莱姆slime#",
      @"马卡龙&蓝莓蛋糕#手工#💓日常更新🙆🙆#美拍手工挑战#",
      @"凤兮凤兮归故乡，遨游四海求其凰。\n时未遇兮无所将，何悟今兮升斯堂！\n有艳淑女在闺房，室迩人遐毒我肠。\n何缘交颈为鸳鸯，胡颉颃兮共翱翔！\n凰兮凰兮从我栖，得托孳尾永为妃。\n交情通意心和谐，中夜相从知者谁？\n双翼俱起翻高飞，无感我思使余悲。",
      @"【超萌水果道歉信DIY】第一集-一起来学DIY可爱的水果道歉信吧！#小伶玩具##DIY##手工##少儿##益智#",
      @"趁着上海多年来的第一场大雪之际，我终于更新了！封面是特地在雪地里拍的😂这次做了款爱丽丝的高跟鞋，蓝白风格很适合这个冬天～视频最后分享给大家看我拍的一些雪景照片，还有萌萌和我的蛙蛙😃视频材料链接https://shop.m.taobao.com/shop/shop_index.htm?spm=0.0.0.0&shop_id=109390037 下单报红兮兮打九折 #手工#评论告诉我你们那边下雪了吗？下的多大？",
      @"#手工#芒果派对💁🏼再说一次 微店买满100才发货的 请各位看好微店公告再拍 还有你买4块钱让我包邮这种事情我做不到的谢谢！"];
    NSArray<NSString *> *coverURLStrs = @[@"cover0", @"cover2", @"cover3",
                                          @"cover4", @"cover5"];
    
    NSMutableArray<SJVideoModel *> *testVideosM = [NSMutableArray array];
    NSDate *date = [NSDate date];
    
    
    NSArray<NSString *> *testURLStrs =
    @[@"http://v.dansewudao.com/444fccb3590845a799459f6154d2833f/fe86a70dc4b8497f828eaa19058639ba-6e51c667edc099f5b9871e93d0370245-sd.mp4",
      @"http://v.dansewudao.com/d8d10b7e6c38421bb04fa8f7973aa906/a25106127ccf4052aa11aa792a8fc945-63be549439f2f81b92c75e150dc28e77-sd.mp4",
      @"http://v.dansewudao.com/3da9bf57591b40e18959eb742b61cbc1/f4ccd0efa1114eac9aaadeb2f91cce75-6d5b8e7f16f5c95e9b13477414c086aa-sd.mp4",
      @"http://v.dansewudao.com/502718a3e0a24673b2afa1c5c27cd301/771b26823ac64631b8977a718610b779-9f4d50aeba651a86d2b45f89f4799f31-sd.mp4",
      @"http://v.dansewudao.com/49e9f074e890493fa1f1677ca4f2faec/69e262b1b2014ff3afbb4052b1829d7a-7d56bc62083a11837ece71958f513034-sd.mp4",
      @"http://v.dansewudao.com/5ae2ef70bd854044a7e467a6de9b4557/5680314fc7dc4406b171ee613f231bd9-7b4a0bc984b4073be92825a8ecb36850-sd.mp4",
      @"http://v.dansewudao.com/ef2236d79ec848b5b07415d66494739b/95b4d2efcd2641cbb5c8cff53637972d-b92a1d32edec0becb5436483bda75679-sd.mp4",
      @"http://v.dansewudao.com/969785b209534ae2ae70a35bee5edb3f/e2cac516d2124089a796b5f177bd5a78-9f8e07f5fa9388811ba791a8e8864236-sd.mp4",
      ];
    
    // prepare test data
    for ( int i = 0 ; i < size ; ++ i ) {
        SJVideoModel *model =
        [[SJVideoModel alloc] initWithTitle:titles[arc4random() % titles.count]
                                    videoId:i
                                 createTime:date.timeIntervalSince1970 - arc4random() % 100000
                                    creator:users[arc4random() % users.count]
                                 playURLStr:testURLStrs[arc4random() % testURLStrs.count]
                                coverURLStr:coverURLStrs[arc4random() % coverURLStrs.count]];
        
        [SJVideoListTableViewCell sync_makeContentWithVideo:model tappedDelegate:actionDelegate];
        
        [testVideosM addObject:model];
    }
    return testVideosM;
}

+ (NSArray<SJVideoModel *> *)lightweighttestModelsWithTapActionDelegate:(id<NSAttributedStringTappedDelegate>)actionDelegate {
    NSArray<SJUserModel *> *users = [SJUserModel userModels];
    NSArray<NSString *> *titles =
    @[@"DIY心情转盘 #手工##手工制作#",
      @"#手工#彤居居给我的第二份礼物🙈@SLIMETCk 我最喜欢的硬身史莱姆和平遥牛肉🐷",
      @"猛然感觉我这个桌垫玩slime还挺好看🤓#辰叔slime##手工##史莱姆slime#",
      @"马卡龙&蓝莓蛋糕#手工#💓日常更新🙆🙆#美拍手工挑战#",
      @"凤兮凤兮归故乡，遨游四海求其凰。\n时未遇兮无所将，何悟今兮升斯堂！\n有艳淑女在闺房，室迩人遐毒我肠。\n何缘交颈为鸳鸯，胡颉颃兮共翱翔！\n凰兮凰兮从我栖，得托孳尾永为妃。\n交情通意心和谐，中夜相从知者谁？\n双翼俱起翻高飞，无感我思使余悲。",
      @"【超萌水果道歉信DIY】第一集-一起来学DIY可爱的水果道歉信吧！#小伶玩具##DIY##手工##少儿##益智#",
      @"趁着上海多年来的第一场大雪之际，我终于更新了！封面是特地在雪地里拍的😂这次做了款爱丽丝的高跟鞋，蓝白风格很适合这个冬天～视频最后分享给大家看我拍的一些雪景照片，还有萌萌和我的蛙蛙😃视频材料链接https://shop.m.taobao.com/shop/shop_index.htm?spm=0.0.0.0&shop_id=109390037 下单报红兮兮打九折 #手工#评论告诉我你们那边下雪了吗？下的多大？",
      @"#手工#芒果派对💁🏼再说一次 微店买满100才发货的 请各位看好微店公告再拍 还有你买4块钱让我包邮这种事情我做不到的谢谢！"];
    NSArray<NSString *> *coverURLStrs = @[@"cover0", @"cover2", @"cover3",
                                          @"cover4", @"cover5"];
    
    NSMutableArray<SJVideoModel *> *testVideosM = [NSMutableArray array];
    NSDate *date = [NSDate date];
    
    NSArray<NSString *> *testURLStrs =
    @[@"http://v.dansewudao.com/444fccb3590845a799459f6154d2833f/fe86a70dc4b8497f828eaa19058639ba-6e51c667edc099f5b9871e93d0370245-sd.mp4",
      @"http://v.dansewudao.com/d8d10b7e6c38421bb04fa8f7973aa906/a25106127ccf4052aa11aa792a8fc945-63be549439f2f81b92c75e150dc28e77-sd.mp4",
      @"http://v.dansewudao.com/3da9bf57591b40e18959eb742b61cbc1/f4ccd0efa1114eac9aaadeb2f91cce75-6d5b8e7f16f5c95e9b13477414c086aa-sd.mp4",
      @"http://v.dansewudao.com/502718a3e0a24673b2afa1c5c27cd301/771b26823ac64631b8977a718610b779-9f4d50aeba651a86d2b45f89f4799f31-sd.mp4",
      @"http://v.dansewudao.com/49e9f074e890493fa1f1677ca4f2faec/69e262b1b2014ff3afbb4052b1829d7a-7d56bc62083a11837ece71958f513034-sd.mp4",
      @"http://v.dansewudao.com/5ae2ef70bd854044a7e467a6de9b4557/5680314fc7dc4406b171ee613f231bd9-7b4a0bc984b4073be92825a8ecb36850-sd.mp4",
      @"http://v.dansewudao.com/ef2236d79ec848b5b07415d66494739b/95b4d2efcd2641cbb5c8cff53637972d-b92a1d32edec0becb5436483bda75679-sd.mp4",
      @"http://v.dansewudao.com/969785b209534ae2ae70a35bee5edb3f/e2cac516d2124089a796b5f177bd5a78-9f8e07f5fa9388811ba791a8e8864236-sd.mp4",
      ];

    // prepare test data
    for ( int i = 0 ; i < 100 ; ++ i ) {
        SJVideoModel *model =
        [[SJVideoModel alloc] initWithTitle:titles[arc4random() % titles.count]
                                    videoId:i
                                 createTime:date.timeIntervalSince1970 - arc4random() % 100000
                                    creator:users[arc4random() % users.count]
                                 playURLStr:testURLStrs[arc4random() % testURLStrs.count]
                                coverURLStr:coverURLStrs[arc4random() % coverURLStrs.count]];
        
        [LightweightTableViewCell sync_makeContentWithVideo:model tappedDelegate:actionDelegate];
        
        [testVideosM addObject:model];
    }
    return testVideosM;
}

- (instancetype)initWithTitle:(NSString *)title videoId:(NSInteger)videoId createTime:(NSTimeInterval)createTime creator:(SJUserModel *)creator playURLStr:(NSString *)playURLStr coverURLStr:(NSString *)coverURLStr {
    self = [super init];
    if ( !self ) return nil;
    _title = title;
    _videoId = videoId;
    _createTime = createTime;
    _creator = creator;
    _playURLStr = playURLStr;
    _coverURLStr = coverURLStr;
    return self;
}

- (NSTimeInterval)serverTime {
    return [NSDate date].timeIntervalSince1970;
}
@end


#pragma mark -

@implementation SJUserModel

+ (NSArray<SJUserModel *> *)userModels {
    NSArray<NSString *> *names = @[@"人生若只如初见", @"何事秋风悲画扇",
                                   @"山有木兮木有枝", @"心悦君兮君不知",
                                   @"十年生死两茫茫", @"不思量", @"自难忘",
                                   @"只愿君心似我心", @"定不负相思意",
                                   @"平生不会相思", @"才会相思", @"便害相思",
                                   @"入我相思门", @"知我相思苦"];
    
    NSArray<NSString *> *avatars = @[@"ming", @"lucy", @"tom",
                                     @"helun", @"air", @"cat",
                                     @"fuli", @"san", @"mei", @"bal"];
    
    NSMutableArray<SJUserModel *> *testUsersM = [NSMutableArray array];
    for ( int i = 0 ; i < 20 ; ++ i ) {
        SJUserModel *user = [[SJUserModel alloc] initWithNickname:names[arc4random() % names.count] avatar:avatars[arc4random() % avatars.count]];
        [testUsersM addObject:user];
    }
    return testUsersM;
}

- (instancetype)initWithNickname:(NSString *)nickname avatar:(NSString *)avatar {
    self = [super init];
    if ( !self ) return nil;
    _nickname = nickname;
    _avatar = avatar;
    return self;
}
@end
