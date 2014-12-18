//
//  AboutViewController.m
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-4-16.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "AboutViewController.h"
#import "I18NControl.h"

@interface AboutViewController (){
    IBOutlet UILabel *_lblVersion;
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
    self.navigationBar.topItem.title=[[I18NControl bundle] localizedStringForKey:@"aboutUs" value:nil table:nil];
    // Do any additional setup after loading the view from its nib.
    NSString *version=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    _lblVersion.text=[NSString stringWithFormat:@"ipad版\n%@：%@",NSLocalizedString(@"Version", nil),version];
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
