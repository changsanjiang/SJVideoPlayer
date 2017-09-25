//
//  NSURL+SJVideoPlayer.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/17.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "NSURL+SJVideoPlayer.h"

@implementation NSURL (SJVideoPlayer)

- (NSURL *)streamingURL {
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    components.scheme = @"streaming";
    return components.URL;
}

@end
