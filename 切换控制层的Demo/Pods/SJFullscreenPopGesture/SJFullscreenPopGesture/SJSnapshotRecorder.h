//
//  SJSnapshotServer.h
//  SJBackGRProject
//
//  Created by BlueDancer on 2018/4/16.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJScreenshotTransitionMode.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJSnapshotServer : NSObject

@property (nonatomic) SJScreenshotTransitionMode transitionMode;

+ (instancetype)shared;

#pragma mark - action
- (void)nav:(UINavigationController *)nav pushViewController:(UIViewController *)viewController;


#pragma mark -
- (void)nav:(UINavigationController *)nav preparePopViewController:(UIViewController *)viewController;
- (void)nav:(UINavigationController *)nav poppingViewController:(UIViewController *)viewController offset:(double)offset;
- (void)nav:(UINavigationController *)nav willEndPopViewController:(UIViewController *)viewController pop:(BOOL)pop;
- (void)nav:(UINavigationController *)nav endPopViewController:(UIViewController *)viewController;
@end
NS_ASSUME_NONNULL_END
