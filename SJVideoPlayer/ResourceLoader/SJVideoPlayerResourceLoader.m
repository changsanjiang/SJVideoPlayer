//
//  SJVideoPlayerResourceLoader.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/11/27.
//

#import "SJVideoPlayerResourceLoader.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJVideoPlayerResourceLoader
+ (NSBundle *)bundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"SJVideoPlayer" ofType:@"bundle"]];
    });
    return bundle;
}

+ (nullable UIImage *)imageNamed:(NSString *)name {
    if ( 0 == name.length )
        return nil;
    int scale = (int)UIScreen.mainScreen.scale;
    if ( scale < 2 ) scale = 2;
    else if ( scale > 3 ) scale = 3;
    NSString *n = [NSString stringWithFormat:@"%@@%dx.png", name, scale];
    return [UIImage imageWithContentsOfFile:[self.bundle pathForResource:n ofType:nil]];
}

+ (nullable NSString *)localizedStringForKey:(NSString *)key {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
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
    });
    NSString *value = [bundle localizedStringForKey:key value:nil table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}
@end
NS_ASSUME_NONNULL_END
