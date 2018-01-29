//
//  SJVideoModel.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/13.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NSMutableAttributedString+ActionDelegate.h>

@class SJCTData;

@interface SJVideoHelper : NSObject

@property (nonatomic, strong, readonly) SJCTData *contentData;
@property (nonatomic, assign, readonly) CGFloat contentHeight;

- (instancetype)initWithContent:(NSString *)content
                           font:(UIFont *)font
                      textColor:(UIColor *)textColor
                  numberOfLines:(NSUInteger)numberOfLines
                       maxWidth:(float)maxWidth;
- (instancetype)initWithAttrStr:(NSAttributedString *)attrStr
                  numberOfLines:(NSUInteger)numberOfLines
                       maxWidth:(float)maxWidth;
@end

#pragma mark -

@interface SJUserModel: NSObject

+ (NSArray<SJUserModel *> *)userModels;

@property (nonatomic, strong, readonly) NSString *nickname;
@property (nonatomic, strong, readonly) NSString *avatar;

- (instancetype)initWithNickname:(NSString *)nickName avatar:(NSString *)avatar;

@end


#pragma mark -

@interface SJVideoModel : NSObject

+ (NSArray<SJVideoModel *> *)videoModelsWithActionDelegate:(id<NSAttributedStringActionDelegate>)actionDelegate;

@property (nonatomic, strong) SJVideoHelper *contentHelper;
@property (nonatomic, strong) SJVideoHelper *nicknameHelper;
@property (nonatomic, strong) SJVideoHelper *createTimeHelper;

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, assign, readonly) NSTimeInterval createTime;
@property (nonatomic, strong, readonly) SJUserModel *creator;
@property (nonatomic, strong, readonly) NSString *playURLStr;
@property (nonatomic, strong, readonly) NSString *coverURLStr;

- (instancetype)initWithTitle:(NSString *)title
                   createTime:(NSTimeInterval)createTime
                      creator:(SJUserModel *)creator
                   playURLStr:(NSString *)playURLStr
                  coverURLStr:(NSString *)coverURLStr;

@end
