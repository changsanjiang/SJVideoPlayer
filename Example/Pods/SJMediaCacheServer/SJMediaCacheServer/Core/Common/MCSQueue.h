//
//  MCSQueue.h
//  Pods
//
//  Created by 畅三江 on 2020/7/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT dispatch_queue_t
MCSAssetQueue(void);

FOUNDATION_EXPORT dispatch_queue_t
MCSPrefetcherQueue(void);

FOUNDATION_EXPORT dispatch_queue_t
MCSReaderQueue(void);

#pragma mark -

FOUNDATION_EXPORT dispatch_queue_t
MCSFileDataReaderQueue(void);

#pragma mark -

FOUNDATION_EXPORT dispatch_queue_t
HLSAESDataReaderQueue(void);

FOUNDATION_EXPORT dispatch_queue_t
HLSContentIndexReaderQueue(void);

FOUNDATION_EXPORT dispatch_queue_t
HLSTsDataReaderQueue(void);

#pragma mark -

FOUNDATION_EXPORT dispatch_queue_t
FILEContentReaderQueue(void);

#pragma mark -

FOUNDATION_EXPORT dispatch_queue_t
MCSDownloadQueue(void);

FOUNDATION_EXPORT dispatch_queue_t
MCSDelegateQueue(void);

NS_ASSUME_NONNULL_END
