//
//  SJRotationMode2ViewModel.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJMeidaItemModel.h"
#import "SJMediaTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJRotationMode2ViewModel : NSObject
@property (nonatomic, strong, readonly) NSArray<SJMediaTableViewModel *> *tableItems;

- (void)addItems:(NSArray<SJMediaTableViewModel *> *)items;
- (void)removeAllItems;
@end

NS_ASSUME_NONNULL_END
