//
//  SJRotationMode2ViewModel.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoModel.h"
#import "SJVideoCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJRotationMode2ViewModel : NSObject
@property (nonatomic, strong, readonly) NSArray<SJVideoCellViewModel *> *tableItems;

- (void)addItems:(NSArray<SJVideoCellViewModel *> *)items;
- (void)removeAllItems;
@end

NS_ASSUME_NONNULL_END
