//
//  SJVideoCellViewModel.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJVideoCellViewModel.h"
#import <SJUIKit/NSAttributedString+SJMake.h>
 
@implementation SJVideoCellViewModel
- (instancetype)initWithItem:(SJVideoModel *)item {
    self = [super init];
    if ( self ) { 
        _url = item.URL;
        _cover = item.cover;
        _avatar = item.avatar;

        _mediaTitle = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.textColor([UIColor blackColor]);
            make.font([UIFont boldSystemFontOfSize:16]);
            make.append(item.mediaTitle);
        }];
        
        _username = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.textColor([UIColor blackColor]);
            make.font([UIFont systemFontOfSize:14]);
            make.append(item.username);
        }];
        
        CGFloat coverWidth = UIScreen.mainScreen.bounds.size.width - 40;
        CGFloat coverHeight = coverWidth * 9 / 16.0;
        
        _height = 16 + coverHeight + 8 + [_mediaTitle sj_textSizeForPreferredMaxLayoutWidth:coverWidth].height + 8 + 0.5 + 8 + 40 + 8 + 8;
    }
    return self;
}
@end
