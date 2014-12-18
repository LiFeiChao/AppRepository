//
//  DownloadViewController.m
//  IntelligenceCommunity
//
//  Created by 王飞 on 14-6-1.
//  Copyright (c) 2014年 com.ideal. All rights reserved.
//
#import "DownloadDetailViewController.h"
#import "DownloadViewController.h"
#define RCellHeight 60

@interface DownloadViewController ()

@end


@implementation DownloadViewController
@synthesize docLibTypeArray;
@synthesize tableview;
@synthesize docArray;

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
	// Do any additional setup after loading the view.
    tableview.contentInset = UIEdgeInsetsMake(0, 0, RCellHeight *2 , 0);
    [self setExtraCellLineHidden:tableview];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return RCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableCell = @"CellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             tableCell];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCell];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(docLibTypeArray != nil)
    {
        NSDictionary * LibTypes = [docLibTypeArray objectAtIndex:indexPath.row];
        
        if(LibTypes != nil)
        {
            
            //创建显示图像视图
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 35, 35)];
            
            [imgView setImage:[UIImage imageNamed:@"down"]];
            
            [cell addSubview:imgView];
            
            NSString * docLibTypeName =  [LibTypes valueForKey:@"docLibTypeName"];
            NSString * docCount = [LibTypes valueForKey:@"count"];
            
            NSString * labelvaule = [NSString stringWithFormat:@"%@  (%@)",docLibTypeName,docCount];
            // cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
            
            UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(80, 15, 300, 40)];
            lable.font =[UIFont fontWithName:@"Helvetica" size:16];
            lable.textColor =[UIColor darkGrayColor];
            lable.text = labelvaule;
            [cell addSubview:lable];
            
        }
        
        
        
    }
    
    
    return cell;
    
}


//是否分组
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //now only support production information, resource information, others
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(docLibTypeArray != nil)
    {
        return docLibTypeArray.count;
    }
    else
        return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * docLibTypeID = [[docLibTypeArray objectAtIndex:indexPath.row] valueForKey:@"docLibTypeID"];
    
    NSArray * results = nil;
    if(docArray != nil)
    {
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"docLibTypeID == %@",docLibTypeID];
        results = [docArray filteredArrayUsingPredicate:pre];
        
    }
    
    DownloadDetailViewController *detailViewController = [[DownloadDetailViewController alloc] initWithNibName:@"DownloadDetailViewController" bundle:nil];
    
    detailViewController.docArray = results;
    //detailViewController.hidesBottomBarWhenPushed = YES;
    
    
    
    
    
    
    
    
    [self.parentViewController addChildViewController:detailViewController ];
    
    UIView *downloadDateilView = detailViewController.view;
    
    downloadDateilView.frame = (CGRect){447,0,447,748};
    
    [self.parentViewController.view addSubview:downloadDateilView];
    
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        downloadDateilView.frame=(CGRect){self.view.bounds.size.width-447,0,447,748};
    }completion:nil];
    
//    [self removeFromParentViewController];
    
    
    
}


-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

@end
