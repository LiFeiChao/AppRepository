//
//  DocumentInfo.h
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-4-25.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DocumentInfo : NSManagedObject

@property (nonatomic, retain) NSString * docURL;
@property (nonatomic, retain) NSString * productID;
@property (nonatomic, retain) NSDate * downLoadDate;

@end
