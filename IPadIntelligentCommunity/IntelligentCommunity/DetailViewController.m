//
//  DetailViewController.m
//  IntelligenceCommunity
//
//  Created by 高 欣 on 13-4-9.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "IAlertView.h"
#import "iToast.h"
#import "CEGuideArrow.h"
#import "DetailViewController.h"
#import "CommentViewController.h"
#import "FavoriteProduct.h"
#import "DocumentInfo.h"
#import "DAO.h"
#import "ActionLabel.h"
#import "KDMaskGoalBar.h"
#import "FCaches.h"
#import "Download.h"
#import "DownloadCell.h"
#import "Util.h"
#import "UIView+NibLoading.h"
#import <QuartzCore/QuartzCore.h>
#import "I18NControl.h"

#define MAXFLOAT    0x1.fffffep+127f
#define TitleColor RGBColor(4, 114, 170)
#define LineColor  RGBColor(208, 208, 208)
#define MIN_FONT_SIZE    12
#define MAX_FONT_SIZE    20
#define DEF_FONT_SIZE    15
#define TITLE_INCREMENT  6
#define BASIC_ORGIN_Y    10
#define DOWNLOAD_CELL_HEIGHT    75
#define FRAME_LABEL_NAME_BASIC        CGRectMake(30, 20, 260, 30)
#define FRAME_LABEL_VALUE_BASIC       CGRectMake(65, 58, 235, 30)
#define kToolBarOffset 400
//#define kPopToolBarOffset 344
//#define FRAME_DOWNLOAD_VIEW_HIDE      CGRectMake(504, 44, 440, 660)

#define BackViewEdgeInsets UIEdgeInsetsMake(12, 12, 12, 12)
#define LineEdgeInsets UIEdgeInsetsMake(12, 12, 12, 12)
#define LabelNameEdgeInsets UIEdgeInsetsMake(20, 30, 0, 30)
#define LabelValueEdgeInsets UIEdgeInsetsMake(58, 45, 12, 45)

#define currentFontKey  @"currentFont"
#define SECTION         @"SECTION"

@interface DetailViewController ()
{
    NSArray *arraySortedKeys;
    NSDictionary *_dictProduct;
    NSMutableArray *_arrayLabel;
    
    CGFloat _scrollHeight;
    IBOutlet UIToolbar *_toolBar;
    IBOutlet UIButton *_btnIncrease;
    IBOutlet UIButton *_btnDecrease;
    IBOutlet UIButton *_btnFavorite;
    IBOutlet UIButton *_btnComment;
    IBOutlet UIButton *_btnTag;
    IBOutlet UIButton *_btnSend;
    IBOutlet UIScrollView *_scrollView;
    IBOutlet UIView *_downloadView;
    IBOutlet UITableView *_tvDownload;
    IBOutlet UIButton *_btnDownload;
    
    UIView* backView1;
    UIView* backView2;
    
    UIEdgeInsets _backViewEdgeInsets;
    UIEdgeInsets _lineEdgeInsets;
    UIEdgeInsets _lblNameEdgeInsets;
    UIEdgeInsets _lblValueEdgeInsets;
    NSMutableArray *_arrayDownload;
    
    // test
    AFURLConnectionOperation *connectOperation;
    
    CGRect _orginDownloadViewFrame;
    CGPoint _orginToolBarCenter;
    BOOL _isLoaded;
}
@property (nonatomic,strong) CEGuideArrow *guideArrow;
@property (nonatomic, strong) KDMaskGoalBar *goalBar;
@property (strong,nonatomic) UIView *maskView;
@property (strong,nonatomic) CommentViewController *commentVC;
@property (strong,nonatomic) UIActivityIndicatorView *indicatorView;

- (IBAction)favorite:(id)sender;
- (IBAction)showComment:(id)sender;
- (IBAction)expandDownload:(id)sender;

@end

@implementation DetailViewController

- (KDMaskGoalBar *) goalBar{
    if (!_goalBar) {
        
        _goalBar = [[KDMaskGoalBar alloc] initWithFrame:self.navigationController.view.frame];
    }
    //_goalBar.center=self.view.center;
    return _goalBar;
}

#pragma mark - Managing the detail item


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    

    _backViewEdgeInsets=BackViewEdgeInsets;
    _lineEdgeInsets=LineEdgeInsets;
    _lblNameEdgeInsets=LabelNameEdgeInsets;
    _lblValueEdgeInsets=LabelValueEdgeInsets;
    self.view.layer.masksToBounds=YES;
    
    self.navigationBar.topItem.title=[[I18NControl bundle] localizedStringForKey:@"productDetail" value:nil table:nil];
    
    
    self.indicatorView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem *indicatorBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicatorView];
    if(!self.isPop){
        self.navigationBar.topItem.leftBarButtonItem=indicatorBarButtonItem;
        //不是浮动模式toolbar需要做20像素的修正
        CGRect frame=_toolBar.frame;
        frame.origin.y-=20;
        _toolBar.frame=frame;
      
    }else{
        _btnTag.hidden=YES;
    }
 
    
    
    [_toolBar setBackgroundImage:[UIImage imageNamed:@"toolBarBG"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    UIImage *imgBG = [UIImage imageNamed:@"ButtonBG"];
    imgBG = [imgBG resizableImageWithCapInsets:UIEdgeInsetsMake(0,16, 0,16)];
    [_btnComment setBackgroundImage:imgBG forState:UIControlStateNormal];
    [_btnTag setBackgroundImage:imgBG forState:UIControlStateNormal];
    [_btnSend setBackgroundImage:imgBG forState:UIControlStateNormal];
    
    
    self.guideArrow=[[CEGuideArrow alloc] init];
    
    // 项目名称&界面布局排序列表
    arraySortedKeys = [NSArray arrayWithObjects:
                       @{@"productName": @"产品名称："},
                       @{@"introduction": @"产品介绍："},
                       @{@"keyword": @"产品关键词："},
                       @{@"bindService": @"可捆绑业务："},
                       @{@"priceDes": @"报价体系："},
                       @{@"successfulCase": @"成功案例："},
                       @{@"demoURL": @"演示链接："},
                       @{@"remark": @"备注："},
                       @{SECTION: @"0"},            // 区域分隔标志 (无该元素时表示不分隔区域)
                       @{@"pmName": @"产品经理："},
                       @{@"pmMobileNum": @"手机号码："},
                       @{@"pmEmail": @"电子邮箱："},
                       nil];
    
    // 初始化
    _dictProduct = [[NSDictionary alloc] init];
    _arrayLabel = [[NSMutableArray alloc] init];
    _arrayDownload = [[NSMutableArray alloc] init];
    
    // 添加背景框
    backView1 = [[UIView alloc] init];
    backView1.backgroundColor = [UIColor whiteColor];
    backView1.layer.borderColor = LineColor.CGColor;
    backView1.layer.borderWidth = 0.8;
    backView1.layer.cornerRadius = 10.0;
    
    backView2 = [[UIView alloc] init];
    backView2.backgroundColor = [UIColor whiteColor];
    backView2.layer.borderColor = LineColor.CGColor;
    backView2.layer.borderWidth = 0.8;
    backView2.layer.cornerRadius = 10.0;
    
    [_scrollView addSubview:backView1];
    [_scrollView addSubview:backView2];
    
    // 获取产品详细信息
    [self getProductInfo];
    
    [self checkFavorite];
    if(!self.isPop){
        [self getCustomKeyword];
    }


    //_downloadView.frame = _orginDownloadViewFrame;
    _downloadView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _downloadView.layer.borderWidth=1.0f;
    
    // 消息通知 
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(download:) name:DFNotificationDownload object:nil];
    [notificationCenter addObserver:self selector:@selector(downloadDelete:) name:DFNotificationDownloadDelete object:nil];

    
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 键盘切换事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyBoardEvent:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyBoardEvent:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    if(!_isLoaded){
        _isLoaded=YES;
        _orginDownloadViewFrame=_downloadView.frame;
        _orginToolBarCenter=_toolBar.center;
    }
}
-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"产品明细", @"产品明细");
    }
    return self;
}
							
- (void)viewDidUnload {
    _btnDownload = nil;
    _tvDownload = nil;
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DFNotificationDownload
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DFNotificationDownloadDelete
                                                  object:nil];
}

// 下载资料文件
-(void) download:(NSNotification *)notification {
    if (notification) {
        
        DownloadCell *cell = [[notification userInfo] objectForKey:@"downloadCell"];
        Download* download = [[notification userInfo] objectForKey:@"download"];
        NSString* _filePath = [NSString stringWithFormat:@"%@/%@",[FCaches pathForData], [download.docURL lastPathComponent]];

        //删除现有文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:_filePath error:nil];
        
        // 下载资料
        NSString *url=[download.docURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        connectOperation = [[AFURLConnectionOperation alloc] initWithRequest:request];
        connectOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:_filePath append:NO];

        // 显示进度条
        cell.proView.hidden = NO;
        
        // ［取消］按钮设置
//        [cell.btnDownload setTitle: @"" forState:UIControlStateNormal];
//        cell.btnDownload.hidden = YES;
//        [cell.btnDelete setTitle: @"取消" forState:UIControlStateNormal];
//        cell.btnDelete.hidden = NO;
//        cell.btnDelete.frame = cell.btnDownload.frame;
        
        [connectOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
         {
             float newProgress = (float)totalBytesRead / (float)totalBytesExpectedToRead;
             CLog(@"Sent %lld of %lld bytes", totalBytesRead, totalBytesExpectedToRead);
             
             // 设置进度
             [cell.proView setProgress:newProgress];
         }];

        [connectOperation setCompletionBlock:^
         {
             CLog(@"Successfully complite downloaded!");
             dispatch_async(dispatch_get_main_queue(), ^{
                 /*-------- CHG Start for 多文档下载 2013/12/04 ----------*/
                 //               NSPredicate *predicate=[NSPredicate predicateWithFormat:@"productID == %@", cell.productID];
                 NSPredicate *predicate=[NSPredicate predicateWithFormat:@"productID == %@ AND docURL == %@", cell.productID, url];
                 /*-------- CHG End   for 多文档下载 2013/12/04 ----------*/
                 NSArray *arrayData = [[DAO shareDAO] queryObjectWithEntityName:@"DocumentInfo" Predicate:predicate SortKeys:nil];
                 DocumentInfo *documentInfo;
                 if(arrayData.count){
                     documentInfo=(DocumentInfo*)arrayData[0];
                 }else{
                     documentInfo=(DocumentInfo*)[[DAO shareDAO] newInsertObject:@"DocumentInfo"];
                 }
                 
                 documentInfo.productID = cell.productID;
                 documentInfo.docURL=url;
                 documentInfo.downLoadDate=[Util NSStringDateToNSDate:download.docUpdateTime format:@"yyyy-MM-dd HH:mm:ss"];
                 [[DAO shareDAO] saveObject];
                 
                 // 隐藏进度条
                 cell.proView.hidden = YES;
                 
//                 [cell.btnDelete setTitle: @"删除" forState:UIControlStateNormal];
             });
         }];
        
        [connectOperation start];
    }
}

-(void) downloadDelete:(NSNotification *)notification {
    if (notification) {
        
        DownloadCell *cell = [[notification userInfo] objectForKey:@"downloadCell"];
        Download* download = [[notification userInfo] objectForKey:@"download"];
        NSString* _filePath = [NSString stringWithFormat:@"%@/%@",[FCaches pathForData], [download.docURL lastPathComponent]];
        
        if (connectOperation.isExecuting == YES)
        {
            [connectOperation cancel];
        }
        
        // 删除现有文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:_filePath error:nil];
        
//        cell.btnDelete.hidden = YES;
        
//        [cell.btnDownload setTitle: @"下载" forState:UIControlStateNormal];
//        cell.btnDownload.hidden = NO;
    }
}


#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayDownload.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DownloadCell";
    
    DownloadCell *cell = (DownloadCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (DownloadCell *)[DownloadCell loadInstanceFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.contentView.backgroundColor = DefaultBackgroundColor;
    }
    
    Download *fCell = [_arrayDownload objectAtIndex:indexPath.row];
    cell.download = fCell;
    cell.productID = self.product.productID;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DOWNLOAD_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tvDownload deselectRowAtIndexPath:indexPath animated:YES];
    
    // 获取资料下载地址
    Download *doc=[_arrayDownload objectAtIndex:indexPath.row];
    NSString *url =doc.docURL;
    CLog(@"docURL: %@", url);

    // 文件保存地址
    NSString *fileName=[url lastPathComponent];
    NSString *filePath=[NSString stringWithFormat:@"%@/%@",[FCaches pathForData],fileName];
    CLog(@"filePath：%@", filePath);

    // 打开文件
    if([FCaches isFileExists:fileName For:@"data"]){
        if([doc.docType intValue]==9){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"无法打开改文档"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }else{
            [self openFile:filePath type:[doc.docType intValue]];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"请先下载文档"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark -
#pragma mark IBAction method
// 返回
- (void)showBackView
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void) checkFavorite
{
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"userID == %@ AND productID == %@",[AppController sharedInstance].userInfo.userID,self.product.productID];
    
    //    NSFetchRequest *fetch=[dao fetchRequestWithEntityName:@"FavoriteProduct" Predicate:predicate SortKeys:nil];
    //    NSError *error = nil;
    //    NSArray *results = [dao.managedObjectContext executeFetchRequest:fetch error:&error];
    
    NSArray *results =[[DAO shareDAO] queryObjectWithEntityName:@"FavoriteProduct" Predicate:predicate SortKeys:nil];
    
    if (results.count) {
        [_btnFavorite setImage:[UIImage imageNamed:@"ButtonFavorite"] forState:UIControlStateNormal];
    }else{
        [_btnFavorite setImage:[UIImage imageNamed:@"ButtonUnFavorite"] forState:UIControlStateNormal];
    }
}

-(IBAction)favorite:(id)sender
{
    //DAO *dao=[[DAO alloc] init];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"userID == %@ AND productID == %@",[AppController sharedInstance].userInfo.userID ,self.product.productID];
     
//    NSFetchRequest *fetch=[dao fetchRequestWithEntityName:@"FavoriteProduct" Predicate:predicate SortKeys:nil];
//    NSError *error = nil;
//    NSArray *results = [dao.managedObjectContext executeFetchRequest:fetch error:&error];
    
    NSArray *results =[[DAO shareDAO] queryObjectWithEntityName:@"FavoriteProduct" Predicate:predicate SortKeys:nil];
    
    if (results.count) {
        //删除
        [[DAO shareDAO] deleteObject:results[0]];
        //[[DAO shareDAO] deleteObjectsWithEntityName:@"FavoriteProduct" Predicate:predicate];
        [_btnFavorite setImage:[UIImage imageNamed:@"ButtonUnFavorite"] forState:UIControlStateNormal];
        [[[iToast makeText:@"取消收藏成功"] setGravity:iToastGravityCenter] showInView:self.view];
    }else{
        //添加
        FavoriteProduct *newFavoriteProduct=(FavoriteProduct*)[[DAO shareDAO] newInsertObject:@"FavoriteProduct"];
        newFavoriteProduct.userID=[AppController sharedInstance].userInfo.userID;
        newFavoriteProduct.productID=self.product.productID;
        newFavoriteProduct.productName=self.product.productName;
        newFavoriteProduct.imageUrl=self.product.imageUrl;
        newFavoriteProduct.briefIntroduction=self.product.briefIntroduction;
        newFavoriteProduct.storeDate=[NSDate date];
        [[DAO shareDAO] saveObject];
        [_btnFavorite setImage:[UIImage imageNamed:@"ButtonFavorite"] forState:UIControlStateNormal];
        [[[iToast makeText:@"收藏成功"] setGravity:iToastGravityCenter] showInView:self.view];
    }
}

// 跳转评论界面
- (IBAction)showComment:(id)sender
{
    self.commentVC = [[CommentViewController alloc] initWithNibName:@"CommentViewController" bundle:nil];
    _commentVC.product = self.product;
    
    UIImage *imgClose=[UIImage imageNamed:@"close@2x.png"];
    UIButton *btnClose=[UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.frame=(CGRect){CGPointZero, imgClose.size};
    [btnClose setImage:imgClose forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(closeCommentVC) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnClose];
    
    double delayInSeconds = .2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.commentVC.navigationBar.topItem.leftBarButtonItem= closeBarButtonItem;
    });
    
    if(!self.maskView){
        self.maskView=[[UIView alloc] initWithFrame:(CGRect){self.view.bounds.size.width,0,504,748}];
        _maskView.backgroundColor=RGBAColor(0, 0, 0, .3);
    }
    
    UIView *commentView=self.commentVC.view;
    commentView.frame=(CGRect){504-440,0,440,748};
    [_maskView addSubview:commentView];
    [self.view addSubview:_maskView];
    
    
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _maskView.frame=(CGRect){self.view.bounds.size.width-504,0,504,748};
    }completion:nil];
}

// 展开下载界面
- (IBAction)expandDownload:(id)sender
{
    if (_downloadView.frame.origin.x == _orginDownloadViewFrame.origin.x) {
        if (self.guideArrow.isDisplayed) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DFKeyDetailGuide];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.guideArrow removeAnimated:YES];
        }
        // 显示下载界面
        [UIView animateWithDuration:0.5 animations:^{
            CGPoint center = _downloadView.center;
            center.x -= _downloadView.frame.size.width;
            _downloadView.center = center;
            
            CGPoint center2 = _btnDownload.center;
            center2.x -= _downloadView.frame.size.width;
            _btnDownload.center = center2;
            
            
        }];
        _btnDownload.transform = CGAffineTransformMakeRotation(M_PI);
    } else {
        // 隐藏下载界面
        [UIView animateWithDuration:0.5 animations:^{
            _downloadView.frame = _orginDownloadViewFrame;
            
            CGPoint center2 = _btnDownload.center;
            center2.x += _downloadView.frame.size.width;
            _btnDownload.center = center2;
            
             
        } completion:^(BOOL finished){
        }];
        _btnDownload.transform = CGAffineTransformIdentity;
    }
}

// 缩小字体
- (IBAction)decreaseFont:(id)sender
{
    if(_arrayLabel.count==0){
        return;
    }
    _btnIncrease.enabled = YES;
    
    // check允许最小字体
    UILabel* title = _arrayLabel[0];
    CGFloat curFont = title.font.pointSize - TITLE_INCREMENT;
    if (curFont - 1 == MIN_FONT_SIZE)
        _btnDecrease.enabled = NO;
    
    // 保存当前设置字号
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%f", curFont - 1] forKey:currentFontKey];
    [defaults synchronize];
    
    // 遍历显示图标
    CGFloat backView1_Y=0, backView2_Y=0;
    CGFloat backView1_H=0, backView2_H=0;
    CGFloat orginY = BASIC_ORGIN_Y;
    for (UIView *tmpView in _arrayLabel)
    {
        if ([tmpView isKindOfClass:[UILabel class]]) 
        {
            // 缩小1号字体
            UILabel* label = (UILabel*)tmpView;
            label.font = [UIFont fontWithName:label.font.fontName size:label.font.pointSize - 1];
            
            // 计算高度
            CGSize size=[label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(label.frame.size.width, MAXFLOAT)
                                   lineBreakMode:UILineBreakModeWordWrap];
            [label setFrame:CGRectMake(label.frame.origin.x, orginY, label.frame.size.width, size.height + label.font.pointSize*0.8)];
            orginY += label.frame.size.height;
            
        } else {
            if(tmpView.tag == 11){          // 隐形分割线1
                [tmpView setFrame:CGRectMake(0, orginY, 0, 0)];
                backView1_Y = orginY;
            
            }else if (tmpView.tag == 22) {  // 隐形分割线2
                [tmpView setFrame:CGRectMake(0, orginY, 0, 0)];
                backView1_H = orginY;
                
                orginY += 15;
                backView2_Y = orginY;
                
            } else {                        // 分割线
                [tmpView setFrame:CGRectMake(_lineEdgeInsets.left, orginY,self.view.bounds.size.width- _lineEdgeInsets.right-_lineEdgeInsets.left, 2)];
                orginY += 2;
            }
        }
        backView2_H = orginY;
    }
    
    // 设置滚动高度
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, orginY + 30)];
    
    // 不存在区域分隔的情况下
    if (backView1_H == 0) {
        backView1_H = backView2_H;
    }
    
    // 设置背景框坐标
    backView1.frame = CGRectMake(_backViewEdgeInsets.left,
                                 backView1_Y,
                                 self.view.bounds.size.width-_backViewEdgeInsets.left-_backViewEdgeInsets.right, backView1_H - backView1_Y);
    backView2.frame = CGRectMake(_backViewEdgeInsets.left,
                                 backView2_Y,
                                 self.view.bounds.size.width-_backViewEdgeInsets.left-_backViewEdgeInsets.right, backView2_H - backView2_Y);
}

// 放大字体
- (IBAction)increaseFont:(id)sender
{
    if(_arrayLabel.count==0){
        return;
    }
    _btnDecrease.enabled = YES;
    // check最大字体
    UILabel* title = _arrayLabel[0];
    CGFloat curFont = title.font.pointSize - TITLE_INCREMENT;

    if (curFont + 1 == MAX_FONT_SIZE)
        _btnIncrease.enabled = NO;
    
    // 保存当前设置字号
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%f",curFont + 1] forKey:currentFontKey];
    [defaults synchronize];
    
    // 遍历显示图标
    CGFloat backView1_Y=0, backView2_Y=0;
    CGFloat backView1_H=0, backView2_H=0;
    CGFloat orginY = BASIC_ORGIN_Y;
    for (UIView* tmpView in _arrayLabel)
    {
        if ([tmpView isKindOfClass:[UILabel class]])
        {
            // 放大1号字体
            UILabel* label = (UILabel*)tmpView;
            label.font = [UIFont fontWithName:label.font.fontName size:label.font.pointSize + 1];
            
            // 计算高度
            CGSize size=[label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(label.frame.size.width, MAXFLOAT)
                                   lineBreakMode:UILineBreakModeWordWrap];
            [label setFrame:CGRectMake(label.frame.origin.x, orginY, label.frame.size.width, size.height + label.font.pointSize*0.8)];
            orginY += label.frame.size.height;
            
        } else {
            if(tmpView.tag == 11){          // 隐形分割线1
                [tmpView setFrame:CGRectMake(0, orginY, 0, 0)];
                
                backView1_Y = orginY;
                
            }else if (tmpView.tag == 22) {  // 隐形分割线2
                [tmpView setFrame:CGRectMake(0, orginY, 0, 0)];
                backView1_H = orginY;
                
                orginY += 15;
                backView2_Y = orginY;
                
            } else {                        // 分割线
                [tmpView setFrame:CGRectMake(_lineEdgeInsets.left, orginY,self.view.bounds.size.width- _lineEdgeInsets.right-_lineEdgeInsets.left, 2)];
                orginY += 2;
            }
        }
        backView2_H = orginY;
    }
    
    // 设置滚动高度
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, orginY + 30)];
    
    // 不存在区域分隔的情况下
    if (backView1_H == 0) {
        backView1_H = backView2_H;
    }
    
    
    // 设置背景框坐标
    backView1.frame = CGRectMake(_backViewEdgeInsets.left,
                                 backView1_Y,
                                 self.view.bounds.size.width-_backViewEdgeInsets.left-_backViewEdgeInsets.right, backView1_H - backView1_Y);
    backView2.frame = CGRectMake(_backViewEdgeInsets.left,
                                 backView2_Y,
                                 self.view.bounds.size.width-_backViewEdgeInsets.left-_backViewEdgeInsets.right, backView2_H - backView2_Y);
    
}
- (IBAction)editTag:(id)sender
{
    [_txtTag resignFirstResponder];
    
    if (_btnTag.tag == 0) {         // 编辑标签
        _btnTag.tag = 1;
        [_btnTag setTitle:@"取 消" forState:UIControlStateNormal];
        
        // 向右移动工具栏
        [UIView animateWithDuration:0.5 animations:^{
          
            _toolBar.center = CGPointMake(_orginToolBarCenter.x-kToolBarOffset, _toolBar.center.y);
        }];
    } else {                        // 取消编辑
        _btnTag.tag = 0;
        [_btnTag setTitle:@"自定义标签" forState:UIControlStateNormal];
         
        
        if (_toolBar.frame.origin.y < _orginToolBarCenter.y){
            // 向下移动工具栏
            [UIView animateWithDuration:0.5 animations:^{
                _toolBar.center = CGPointMake(_toolBar.center.x, _orginToolBarCenter.y);
            }];
        }
        
        // 向左移动工具栏
        [UIView animateWithDuration:0.5 animations:^{
            _toolBar.center = CGPointMake(_orginToolBarCenter.x, _toolBar.center.y);
        }];
    }
}

- (IBAction)submitTag:(id)sender {
    // 多个标签用逗号或空格分隔
    NSString *strTag=[_txtTag.text stringByReplacingOccurrencesOfString:@"，" withString:@","];
    strTag=[strTag stringByReplacingOccurrencesOfString:@" " withString:@","];
    NSArray *arrayTag = [strTag componentsSeparatedByString:@","];
    
    NSMutableArray *arrayKeyWord = [[NSMutableArray alloc] init];
    for (NSString *tag in arrayTag)
    {
        if ([tag isEqualToString:@""])
            continue;
        NSDictionary *dict = @{@"keyword":tag};
        [arrayKeyWord addObject:dict];
    }
    
    if (arrayKeyWord.count>3)
    {
        [[[iToast makeText:@"一个产品不得定义多余3个自定义标签"] setGravity:iToastGravityCenter] showInView:self.view];
        
//        // 向下移动工具栏
//        [UIView animateWithDuration:0.25 animations:^{
//            _toolBar.center = CGPointMake(_toolBar.center.x, _orginToolBarCenter.y);
//        }];
        return;
    }
    
    // 请求参数
    NSDictionary *dicParams=@{@"productID":self.product.productID,
                              @"userID":[AppController sharedInstance].userInfo.userID,
                              @"keywordArray": arrayKeyWord,};
    
    // 自定义业务标签
    [[AFIntelligentCommunityClient sharedClient] postPath:@"keywordInterface/submitCustomKeyword" parameters:dicParams
                                         success:^(AFHTTPRequestOperation *operation, id JSON) {
                                             [_txtTag resignFirstResponder];
                                             [[[iToast makeText:@"自定义业务标签成功!"] setGravity:iToastGravityCenter] showInView:self.view];
                                             
                                             _btnTag.tag = 0;
                                             [_btnTag setTitle:@"建议标签" forState:UIControlStateNormal];
                                             
                                             _txtTag.text = @"";
                                             
                                             // 向下移动工具栏
                                             [UIView animateWithDuration:0.25 animations:^{
                                                 _toolBar.center = CGPointMake(_toolBar.center.x, _orginToolBarCenter.y);
                                             } completion:^(BOOL finished){
                                                 // 向左移动工具栏
                                                 [UIView animateWithDuration:0.5  animations:^{
                                                         _toolBar.center = CGPointMake(_orginToolBarCenter.x, _toolBar.center.y);
                                                 }];
                                                 
                                             }];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             CLog(@"%@",operation);
                                             [[[iToast makeText:@"自定义业务标签失败!"] setGravity:iToastGravityCenter] show];
                                         }];
}


- (void)showKeyBoardEvent:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    //因为Ipad程序是横屏的，所以取的是width值当做键盘的高度，竖屏还是取height
    CGFloat kbHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.width;
    CLog(@"kbHeight: %f", kbHeight);
    
    // 抬高工具栏
    [UIView animateWithDuration:0.25 animations:^{
        CGPoint center = _toolBar.center;
        center.y = _orginToolBarCenter.y - kbHeight;
        _toolBar.center = center;
    }];
}
- (void)hideKeyBoardEvent:(NSNotification *)notification
{
//    NSDictionary *info = [notification userInfo];
//    //因为Ipad程序是横屏的，所以取的是width值当做键盘的高度，竖屏还是取height
//    CGFloat kbHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.width;
//    CLog(@"kbHeight: %f", kbHeight);
    // 降低工具栏
    [UIView animateWithDuration:0.25 animations:^{
        CGPoint center = _toolBar.center;
        center.y = _orginToolBarCenter.y;
        _toolBar.center = center;
    }];
}

#pragma mark -
#pragma mark textFiled delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_txtTag resignFirstResponder];
    
    // 向下移动工具栏
    [UIView animateWithDuration:0.25 animations:^{
        _toolBar.center = CGPointMake(_toolBar.center.x, self.view.frame.size.height - 22);
    }];
    
    return YES;
}

#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate Methods
-(UIViewController*)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController*)controller
{
    return self;
}

- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller
{
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    return self.view.frame;
}

#pragma mark -
#pragma mark private method
// 获取产品详细信息
-(void)getProductInfo
{
    //[Util showLoadingDialog];
    if(!self.isPop){
        [self.indicatorView startAnimating];
    }
    NSDictionary *dicParams=@{@"productID":self.product.productID,
                              @"userID":[AppController sharedInstance].userInfo.userID, @"language":[Util getCurrentLanguage]};
    [[AFIntelligentCommunityClient sharedClient] postPath:@"productInterface/getProductInfo" parameters:dicParams
                                        success:^(AFHTTPRequestOperation *operation, id JSON) {
                                            CLog(@"%@",JSON);
                                            //[Util dismissDialog];
                                            [self.indicatorView stopAnimating];
                                            _dictProduct = (NSDictionary*)JSON;
                                            
                                            /*------------------------------------------------*/
                                            // 下载文档信息
                                            NSArray *arrayDoc = [_dictProduct objectForKey:@"docArray"];
                                            // 初始化下载界面
                                            [self initDownloadView:arrayDoc];
                                            /*------------------------------------------------*/
                                            
                                            // 加载界面项目
                                            [self addLabelArray];
                                            
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            CLog(@"%@",operation);
                                            //[Util dismissDialog];
                                            [self.indicatorView stopAnimating];
                                            
                                            [Util failOperation:operation.responseData];
//                                            [[[iToast makeText:@"获取产品详细信息失败"] setGravity:iToastGravityCenter] show];
                                        }];
}

-(void) getCustomKeyword
{
    NSDictionary *dicParams=@{@"productID":self.product.productID,
                              @"userID":[AppController sharedInstance].userInfo.userID};
    [[AFIntelligentCommunityClient sharedClient] postPath:@"keywordInterface/getCustomKeyword" parameters:dicParams
                                        success:^(AFHTTPRequestOperation *operation, id JSON) {
                                            CLog(@"%@",JSON);
                                            NSDictionary *keywordDic = (NSDictionary*)JSON;
                                            NSArray *keywordArray=keywordDic[@"keywordArray"];
                                            NSMutableString *keywordString=[[NSMutableString alloc] init];
                                            [keywordArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                NSDictionary *dicKeyword=obj;
                                                [keywordString appendString:dicKeyword[@"keyword"]];
                                                [keywordString appendString:@","];
                                            }];
                                            if(keywordString.length>0){
                                                _txtTag.text=[keywordString substringToIndex:keywordString.length-1];
                                            }
                                        
                                        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            CLog(@"%@",operation);
                                            [Util failOperation:operation.responseData];
                                        }];
}
// 初始化资料下载界面
-(void)initDownloadView:(NSArray *)arrayDoc
{
    [_arrayDownload removeAllObjects];
    
    // 无下载资料隐藏下载界面
    if (arrayDoc.count == 0) {
        _btnDownload.hidden = YES;
        return;
    }else{
        _btnDownload.hidden=NO;
        //显示指示按钮
        if(![[NSUserDefaults standardUserDefaults] boolForKey:DFKeyDetailGuide]){
            [self.guideArrow showInWindow:nil atPosition:CEGuideArrowPositionTypeLeftCenter inView:_btnDownload atAngle:0.0f length:100.0];
        }
    }
    
    for (int i = 0; i < arrayDoc.count; i++)
    {
        NSString *url = [arrayDoc[i] objectForKey:@"docURL"];
        if (url.length)
        {
            Download *download = [[Download alloc] init];
            
            // 资料是否存在
            if([FCaches isFileExists:[url lastPathComponent] For:@"data"]){
//                download.btnDelTitle = @"删除";
                /*-------- ADD Start for 多文档下载 2013/12/04 ----------*/
                //判断以前下载过的文档是否已被更新
                NSString *urlUTF=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSPredicate *predicate=[NSPredicate predicateWithFormat:@"productID == %@ AND docURL == %@", self.product.productID, urlUTF];
                
                NSArray *arrayData = [[DAO shareDAO] queryObjectWithEntityName:@"DocumentInfo" Predicate:predicate SortKeys:nil];
                if(arrayData.count){
                    NSString *updateDateString=[arrayDoc[i] objectForKey:@"docUpdateTime"];
                    NSDate *updateDate=[Util  NSStringDateToNSDate:updateDateString format:@"yyyy-MM-dd HH:mm:ss"];
                    CLog(@"%@", updateDate);
                    
                    // 对应唯一的文件
                    DocumentInfo *documentInfo=(DocumentInfo*)arrayData[0];
                    CLog(@"%@", documentInfo.downLoadDate);
                    
                    NSComparisonResult result=[documentInfo.downLoadDate compare:updateDate];
                    if(result==NSOrderedAscending){
//                        download.btnDowTitle= @"更新";
                    }
                }
                /*-------- ADD End   for 多文档下载 2013/12/04 ----------*/
            } else {
//                download.btnDowTitle = @"下载";
            }
            
     
            
            download.docName = [arrayDoc[i] objectForKey:@"docName"];
            download.docURL = [arrayDoc[i] objectForKey:@"docURL"];
            download.docType = [arrayDoc[i] objectForKey:@"docType"];
            download.docUpdateTime = [arrayDoc[i] objectForKey:@"docUpdateTime"];
            
            [_arrayDownload addObject:download];
        }
        
        [_tvDownload reloadData];
    }
}

// 加载界面项目
-(void)addLabelArray
{
    CGFloat orginY = BASIC_ORGIN_Y;
    
    CGFloat backView1_Y = 0, backView2_Y = 0;
    CGFloat backView1_H = 0, backView2_H = 0;
    
    NSString *tmpValue;
    NSArray *arrayKeyWord;
    NSDictionary *dictPM;

    // 获取用户设置的字号
    int curFontSize = DEF_FONT_SIZE;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int defSize = [[defaults objectForKey:currentFontKey] intValue];
    if ((defSize >= MIN_FONT_SIZE) && (defSize <= MAX_FONT_SIZE))
    {
        curFontSize = defSize;
        CLog(@"curFontSize: %d", curFontSize);
        
        // 放大缩小按钮设置
        if (defSize == MIN_FONT_SIZE)
            _btnDecrease.enabled = false;
        else if (defSize == MAX_FONT_SIZE)
            _btnIncrease.enabled = false;
    }
    
    CGRect labelNameBasicFrame=(CGRect){_lblNameEdgeInsets.left,_lblNameEdgeInsets.top,self.view.bounds.size.width-_lblNameEdgeInsets.left-_lblNameEdgeInsets.right,0};
    CGRect labelValueBasicFrame=(CGRect){_lblValueEdgeInsets.left,_lblValueEdgeInsets.top,self.view.bounds.size.width-_lblNameEdgeInsets.left-_lblValueEdgeInsets.right,0};
    
    for (NSDictionary *dictKey in arraySortedKeys)
    {
        // 获取项目名称
        NSString *key = dictKey.allKeys[0];
        NSString *keyName = dictKey.allValues[0];
        
        // Check该字段内容有无
        if ([key isEqualToString: SECTION]) {               // 区域分隔标志
            ;
        } else if ([key isEqualToString:@"keyword"]) {      // 产品关键字数组
            arrayKeyWord = [_dictProduct objectForKey:@"keywordArray"];
            if (arrayKeyWord.count == 0)
                continue;
            
        } else if ([key isEqualToString:@"pmName"]          // 产品经理相关信息
                   ||[key isEqualToString:@"pmMobileNum"]
                   ||[key isEqualToString:@"pmEmail"]) {
            
            dictPM = [_dictProduct objectForKey:@"productManager"];
            tmpValue = [dictPM objectForKey:key];
            
            if (!tmpValue.length)
                continue;
        } else {
            tmpValue = [_dictProduct objectForKey:key];
            if (!tmpValue.length)
                continue;
        }
        
        //------------ 设置分隔区域 ------------
        if ([key isEqualToString:@"SECTION"]) {
            
            // 删除最后分隔线
            [_arrayLabel removeLastObject];
            
            // 添加隐形分隔线2
            UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, orginY, 0, 0)];
            imgView.tag = 22;
            [_arrayLabel addObject:imgView];
            
            // 背景框坐标
            backView1_H = orginY;
            
            // 间距
            orginY += 15;
            backView2_Y = orginY;
            
            continue;
        }
        
        // 标题：产品名称
        if ([key isEqualToString:@"productName"]) {
            
            UILabel *lblName = [[UILabel alloc] initWithFrame:labelNameBasicFrame];
            lblName.backgroundColor = [UIColor clearColor];
            lblName.font = [UIFont fontWithName:@"Helvetica-Bold" size:curFontSize + TITLE_INCREMENT];
            lblName.textAlignment = UITextAlignmentCenter;
            lblName.textColor = TitleColor;
            lblName.numberOfLines = 0;
            lblName.text = tmpValue;
            
            // 计算高度
            CGSize size=[tmpValue sizeWithFont:lblName.font constrainedToSize:CGSizeMake(lblName.frame.size.width, MAXFLOAT)
                          lineBreakMode:UILineBreakModeWordWrap];
            [lblName setFrame:CGRectMake(lblName.frame.origin.x, orginY, lblName.frame.size.width, size.height + curFontSize*1.0)];
            orginY += (size.height + curFontSize*1.0);
            
            // 加入显示图标队列
            [_arrayLabel addObject:lblName];
            
            // 添加隐形分隔线1
            UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, orginY, 0, 0)];
            imgView.tag = 11;
            [_arrayLabel addObject:imgView];
            
            // 背景框坐标
            backView1_Y = orginY;

            continue;
        }
        
        //------------ 设置项目名称 ------------
        UILabel *lblName =[[UILabel alloc] initWithFrame:labelNameBasicFrame];
        lblName.backgroundColor = [UIColor clearColor];
        lblName.font = [UIFont fontWithName:@"Helvetica-Bold" size:curFontSize];
        lblName.textColor = [UIColor darkGrayColor];
        lblName.text = keyName;
        
        // 计算高度
        CGSize size=[lblName.text sizeWithFont:lblName.font constrainedToSize:CGSizeMake(lblName.frame.size.width, MAXFLOAT)
                                 lineBreakMode:UILineBreakModeWordWrap];
        [lblName setFrame:CGRectMake(lblName.frame.origin.x, orginY, lblName.frame.size.width, size.height + curFontSize*0.8)];
        orginY += lblName.frame.size.height;
        
        // 加入显示图标队列
        [_arrayLabel addObject:lblName];
        
        //------------ 设置项目内容 ------------
        if ([key isEqualToString:@"pmMobileNum"] || [key isEqualToString:@"pmEmail"] || [key isEqualToString:@"demoURL"]) {     
            ActionLabel *actLabel = [[ActionLabel alloc] initWithFrame:labelValueBasicFrame];
            actLabel.backgroundColor = [UIColor clearColor];
            actLabel.font = [UIFont fontWithName:@"Helvetica" size:curFontSize];
            actLabel.textColor = [UIColor blueColor];
   //       actLabel.numberOfLines = 0;
            actLabel.text = tmpValue;
            
            // 电话/邮件/网页
            if ([key isEqualToString:@"pmMobileNum"])
                actLabel.type = @"tel";
            else if ([key isEqualToString:@"pmEmail"])
                actLabel.type = @"mail";
            else
                actLabel.type = @"web";
            
            // 计算高度
            size=[tmpValue sizeWithFont:actLabel.font constrainedToSize:CGSizeMake(actLabel.frame.size.width, MAXFLOAT)
                          lineBreakMode:UILineBreakModeWordWrap];
            [actLabel setFrame:CGRectMake(actLabel.frame.origin.x, orginY, actLabel.frame.size.width, size.height + curFontSize*0.8)];
            orginY += actLabel.frame.size.height;
            
            // 加入显示图标队列
            [_arrayLabel addObject:actLabel];
            
        } else {
            UILabel *lblValue = [[UILabel alloc] initWithFrame:labelValueBasicFrame];
            lblValue.backgroundColor = [UIColor clearColor];
            lblValue.font = [UIFont fontWithName:@"Helvetica" size:curFontSize];
            lblValue.textColor = [UIColor darkGrayColor];
            lblValue.numberOfLines = 0;
            lblValue.text = tmpValue;
            
            // 产品关键字数组
            if ([key isEqualToString:@"keyword"])
            {
                NSMutableString *mstr = [[NSMutableString alloc] init];
                for (NSDictionary *dict in arrayKeyWord) {
                    tmpValue = [dict objectForKey:key];
                    if (!tmpValue.length)
                        continue;
                    // 空格分隔
                    [mstr appendString:[NSString stringWithFormat:@"%@  ", tmpValue]];
                }
                
                lblValue.text = [mstr stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            
            // 计算高度
            size=[lblValue.text sizeWithFont:lblValue.font constrainedToSize:CGSizeMake(lblValue.frame.size.width, MAXFLOAT)
                          lineBreakMode:UILineBreakModeWordWrap];
            
            [lblValue setFrame:CGRectMake(lblValue.frame.origin.x, orginY, lblValue.frame.size.width, size.height + curFontSize*0.8)];
            orginY += lblValue.frame.size.height;
            
            // 加入显示图标队列
            [_arrayLabel addObject:lblValue];
        }
        
        //------------ 设置分隔线 ------------
        UIImage *imgLine = [UIImage imageNamed: @"dotline"];
        imgLine = [imgLine resizableImageWithCapInsets:UIEdgeInsetsMake(0,0,0,0)];
        UIImageView *imgView=[[UIImageView alloc] initWithImage:imgLine];
        [imgView setFrame:CGRectMake(_lineEdgeInsets.left, orginY,self.view.bounds.size.width- _lineEdgeInsets.right-_lineEdgeInsets.left, 2)];
        orginY += 2;
        
        [_arrayLabel addObject:imgView];
        
        // 背景框坐标
        backView2_H = orginY;
    }
    
    // 删除队列最后的分隔线
    [_arrayLabel removeLastObject];
    
    // 设置背景框坐标
    if (backView1_H == 0 ||             // 不存在区域分隔标志的情况下
        backView2_H <= backView2_Y)     // 特殊:区域分隔标志在队列的最后（或分隔标志后的数据值都为空）
    {
        [backView2 removeFromSuperview];
        backView1_H = backView2_H;
    }
    // 设置背景框坐标
    backView1.frame = CGRectMake(_backViewEdgeInsets.left,
                                 backView1_Y,
                                 self.view.bounds.size.width-_backViewEdgeInsets.left-_backViewEdgeInsets.right, backView1_H - backView1_Y);
    backView2.frame = CGRectMake(_backViewEdgeInsets.left,
                                 backView2_Y,
                                 self.view.bounds.size.width-_backViewEdgeInsets.left-_backViewEdgeInsets.right, backView2_H - backView2_Y);

    // 遍历显示图标
    for (UILabel *label in _arrayLabel) {
        [_scrollView addSubview:label];
    }
    
    // 计算_scrollView高度
    _scrollHeight = orginY + 30;
    
    // 设置滚动高度
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, _scrollHeight)];
    
}

// 打开文件
-(void) openFile:(NSString*) filePath type:(int) docType
{
    NSURL *fileUrl=[NSURL fileURLWithPath:filePath];
    UIDocumentInteractionController *docController = [UIDocumentInteractionController interactionControllerWithURL:fileUrl];
    docController.delegate = self;

    switch (docType) {
        case 0:     // 表示txt文档
            docController.UTI = @"public.text";
            break;
        case 1:     // 表示word文档
            docController.UTI = @"com.microsoft.word.doc";
            break;
        case 2:     // 表示excel文档
            docController.UTI = @"com.microsoft.excel.xls";
            break;
        case 3:     // 表示ppt文档
            docController.UTI = @"com.microsoft.powerpoint.ppt";
            break;
        case 4:     // 表示pdf文档
            docController.UTI = @"com.adobe.pdf";
            break;
        case 5:     // 表示图片格式文档
            docController.UTI = @"public.image";
            break;
        case 6:
            docController.UTI =@"com.pkware.zip-archive";
            break;
        case 9:     // 表示其他
            docController.UTI = @"public.item";
            break;
        default:
            break;
    }

    [docController presentPreviewAnimated:YES];
}
-(void) closeCommentVC
{
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _maskView.frame=(CGRect){self.view.bounds.size.width,0,504,748};
    }completion:^(BOOL finished) {
        [self.commentVC.view removeFromSuperview];
        [_maskView removeFromSuperview];
    }];
}
@end
