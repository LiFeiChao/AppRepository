//
//  MasterViewController.m
//  IntelligenceCommunity
//
//  Created by 高 欣 on 13-4-9.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "FilterViewController.h"
#import "SearchViewController.h"
#import "FavoriteViewController.h"
#import "DetailViewController.h"
#import "SVSegmentedControl.h"
#import "Product.h"
#import "ProductCell.h"
#import "FilterMenu.h"
#import "ProductCell.h"
#import "FilterMenuCell.h"
#import "IActionSheet.h"
#import "IAlertView.h"
#import "UIView+NibLoading.h"
#import "UIButton+Title.h"
#import "HorizFilter.h"
#import "Util.h"


#define FilterDefalutColor [UIColor grayColor]
#define FilterSelectedColor RGBColor(4, 114, 170)

#define kContentTableViewCellHeight 74
#define kFilterTableViewCellHeight 36
#define kFilterTableViewOffset 6
#define HorizFilterHeight 36
#define kHeadLabelWidth 82

@interface FilterViewController ()
{
    IBOutlet UIView *_horizFilterView;
    IBOutlet UIImageView *_imgArrow;
    IBOutlet UIView *_viewFilter;
    IBOutlet UIButton *_btnFilter;
    IBOutlet UIButton *_btnHot;
    IBOutlet UIButton *_btnNew;
    IBOutlet EGOTableView *_tableView;
    
    NSArray *_arrayFilteredProducts;
    NSArray *_arrayFilteredResultBackup;
    NSMutableArray *_arrayProducts;
    NSMutableArray *_arrayTableFilterItems; //过滤表数据数组
    NSMutableArray *_arrayFilterConditions;
}

- (IBAction)filterClick:(id)sender;
- (IBAction)hotClick:(id)sender;
- (IBAction)newChick:(id)sender;

@end

@implementation FilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = NSLocalizedString(@"Master", @"Master");
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // 初期化
    _arrayTableFilterItems=[[NSMutableArray alloc] init];
    _arrayFilterConditions=[[NSMutableArray alloc] init];
    _arrayProducts=[[NSMutableArray alloc] init];
    
    // 初始化筛选展开视图
    [self initHorizFilterView];
    
    [_btnHot setBackgroundImage:[UIImage imageNamed:@"zx_hover_bg"] forState:UIControlStateSelected];
    [_btnNew setBackgroundImage:[UIImage imageNamed:@"zx_hover_bg"] forState:UIControlStateSelected];
    [_btnFilter setBackgroundImage:[UIImage imageNamed:@"sx_hover_bg"] forState:UIControlStateSelected];
    [_btnFilter setTitleColor:[UIColor whiteColor]forState:UIControlStateHighlighted];
    [_btnNew setTitleColor:[UIColor whiteColor]forState:UIControlStateHighlighted];
    
    //    [_btnFilter.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    //    _btnNew.titleLabel.font = [UIFont fontWithName:@"Verdana" size:16];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    if(_arrayProducts.count==0){
        [_tableView autoLoadData];
    }
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidUnload
{
    _horizFilterView = nil;
    _btnFilter = nil;
    _viewFilter = nil;
    _btnHot = nil;
    _btnNew = nil;
    [super viewDidUnload];
}

#pragma mark - Table View


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    //自动选择第一项
    //    if(_arrayFilteredProducts.count>0){
    //
    //        double delayInSeconds = .2;
    //        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    //        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    //            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    //            [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
    //            DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    //            // 产品ID
    //            Product *product = _arrayFilteredProducts[indexPath.row];
    //            detailViewController.product = product;
    //
    //            self.splitVC.detailViewController=detailViewController;
    //        });
    //
    //    }
    return _arrayFilteredProducts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProductCell";
    
    ProductCell *cell = (ProductCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (ProductCell*)[ProductCell loadInstanceFromNib];
        cell.accessoryView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicator"]];
        cell.selectionStyle=UITableViewCellSelectionStyleGray;
        //      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    Product *product = _arrayFilteredProducts[indexPath.row];
    cell.product=product;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kContentTableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    // 产品ID
    Product *product = _arrayFilteredProducts[indexPath.row];
    detailViewController.product = product;
    
    self.splitVC.detailViewController=detailViewController;
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
// 页面滚动时回调
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_tableView egoRefreshScrollViewDidScroll:scrollView];
}

// 滚动结束时回调
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_tableView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGOTableViewDelegate Methods
- (void) startLoadData:(id) sender
{
    [self getAllProduct];
}

#pragma mark - IBActions And Custom Methods

- (IBAction)filterClick:(id)sender
{
    [_btnNew setSelected:NO];
    [_btnHot setSelected:NO];
    
    // test
    //    //如果开始没有取到菜单数据在这里重新获取
    //    if(arrayAllCategory.count==0){
    //        [self getAllCategory];
    //    }
    
    //  BOOL selectionIsExpand=[self filterIsExpand:_horizFilterView];
    BOOL selectionIsExpand= (_horizFilterView.frame.origin.y >= _viewFilter.frame.origin.y+_viewFilter.frame.size.height ) ? YES : NO;
    
    _btnFilter.selected=!selectionIsExpand;
    
    // 下拉展开与否
    if(selectionIsExpand){
        [UIView animateWithDuration:.5 animations:^{
            CGRect frame=_horizFilterView.frame;
            frame.origin.y -= _horizFilterView.frame.size.height;
            _horizFilterView.frame = frame;
            // 产品列表显示
            frame=_tableView.frame;
            frame.origin.y -= _horizFilterView.frame.size.height;
            frame.size.height += _horizFilterView.frame.size.height;
            _tableView.frame = frame;
            _imgArrow.transform=CGAffineTransformIdentity;
        }];
    }else{
        [UIView animateWithDuration:.5 animations:^{
            CGRect frame=_horizFilterView.frame;
            frame.origin.y += _horizFilterView.frame.size.height;
            _horizFilterView.frame = frame;
            // 产品列表显示
            frame=_tableView.frame;
            frame.origin.y += _horizFilterView.frame.size.height;
            frame.size.height -= _horizFilterView.frame.size.height;
            _tableView.frame = frame;
            _imgArrow.transform=CGAffineTransformMakeRotation(M_PI);
        }];
    }
    _arrayFilteredProducts = _arrayFilteredResultBackup;
    [_tableView reloadData];
}

// ［最热］显示热门产品
- (IBAction)hotClick:(id)sender
{
    [_btnHot setSelected:YES];
    [_btnNew setSelected:NO];
    
    // 分类筛选下拉展开与否
    if(_btnFilter.selected){
        [UIView animateWithDuration:.5 animations:^{
            CGRect frame=_horizFilterView.frame;
            frame.origin.y -= _horizFilterView.frame.size.height;
            _horizFilterView.frame = frame;
            // 产品列表显示
            frame=_tableView.frame;
            frame.origin.y -= _horizFilterView.frame.size.height;
            frame.size.height += _horizFilterView.frame.size.height;
            _tableView.frame = frame;
            _imgArrow.transform=CGAffineTransformIdentity;
        }];
        [_btnFilter setSelected:NO];
    }
    // 筛选列表初始设定
    for (HorizFilter* view in [_horizFilterView subviews]){
        if([view isKindOfClass:[HorizFilter class]]){
            [view reloadData];
            [view setSelectedIndex:0 animated:YES];
        }
    }
    
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"isHot == 1"];
    NSArray *filterArray=[_arrayProducts filteredArrayUsingPredicate:predicate];
    NSSortDescriptor *sorter=[[NSSortDescriptor alloc] initWithKey:@"hotOrder" ascending:YES];
    _arrayFilteredProducts=[filterArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
    //    [_arrayFilteredProducts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //        Product *product=obj;
    //        CLog(@"%d",product.hotOrder);
    //    }];
    [_tableView reloadData];
}

// ［最新］显示新产品
- (IBAction)newChick:(id)sender
{
    [_btnNew setSelected:YES];
    [_btnHot setSelected:NO];
    
    // 分类筛选下拉展开与否
    if(_btnFilter.selected){
        [UIView animateWithDuration:.5 animations:^{
            CGRect frame=_horizFilterView.frame;
            frame.origin.y -= _horizFilterView.frame.size.height;
            _horizFilterView.frame = frame;
            // 产品列表显示
            frame=_tableView.frame;
            frame.origin.y -= _horizFilterView.frame.size.height;
            frame.size.height += _horizFilterView.frame.size.height;
            _tableView.frame = frame;
            _imgArrow.transform=CGAffineTransformIdentity;
        }];
        [_btnFilter setSelected:NO];
    }
    // 筛选列表初始设定
    for (HorizFilter* view in [_horizFilterView subviews]){
        if([view isKindOfClass:[HorizFilter class]]){
            [view reloadData];
            [view setSelectedIndex:0 animated:YES];
        }
    }
    
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"isNew == 1"];
    NSArray *filterArray=[_arrayProducts filteredArrayUsingPredicate:predicate];
    NSSortDescriptor *sorter=[[NSSortDescriptor alloc] initWithKey:@"newOrder" ascending:YES];
    _arrayFilteredProducts=[filterArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
    //    [_arrayFilteredProducts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //        Product *product=obj;
    //        CLog(@"%d",product.newOrder);
    //    }];
    
    
    //_arrayFilteredProducts=[_arrayProducts filteredArrayUsingPredicate:predicate];
    
    [_tableView reloadData];
}

//跳转检索界面
- (void)showSearchView
{
    SearchViewController *searchVC = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    searchVC.title=@"搜索";
    
    [[AppController sharedInstance].navigationController pushViewController:searchVC animated:YES];
}

/*-------- ADD End   for 智慧社区 2013/07/08 ----------*/
//-(BOOL) filterIsExpand:(UIView*) filter
//{
//    return filter.frame.origin.y!=_filterTableViewHideFrame.origin.y;
//}

//-(void) getAllCategory
//{
//    [[AFIntelligentCommunityClient sharedClient] getPath:@"categoryInterface/getCategoryInfo" parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
//
//        NSDictionary *dicAllCategory = JSON;
//
//
//        /*-------- ADD Start for 智慧社区 2013/07/08 ----------*/
//        //--------------------------------
//        _arrayTableFilterItems=[[NSMutableArray alloc] init];
//        [dicAllCategory enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
////            NSLog(@"dict[%@] = %@", key, dicAllCategory[key]);
//
//            NSArray *arrayCategory = obj;
//            FilterMenu *filterMenu = [[FilterMenu alloc] init];
//            filterMenu.categoryName=@"全部";
//
//            NSMutableArray *_arrayFilterItems=[[NSMutableArray alloc] init];
//            [_arrayFilterItems addObject:filterMenu];
//
//            [arrayCategory enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                FilterMenu *filterMenu=[[FilterMenu alloc] init];
//                filterMenu.categoryID=arrayCategory[idx][@"id"];
//                filterMenu.categoryName=arrayCategory[idx][@"name"];
//                [_arrayFilterItems addObject:filterMenu];
//            }];
//            [_arrayTableFilterItems addObject:_arrayFilterItems];
//
//        }];
//
//        /*-------- ADD End   for 智慧社区 2013/07/08 ----------*/
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        CLog(@"%@",operation);
//        [[[iToast makeText:@"获取Category信息失败"] setGravity:iToastGravityCenter] show];
//    }];
//}

// 初始化筛选展开视图
-(void) initHorizFilterView
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSArray * arrayAllCategory = [defaults objectForKey:DFKeyCategoryInfo];
    
    //    //如果开始没有取到菜单数据在这里重新获取
    //    if (arrayAllCategory.count < 1) {
    //        // getAllCategory ？
    //    }
    
    [_arrayTableFilterItems removeAllObjects];
    [_arrayFilterConditions removeAllObjects];
    
    [arrayAllCategory enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSArray *arrayCategory = [obj objectForKey:@"category"];
        NSMutableArray *_arrayFilterItems=[[NSMutableArray alloc] init];
        //        FilterMenu *filterMenuFirst = [[FilterMenu alloc] init];
        //        //filterMenu.categoryName=@"全部";
        //        filterMenuFirst.categoryName=[NSString stringWithFormat:@"%@%@", [obj objectForKey:@"name"],@"  |"];
        //        [_arrayFilterItems addObject:filterMenuFirst];
        FilterMenu *filterMenuAll = [[FilterMenu alloc] init];
        filterMenuAll.categoryName=@"不限";
        [_arrayFilterItems addObject:filterMenuAll];
        [arrayCategory enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FilterMenu *filterMenu = [[FilterMenu alloc] init];
            filterMenu.categoryID = arrayCategory[idx][@"id"];
            filterMenu.categoryName = arrayCategory[idx][@"name"];
            [_arrayFilterItems addObject:filterMenu];
        }];
        
        [_arrayTableFilterItems addObject:_arrayFilterItems];
        [_arrayFilterConditions addObject:@""];
        
        // 加载筛选列表
        HorizFilter *horizFilter = [[HorizFilter alloc] initWithFrame:CGRectMake(kHeadLabelWidth, (HorizFilterHeight+1)*idx, self.view.bounds.size.width-kHeadLabelWidth, HorizFilterHeight)];
        horizFilter.dataSource = self;
        horizFilter.itemSelectedDelegate = self;
        horizFilter.tag = idx;
        [_horizFilterView addSubview:horizFilter];
        
        
        [horizFilter reloadData];
        [horizFilter setSelectedIndex:0 animated:YES];
        UILabel *lblHead=[[UILabel alloc] initWithFrame:CGRectMake(0, (HorizFilterHeight+1)*idx, kHeadLabelWidth, HorizFilterHeight)];
        lblHead.text=[NSString stringWithFormat:@"%@%@%@", @"  ",[obj objectForKey:@"name"],@"  |"];
        lblHead.textColor=RGBColor(180, 60, 60);
        lblHead.font=[UIFont systemFontOfSize:15];
        lblHead.backgroundColor = RGBColor(245, 245, 245);
        [_horizFilterView addSubview:lblHead];
        
        
    }];
    
    
    // 计算下拉展开高度
    CGRect frameFilterView = _horizFilterView.frame;
    frameFilterView.size.height = (HorizFilterHeight+1) * arrayAllCategory.count;
    
    frameFilterView.origin.y = _viewFilter.frame.size.height - frameFilterView.size.height;
    _horizFilterView.frame = frameFilterView;
    UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0,  frameFilterView.size.height-2, _horizFilterView.bounds.size.width, 2)];
    lineView.backgroundColor=DefaultBlueColor;
    //    [[lineView layer] setShadowOffset:CGSizeMake(1, 1)];
    //
    //    [[lineView layer] setShadowOpacity:.5];
    //    [[lineView layer] setShadowColor:DefaultBlueColor.CGColor];
    [_horizFilterView addSubview:lineView];
}

-(void) getAllProduct
{
    NSDictionary *dicParams=@{@"userID":[AppController sharedInstance].userInfo.userID,
                              @"language":[Util getCurrentLanguage]};
    [[AFIntelligentCommunityClient sharedClient] getPath:@"productInterface/getProductList" parameters:dicParams success:^(AFHTTPRequestOperation *operation, id JSON) {
        CLog(@"%@",JSON);
        NSArray *arrayAllProduct=JSON;
        [_arrayProducts removeAllObjects];
        [arrayAllProduct enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dicProduct=obj;
            Product *product=[[Product alloc] init];
            product.productID=dicProduct[@"productID"];
            product.productName=dicProduct[@"productName"];
            product.briefIntroduction=dicProduct[@"briefIntroduction"];
            product.imageUrl=dicProduct[@"iconURL"];
            // [新产品]&[热门产品]
            product.isNew = [dicProduct[@"isNew"] intValue];
            product.isHot = [dicProduct[@"isHot"] intValue];
            product.newOrder=[dicProduct[@"newOrder"] intValue];
            product.hotOrder=[dicProduct[@"hotOrder"] intValue];
            
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
            [_arrayProducts addObject:product];
        }];
        // 下拉刷新状态
        if (_btnHot.isSelected) {           // 最热
            NSPredicate *predicate=[NSPredicate predicateWithFormat:@"isHot == 1"];
            NSArray *filterArray=[_arrayProducts filteredArrayUsingPredicate:predicate];
            NSSortDescriptor *sorter=[[NSSortDescriptor alloc] initWithKey:@"hotOrder" ascending:YES];
            _arrayFilteredProducts=[filterArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
        }else if (_btnNew.isSelected) {     // 最新
            NSPredicate *predicate=[NSPredicate predicateWithFormat:@"isNew == 1"];
            NSArray *filterArray=[_arrayProducts filteredArrayUsingPredicate:predicate];
            NSSortDescriptor *sorter=[[NSSortDescriptor alloc] initWithKey:@"newOrder" ascending:YES];
            _arrayFilteredProducts=[filterArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
        } else {                            // 分类筛选
            _arrayFilteredProducts=[self getFilteredProducts];
            _arrayFilteredResultBackup = _arrayFilteredProducts;
        }
        /*-------- CHG End   2013/10/22 ----------*/
        
        [_tableView refreshTableView];
        
        [_tableView refreshTableView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Util failOperation:operation.responseData];
        [_tableView refreshTableView];
    }];
}


-(NSArray*) getFilteredProducts
{
    NSMutableString *predicateString=[[NSMutableString alloc] init];
    [_arrayFilterConditions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(![obj isEqualToString:@""]){
            if(predicateString.length>0){
                [predicateString appendString:@" AND "];
            }
            [predicateString appendString:@"categoryString CONTAINS "];
            [predicateString appendString:@"'"];
            [predicateString appendString:obj];
            [predicateString appendString:@"'"];
        }
    }];
    if(predicateString.length==0){
        return [_arrayProducts copy];
    }else{
        NSPredicate *predicate=[NSPredicate predicateWithFormat:predicateString];
        return [_arrayProducts filteredArrayUsingPredicate:predicate];
    }
}


#pragma mark -
#pragma mark HorizMenu Data Source
- (UIImage*) selectedItemImageForMenu:(HorizFilter *) horizMenu
{
    return [[UIImage imageNamed:@"ButtonSelected"] stretchableImageWithLeftCapWidth:16 topCapHeight:0];
}

- (UIColor*) backgroundColorForMenu:(HorizFilter *)horizMenu
{
    // #f5f5f5
    return RGBColor(245, 245, 245);
}

- (int) numberOfItemsForMenu:(HorizFilter *)horizMenu
{
    NSMutableArray *arrayFilterItem = _arrayTableFilterItems[horizMenu.tag];
    return arrayFilterItem.count;
}

- (NSString*) horizMenu:(HorizFilter *)horizMenu titleForItemAtIndex:(NSUInteger)index
{
    NSMutableArray *arrayFilterItem = _arrayTableFilterItems[horizMenu.tag];
    NSString *retCategoryName = ((FilterMenu *)[arrayFilterItem objectAtIndex:index]).categoryName;
    
    return retCategoryName;
}

#pragma mark -
#pragma mark HorizMenu Delegate
-(void) horizMenu:(HorizFilter *)horizMenu itemSelectedAtIndex:(NSUInteger)index
{
    FilterMenu *filterMenu=_arrayTableFilterItems[horizMenu.tag][index];
    //    NSString *title=filterMenu.categoryName;
    //    if([title isEqualToString:@"全部"]){
    //        [_arrayFilterConditions replaceObjectAtIndex:horizMenu.tag withObject:@""];
    //    }
    
    if(index==0){
        [_arrayFilterConditions replaceObjectAtIndex:horizMenu.tag withObject:@""];
    }
    else{
        [_arrayFilterConditions replaceObjectAtIndex:horizMenu.tag withObject:filterMenu.categoryID];
    }
    _arrayFilteredProducts=[self getFilteredProducts];
    _arrayFilteredResultBackup = _arrayFilteredProducts;
    
    // CLog(@"%@",_arrayFilteredProducts);
    [_tableView reloadData];
    
}


@end
