//
//  MCSQueue.m
//  Pods
//
//  Created by 畅三江 on 2020/7/14.
//

#import "MCSQueue.h"

dispatch_queue_t
MCSResourceQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        queue = dispatch_queue_create("mcs.MCSResourceQueue", DISPATCH_QUEUE_CONCURRENT);
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
MCSHLSAESDataReaderQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("mcs.MCSHLSAESDataReaderQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

dispatch_queue_t
MCSHLSIndexDataReaderQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("mcs.MCSHLSIndexDataReaderQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

dispatch_queue_t
MCSHLSTsDataReaderQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("mcs.MCSHLSTsDataReaderQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

#pragma mark -

dispatch_queue_t
MCSVODNetworkDataReaderQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("mcs.MCSVODNetworkDataReaderQueue", DISPATCH_QUEUE_CONCURRENT);
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
