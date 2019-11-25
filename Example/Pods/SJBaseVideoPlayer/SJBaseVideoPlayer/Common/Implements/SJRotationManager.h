//
//  SJRotationManager.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/7/13.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJRotationManagerDefines.h"
#import "SJViewControllerManagerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJRotationManager : NSObject<SJRotationManager>

@property (nonatomic, weak, nullable) id<SJViewControllerManager> viewControllerManager;

@end
NS_ASSUME_NONNULL_END
