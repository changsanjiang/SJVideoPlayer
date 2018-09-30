//
//  SJEdgeControlLayerLoader.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJEdgeControlLayerLoader.h"

NSString *const SJVideoPlayer_ReplayText = @"SJVideoPlayer_ReplayText";
NSString *const SJVideoPlayer_PreviewText = @"SJVideoPlayer_PreviewText";
NSString *const SJVideoPlayer_PlayFailedText = @"SJVideoPlayer_PlayFailedText";
NSString *const SJVideoPlayer_NotReachablePrompt = @"SJVideoPlayer_NotReachablePrompt";
NSString *const SJVideoPlayer_ReachableViaWWANPrompt = @"SJVideoPlayer_ReachableViaWWANPrompt";

@implementation SJEdgeControlLayerLoader

+ (NSBundle *)bundle {
    static NSBundle *bundle = nil;
    if ( nil == bundle ) {
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"SJEdgeControlLayer" ofType:@"bundle"]];
    }
    return bundle;
}

+ (UIImage *)imageNamed:(NSString *)name {
    return [UIImage imageNamed:name inBundle:[self bundle] compatibleWithTraitCollection:nil];
}

+ (NSString *)localizedStringForKey:(NSString *)key {
    static NSBundle *bundle = nil;
    if ( nil == bundle ) {
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ( [language hasPrefix:@"en"] ) {
            language = @"en";
        }
        else if ( [language hasPrefix:@"zh"] ) {
            if ( [language containsString:@"Hans"] ) {
                language = @"zh-Hans";
            }
            else {
                language = @"zh-Hant";
            }
        }
        else {
            language = @"en";
        }
        bundle = [NSBundle bundleWithPath:[[self bundle] pathForResource:language ofType:@"lproj"]];
    }
    NSString *value = [bundle localizedStringForKey:key value:nil table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}
@end
