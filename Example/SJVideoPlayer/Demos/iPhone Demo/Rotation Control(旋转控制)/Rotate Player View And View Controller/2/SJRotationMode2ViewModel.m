//
//  SJRotationMode2ViewModel.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJRotationMode2ViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJRotationMode2ViewModel {
    NSMutableArray<SJVideoCellViewModel *> *_m;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _m = [NSMutableArray array];
    }
    return self;
}

- (NSArray<SJVideoCellViewModel *> *)tableItems {
    return _m;
}

- (void)addItems:(NSArray<SJVideoCellViewModel *> *)items {
    if ( items.count != 0 ) {
        [_m addObjectsFromArray:items];
    }
}

- (void)removeAllItems {
    [_m removeAllObjects];
}
@end
NS_ASSUME_NONNULL_END
