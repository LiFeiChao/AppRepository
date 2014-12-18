//
//  FilterViewController.h
//  IntelligenceCommunity
//
//  Created by 高 欣 on 13-4-9.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import "EGOTableView.h"
#import "HorizFilter.h"
#import "MGSplitViewController.h"
@class DetailViewController;

@interface FilterViewController : UIViewController<EGOTableViewDelegate, HorizFilterDataSource, HorizFilterDelegate>
@property (retain,nonatomic) Product *product;
@property (assign,nonatomic) MGSplitViewController *splitVC;

@end
