//
//  HexColor.m
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-7-24.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "HexColor.h"

@implementation HXColor (HexColorAddition)

+ (HXColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha{
    if('#' != [hexString characterAtIndex:0]){
        hexString = [NSString stringWithFormat:@"#%@", hexString];
    }
    assert(7 == hexString.length);
    
    NSString *redHex    = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(1, 2)]];
    NSString *greenHex  = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(3, 2)]];
    NSString *blueHex   = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(5, 2)]];
    
    unsigned redInt = 0;
    NSScanner *redScanner = [NSScanner scannerWithString:redHex];
    [redScanner scanHexInt:&redInt];
    
    unsigned greenInt = 0;
    NSScanner *greenScanner = [NSScanner scannerWithString:greenHex];
    [greenScanner scanHexInt:&greenInt];
    
    unsigned blueInt = 0;
    NSScanner *blueScanner = [NSScanner scannerWithString:blueHex];
    [blueScanner scanHexInt:&blueInt];
    
    HXColor *color = [HXColor colorWith8BitRed:redInt green:greenInt blue:blueInt alpha:alpha];
    
    return color;
}

+ (HXColor *)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha
{
    HXColor *color = [[HXColor alloc] init];
#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
    color = [HXColor colorWithRed:(float)red/255 green:(float)green/255 blue:(float)blue/255 alpha:alpha];
#else
    color = [HXColor colorWithCalibratedRed:(float)red/255 green:(float)green/255 blue:(float)blue/255 alpha:alpha];
#endif
    
    return color;
}


@end
