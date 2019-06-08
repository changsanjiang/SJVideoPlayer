//
//  SJMediaTableViewModel.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJMediaTableViewModel.h"
#import <SJUIKit/NSAttributedString+SJMake.h>

NSInteger const SJMediaCoverTag = 101;

@implementation SJMediaTableViewModel
- (instancetype)initWithItem:(SJMeidaItemModel *)item {
    self = [super init];
    if ( self ) {
        _coverTag = SJMediaCoverTag;
        _url = item.URL;
        _cover = item.cover;
        _avatar = item.avatar;

        _medianame = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.textColor([UIColor blackColor]);
            make.font([UIFont boldSystemFontOfSize:16]);
            make.append(item.medianame);
        }];
        
        _username = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.textColor([UIColor blackColor]);
            make.font([UIFont systemFontOfSize:14]);
            make.append(item.username);
        }];
        
        CGFloat coverWidth = UIScreen.mainScreen.bounds.size.width - 40;
        CGFloat coverHeight = coverWidth * 9 / 16.0;
        
        _height = 16 + coverHeight + 8 + [_medianame sj_textSizeForPreferredMaxLayoutWidth:coverWidth].height + 8 + 0.5 + 8 + 40 + 8 + 8;
    }
    return self;
}
@end
