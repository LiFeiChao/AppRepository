//
//  ForumViewController.h
//  IntelligenceCommunity
//
//  Created by IdealRD on 13-7-17.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOTableView.h"
#import "MGSplitViewController.h"
@interface ForumViewController : UIViewController<EGOTableViewDelegate>
@property (assign,nonatomic) MGSplitViewController *splitVC;
@end
