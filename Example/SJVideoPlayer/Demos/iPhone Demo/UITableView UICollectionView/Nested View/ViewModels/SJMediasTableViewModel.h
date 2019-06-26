//
//  SJMediasTableViewModel.h
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/6/26.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJMediaItemsTableViewCell.h"
#import "SJMeidaItemModel.h"
#import "SJExtendedMediaCollectionViewModel.h"
extern NSInteger const SJMediasCollectionViewTag;

NS_ASSUME_NONNULL_BEGIN

@interface SJMediasTableViewModel : NSObject<SJMediaItemsTableViewCellDataSource>
- (instancetype)initWithTitle:(NSString *)title items:(NSArray<SJMeidaItemModel *> *)items;

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, readonly) NSInteger collectionViewTag;
@property (nonatomic, strong, readonly) NSArray<SJExtendedMediaCollectionViewModel *> *medias;
@property (nonatomic) CGFloat height;
@end

NS_ASSUME_NONNULL_END
