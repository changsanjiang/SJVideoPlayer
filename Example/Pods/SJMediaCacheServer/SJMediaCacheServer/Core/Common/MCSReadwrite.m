//
//  MCSReadwrite.m
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2021/7/19.
//

#import "MCSReadwrite.h"
#import "MCSQueue.h"
#import "MCSConsts.h"

@implementation MCSReadwrite {
    NSInteger mReadwriteCount;
}

- (NSInteger)readwriteCount {
    __block NSInteger readwriteCount = 0;
    mcs_queue_sync(^{
        readwriteCount = mReadwriteCount;
    });
    return readwriteCount;
}

- (void)readwriteRetain {
    mcs_queue_sync(^{
        mReadwriteCount += 1;
        [self readwriteCountDidChange:mReadwriteCount];
    });
}

- (void)readwriteRelease {
    mcs_queue_sync(^{
        if ( mReadwriteCount > 0 ) {
            mReadwriteCount -= 1;
            [self readwriteCountDidChange:mReadwriteCount];
        }
    });
}

- (void)readwriteCountDidChange:(NSInteger)count {}
@end
