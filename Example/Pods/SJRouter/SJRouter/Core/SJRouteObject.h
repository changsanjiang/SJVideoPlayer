//
//  SJRouteObject.h
//  Pods
//
//  Created by BlueDancer on 2019/12/25.
//

#import <Foundation/Foundation.h>
#import "SJRouteHandler.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^SJCreateInstanceBlock)(SJRouteRequest *request, SJCompletionHandler _Nullable completionHandler);
typedef enum : NSUInteger {
    /// push
    SJViewControllerTransitionModeNavigation,
    /// present
    SJViewControllerTransitionModeModal,
} SJViewControllerTransitionMode;

@interface SJRouteObject : NSObject
- (nullable instancetype)initWithPath:(NSString *)path transitionMode:(SJViewControllerTransitionMode)mode createInstanceBlock:(nonnull SJCreateInstanceBlock)createInstanceBlock;
- (nullable instancetype)initWithPaths:(NSArray<NSString *> *)paths transitionMode:(SJViewControllerTransitionMode)mode createInstanceBlock:(SJCreateInstanceBlock)createInstanceBlock transitionAnimated:(BOOL)animated;

@property (nonatomic) SJViewControllerTransitionMode mode;
@property (nonatomic) BOOL animated; // transitionAnimated
@end
NS_ASSUME_NONNULL_END
