//
//  SJVideoModel.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/13.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoModel.h"
#import "SJVideoListTableViewCell.h"
#import <SJStringParserConfig.h>
#import <SJCTData.h>

@implementation SJVideoHelper

- (instancetype)initWithContent:(NSString *)content font:(id)font textColor:(id)textColor numberOfLines:(NSUInteger)numberOfLines maxWidth:(float)maxWidth {
    self = [super init];
    if ( !self ) return nil;
    SJStringParserConfig *config = [SJStringParserConfig defaultConfig];
    config.font = font;
    config.textColor = textColor;
    config.numberOfLines = numberOfLines;
    config.maxWidth = maxWidth;
    _contentData = [[SJCTData alloc] initWithString:content config:config];
    [_contentData needsDrawing];
    return self;
}
- (instancetype)initWithAttrStr:(NSAttributedString *)attrStr numberOfLines:(NSUInteger)numberOfLines maxWidth:(float)maxWidth {
    self = [super init];
    if ( !self ) return nil;
    SJCTFrameParserConfig *config = [SJCTFrameParserConfig defaultConfig];
    config.numberOfLines = numberOfLines;
    config.maxWidth = maxWidth;
    _contentData = [[SJCTData alloc] initWithAttributedString:attrStr config:config];
    [_contentData needsDrawing];
    return self;
}

- (CGFloat)contentHeight {
    return ceil(_contentData.height);
}
@end


#pragma mark -

@implementation SJVideoModel

+ (NSArray<SJVideoModel *> *)videoModelsWithActionDelegate:(id<NSAttributedStringActionDelegate>)actionDelegate {
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
    
    
    // prepare test data
    for ( int i = 0 ; i < 88 ; ++ i ) {
        SJVideoModel *model =
        [[SJVideoModel alloc] initWithTitle:titles[arc4random() % titles.count]
                                    videoId:i
                                 createTime:date.timeIntervalSince1970 - arc4random() % 100000
                                    creator:users[arc4random() % users.count]
                                 playURLStr:@"http://video.cdn.lanwuzhe.com/14945858406905f0c"
                                coverURLStr:coverURLStrs[arc4random() % coverURLStrs.count]];
        // 昵称
        model.nicknameHelper = [SJVideoListTableViewCell helperWithNickname:model.creator.nickname];
        // 创建时间
        model.createTimeHelper = [SJVideoListTableViewCell helperWithCreateTime:model.createTime];
        // 发布内容
        model.contentHelper = [SJVideoListTableViewCell helperWithContent:model.title actionDelegate:actionDelegate];

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

- (instancetype)initWithNickname:(NSString *)nickName avatar:(NSString *)avatar {
    self = [super init];
    if ( !self ) return nil;
    _nickname = nickName;
    _avatar = avatar;
    return self;
}
@end
