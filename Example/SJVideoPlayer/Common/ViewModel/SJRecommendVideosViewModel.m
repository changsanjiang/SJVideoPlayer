//
//  SJRecommendVideosViewModel.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/26.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJRecommendVideosViewModel.h"
#import "SJExtendedMediaCollectionViewModel.h"

NSInteger const SJMediasCollectionViewTag = 111;

NS_ASSUME_NONNULL_BEGIN
@implementation SJRecommendVideosViewModel
- (instancetype)initWithTitle:(NSString *)title items:(NSArray<SJVideoModel *> *)items {
    self = [super init];
    if ( self ) {
        _title = title;
        _collectionViewTag = SJMediasCollectionViewTag;

        UIFont *font = [UIFont boldSystemFontOfSize:16];
        CGFloat width = UIScreen.mainScreen.bounds.size.width - 120;
        CGFloat coverWidth = width - 40;
        CGFloat coverHeight = coverWidth * 9 / 16.0;
        CGFloat height = ceil(16 + coverHeight + 8 + font.lineHeight * 2 + 8 + 0.5 + 8 + 40 + 8);
        CGSize size = CGSizeMake(width, height);

        NSMutableArray<SJExtendedMediaCollectionViewModel *> *m = [NSMutableArray arrayWithCapacity:items.count];
        UIColor *backgroundColor = [UIColor whiteColor];
        for ( SJVideoModel *item in items ) {
            SJExtendedMediaCollectionViewModel *vm = [[SJExtendedMediaCollectionViewModel alloc] initWithItem:item mediaTitleFont:font];
            vm.size = size;
            vm.backgroundColor = backgroundColor;
            [m addObject:vm];
        }
        _medias = m;
        
        _height = size.height;
    }
    return self;
}
@end
NS_ASSUME_NONNULL_END
