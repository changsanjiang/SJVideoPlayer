//
//  SJVideoCellViewModel.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoTableViewCell.h"
#import "SJVideoCollectionViewCell.h"
#import "SJVideoModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoCellViewModel : NSObject<SJVideoTableViewCellDataSource, SJVideoCollectionViewCellDataSource>
- (instancetype)initWithItem:(SJVideoModel *)item;
@property (nonatomic) CGFloat height;

@property (nonatomic, strong, nullable) NSURL *url; 
@property (nonatomic, copy, nullable) NSString *cover;
@property (nonatomic, copy, nullable) NSAttributedString *mediaTitle;
@property (nonatomic, copy, nullable) NSString *avatar;
@property (nonatomic, copy, nullable) NSAttributedString *username;
@end

NS_ASSUME_NONNULL_END
