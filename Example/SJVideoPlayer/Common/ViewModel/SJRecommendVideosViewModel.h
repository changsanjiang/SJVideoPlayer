//
//  SJRecommendVideosViewModel.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/26.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJRecommendVideosTableViewCell.h"
#import "SJRecommendVideosCollectionViewCell.h"
#import "SJVideoModel.h"
#import "SJExtendedMediaCollectionViewModel.h"
extern NSInteger const SJMediasCollectionViewTag;

NS_ASSUME_NONNULL_BEGIN

@interface SJRecommendVideosViewModel : NSObject<SJRecommendVideosTableViewCellDataSource, SJRecommendVideosCollectionViewCellDataSource>
- (instancetype)initWithTitle:(NSString *)title items:(NSArray<SJVideoModel *> *)items;

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, readonly) NSInteger collectionViewTag;
@property (nonatomic, strong, readonly) NSArray<SJExtendedMediaCollectionViewModel *> *medias;
@property (nonatomic) CGFloat height;
@end

NS_ASSUME_NONNULL_END
