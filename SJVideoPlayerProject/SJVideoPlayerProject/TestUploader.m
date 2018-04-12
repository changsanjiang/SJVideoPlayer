//
//  TestUploader.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/12.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "TestUploader.h"
#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import <objc/message.h>

@interface TestUploader ()

@end

@implementation TestUploader
+ (instancetype)sharedManager {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

static const char *const CancelFlag = "CancelFlag";

- (void)upload:(id<SJVideoPlayerFilmEditingResult>)result
      progress:(void(^ __nullable)(float progress))progressBlock
       success:(void(^ __nullable)(void))success
       failure:(void (^ __nullable)(NSError *error))failure {
    objc_setAssociatedObject(result, CancelFlag, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    
    NSString *title = result.currentPlayAsset.title; NSLog(@"Upload segment From --> %@", title);
    
    // test code test code
    __block float progress = 0;
    for ( int i = 1 ; i <= 10 ; ++i ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BOOL cancelFalg = [objc_getAssociatedObject(result, CancelFlag) boolValue];
            if ( cancelFalg ) {
                // cancel code
                return;
            }
            else  {
                progressBlock(progress = i * 0.1);
                if ( progress == 1 ) success();
            }
        });
    }
}

- (void)cancelUpload:(id<SJVideoPlayerFilmEditingResult>)result {
    NSString *title = result.currentPlayAsset.title; NSLog(@"Cancel segment From --> %@", title);
    objc_setAssociatedObject(result, CancelFlag, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
