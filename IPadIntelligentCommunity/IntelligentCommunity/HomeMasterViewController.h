//
//  HomeMasterViewController.h
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-7-11.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSplitViewController.h"
@class MainViewController;

@interface HomeMasterViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (assign,nonatomic) MGSplitViewController *splitVC;

@property (strong, nonatomic) IBOutlet UILabel *welcomelable;
@property (strong, nonatomic) IBOutlet UIImageView *userHeaderImg;

@property (strong, nonatomic) MainViewController *mainViewController;

@property (strong, nonatomic) IBOutlet UIButton *btnGNS;
@property (strong, nonatomic) IBOutlet UIButton *btnUC;
@property (strong, nonatomic) IBOutlet UIButton *btnGIS;
@property (strong, nonatomic) IBOutlet UIButton *btnCloud;
@property (strong, nonatomic) IBOutlet UIButton *btnCMD;
@property (strong, nonatomic) IBOutlet UIButton *btnMSecurity;
@property (strong, nonatomic) IBOutlet UILabel *lblCurrentDate;

//@property (assign,nonatomic) MGSplitViewController *splitVC;
- (IBAction)GNSClick:(id)sender;

- (IBAction)UCCClick:(id)sender;

- (IBAction)GISClick:(id)sender;
- (IBAction)CLOUDClick:(id)sender;
- (IBAction)CMDClick:(id)sender;
- (IBAction)MSecurityClick:(id)sender;




@end
