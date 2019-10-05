//
//  SJListViewAutoplayCollectionViewCell.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/8/16.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJBaseCollectionViewCell.h"
#import "SJListViewAutoplayMediaInfoView.h"
@protocol SJListViewAutoplayCollectionViewCellDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface SJListViewAutoplayCollectionViewCell : SJBaseCollectionViewCell
@property (nonatomic, weak, nullable) id<SJListViewAutoplayCollectionViewCellDataSource> dataSource;

- (void)refreshData;
@end

@protocol SJListViewAutoplayCollectionViewCellDataSource <SJListViewAutoplayMediaInfoViewDataSource>
@property (nonatomic, copy, readonly, nullable) NSString *cover;
@property (nonatomic, readonly) NSInteger tag;
@end
NS_ASSUME_NONNULL_END
