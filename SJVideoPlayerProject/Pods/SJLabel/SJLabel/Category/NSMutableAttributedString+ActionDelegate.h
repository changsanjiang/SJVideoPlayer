//
//  NSMutableAttributedString+ActionDelegate.h
//  SJLabel
//
//  Created by BlueDancer on 2018/1/27.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NSAttributedStringActionDelegate;

typedef NSString * NSAttributedStringKey NS_EXTENSIBLE_STRING_ENUM;

#pragma mark -
@interface NSMutableAttributedString (ActionDelegate)

/*!
 *  add some action. see `NSAttributedStringActionDelegate`.
 *
 *  attrStr.actionDelegate = self;
 *  attrStr.addAction(@"我们");       // 所有的`我们`添加点击事件, 回调将在代理方法`NSAttributedStringActionDelegate`中回调.
 *  attrStr.addAction(@"[活动链接]");  // 所有的`[活动链接]`添加点击事件, 回调将在代理方法中回调.
 *
 **/
@property (nonatomic, copy, readonly) void(^addAction)(NSString *regStr);

@property (nonatomic, copy, readonly) void(^regexp)(NSString *regStr, BOOL reverse, void(^matchedTask)(NSArray<NSValue *> *__nullable matchedRanges));

@end

#pragma mark -

@interface NSAttributedString (ActionDelegate)

@property (nonatomic, weak, readwrite, nullable) id<NSAttributedStringActionDelegate> actionDelegate;

@end




#pragma mark - protocol

@protocol NSAttributedStringActionDelegate<NSObject>

@optional
- (void)attributedString:(NSAttributedString *)attrStr action:(NSAttributedString *)action;

@end


#pragma mark -
UIKIT_EXTERN NSAttributedStringKey const SJActionAttributedStringKey;
NS_ASSUME_NONNULL_END
