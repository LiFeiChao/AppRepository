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

#define ImageOffsetY  -0.0f
#define kMaxOffsetY -60.0f
#define kWindmillOrgionCenter CGPointMake(25, -25)
static CGFloat ImageWidth  = 466.0;
static CGFloat ImageHeight  = 220.0;
@interface HomeMasterViewController (){
    //WeatherHeadView *_weatherHeadView;
    WeatherHeadView *_weatherHeadView;
    UIImageView *_windmill;
    CGPoint _windmillOrgionCenter;
    BOOL _isLoading;
    NSIndexPath *_selectedIndex;
    
}
@property (strong,nonatomic) NSMutableArray *noticeArray;
@property (strong,nonatomic) NSMutableArray *hotProductArray;
@property (strong,nonatomic) IBOutlet UITableView *tableView;
@end

@implementation HomeMasterViewController

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
    /*
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"热门推荐" style:UIBarButtonItemStylePlain target:self action:@selector(showHotProduct:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    */
    
    
    self.tableView.backgroundColor = [UIColor clearColor];
    _weatherHeadView=(WeatherHeadView*)[WeatherHeadView loadInstanceFromNib];
    //_weatherHeadView.weatherImage.layer.anchorPoint=CGPointMake(0.5, 0);
    _weatherHeadView.frame = CGRectMake(0, ImageOffsetY, ImageWidth, ImageHeight);
    
    
    //[self.view addSubview:_weatherHeadView];
    [self.view insertSubview:_weatherHeadView belowSubview:self.tableView];
    UIImage *imgWindmill=[UIImage imageNamed:@"windmill@2x.png"];
    _windmill=[[UIImageView alloc] initWithImage:imgWindmill];
    _windmill.center=kWindmillOrgionCenter;
    [self.view addSubview:_windmill];
    self.hotProductArray=[NSMutableArray array];
    self.noticeArray=[NSMutableArray array];
    //先添加一个空的公告信息挡住东西
//    Notice *notice=[[Notice alloc] init];
//    notice.noticeID=@"";
//    notice.noticeTitle=@"";
//    notice.createTime=@"";
//    [_noticeArray addObject:notice];
    
    
//    Notice *notice0=[[Notice alloc] init];
//    Notice *notice1=[[Notice alloc] init];
//    notice0.noticeTitle=@"热烈祝贺xxx产品用户突破1000万！";
//    notice0.createTime=@"2013-07-16 12:00:00";
//    notice1.noticeTitle=@"测试2";
//    notice1.createTime=@"2013-07-16 8:00:00";
//    [self.noticeArray addObject:notice0];
//    [self.noticeArray addObject:notice1];
    //添加热门产品的信息到公告信息里
    //[self.noticeArray insertObject:self.hotProductArray atIndex:0];
    // Do any additional setup after loading the view from its nib.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHotProduct:) name:DFNotificationHotProductTaped object:nil];
    //[self showWindmill];
    //[self getAllProduct];
    //[self getNotice];
    //[self getTodayWeather];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count;
    switch (section) {
        case 0:
            count = 1;
            break;
        case 1:
            count=[_noticeArray count];
            break;
        default:
            count = 1;
            break;
    }
    return count;
	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        static NSString *headIdentifier =@"TableHead";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:headIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headIdentifier];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.backgroundColor=[UIColor clearColor];
        }
        return cell;
    }
//    else if(indexPath.section==1){
//        HotProductCell *hotProductCell=(HotProductCell*)[HotProductCell loadInstanceFromNib];
//        hotProductCell.hotProductArray=self.hotProductArray;
//        return hotProductCell;
//    }
    else{
        static NSString *cellIdentifier =@"TableCell";
        NoticeCell *cell = (NoticeCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell=(NoticeCell*)[NoticeCell loadInstanceFromNib];
            cell.accessoryView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicator"]];
            cell.selectionStyle=UITableViewCellSelectionStyleGray;
        }
        Notice *notice = _noticeArray[indexPath.row];
        cell.notice=notice;
        return cell;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section==1){
        UIView *headerView=[[UIView alloc] initWithFrame:(CGRect){CGPointZero,self.view.bounds.size.width,28}];
        headerView.backgroundColor=RGBColor(18, 139, 198);
        UILabel *lblHeader=[[UILabel alloc] initWithFrame:(CGRect){14,2,100,24}];
        
        lblHeader.text=[[I18NControl bundle] localizedStringForKey:@"announceList" value:nil table:nil];
        lblHeader.textColor=[UIColor whiteColor];
        lblHeader.backgroundColor=[UIColor clearColor];
        [headerView addSubview:lblHeader];
        return headerView;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==1){
        return 28;
    }
    return 0;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
		return ImageHeight;
//    else if(indexPath.section == 1){
//        return 100;
//    }
    else{
		return 60.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1){
        _selectedIndex=indexPath;
        Notice *notice = _noticeArray[indexPath.row];
        NoticeDetailViewController *noticeDetailVC=[[NoticeDetailViewController alloc] initWithNibName:@"NoticeDetailViewController" bundle:nil];
        noticeDetailVC.notice=notice;
        self.splitVC.detailViewController=noticeDetailVC;
    }
}
#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateImg];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat yOffset   = _tableView.contentOffset.y;
    if(yOffset<kMaxOffsetY){//小于这个值则要刷新页面数据
        
        [self refreshAllData];
    }
}
#pragma mark - Custom Method
- (void)updateImg {
    CGFloat yOffset   = _tableView.contentOffset.y;
    
    if (yOffset <= 0) {
        
        //CGFloat factor = ((ABS(yOffset)+ImageHeight)*ImageWidth)/ImageHeight;
        CGFloat factor=1.0f;
        if(yOffset<=-60){
            factor=1.0f+ABS(yOffset+60)/300.0f;
        }
        _weatherHeadView.weatherImage.transform=CGAffineTransformMakeScale(factor, factor);
        CGRect frame=_weatherHeadView.frame;
        frame.origin.y=ImageOffsetY+ABS(yOffset)/2;
        _weatherHeadView.frame=frame;

        if(!_isLoading){
            _windmill.transform=CGAffineTransformMakeRotation(yOffset/10);
            if(yOffset>=kMaxOffsetY){
                _windmill.center=CGPointMake(kWindmillOrgionCenter.x, kWindmillOrgionCenter.y+yOffset*(-1));
            }
        }
        
        
    } else {
        CGRect f = _weatherHeadView.frame;
        f.origin.y = -yOffset+ImageOffsetY;
        _weatherHeadView.frame = f;
    }
    
}



-(void) getNotice
{
    NSDictionary *dicParams=@{@"userID":[AppController sharedInstance].userInfo.userID};
    [[AFIntelligentCommunityClient sharedClient] getPath:@"NoticeInterface/getNoticeList" parameters:dicParams success:^(AFHTTPRequestOperation *operation, id JSON) {
        CLog(@"%@",JSON);
        NSArray *arrayNotice=JSON;
        [_noticeArray removeAllObjects];
        [arrayNotice enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dicNotice=obj;
            Notice *notice=[[Notice alloc] init];
            notice.noticeID=dicNotice[@"id"];
            notice.noticeTitle=dicNotice[@"title"];
            notice.createTime=dicNotice[@"createTime"];
            [_noticeArray addObject:notice];
        }];
        [_tableView reloadData];
        [self hideWindmill];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Util failOperation:operation.responseData];
        [self hideWindmill];
    }];
}


-(void) showHotProduct:(id) sender
{
    HotProductViewController *hotProductVC=[[HotProductViewController alloc] initWithNibName:@"HotProductViewController" bundle:nil];
    self.splitVC.detailViewController=hotProductVC;
}

 


-(void) rotateWindmill
{
    _windmill.transform=CGAffineTransformIdentity;
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = .6f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = NSIntegerMax;
    [_windmill.layer addAnimation:rotationAnimation forKey:@"rotate"];
}
-(void) refreshAllData
{
    _isLoading=YES;
    [_weatherHeadView getTodayWeather];
    [self rotateWindmill];
    [self getNotice];
}

-(void) showWindmill
{
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGPointMake(kWindmillOrgionCenter.x, kWindmillOrgionCenter.y-kMaxOffsetY) ;
    }completion:^(BOOL finished) {
    }];
    [self rotateWindmill];
}
-(void) hideWindmill
{
    _isLoading=NO;
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _windmill.center= kWindmillOrgionCenter;
    }completion:^(BOOL finished) {
        [_windmill.layer removeAllAnimations];
    }];
}

@end
