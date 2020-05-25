//
//  SJPresentationQueue.h
//  Pods
//
//  Created by BlueDancer on 2020/5/8.
//

#import <UIKit/UIKit.h>
@protocol SJPresentViewProtocol;

typedef enum : NSUInteger {
    /// 可抛弃的
    SJPresentationPriorityDroppable,
    /// 必须呈现的, 优先级高的将优先呈现
    SJPresentationPriorityLow,
    /// 必须呈现的, 优先级高的将优先呈现
    SJPresentationPriorityNormal,
    /// 必须呈现的, 优先级高的将优先呈现
    SJPresentationPriorityHigh,
    /// 必须呈现的, 此选项将优先呈现
    SJPresentationPriorityVeryHigh
} SJPresentationPriority;

NS_ASSUME_NONNULL_BEGIN
@interface SJPresentationQueue : NSObject

/// 在`sourceView`上呈现`presentView`
/// 只有前一个`presentView`消失后, 才会继续后续的任务
/// 如果`sourceView`释放了, 则后续相关的任务将不会执行
+ (void)enqueueToPresent:(UIView<SJPresentViewProtocol> *)presentView sourceView:(UIView *)sourceView;

@end

@protocol SJPresentViewProtocol <NSObject>
@property (nonatomic, readonly) SJPresentationPriority priority;
- (void)showInSourceView:(UIView *)source dismissedCallback:(void(^)(void))callback;
@end
NS_ASSUME_NONNULL_END

