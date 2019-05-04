//
//  DemoTableViewCellViewModel.h
//  MJRefreshDemo
//
//  Created by BlueDancer on 2019/5/4.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DemoTableViewCell.h"
#import "DemoMediaModel.h"

NS_ASSUME_NONNULL_BEGIN
extern NSInteger DemoTableViewCellCoverTag;

@interface DemoTableViewCellViewModel : NSObject<DemoTableViewCellDataSoruce>
- (instancetype)initWithModel:(DemoMediaModel *)model;
@property (nonatomic, strong, readonly) DemoMediaModel *model;
- (CGFloat)height;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
