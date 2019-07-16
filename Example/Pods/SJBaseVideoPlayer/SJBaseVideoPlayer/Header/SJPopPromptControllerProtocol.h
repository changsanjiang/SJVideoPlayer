//
//  SJPopPromptControllerProtocol.h
//  Pods
//
//  Created by 畅三江 on 2019/7/12.
//

#ifndef SJPopPromptControllerProtocol_h
#define SJPopPromptControllerProtocol_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJPopPromptControllerProtocol <NSObject>
- (void)show:(NSAttributedString *)title;
- (void)show:(NSAttributedString *)title duration:(NSTimeInterval)duration;
- (void)clear;

@property (nonatomic) CGFloat leftMargin; ///< default value is 16
@property (nonatomic) CGFloat bottomMargin; ///< default value is 16
@property (nonatomic) CGFloat itemSpacing; ///< default value is 12
@property (nonatomic) UIEdgeInsets contentInset; ///< default value is UIEdgeInsetsMake(12, 22, 12, 22);

/// 以下属性由播放器维护
///
@property (nonatomic, weak, nullable) UIView *target;
@end
NS_ASSUME_NONNULL_END

#endif /* SJPopPromptControllerProtocol_h */
