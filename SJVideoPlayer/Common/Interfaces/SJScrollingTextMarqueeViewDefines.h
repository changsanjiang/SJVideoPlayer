//
//  SJScrollingTextMarqueeViewDefines.h
//  Pods
//
//  Created by 畅三江 on 2019/12/7.
//

#ifndef SJScrollingTextMarqueeViewDefines_h
#define SJScrollingTextMarqueeViewDefines_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
///
/// 滚动标题
///
@protocol SJScrollingTextMarqueeView <NSObject>
@property (nonatomic, copy, nullable) NSAttributedString *attributedText;
@property (nonatomic) CGFloat margin;

@property (nonatomic, readonly, getter=isScrolling) BOOL scrolling;
@property (nonatomic, getter=isScrollEnabled) BOOL scrollEnabled; ///< default value is YES
@end
NS_ASSUME_NONNULL_END

#endif /* SJScrollingTextMarqueeViewDefines_h */
