//
//  SJListViewAutoplayMediaViewModel.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/8/16.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJListViewAutoplayMediaViewModel.h"
#import <SJUIKit/NSAttributedString+SJMake.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJListViewAutoplayMediaViewModel
- (instancetype)initWithItem:(SJMeidaItemModel *)item tag:(NSInteger)tag {
    self = [super init];
    if ( self ) {
        _media = item;

        _name = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(item.username);
            make.font([UIFont boldSystemFontOfSize:16]);
            make.textColor(UIColor.whiteColor);
        }];
        
        _des = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(item.mediaTitle);
            make.font([UIFont systemFontOfSize:14]);
            make.textColor(UIColor.whiteColor);
        }];
        
        _cover = item.cover;
        
        _tag = tag;
    }
    return self;
}
@end
NS_ASSUME_NONNULL_END
