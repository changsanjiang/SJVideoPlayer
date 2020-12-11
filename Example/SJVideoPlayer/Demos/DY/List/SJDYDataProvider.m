//
//  SJDYDataProvider.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/6/13.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJDYDataProvider.h"

@implementation SJDYDataProvider
- (nullable NSURLSessionTask *)playbackListWithPageNum:(NSInteger)pageNum pageSize:(NSInteger)pageSize completionHandler:(void(^)(NSArray<SJVideoModel *> *_Nullable list, NSError *_Nullable error))completionHandler {
    if ( completionHandler ) completionHandler([SJVideoModel testItemsWithCount:pageSize], nil);
    return nil;
}
@end
