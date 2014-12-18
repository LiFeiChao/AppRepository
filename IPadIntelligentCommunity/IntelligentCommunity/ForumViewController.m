//
//  ForumViewController.m
//  IntelligenceCommunity
//
//  Created by IdealRD on 13-7-17.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "ForumViewController.h"
#import "ForumDetialViewController.h"
#import "ForumEditViewController.h"
#import "ForumCell.h"
#import "Forum.h"
#import "UIView+NibLoading.h"
#import "Util.h"
#import "MoreViewController.h"
#import "I18NControl.h"

#define FontSize            16
#define ContentWidth        235
#define kContentTableViewCellHeight 74


@interface ForumViewController ()
{
    IBOutlet EGOTableView *_tvForum;
    
    NSMutableArray *_arrayForum;
    
    //BOOL _hasAutoSelected;//第一次自动显示第一项
}

@end

@implementation ForumViewController

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

    // ［发帖］按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 50, 50);
    [button setImage:[UIImage imageNamed:@"bj_icon"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showEditView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
   

    // 初始化数组
    _arrayForum=[[NSMutableArray alloc] init];
    
    // 消息通知
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(addPosts:) name:DFNotificationAddPosts object:nil];
    
}



-(void) viewDidAppear:(BOOL)animated
{
    if(_arrayForum.count==0){
        [_tvForum autoLoadData];
    }
    
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _tvForum = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DFNotificationAddPosts
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
// 页面滚动时回调
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_tvForum egoRefreshScrollViewDidScroll:scrollView];
}

// 滚动结束时回调
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_tvForum egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGOTableViewDelegate Methods
- (void) startLoadData:(id) sender
{
    // 获取论坛帖子列表
    [self getPostsList];
}

#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    int count=_arrayForum.count;
//    if(count>0){
//        double delayInSeconds = .2;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
//            [_tvForum selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
//            Forum *forum = _arrayForum[indexPath.row];
//            // 查看计数
//            forum.viewCount = forum.viewCount + 1;
//     
//            
//            // 转至帖子详细界面
//            ForumDetialViewController *detailVC = [[ForumDetialViewController alloc] initWithNibName:@"ForumDetialViewController" bundle:nil];
//            detailVC.title = @"贴子详细";
//            detailVC.postID = forum.postID;
//            self.splitVC.detailViewController=detailVC;
//        });
//        
//    }

    return _arrayForum.count;
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ForumCell";
    
    ForumCell *cell = (ForumCell*)[_tvForum dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (ForumCell *)[ForumCell loadInstanceFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicator"]];
    }
    
    Forum* fCell=[_arrayForum objectAtIndex:indexPath.row];
    cell.forum = fCell;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    Forum* forum=[_arrayForum objectAtIndex:indexPath.row];
//    NSString* title = forum.title;
//    CGSize contentSize = [title sizeWithFont:[UIFont systemFontOfSize:FontSize] constrainedToSize:CGSizeMake(ContentWidth, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
//    
//    return contentSize.height+CellHeight;
    
    return kContentTableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Forum *forum = _arrayForum[indexPath.row];
    
    // 查看计数
    forum.viewCount = forum.viewCount + 1;
  

    // 转至帖子详细界面
    ForumDetialViewController *detailVC = [[ForumDetialViewController alloc] initWithNibName:@"ForumDetialViewController" bundle:nil];
    detailVC.title = [[I18NControl bundle] localizedStringForKey:@"postDetail" value:nil table:nil];
    detailVC.postID = forum.postID;
    self.splitVC.detailViewController=detailVC;
}

#pragma mark - IBActions And Custom Methods
// 添加帖子后刷新列表
-(void) addPosts:(NSNotification *)notification {
    if (notification) {
        [_tvForum autoLoadData];
    }
}

// 跳转论坛编辑界面
- (void)showEditView
{
    if([self.splitVC.detailViewController isKindOfClass:[ForumDetialViewController class]]){
        ForumDetialViewController *detailVC=(ForumDetialViewController*)self.splitVC.detailViewController;
        [detailVC addForum];
    }else{
        ForumEditViewController *editVC = [[ForumEditViewController alloc] initWithNibName:@"ForumEditViewController" bundle:nil];
        editVC.postType = AddPost;
        self.splitVC.detailViewController=editVC;
    }

}

 

// 获取论坛帖子列表
-(void) getPostsList
{
    [[AFIntelligentCommunityClient sharedClient] getPath:@"ForumInterface/getPostsList"
                                              parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
            
       [_arrayForum removeAllObjects];
                                                  
       NSArray *arraytPostsList = JSON;
       [arraytPostsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           
           NSDictionary *dicPosts = obj;
           
           Forum *forum = [[Forum alloc] init];
           forum.postID = dicPosts[@"id"];                  // 帖子ID
           forum.title = dicPosts[@"title"];                // 帖子标题
           forum.createTime = dicPosts[@"createTime"];      // 发表时间
           forum.lastReplyTime = dicPosts[@"lastReplyTime"];// 最后回复时间
           forum.viewCount = [dicPosts[@"viewCount"] intValue];  // 帖子查看数
           forum.replyCount = [dicPosts[@"replyCount"] intValue];// 帖子回复数
           // 发表用户信息息
           NSDictionary *dicSubmitUser=[dicPosts objectForKey:@"submitUser"];
           User *submitUser = [[User alloc] init];
           submitUser.userID = dicSubmitUser[@"id"];
           submitUser.userName = dicSubmitUser[@"name"];
           submitUser.avatarUrl = dicSubmitUser[@"iconURL"];
           forum.submitUser = submitUser;
           
           // 最后回复用户息息
           User *lastReplyUser = [[User alloc] init];
           lastReplyUser.userID = @"";
           lastReplyUser.userName = @"";
           
           // 判断回复有无
           if (![[dicPosts objectForKey:@"lastReplyUser"] isEqual:@""]){
               NSDictionary *dicLastReplyUser=[dicPosts objectForKey:@"lastReplyUser"];
               lastReplyUser.userID = dicLastReplyUser[@"id"];
               lastReplyUser.userName = dicLastReplyUser[@"name"];
           }
           
           forum.lastReplyUser = lastReplyUser;
           [_arrayForum addObject:forum];
        }];
                                                  
        [_tvForum refreshTableView];
                                                  
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%@", operation.responseString);
        [Util failOperation:operation.responseData];   
        [_tvForum refreshTableView];
    }];
}

@end
