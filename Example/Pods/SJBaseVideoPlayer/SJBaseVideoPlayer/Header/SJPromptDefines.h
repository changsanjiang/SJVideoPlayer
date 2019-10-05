//
//  SJPromptDefines.h
//  Pods
//
//  Created by 畅三江 on 2019/9/15.
//

#ifndef SJPromptDefines_h
#define SJPromptDefines_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJPromptProtocol <NSObject>
- (void)show:(NSAttributedString *)title;
- (void)show:(NSAttributedString *)title duration:(NSTimeInterval)duration;
- (void)show:(NSAttributedString *)title duration:(NSTimeInterval)duration completionHandler:(nullable void(^)(void))completionHandler;
- (void)hidden;

@property (nonatomic) UIEdgeInsets contentInset; ///< default value is UIEdgeInsetsMake(12, 22, 12, 22);
@property (nonatomic) CGFloat cornerRadius;      ///< default value is 8.0
@property (nonatomic, strong, nullable) UIColor *backgroundColor;   ///< default value is blackColor
@property (nonatomic) CGFloat maxLayoutWidth; ///< default value is ( target.width * 0.6 )

/// 以下属性由播放器维护
///
@property (nonatomic, weak, nullable) UIView *target;
@end
NS_ASSUME_NONNULL_END
#endif /* SJPromptDefines_h */
