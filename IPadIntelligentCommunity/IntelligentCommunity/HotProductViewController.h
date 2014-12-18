//
//  HotProductViewController.h
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-9-2.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDGridView.h"
#import "ProductDetailViewController.h"
@interface HotProductViewController : UIViewController<IDGridViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong,nonatomic) ProductDetailViewController *detailViewController;

@end
