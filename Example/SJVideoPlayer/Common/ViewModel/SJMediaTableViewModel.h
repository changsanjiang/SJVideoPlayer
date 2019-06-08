//
//  SJMediaTableViewModel.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJMediaTableViewCell.h"
#import "SJMeidaItemModel.h"

NS_ASSUME_NONNULL_BEGIN
extern NSInteger const SJMediaCoverTag;

@interface SJMediaTableViewModel : NSObject<SJMediaTableViewCellDataSource>
- (instancetype)initWithItem:(SJMeidaItemModel *)item;
@property (nonatomic) CGFloat height;

@property (nonatomic, strong, nullable) NSURL *url;
@property (nonatomic) NSInteger coverTag;
@property (nonatomic, copy, nullable) NSString *cover;
@property (nonatomic, copy, nullable) NSAttributedString *medianame;
@property (nonatomic, copy, nullable) NSString *avatar;
@property (nonatomic, copy, nullable) NSAttributedString *username;
@end

NS_ASSUME_NONNULL_END
