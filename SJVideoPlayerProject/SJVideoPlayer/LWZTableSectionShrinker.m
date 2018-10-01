//
//  LWZTableSectionShrinker.m
//  LWZAudioModule_Example
//
//  Created by BlueDancer on 2018/9/3.
//  Copyright © 2018年 changsanjiang@gmail.com. All rights reserved.
//

#import "LWZTableSectionShrinker.h"

NS_ASSUME_NONNULL_BEGIN
@implementation LWZTableSectionShrinker {
    NSArray *_dataArr;
    id _title;
    id _titleWhenShrank;
}

- (instancetype)initWithTitle:(nullable id)title
              titleWhenShrank:(nullable id)titleWhenShrank
                      dataArr:(nullable NSArray *)dataArr {
    self = [super init];
    if ( !self ) return nil;
    _title = title;
    _titleWhenShrank = titleWhenShrank;
    _dataArr = dataArr.copy;
    return self;
}

- (void)switchingStatus {
    _shrink = !_shrink;
}

- (nullable id)titleForShrinkStatus {
    return self.isShrink?_titleWhenShrank:_title;
}

- (nullable NSArray *)dataArrByShrinkStatus {
    return self.isShrink?nil:_dataArr;
}

- (void)resetDataArr:(nullable NSArray *)dataArr {
    _dataArr = dataArr.copy;
}

@end
NS_ASSUME_NONNULL_END
