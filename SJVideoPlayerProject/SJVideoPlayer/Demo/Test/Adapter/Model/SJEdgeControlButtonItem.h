//
//  SJEdgeControlButtonItem.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/19.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef struct SJEdgeInsets {
    CGFloat left, right;
} SJEdgeInsets;

UIKIT_STATIC_INLINE SJEdgeInsets SJEdgeInsetsMake(CGFloat left, CGFloat right) {
    SJEdgeInsets insets = {left, right};
    return insets;
}

typedef NSInteger SJEdgeControlButtonItemTag;
@protocol SJEdgeControlButtonItemDelegate;
@class SJBaseVideoPlayer;

NS_ASSUME_NONNULL_BEGIN
@interface SJEdgeControlButtonItem : NSObject
/// 布局大小: 44 * autoresizing
- (instancetype)initWithTitle:(nullable NSAttributedString *)title
                       target:(nullable id)target
                       action:(nullable SEL)action
                          tag:(SJEdgeControlButtonItemTag)tag;
/// 布局大小: 44 * 44
- (instancetype)initWithImage:(nullable UIImage *)image
                       target:(nullable id)target
                       action:(nullable SEL)action
                          tag:(SJEdgeControlButtonItemTag)tag;

/// 布局大小: 44 * autoresizing
- (instancetype)initWithCustomView:(nullable __kindof UIView *)customView
                               tag:(SJEdgeControlButtonItemTag)tag;

@property (nonatomic) SJEdgeInsets insets; // 左右间隔, 默认{0, 0}
@property (nonatomic) SJEdgeControlButtonItemTag tag;
@property (nonatomic, weak, nullable) id<SJEdgeControlButtonItemDelegate> delegate;
@property (nonatomic, strong, nullable) __kindof UIView *customView;
@property (nonatomic, strong, nullable) NSAttributedString *title;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, weak, nullable) id target;
@property (nonatomic, nullable) SEL action;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@property (nonatomic) BOOL fill; // 当想要填充剩余空间时, 可以设置为`Yes`. 注意: 在`adapter`中, 此`item`只能存在一个.
@end

@protocol SJEdgeControlButtonItemDelegate <NSObject>
- (void)updatePropertiesIfNeed:(SJEdgeControlButtonItem *)item videoPlayer:(__kindof SJBaseVideoPlayer *)player;
@end
NS_ASSUME_NONNULL_END
