//
//  SJVideoModel.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/13.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJUserModel;

@protocol NSAttributedStringTappedDelegate;

@interface SJVideoModel : NSObject

+ (NSArray<SJVideoModel *> *)videoModelsWithTapActionDelegate:(id<NSAttributedStringTappedDelegate>)actionDelegate;

@property (nonatomic, assign) NSInteger videoId;
@property (nonatomic, strong) SJUserModel *creator;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSTimeInterval createTime;
@property (nonatomic, strong) NSString *playURLStr;
@property (nonatomic, strong) NSString *coverURLStr;

- (instancetype)initWithTitle:(NSString *)title
                      videoId:(NSInteger)videoId
                   createTime:(NSTimeInterval)createTime
                      creator:(SJUserModel *)creator
                   playURLStr:(NSString *)playURLStr
                  coverURLStr:(NSString *)coverURLStr;


#pragma mark -
@property (nonatomic, strong, readonly) NSAttributedString *attributedTitle;
@property (nonatomic, assign, readonly) CGFloat contentHeight;
@property (nonatomic, strong, readonly) NSString *createTimeStr;
@end

#pragma mark -

@interface SJUserModel: NSObject

+ (NSArray<SJUserModel *> *)userModels;

@property (nonatomic, strong, readonly) NSString *nickname;
@property (nonatomic, strong, readonly) NSString *avatar;

- (instancetype)initWithNickname:(NSString *)nickName avatar:(NSString *)avatar;

@end
