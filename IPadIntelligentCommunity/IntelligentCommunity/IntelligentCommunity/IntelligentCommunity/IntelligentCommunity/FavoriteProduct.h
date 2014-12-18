//
//  FavoriteProduct.h
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-4-26.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FavoriteProduct : NSManagedObject

@property (nonatomic, retain) NSString * briefIntroduction;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * productID;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSDate * storeDate;
@property (nonatomic, retain) NSString * userID;

@end
