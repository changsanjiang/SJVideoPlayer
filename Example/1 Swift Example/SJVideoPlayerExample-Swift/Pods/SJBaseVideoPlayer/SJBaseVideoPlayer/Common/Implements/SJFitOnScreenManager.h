//
//  SJFitOnScreenManager.h
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2018/12/31.
//

#import <Foundation/Foundation.h>
#import "SJFitOnScreenManagerDefines.h"
#import "SJViewControllerManagerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJFitOnScreenManager : NSObject<SJFitOnScreenManager>
@property (nonatomic, weak, nullable) id<SJViewControllerManager> viewControllerManager;
@end
NS_ASSUME_NONNULL_END

