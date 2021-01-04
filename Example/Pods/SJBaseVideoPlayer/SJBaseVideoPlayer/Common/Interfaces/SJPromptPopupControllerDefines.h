//
//  SJPromptPopupController.h
//  Pods
//
//  Created by 畅三江 on 2019/7/12.
//

#ifndef SJPromptPopupControllerProtocol_h
#define SJPromptPopupControllerProtocol_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJPromptPopupController <NSObject>
@property (nonatomic) UIEdgeInsets contentInset; ///< default value is UIEdgeInsetsMake(12, 22, 12, 22);
- (void)show:(NSAttributedString *)title;
- (void)show:(NSAttributedString *)title duration:(NSTimeInterval)duration;

- (void)showCustomView:(UIView *)view;
- (void)showCustomView:(UIView *)view duration:(NSTimeInterval)duration;
- (BOOL)isShowingWithCustomView:(UIView *)view;

- (void)remove:(UIView *)view;
- (void)clear;
@property (nonatomic) CGFloat leftMargin; ///< default value is 16
@property (nonatomic) CGFloat bottomMargin; ///< default value is 16
@property (nonatomic) CGFloat itemSpacing; ///< default value is 12

@property (nonatomic, copy, readonly, nullable) __kindof NSArray<UIView *> *displayingViews;

@property (nonatomic) BOOL automaticallyAdjustsLeftInset;
@property (nonatomic) BOOL automaticallyAdjustsBottomInset;

/// 以下属性由播放器维护
///
@property (nonatomic, weak, nullable) UIView *target;
@end
NS_ASSUME_NONNULL_END

#endif /* SJPromptPopupControllerProtocol_h */
