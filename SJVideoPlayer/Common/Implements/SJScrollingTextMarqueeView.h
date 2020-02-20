//
//  SJScrollingTextMarqueeView.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/12/7.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SJVideoPlayer/SJScrollingTextMarqueeViewDefines.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJScrollingTextMarqueeView : UIView<SJScrollingTextMarqueeView>
@property (nonatomic, copy, nullable) NSAttributedString *attributedText;
@property (nonatomic) CGFloat margin;

@property (nonatomic, readonly, getter=isScrolling) BOOL scrolling;
@property (nonatomic, getter=isScrollEnabled) BOOL scrollEnabled;
@end
NS_ASSUME_NONNULL_END
