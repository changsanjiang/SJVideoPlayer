//
//  SJDYDataProvider.h
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/6/13.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJDYDataProvider : NSObject
- (nullable NSURLSessionTask *)playbackListWithPageNum:(NSInteger)pageNum pageSize:(NSInteger)pageSize completionHandler:(void(^)(NSArray<SJVideoModel *> *_Nullable list, NSError *_Nullable error))completionHandler;
@end

NS_ASSUME_NONNULL_END
