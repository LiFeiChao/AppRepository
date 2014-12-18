//
//  HomeMasterViewController.m
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-7-11.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HomeMasterViewController.h"
#import "HotProductViewController.h"
#import "DetailViewController.h"
#import "NoticeDetailViewController.h"
#import "HotProductCell.h"
#import "NoticeCell.h"
#import "Notice.h"
#import "WeatherHeadView.h"
#import "UIView+NibLoading.h"
#import "I18NControl.h"
#import "Util.h"
#import "ProductDetailViewController.h"
#import "Product.h"
#import "ProductView.h"
#import "MainViewController.h"
#import "FilterViewController.h"

#define IMAGE_CHANGED @"imageChanged"

#define ImageOffsetY  -0.0f
#define kMaxOffsetY -60.0f
#define kWindmillOrgionCenter CGPointMake(25, -25)

#define CATEGORY_CLICK @"category_click"
#define MORE_CLICK @"more_click"

static CGFloat ImageWidth  = 466.0;
static CGFloat ImageHeight  = 220.0;
@interface HomeMasterViewController (){
    //WeatherHeadView *_weatherHeadView;
    WeatherHeadView *_weatherHeadView;
    UIImageView *_windmill;
    CGPoint _windmillOrgionCenter;
    BOOL _isLoading;
    NSIndexPath *_selectedIndex;
    NSArray *detailViewControllers;
    
    
    
}
@property (strong,nonatomic) NSMutableArray *noticeArray;
@property (strong,nonatomic) NSMutableArray *hotProductArray;
@property (strong,nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) UIView *maskView;




@end

HotProductViewController *hotProductVC;
ProductDetailViewController *productDetailVC;
FilterViewController *filtVC;
UIView *detailView;

@implementation HomeMasterViewController

@synthesize mainViewController;

@synthesize btnGNS;
@synthesize btnGIS;
@synthesize btnCloud;
@synthesize btnCMD;
@synthesize btnMSecurity;
@synthesize btnUC;
@synthesize lblCurrentDate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil value:(NSInteger) x
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //welcome
    
    NSString *userName = [AppController sharedInstance].userInfo.userName;
    
    if ([[I18NControl userLanguage] isEqualToString:@"en"]) {
        userName = [AppController sharedInstance].userInfo.ename;
    }
    
    NSString * welcomeMessage = [NSString stringWithFormat:@"%@:%@",[[I18NControl bundle] localizedStringForKey:@"welcome" value:nil table:nil],userName];
    [self.welcomelable setText:welcomeMessage];
    
    [self.userHeaderImg setUserInteractionEnabled:YES];
    UITapGestureRecognizer *avatarGR=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAvatar:)];
    [self.userHeaderImg addGestureRecognizer:avatarGR];
    
    //[self.view addSubview:_weatherHeadView];
    [self.view insertSubview:_weatherHeadView belowSubview:self.tableView];
    UIImage *imgWindmill=[UIImage imageNamed:@"windmill@2x.png"];
    _windmill=[[UIImageView alloc] initWithImage:imgWindmill];
    _windmill.center=kWindmillOrgionCenter;
    [self.view addSubview:_windmill];
    self.hotProductArray=[NSMutableArray array];
    self.noticeArray=[NSMutableArray array];
    
//    ProductDetailViewController *productDetailVC = [[ProductDetailViewController alloc] initWithNibName:@"ProducDetailtViewController" bundle:nil];

    hotProductVC = [[HotProductViewController alloc] initWithNibName:@"HotProductViewController" bundle:nil];

    
    self.splitVC.detailViewController = hotProductVC;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillAppear:) name:IMAGE_CHANGED object:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    
    [self.userHeaderImg setImageWithURL:[NSURL URLWithString:[AppController sharedInstance].userInfo.avatarUrl] placeholderImage:[UIImage imageNamed:@"avatar.png"]];
    NSLog(@"Home 图片更新");
}

-(void)viewDidAppear:(BOOL)animated
{
    _userHeaderImg.layer.cornerRadius = 50;
    
    _userHeaderImg.layer.masksToBounds = YES;
    _userHeaderImg.layer.borderColor = [[UIColor colorWithRed:0.255 green:0.529 blue:0.106 alpha:1] CGColor];
    _userHeaderImg.layer.borderWidth = 1.5;
    
    [btnGNS setTitle:[[I18NControl bundle] localizedStringForKey:@"GNSTitle" value:nil table:nil]
            forState:UIControlStateNormal];
    
    
    [btnUC setTitle:[[I18NControl bundle] localizedStringForKey:@"UC&C" value:nil table:nil]
           forState:UIControlStateNormal];
    
    
    [btnGIS setTitle:[[I18NControl bundle] localizedStringForKey:@"GISTitle" value:nil table:nil]
            forState:UIControlStateNormal];
    
    
    
    
    [btnCloud setTitle:[[I18NControl bundle] localizedStringForKey:@"Cloud" value:nil table:nil]
              forState:UIControlStateNormal];
    
    [btnCMD setTitle:[[I18NControl bundle] localizedStringForKey:@"CMDTitle" value:nil table:nil]
            forState:UIControlStateNormal];
    
    
    
    [btnMSecurity setTitle:[[I18NControl bundle] localizedStringForKey:@"Managed Security" value:nil table:nil]
                  forState:UIControlStateNormal];
    
    lblCurrentDate.text = [self GetCurrentDate];
    
}

-(NSString *) GetCurrentDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate * currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init] ;
    NSInteger unitFlags = NSWeekdayCalendarUnit;
    comps = [calendar components:unitFlags fromDate:currentDate];
    int weekIndex = [comps weekday];
    NSString *lan = [I18NControl userLanguage];
    NSString * week = @"";
    
    if([lan isEqualToString:@"en"]){//判断当前的语言，进行改变
        
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
        week = [self week:weekIndex :YES];
        NSString * showstr = [NSString stringWithFormat:@"%@ %@ GTM+8",week,currentDateStr];
        return showstr;
        
    }else{
        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
        week = [self week:weekIndex :NO];
        NSString * showstr = [NSString stringWithFormat:@"%@ %@ GTM+8",week,currentDateStr];
        return showstr;
    }
    
}

-(NSString*)week:(NSInteger)week :(BOOL)isEn
{
    NSString*weekStr=@"";
    switch (week) {
        case 1:
            if(isEn)
            {
                weekStr = @"Sun.";
            }
            else
                weekStr = @"星期天";
            break;
        case 2:
            if(isEn)
            {
                weekStr = @"Mon.";
            }
            else
                weekStr = @"星期一";
            break;
        case 3:
            if(isEn)
            {
                weekStr = @"Tues.";
            }
            else
                weekStr = @"星期二";
            break;
        case 4:
            if(isEn)
            {
                weekStr = @"Wed.";
            }
            else
                weekStr = @"星期三";
        case 5:
            if(isEn)
            {
                weekStr = @"Thur.";
            }
            else
                weekStr =@"星期四";
            break;
        case 6:
            if(isEn)
            {
                weekStr = @"Fri.";
            }
            else
                weekStr = @"星期五";
            break;
        case 7:
            if(isEn)
            {
                weekStr = @"Sat.";
            }
            else
                weekStr = @"星期六";
            break;
        default:
            break;
    }
    
    return weekStr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *) GetFilterCategorIDByName:(NSString*)name
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSArray * arrayAllCategory = [defaults objectForKey:DFKeyCategoryInfo];
    //    NSString * filterstring =[NSString stringWithFormat:@"name CONTAINS[d] %@",name];
    //    NSPredicate *pre = [NSPredicate predicateWithFormat:filterstring];
    NSString * categoryId = @"";
    if(arrayAllCategory != nil )
    {
        for (NSObject * item in arrayAllCategory) {
            NSArray * categories = [item valueForKey:@"category"];
            if(categories != nil)
            {
                for (NSObject * tmp in categories) {
                    NSString * categoryname = [tmp valueForKey:@"name"];
                    if([name isEqualToString:categoryname])
                    {
                        return [tmp valueForKey:@"id"];
                    }
                    
                }
            }
        }
        
    }
    return  categoryId;
}

- (IBAction)GNSClick:(id)sender {
    
    [hotProductVC.detailViewController.view removeFromSuperview];

    
    NSString* categorName = [[I18NControl bundle] localizedStringForKey:@"GNS" value:nil table:nil];
    [AppController sharedInstance].filterCategoryID =[self GetFilterCategorIDByName:categorName];
    
    
    [mainViewController btnClick:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CATEGORY_CLICK object:nil];
    
    
//    filtVC.
//    
//    [filtVC horizMenu: itemSelectedAtIndex:1];
    
    
}

- (IBAction)UCCClick:(id)sender {
    
    [hotProductVC.detailViewController.view removeFromSuperview];
    
    NSString* categorName = [[I18NControl bundle] localizedStringForKey:@"UC&C" value:nil table:nil];
    [AppController sharedInstance].filterCategoryID =[self GetFilterCategorIDByName:categorName];
    
    [mainViewController btnClick:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CATEGORY_CLICK object:nil];
    
}

- (IBAction)GISClick:(id)sender {
    
    [hotProductVC.detailViewController.view removeFromSuperview];
    
    NSString* categorName = [[I18NControl bundle] localizedStringForKey:@"GIS" value:nil table:nil];
    [AppController sharedInstance].filterCategoryID =[self GetFilterCategorIDByName:categorName];
    
    [mainViewController btnClick:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CATEGORY_CLICK object:nil];
    
}

- (IBAction)CLOUDClick:(id)sender {
    
    [hotProductVC.detailViewController.view removeFromSuperview];
    
    NSString* categorName = [[I18NControl bundle] localizedStringForKey:@"Cloud" value:nil table:nil];
    [AppController sharedInstance].filterCategoryID =[self GetFilterCategorIDByName:categorName];
    
    [mainViewController btnClick:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CATEGORY_CLICK object:nil];
    
}

- (IBAction)CMDClick:(id)sender {
    
    [hotProductVC.detailViewController.view removeFromSuperview];
    
    NSString* categorName = [[I18NControl bundle] localizedStringForKey:@"CMD" value:nil table:nil];
    [AppController sharedInstance].filterCategoryID =[self GetFilterCategorIDByName:categorName];
    
    [mainViewController btnClick:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CATEGORY_CLICK object:nil];
    
}

- (IBAction)MSecurityClick:(id)sender {
    
    [hotProductVC.detailViewController.view removeFromSuperview];
    
    NSString* categorName = [[I18NControl bundle] localizedStringForKey:@"Managed Security" value:nil table:nil];
    [AppController sharedInstance].filterCategoryID =[self GetFilterCategorIDByName:categorName];
    
    [mainViewController btnClick:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CATEGORY_CLICK object:nil];

}

-(void) clickAvatar:(UIGestureRecognizer*) recognizer{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MORE_CLICK object:nil];
    
}

@end
