//
//  SJExtendedMediaCollectionViewModel.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/26.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJRecommendVideosTableViewCell.h"
#import "SJVideoModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJExtendedMediaCollectionViewModel : NSObject<SJExtendedMediaCollectionViewCellDataSource>
- (instancetype)initWithItem:(SJVideoModel *)item mediaTitleFont:(UIFont *)font;
@property (nonatomic) CGSize size;

@property (nonatomic, strong, nullable) NSURL *url;
@property (nonatomic, copy, nullable) NSString *cover;
@property (nonatomic, copy, nullable) NSAttributedString *mediaTitle;
@property (nonatomic, copy, nullable) NSString *avatar;
@property (nonatomic, copy, nullable) NSAttributedString *username;
@property (nonatomic, strong, nullable) UIColor *backgroundColor;
@end

NS_ASSUME_NONNULL_END
