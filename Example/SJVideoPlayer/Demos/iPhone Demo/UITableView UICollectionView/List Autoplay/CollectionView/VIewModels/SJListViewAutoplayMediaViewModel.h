//
//  SJListViewAutoplayMediaViewModel.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/8/16.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJListViewAutoplayCollectionViewCell.h"
#import "SJMeidaItemModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJListViewAutoplayMediaViewModel : NSObject<SJListViewAutoplayCollectionViewCellDataSource>
- (instancetype)initWithItem:(SJMeidaItemModel *)item tag:(NSInteger)tag;

@property (nonatomic, strong, readonly) SJMeidaItemModel *media;
@property (nonatomic, copy, readonly) NSAttributedString *name;
@property (nonatomic, copy, readonly) NSAttributedString *des;
@property (nonatomic, copy, readonly) NSString *cover;
@property (nonatomic, readonly) NSInteger tag;

@property (nonatomic) BOOL showPausedImageView;
@end

NS_ASSUME_NONNULL_END
