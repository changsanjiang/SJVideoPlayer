//
//  SJVideoModel.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/13.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoModel.h"
#import "SJVideoListTableViewCell.h"
#import <SJCTFrameParser.h>
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
    _contentData = [SJCTFrameParser parserContent:content config:config];
    return self;
}

- (CGFloat)contentHeight {
    return ceil(_contentData.height_t);
}
@end


#pragma mark -

@implementation SJVideoModel

+ (NSArray<SJVideoModel *> *)videoModels {
    NSArray<SJUserModel *> *users = [SJUserModel userModels];
    NSArray<NSString *> *titles =
  @[@"今夕何夕兮，搴舟中流。\n今日何日兮，得与王子同舟。",
    @"人生若只如初见，何事秋风悲画扇。\n等闲变却故人心，却道故人心易变。",
    @"相顾无言，惟有泪千行。料得年年肠断处，明月夜，短松冈。",
    @"井底点灯深烛伊，共郎长行莫围棋。\n玲珑骰子安红豆，入骨相思知不知。",
    @"凤兮凤兮归故乡，遨游四海求其凰。\n时未遇兮无所将，何悟今兮升斯堂！\n有艳淑女在闺房，室迩人遐毒我肠。\n何缘交颈为鸳鸯，胡颉颃兮共翱翔！\n凰兮凰兮从我栖，得托孳尾永为妃。\n交情通意心和谐，中夜相从知者谁？\n双翼俱起翻高飞，无感我思使余悲。",
    @"竹竿何袅袅，鱼尾何簁簁！\n男儿重意气，何用钱刀为！",
    @"上邪，我欲与君相知，长命无绝衰。\n山无陵，江水为竭。冬雷震震，夏雨雪。天地合，乃敢与君绝。",
    @"剪绡零碎点酥乾，向背稀稠画亦难。\n日薄从甘春至晚，霜深应怯夜来寒。\n澄鲜只共邻僧惜，冷落犹嫌俗客看。\n忆着江南旧行路，酒旗斜拂堕吟鞍。"];
    NSArray<NSString *> *coverURLStrs = @[@"cover0", @"cover2", @"cover3",
                                          @"cover4", @"cover5"];
    
    
    NSMutableArray<SJVideoModel *> *testVideosM = [NSMutableArray array];
    NSDate *date = [NSDate date];
    
    
    // prepare test data
    for ( int i = 0 ; i < 300 ; ++ i ) {
        SJVideoModel *model =
        [[SJVideoModel alloc] initWithTitle:titles[arc4random() % titles.count]
                                 createTime:date.timeIntervalSince1970 - arc4random() % 100000
                                    creator:users[arc4random() % users.count]
                                 playURLStr:@"http://pu.latin5.com/bd1c831d-7024-4b17-a03e-e8ab89bb2a4b.m3u8"
                                coverURLStr:coverURLStrs[arc4random() % coverURLStrs.count]];
        
        model.contentHelper = [SJVideoListTableViewCell helperWithContent:model.title];
        model.nicknameHelper = [SJVideoListTableViewCell helperWithNickname:model.creator.nickname];
        model.createTimeHelper = [SJVideoListTableViewCell helperWithCreateTime:model.createTime];
        
        [testVideosM addObject:model];
    }
    return testVideosM;
}

- (instancetype)initWithTitle:(NSString *)title createTime:(NSTimeInterval)createTime creator:(SJUserModel *)creator playURLStr:(NSString *)playURLStr coverURLStr:(NSString *)coverURLStr {
    self = [super init];
    if ( !self ) return nil;
    _title = title;
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
