//
//  SJReachabilityObserver.h
//  Project
//
//  Created by BlueDancer on 2018/12/28.
//  Copyright © 2018 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJReachabilityDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJReachability : NSObject<SJReachability>
+ (instancetype)shared;
@end
NS_ASSUME_NONNULL_END
