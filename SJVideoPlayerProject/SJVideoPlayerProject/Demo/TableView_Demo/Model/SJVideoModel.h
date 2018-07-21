//
//  SJVideoModel.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/13.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJUserModel, YYTextLayout;

@protocol NSAttributedStringTappedDelegate;

@interface SJVideoModel : NSObject

+ (NSArray<SJVideoModel *> *)testModelsWithTapActionDelegate:(id<NSAttributedStringTappedDelegate>)actionDelegate;
+ (NSArray<SJVideoModel *> *)testModelsWithTapActionDelegate:(id<NSAttributedStringTappedDelegate>)actionDelegate size:(NSInteger)size;
+ (NSArray<SJVideoModel *> *)lightweighttestModelsWithTapActionDelegate:(id<NSAttributedStringTappedDelegate>)actionDelegate;

@property (nonatomic, assign) NSInteger videoId;
@property (nonatomic, strong) SJUserModel *creator;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSTimeInterval createTime;
@property (nonatomic, assign) NSTimeInterval serverTime;
@property (nonatomic, strong) NSString *playURLStr;
@property (nonatomic, strong) NSString *coverURLStr;

- (instancetype)initWithTitle:(NSString *)title
                      videoId:(NSInteger)videoId
                   createTime:(NSTimeInterval)createTime
                      creator:(SJUserModel *)creator
                   playURLStr:(NSString *)playURLStr
                  coverURLStr:(NSString *)coverURLStr;

@end

#pragma mark -

@interface SJUserModel: NSObject

+ (NSArray<SJUserModel *> *)userModels;

@property (nonatomic, strong, readonly) NSString *nickname;
@property (nonatomic, strong, readonly) NSString *avatar;

- (instancetype)initWithNickname:(NSString *)nickname avatar:(NSString *)avatar;

@end
