//
//  SJTableViewCellHasCollectionView.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/30.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJTableViewCellHasCollectionView.h"
#import <Masonry/Masonry.h>

@implementation SJTableViewCellHasCollectionView
+ (SJTableViewCellHasCollectionView *)cellWithTableView:(UITableView *)tableView {
    static NSString *SJTableViewCellHasCollectionViewID = @"SJTableViewCellHasCollectionView";
    SJTableViewCellHasCollectionView *cell = [tableView dequeueReusableCellWithIdentifier:SJTableViewCellHasCollectionViewID];
    if ( !cell ) cell = [[SJTableViewCellHasCollectionView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SJTableViewCellHasCollectionViewID];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( !self ) return nil;
    self.contentView.backgroundColor = [UIColor blackColor];
    _view = [SJHasCollectionView new];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _view.frame = self.contentView.bounds;
    [self.contentView addSubview:_view];
    return self;
}
@end
