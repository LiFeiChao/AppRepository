//
//  HexColor.h
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-7-24.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#define HXColor UIColor
#else
#import <Foundation/Foundation.h>
#define HXColor NSColor
#endif

@interface HXColor (HexColorAddition)

+ (HXColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;
+ (HXColor *)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha;

@end