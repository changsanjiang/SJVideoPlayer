//
//  MCSQueue.m
//  Pods
//
//  Created by 畅三江 on 2020/7/14.
//

#import "MCSQueue.h"

dispatch_queue_t
MCSAssetQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        queue = dispatch_queue_create("mcs.MCSAssetQueue", DISPATCH_QUEUE_CONCURRENT);
        queue = dispatch_get_global_queue(0, 0);
    });
    return queue;
}

dispatch_queue_t
MCSPrefetcherQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("mcs.MCSPrefetcherQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

dispatch_queue_t
MCSReaderQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("mcs.MCSReaderQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

#pragma mark -

dispatch_queue_t
MCSFileDataReaderQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("mcs.MCSFileDataReaderQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

#pragma mark -

dispatch_queue_t
HLSAESDataReaderQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("mcs.HLSAESDataReaderQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

dispatch_queue_t
HLSContentIndexReaderQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("mcs.HLSContentIndexReaderQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

dispatch_queue_t
HLSTsDataReaderQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("mcs.HLSTsDataReaderQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

#pragma mark -

dispatch_queue_t
FILEContentReaderQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("mcs.FILEContentReaderQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

#pragma mark -

dispatch_queue_t
MCSDownloadQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("mcs.MCSDownloadQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

dispatch_queue_t
MCSDelegateQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("mcs.MCSDelegateQueue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}
