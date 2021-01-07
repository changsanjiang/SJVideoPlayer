//
//  SJUTUtils.m
//  LWZAudioModule-LWZAudioModule
//
//  Created by BlueDancer on 2020/12/2.
//

#import "SJUTUtils.h"
 
BOOL
SJUTRangeContains(NSRange main, NSRange sub) {
    return (main.location <= sub.location) && (main.location + main.length >= sub.location + sub.length);
}

NSRange
SJUTGetTextRange(NSAttributedString *text) {
    return NSMakeRange(0, text.length);
}
