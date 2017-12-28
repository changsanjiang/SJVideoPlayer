//
//  SJVideoPlayerPreviewCollectionViewCell.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SJVideoPreviewModel;

@interface SJVideoPlayerPreviewCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readwrite, nullable) SJVideoPreviewModel *model;

@end

NS_ASSUME_NONNULL_END
