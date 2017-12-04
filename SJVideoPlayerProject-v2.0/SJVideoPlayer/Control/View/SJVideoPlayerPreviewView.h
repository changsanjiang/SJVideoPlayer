//
//  SJVideoPlayerPreviewView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerBaseView.h"
#import "SJVideoPreviewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerPreviewView : SJVideoPlayerBaseView

@property (nonatomic, strong, readwrite, nullable) NSArray<SJVideoPreviewModel *> *previewImages;

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@end

NS_ASSUME_NONNULL_END
