//
//  MCSQueue.m
//  Pods
//
//  Created by 畅三江 on 2020/7/14.
//

#import "MCSQueue.h"
#import "MCSUtils.h"

dispatch_queue_t
MCSDelegateQueue(void) {
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = mcs_dispatch_queue_create("mcs.MCSDelegateQueue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}
