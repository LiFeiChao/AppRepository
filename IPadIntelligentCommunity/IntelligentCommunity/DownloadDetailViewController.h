//
//  DownloadDetailViewController.h
//  IntelligenceCommunity
//
//  Created by 王飞 on 14-6-1.
//  Copyright (c) 2014年 com.ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadCell.h"
#import "UIView+NibLoading.h"
#import "Download.h"
#import "FCaches.h"
#import "DAO.h"
#import "DocumentInfo.h"
#import "IAlertView.h"

@interface DownloadDetailViewController : UIViewController<UITableViewDataSource
, UITableViewDelegate,UIDocumentInteractionControllerDelegate>
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;

- (IBAction)GoBack:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableview;


@property NSMutableArray * downloadArray;
@property NSArray * docArray;
@end
