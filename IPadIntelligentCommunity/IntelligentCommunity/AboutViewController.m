//
//  AboutViewController.m
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-4-16.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "AboutViewController.h"
#import "I18NControl.h"

#define degreesToRadian(x) (M_PI * (x) / 180.0)

@interface AboutViewController (){
    IBOutlet UILabel *_lblVersion;
    __weak IBOutlet UILabel *lbProductName;
    __weak IBOutlet UILabel *lbCompanyName;
    __weak IBOutlet UILabel *lbCopyRight;
}

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBar.topItem.title=[[I18NControl bundle] localizedStringForKey:@"AboutTitle" value:nil table:nil];
    // Do any additional setup after loading the view from its nib.
    NSString *version=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    _lblVersion.text=[NSString stringWithFormat:@"iPad\n%@：%@",[[I18NControl bundle] localizedStringForKey:@"Version" value:nil table:nil],version];
        
    lbProductName.text = [[I18NControl bundle] localizedStringForKey:@"aboutusProductName" value:nil table:nil];
    lbCompanyName.text = [[I18NControl bundle] localizedStringForKey:@"companyName" value:nil table:nil];
    lbCopyRight.text = [[I18NControl bundle] localizedStringForKey:@"copyRight" value:nil table:nil];
}
//-(void) viewWillAppear:(BOOL)animated
//{
//    [AppController sharedInstance].navigationController.navigationBarHidden=NO;
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
