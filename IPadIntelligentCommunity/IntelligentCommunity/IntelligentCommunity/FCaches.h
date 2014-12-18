//
//  FCaches.h
//  iOA
//
//  Created by Wills on 10-09-16.
//  Copyright 2010 Finalist. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FCaches : NSObject


+ (BOOL) cacheData:(NSData *)data forKey:(NSString *)key;
+ (BOOL) cacheData:(NSData *)data forKey:(NSString *)key isImage:(BOOL)isImage;

+ (NSData *) dataForKey:(NSString *)key;
+ (NSData *) dataForKey:(NSString *)key isImage:(BOOL)isImage;
+ (NSString *) pathForData;

+ (BOOL) removeCaches;
+ (BOOL) removeCachesIsImage:(BOOL)isImage;

+ (BOOL) isFileExists:(NSString *)fileName For:(NSString *)which;
@end
