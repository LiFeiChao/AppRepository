//
//  Download.h
//  IntelligenceCommunity
//
//  Created by IdealRD on 13-7-31.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Download : NSObject
@property (nonatomic,copy) NSString *docURL;
@property (nonatomic,copy) NSString* docName;
//@property (nonatomic,copy) NSString* btnDelTitle;
//@property (nonatomic,copy) NSString* btnDowTitle;

@property (nonatomic,copy) NSString *docType;
@property (nonatomic,copy) NSString *productID;
@property (nonatomic,copy) NSString* docUpdateTime;
//@property (nonatomic,copy) NSString* docType;
//0-- 未下载 1 －－ 已下载 2 －－ 更新
@property int currentStatus;
@end

