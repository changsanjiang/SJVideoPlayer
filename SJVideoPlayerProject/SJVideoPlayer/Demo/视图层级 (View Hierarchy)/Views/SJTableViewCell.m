//
//  SJTableViewCell.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/30.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJTableViewCell.h"
#import <Masonry/Masonry.h>

@implementation SJTableViewCell
+ (SJTableViewCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *SJTableViewCellID = @"SJTableViewCell";
    SJTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SJTableViewCellID];
    if ( !cell ) cell = [[SJTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SJTableViewCellID];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( !self ) return nil;
    self.contentView.backgroundColor = [UIColor blackColor];
    _view = [SJPlayView new];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _view.frame = self.contentView.bounds;
    [self.contentView addSubview:_view];
    return self;
}
@end
