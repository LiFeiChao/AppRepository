//
//  HotProductViewController.m
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-9-2.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "HotProductViewController.h"
#import "DetailViewController.h"
#import "Product.h"
#import "ProductView.h"
#import "Util.h"
#import "UIView+NibLoading.h"
 
#define kMaxRowCount 4
#define kRowHeight 140
@interface HotProductViewController (){
    IBOutlet IDGridView *_hotProductGridView;
}
@property (strong,nonatomic) UIView *maskView;
@property (strong,nonatomic) NSMutableArray *hotProductArray;
@property (strong,nonatomic) DetailViewController *detailViewController;
@end

@implementation HotProductViewController

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
    // Do any additional setup after loading the view from its nib.
    self.hotProductArray=[NSMutableArray array];
    _hotProductGridView.col=4;
    
    _hotProductGridView.left=0;
    _hotProductGridView.top=5;
    _hotProductGridView.bottom=5;
    _hotProductGridView.hidePageControl=YES;
    [self getHotProduct];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark IDGridViewDelegate method
-(void)IDGridView:(IDGridView *)IDGridView didSelectAtIndex:(NSUInteger)index
{
    Product *product=_hotProductArray[index];
    self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    self.detailViewController.product = product;
    self.detailViewController.isPop=YES;
    
    UIImage *imgClose=[UIImage imageNamed:@"close@2x.png"];
    UIButton *btnClose=[UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.frame=(CGRect){CGPointZero, imgClose.size};
    [btnClose setImage:imgClose forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(closeDetailVC) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnClose];
    
    double delayInSeconds = .2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.detailViewController.navigationBar.topItem.leftBarButtonItem= closeBarButtonItem;
    });
    
    if(!self.maskView){
        self.maskView=[[UIView alloc] initWithFrame:(CGRect){self.view.bounds.size.width,0,504,748}];
        _maskView.backgroundColor=RGBAColor(0, 0, 0, .3);
    }
    
    UIView *detailView=self.detailViewController.view;
    detailView.frame=(CGRect){504-440,0,440,748};
    [_maskView addSubview:detailView];
    [self.view addSubview:_maskView];
   
    
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _maskView.frame=(CGRect){self.view.bounds.size.width-504,0,504,748};
    }completion:nil];
    
}

#pragma mark -
#pragma mark Custom method
-(void) getHotProduct
{
    NSDictionary *dicParams=@{@"userID":[AppController sharedInstance].userInfo.userID};
    [[AFIntelligentCommunityClient sharedClient] getPath:@"productInterface/getHotProductList" parameters:dicParams success:^(AFHTTPRequestOperation *operation, id JSON) {
        CLog(@"%@",JSON);
        
        NSArray *arrayAllProduct=JSON;
        [_hotProductArray removeAllObjects];
         NSMutableArray *arrayViews=[[NSMutableArray alloc] init];
        [arrayAllProduct enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dicProduct=obj;
            Product *product=[[Product alloc] init];
            product.productID=dicProduct[@"productID"];
            product.productName=dicProduct[@"productName"];
            product.briefIntroduction=dicProduct[@"briefIntroduction"];
            product.imageUrl=dicProduct[@"iconURL"];
            NSArray *arrayCategory=dicProduct[@"categoryArray"];
            NSMutableArray *arrayCategoryID=[[NSMutableArray alloc] init];
            NSMutableString *categoryIDString=[[NSMutableString alloc] init];
            [arrayCategory enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [arrayCategoryID addObject:arrayCategory[idx][@"categoryID"]];
                [categoryIDString appendString:arrayCategory[idx][@"categoryID"]];
                [categoryIDString appendString:@","];
            }];
            
            product.categoryArray=arrayCategoryID;
            product.categoryString=categoryIDString;
            
            ProductView *productView=(ProductView*)[ProductView loadInstanceFromNib];
            productView.product=product;
            [arrayViews addObject:productView];
             
            [_hotProductArray addObject:product];
            
            
        }];
        int rowCount=(int)_hotProductArray.count/_hotProductGridView.col;
        if(_hotProductArray.count%_hotProductGridView.col!=0){
            rowCount+=1;
        }
        
        if(rowCount>kMaxRowCount){
            rowCount=kMaxRowCount;
            _hotProductGridView.hidePageControl=NO;
        }
        _hotProductGridView.row=rowCount;
        CGRect frame = _hotProductGridView.frame;
        frame.size.height=rowCount*kRowHeight;
        _hotProductGridView.frame=frame;
        _hotProductGridView.arrayViews=arrayViews;
        [_hotProductGridView setNeedsLayout];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Util failOperation:operation.responseData]; 
    }];
}
-(void) closeDetailVC
{
    //UIView *detailView=self.detailViewController.view;
  
    
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _maskView.frame=(CGRect){self.view.bounds.size.width,0,504,748};
    }completion:^(BOOL finished) {
        [self.detailViewController.view removeFromSuperview];
        [_maskView removeFromSuperview];
    }];
}
@end
