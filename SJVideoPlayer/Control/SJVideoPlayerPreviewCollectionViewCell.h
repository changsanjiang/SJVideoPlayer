//
//  SJVideoPlayerPreviewCollectionViewCell.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJVideoPlayerPreviewInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerPreviewCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readwrite, nullable) id<SJVideoPlayerPreviewInfo> model;

@end

NS_ASSUME_NONNULL_END
