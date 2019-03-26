//
//  SJEdgeControlButtonItem.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/19.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SJBaseVideoPlayer/SJPlayerGestureControl.h>
typedef NSInteger SJEdgeControlButtonItemTag;
@protocol SJEdgeControlButtonItemDelegate;
@class SJBaseVideoPlayer;

typedef struct SJEdgeInsets {
    // 前后间距
    CGFloat front, rear;
} SJEdgeInsets;

UIKIT_STATIC_INLINE SJEdgeInsets SJEdgeInsetsMake(CGFloat front, CGFloat rear) {
    return (SJEdgeInsets){front, rear};
}

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN NSNotificationName const SJEdgeControlButtonItemPerformedActionNotification;

@interface SJEdgeControlButtonItem : NSObject
/// 49 * 49
- (instancetype)initWithImage:(nullable UIImage *)image
                       target:(nullable id)target
                       action:(nullable SEL)action
                          tag:(SJEdgeControlButtonItemTag)tag;

/// 49 * title.size.width
- (instancetype)initWithTitle:(nullable NSAttributedString *)title
                       target:(nullable id)target
                       action:(nullable SEL)action
                          tag:(SJEdgeControlButtonItemTag)tag;

/// 49 * customView.size.width
- (instancetype)initWithCustomView:(nullable __kindof UIView *)customView
                               tag:(SJEdgeControlButtonItemTag)tag;

- (instancetype)initWithTag:(SJEdgeControlButtonItemTag)tag;

@property (nonatomic) SJEdgeInsets insets; // 左右间隔, 默认{0, 0}
@property (nonatomic) SJEdgeControlButtonItemTag tag;
@property (nonatomic, strong, nullable) __kindof UIView *customView;
@property (nonatomic, strong, nullable) NSAttributedString *title;
@property (nonatomic) NSInteger numberOfLines; // default is 1.0
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, getter=isHidden) BOOL hidden;
@property (nonatomic, weak, nullable) id target;
@property (nonatomic, nullable) SEL action;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@property (nonatomic) BOOL fill; // 当想要填充剩余空间时, 可以设置为`Yes`. 
@property (nonatomic, weak, nullable) id<SJEdgeControlButtonItemDelegate> delegate;

- (void)addTarget:(id)target action:(nonnull SEL)action;
- (void)performAction;
@end

@protocol SJEdgeControlButtonItemDelegate <NSObject>
@optional
/// 每次控制层显示, 这个方法都会被调用
- (void)updatePropertiesIfNeeded:(SJEdgeControlButtonItem *)item videoPlayer:(__kindof SJBaseVideoPlayer *)player;
/// 手势是否可以触发
- (BOOL)edgeControlButtonItem:(SJEdgeControlButtonItem *)item gestureRecognizerShouldTrigger:(SJPlayerGestureType)type atPoint:(CGPoint)point;
@end



typedef enum : NSUInteger {
    SJButtonItemPlaceholderType_Unknown,
    SJButtonItemPlaceholderType_49x49,              // 49 * 49
    SJButtonItemPlaceholderType_49xAutoresizing,    // 49 * 自适应大小
    SJButtonItemPlaceholderType_49xFill,            // 49 * 填充父视图剩余空间
    SJButtonItemPlaceholderType_49xSpecifiedSize,   // 49 * 指定尺寸(水平布局时, 49为高度, `指定尺寸`为宽度. 相反的, 垂直布局时, 49为宽度, `指定尺寸`为高度)
} SJButtonItemPlaceholderType;
/// 占位Item
/// 先占好位置, 后更新属性
@interface SJEdgeControlButtonItem(Placeholder)
+ (instancetype)placeholderWithType:(SJButtonItemPlaceholderType)placeholderType tag:(SJEdgeControlButtonItemTag)tag;
+ (instancetype)placeholderWithSize:(CGFloat)size tag:(SJEdgeControlButtonItemTag)tag; // `placeholderType == SJButtonItemPlaceholderType_49xSpecifiedSize`
@property (nonatomic, readonly) SJButtonItemPlaceholderType placeholderType;
@property (nonatomic) CGFloat size;
@end



/// - 此分类只配合帧布局使用(SJAdapterItemsLayoutTypeFrameLayout), 其他布局无效
/// - 帧布局仅支持`customView`
/// - 请设置`customView`的`bounds`
@interface SJEdgeControlButtonItem (FrameLayout)
+ (instancetype)frameLayoutWithCustomView:(__kindof UIView *)customView tag:(SJEdgeControlButtonItemTag)tag;
@property (nonatomic, readonly) BOOL isFrameLayout;
@end
NS_ASSUME_NONNULL_END
