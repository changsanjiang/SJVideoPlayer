//
//  MCSQueue.m
//  Pods
//
//  Created by 畅三江 on 2020/7/14.
//

#import "MCSQueue.h"
#import "MCSUtils.h"

static void *mQueueKey = &mQueueKey;
static dispatch_queue_t mQueue = NULL;
void
mcs_queue_init(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mQueue = mcs_dispatch_queue_create("queue.SJMediaCacheServer", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(mQueue, mQueueKey, mQueueKey, NULL);
    });
}

void
mcs_queue_sync(NS_NOESCAPE dispatch_block_t block) {
    if ( dispatch_get_specific(mQueueKey) ) {
        block();
    }
    else {
        dispatch_sync(mQueue, block);
    }
}

void
mcs_queue_async(dispatch_block_t block) {
    dispatch_async(mQueue, block);
}

dispatch_queue_t
mcs_queue(void) {
    return mQueue;
}
