//
//  SJVideoPlayerResourceLoader.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/11/27.
//

#import "SJVideoPlayerResourceLoader.h"
 
NS_ASSUME_NONNULL_BEGIN
@implementation SJVideoPlayerResourceLoader
static NSBundle *bundle = nil;
static NSBundle *preferredLanguageBundle = nil;
static NSBundle *enBundle = nil;
static NSBundle *zhHansBundle = nil;
static NSBundle *zhHantBundle = nil;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"SJVideoPlayer" ofType:@"bundle"]];
        NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject;
        if      ( [preferredLanguage hasPrefix:@"en"] ) {
            preferredLanguage = @"en";
        }
        else if ( [preferredLanguage hasPrefix:@"zh"] ) {
            preferredLanguage = [preferredLanguage rangeOfString:@"Hans"].location != NSNotFound ? @"zh-Hans" : @"zh-Hant";
        }
        else {
            preferredLanguage = @"en";
        }
        preferredLanguageBundle = [NSBundle bundleWithPath:[bundle pathForResource:preferredLanguage ofType:@"lproj"]];
        enBundle = [NSBundle bundleWithPath:[bundle pathForResource:@"en" ofType:@"lproj"]];
        zhHansBundle = [NSBundle bundleWithPath:[bundle pathForResource:@"zh-Hans" ofType:@"lproj"]];
        zhHantBundle = [NSBundle bundleWithPath:[bundle pathForResource:@"zh-Hant" ofType:@"lproj"]];
    });
}

+ (NSBundle *)bundle {
    return bundle;
}

+ (NSBundle *)preferredLanguageBundle {
    return preferredLanguageBundle;
}

+ (NSBundle *)enBundle {
    return enBundle;
}
 
/// 简体中文
+ (NSBundle *)zhHansBundle {
    return zhHansBundle;
}

/// 繁體中文
+ (NSBundle *)zhHantBundle {
    return zhHantBundle;
}

+ (nullable UIImage *)imageNamed:(NSString *)name {
    if ( 0 == name.length )
        return nil;
    NSString *path = [self.bundle pathForResource:name ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage imageWithData:data scale:3.0];
    return image;
}
@end
NS_ASSUME_NONNULL_END
