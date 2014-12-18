//
//  FCaches.m
//  iOA
//
//  Created by Wills on 10-09-16.
//  Copyright 2010 Finalist. All rights reserved.
//

#import "FCaches.h"

#import "FConstants.h"


static NSString *dataPath = nil;
static NSString *imagePath = nil;


@interface FCaches (private)

+ (NSString *) pathFor:(NSString *)which;

+ (NSString *) pathForImage;

@end


#pragma mark -


@implementation FCaches


+ (NSString *) pathFor:(NSString *)which {
    if (![which length]) {
        //NSLog(@"can not init path without subpath");
        return nil;
    }
    
//    static NSString *cachePath = nil;
//    if (!cachePath) {
//        cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        cachePath = [cachePath copy];
//    }
//    NSString *tmpPath = cachePath;
    NSString *tmpPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *path = [tmpPath stringByAppendingPathComponent:which];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //NSLog(@"init path: %@ for: %@", path, which);
    
    BOOL isDirectory = YES;
    
    // if file, remove
    if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory) {
        //NSLog(@"remove file: %@", path);
        NSError *error = nil;
        [fileManager removeItemAtPath:path error:&error];
        if (error) {
            //NSLog(@"ERROR: %@", error);
        }
    }
    
    // if no directory or not directory, create
    if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory] || !isDirectory) {
        //NSLog(@"create directory: %@", path);
        NSError *error = nil;
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            //NSLog(@"ERROR: %@", error);
        }
    }
    
    return path;
}

+ (BOOL) isFileExists:(NSString *)fileName For:(NSString *)which
{
//    static NSString *cachePath = nil;
//    if (!cachePath) {
//        cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        cachePath = [cachePath copy];
//    }
//    NSString *tmpPath = cachePath;
    NSString *tmpPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    NSString *path = [[tmpPath stringByAppendingPathComponent:which] stringByAppendingPathComponent:fileName];
    //path=[path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path isDirectory:NO];
}

+ (NSString *) pathForData {
    return dataPath ? dataPath : (dataPath = [self pathFor:@"data"]);
}

+ (NSString *) pathForImage {
    //return imagePath ? imagePath : (imagePath = [[self pathFor:@"image"] retain]);
    //图片和数据都放在data里
    return imagePath ? imagePath : (imagePath = [self pathFor:@"data"]);
}


+ (BOOL) cacheData:(NSData *)data forKey:(NSString *)key {
    return [self cacheData:data forKey:key isImage:NO];
}

+ (BOOL) cacheData:(NSData *)data forKey:(NSString *)key isImage:(BOOL)isImage {
    //设置死都从data目录中读取
    isImage=NO;
//    if (![key length] || ![data length]) {
//        NSLog(@"can not save without %@", !key ? @"key" : @"data");
//        return NO;
//    }
    NSString *path = [isImage ? [self pathForImage] : [self pathForData] stringByAppendingPathComponent:key];
    //NSLog(@"save cache to: %@", path);
        
    return [data writeToFile:path atomically:YES];
    //return [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
}


+ (NSData *) dataForKey:(NSString *)key {
    return [self dataForKey:key isImage:NO];
}

+ (NSData *) dataForKey:(NSString *)key isImage:(BOOL)isImage {
    if (![key length]) {
        //NSLog(@"can not load cache without key");
        return nil;
    }
    NSString *path = [isImage ? [self pathForImage] : [self pathForData] stringByAppendingPathComponent:key];
    //NSLog(@"try to load cache from: %@", path);
    return [[NSFileManager defaultManager] contentsAtPath:path];
}


+ (BOOL) removeCaches {
    return [self removeCachesIsImage:NO];
}

+ (BOOL) removeCachesIsImage:(BOOL)isImage {
    NSString *path = isImage ? [self pathForImage] : [self pathForData];
    //NSLog(@"try to remove cache: %@", path);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        //NSLog(@"no cathe");
        return YES;
    }
    
    //NSLog(@"found cathe");
    NSError *error = nil;
    if ([[NSFileManager defaultManager]  removeItemAtPath:path error:&error] && !error) {
        NSLog(@"removed");
        //删除文件夹和里面的内容后需要重新创建一个空的文件夹
        if([[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]){
            //NSLog(@"created");
        }
        return YES;
    }
    
    //NSLog(@"can not remove");
    if (error) {
        //NSLog(@"ERROR: %@", error);
    }
    
    return NO;
}


@end
