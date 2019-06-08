//
//  SJRoundCornerMask.h
//  Pods
//
//  Created by 畅三江 on 2018/7/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// rect corner & border
UIKIT_EXTERN void
SJCornerMaskSetRectCorner(__kindof UIView *view, UIRectCorner corners, CGFloat radius, CGFloat borderWidth, UIColor *_Nullable borderColor);

/// rect corner
UIKIT_EXTERN void __attribute__((overloadable))
SJCornerMaskSetRectCorner(__kindof UIView *view, UIRectCorner corners, CGFloat radius);

/// round & border
UIKIT_EXTERN void
SJCornerMaskSetRound(__kindof UIView *view, CGFloat borderWidth, UIColor *_Nullable borderColor);

/// round
UIKIT_EXTERN void __attribute__((overloadable))
SJCornerMaskSetRound(__kindof UIView *view);
NS_ASSUME_NONNULL_END
