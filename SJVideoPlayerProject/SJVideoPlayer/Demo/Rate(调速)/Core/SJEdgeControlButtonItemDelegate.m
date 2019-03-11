//
//  SJEdgeControlButtonItemDelegate.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/3/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJEdgeControlButtonItemDelegate.h"

@implementation SJEdgeControlButtonItemDelegate
- (instancetype)initWithItem:(SJEdgeControlButtonItem *)item {
    self = [super init];
    if ( !self ) return nil;
    _item = item;
    _item.delegate = self;
    [_item addTarget:self action:@selector(clickedItem:)];
    return self;
}
- (void)updatePropertiesIfNeeded:(SJEdgeControlButtonItem *)item videoPlayer:(__kindof SJBaseVideoPlayer *)player {
    if ( _updatePropertiesIfNeeded)  _updatePropertiesIfNeeded(item, player);
}
- (void)clickedItem:(SJEdgeControlButtonItem *)item {
    if ( _clickedItemExeBlock ) _clickedItemExeBlock(item);
}
@end
