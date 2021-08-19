//
//  MCSQueue.h
//  Pods
//
//  Created by 畅三江 on 2020/7/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT void
mcs_queue_init(void);

FOUNDATION_EXPORT void
mcs_queue_sync(NS_NOESCAPE dispatch_block_t block);

FOUNDATION_EXPORT void
mcs_queue_async(dispatch_block_t block);

FOUNDATION_EXPORT dispatch_queue_t
mcs_queue(void);

NS_ASSUME_NONNULL_END
