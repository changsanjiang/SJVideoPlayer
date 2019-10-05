//
//  DemoTableViewCellViewModel.h
//  MJRefreshDemo
//
//  Created by 畅三江 on 2019/5/4.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DemoTableViewCell.h"
#import "SJMeidaItemModel.h"

NS_ASSUME_NONNULL_BEGIN
extern NSInteger DemoTableViewCellCoverTag;

@interface DemoTableViewCellViewModel : NSObject<DemoTableViewCellDataSoruce>
- (instancetype)initWithModel:(SJMeidaItemModel *)model;
@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, readonly) CGFloat height;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
