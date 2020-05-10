//
//  SJVideoCollectionViewCell.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/26.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJBaseCollectionViewCell.h"
@protocol SJVideoCollectionViewCellDataSource, SJVideoCollectionViewCellDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoCollectionViewCell : SJBaseCollectionViewCell
@property (nonatomic, weak, nullable) id<SJVideoCollectionViewCellDataSource> dataSource;
@property (nonatomic, weak, nullable) id<SJVideoCollectionViewCellDelegate> delegate;
@end

@protocol SJVideoCollectionViewCellDataSource
@property (nonatomic, copy, readonly, nullable) NSString *cover;
@property (nonatomic, copy, readonly, nullable) NSAttributedString *mediaTitle;
@property (nonatomic, copy, readonly, nullable) NSString *avatar;
@property (nonatomic, copy, readonly, nullable) NSAttributedString *username;
@end

@protocol SJVideoCollectionViewCellDelegate
- (void)coverItemWasTapped:(SJVideoCollectionViewCell *)cell;
@end
NS_ASSUME_NONNULL_END
