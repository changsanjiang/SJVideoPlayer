//
//  SJVideoPlayerResourceLoader.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/11/27.
//

#import "SJVideoPlayerResourceLoader.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerResourceLoader ()
@property (nonatomic, strong) NSBundle *currentBundle;
@end

@implementation SJVideoPlayerResourceLoader
+ (SJVideoPlayerResourceLoader *)loader {
    static SJVideoPlayerResourceLoader *loader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loader = [[SJVideoPlayerResourceLoader alloc] init];
    });
    return loader;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentBundle = [SJVideoPlayerResourceLoader currentBundle];
    }
    return self;
}

+ (NSBundle *)bundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"SJVideoPlayer" ofType:@"bundle"]];
    });
    return bundle;
}

+ (NSBundle *)currentBundle {
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ( [language hasPrefix:@"en"] ) {
        language = @"en";
    }
    else if ( [language hasPrefix:@"zh"] ) {
        if ( [language containsString:@"Hans"]) {
            language = @"zh-Hans";
        }
        else {
            language = @"zh-Hant";
        }
    }
    else {
        language = @"en";
    }
    return [NSBundle bundleWithPath:[[self bundle] pathForResource:language ofType:@"lproj"]];
}

+ (nullable UIImage *)imageNamed:(NSString *)name {
    if ( 0 == name.length )
        return nil;
    NSString *path = [self.bundle pathForResource:name ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage imageWithData:data scale:3.0];
    return image;
}

+ (nullable NSString *)localizedStringForKey:(NSString *)key {
    NSString *value = [[SJVideoPlayerResourceLoader loader].currentBundle localizedStringForKey:key value:nil table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

+ (void (^)(void (^ _Nonnull)(void)))update {
    return ^(void (^block)(void)) {
        [SJVideoPlayerResourceLoader loader].currentBundle = [SJVideoPlayerResourceLoader currentBundle];
        block();
    };
}
@end
NS_ASSUME_NONNULL_END
