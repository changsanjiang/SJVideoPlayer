//
//  YYTapActionLabel.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "YYLabel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol NSAttributedStringTappedDelegate;

@interface YYTapActionLabel : YYLabel

@end

@interface YYTextLayout(SJAdd)

+ (YYTextLayout *)sj_layoutWithContainer:(YYTextContainer *)container text:(NSAttributedString *)text;

@property (nonatomic, strong, readonly, nullable) NSAttributedString *tapActionAttributedString;

@end

#pragma mark -

@interface NSAttributedString (SJAddDelegate)

@property (nonatomic, weak, readwrite, nullable) id<NSAttributedStringTappedDelegate> tappedDelegate;

@end


#pragma mark -
@interface NSMutableAttributedString (SJAdd)

/**
 *  add some tap action. see `NSAttributedStringTappedDelegate` & use `YYTapActionLabel`.
 *
 *  attrStr.tappedDelegate = self;
 *  attrStr.addTapAction(@"我们");       // 所有的`我们`添加点击事件, 回调将在代理方法`NSAttributedStringActionDelegate`中回调.
 *  attrStr.addTapAction(@"[活动链接]");  // 所有的`[活动链接]`添加点击事件, 回调将在代理方法中回调.
 *
 *  @param regStr          Regular expression
 */
@property (nonatomic, copy, readonly) void(^addTapAction)(NSString *regStr);

@end

#pragma mark -
@protocol NSAttributedStringTappedDelegate<NSObject>

@optional
- (void)attributedString:(NSAttributedString *)attrStr tappedStr:(NSAttributedString *)tappedStr;

@end
NS_ASSUME_NONNULL_END
