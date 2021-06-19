//
//  UIColor+SJPageMenuBarExtended.h
//  SJUIKit
//
//  Created by BlueDancer on 2021/5/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (SJPageMenuBarExtended)

- (UIColor *)transitionToColor:(UIColor *)color progress:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
