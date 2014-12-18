//
//  ForumDetialViewController.m
//  IntelligenceCommunity
//
//  Created by IdealRD on 13-7-17.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "ForumDetialViewController.h"
#import "UIView+NibLoading.h"
#import "PostDetailCell.h"
#import "PostDetail.h"
#import "PostCell.h"
#import "Util.h"
#import "I18NControl.h"

#define CellHeight_Post          133
#define CellHeight_Reply         72


@interface ForumDetialViewController ()
{
    IBOutlet EGOTableView *_tvDetail;

    NSMutableArray *_arrayReply;    
}
@property (strong,nonatomic) UIView *maskView;
@property (strong,nonatomic) IDGridView *imageGridView;
//@property (strong,nonatomic) ForumEditViewController *forumEditVC;
//@property (strong, nonatomic) IBOutlet EGOTableView *_tvDetail;
@end

@implementation ForumDetialViewController

 

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
    
//    UIBarButtonItem *btnSend = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
//                                                               target:self
//                                                               action:@selector(replyPost)];
//    self.navigationItem.rightBarButtonItem = btnSend;
    self.navigationBar.topItem.title=[[I18NControl bundle] localizedStringForKey:[[I18NControl bundle] localizedStringForKey:@"postDetail" value:nil table:nil] value:nil table:nil];
    // ［回复］按钮
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRight.frame = CGRectMake(0, 0, 46, 42);
    [btnRight setImage:[UIImage imageNamed:@"pl_icon"] forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(replyPost) forControlEvents:UIControlEventTouchUpInside];
    self.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    
 
    
    // 初始化
    _arrayReply=[[NSMutableArray alloc] init];
    
    // 消息通知
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(replyPosts:) name:DFNotificationReplyPosts object:nil];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    if(_arrayReply.count==0){
        [_tvDetail autoLoadData];
    }
    
    [super viewDidAppear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    _tvDetail = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DFNotificationReplyPosts
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
    [_tvDetail egoRefreshScrollViewDidScroll:scrollView];
}

// 滚动结束时回调
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_tvDetail egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGOTableViewDelegate Methods
- (void) startLoadData:(id) sender
{
    // 获取帖子详细信息
    [self getPostsInfo];
}

#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayReply.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *PostCellIdentifier = @"PostCell";
    static NSString *ReplyCellIdentifier = @"ReplyCell";
    
    PostDetail* fCell = [_arrayReply objectAtIndex:indexPath.row];
    if (indexPath.row == 0)
    {
        PostCell *cell = (PostCell*)[_tvDetail dequeueReusableCellWithIdentifier:PostCellIdentifier];
        if (cell == nil) {
            cell = (PostCell *)[PostCell loadInstanceFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = DefaultBackgroundColor;
            cell.delegate=self;
        }
        cell.postDetail = fCell;
        
        return cell;
        
    } else {
        PostDetailCell *cell = (PostDetailCell*)[_tvDetail dequeueReusableCellWithIdentifier:ReplyCellIdentifier];
        if (cell == nil) {
            cell = (PostDetailCell *)[PostDetailCell loadInstanceFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = DefaultBackgroundColor;
            cell.delegate=self;
        }
        cell.postDetail = fCell;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retHegiht;
    
    PostDetail* detail=[_arrayReply objectAtIndex:indexPath.row];
    // test
    if (indexPath.row == 0){
        NSString* content = detail.postContent;
        CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(460, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
        retHegiht = contentSize.height+CellHeight_Post;
        
        // test
        NSLog(@"%f", contentSize.height);        
        
        // test  存在插图
        if (detail.pictures.count > 0)
        {
            retHegiht += 78;
        }
        // test
        NSLog(@"retHegiht 1: %f", retHegiht);
        
    } else {
        NSString* content = detail.postContent;
        CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(396, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
        retHegiht = contentSize.height+CellHeight_Reply;
        
        // test
        NSLog(@"%f", contentSize.height);
        
        // test 存在插图
        if (detail.pictures.count > 0)
        {
            retHegiht += 68;
        }
        else
        {
            if (contentSize.height < 43)
            {
                retHegiht = 112;
            }
        }
        
        // test
        NSLog(@"retHegiht 2: %f", retHegiht);
    }
    return retHegiht;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tvDetail deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - PostDetailCellDelegatem Methods

- (void)showImage:(PostDetailCell*) cell index:(NSUInteger) index
{
    PostDetail *postDetail=cell.postDetail;
    self.imageGridView = [[IDGridView alloc] initWithFrame:(CGRect){504-440,0,440,748}];
    NSMutableArray *arrayViews = [NSMutableArray array];
    [postDetail.pictures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_imageGridView.bounds];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        // 生成大图下载地址（= 缩略图名＋big）
        NSString *urlSmall = obj;
        NSLog(@"%@", urlSmall);
        NSString *urlBig = [NSString stringWithFormat:@"%@big.%@", [urlSmall stringByDeletingPathExtension], [urlSmall pathExtension]];
        NSLog(@"%@", urlBig);

//        [imageView setImageWithURL:[NSURL URLWithString:urlBig] placeholderImage:[UIImage imageNamed:DefaultImage]];
        [imageView setImageWithURL:[NSURL URLWithString:urlBig] placeholderImage:nil];
        [arrayViews addObject:imageView];
    }];
    
    
    _imageGridView.arrayViews=arrayViews;
    _imageGridView.col=1;
    _imageGridView.row=1;
    _imageGridView.direction=Vertical;
    _imageGridView.backgroundColor=[UIColor blackColor];
    [_imageGridView scrollToPage:index animated:NO];
    
    UIImage *imgClose=[UIImage imageNamed:@"close@2x.png"];
    UIButton *btnClose=[UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.frame=(CGRect){0,0, imgClose.size};
    [btnClose setImage:imgClose forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(closeImageGridView) forControlEvents:UIControlEventTouchUpInside];
    [_imageGridView addSubview:btnClose];
    
    if(!self.maskView){
        self.maskView=[[UIView alloc] initWithFrame:(CGRect){self.view.bounds.size.width,0,504,748}];
        _maskView.backgroundColor=RGBAColor(0, 0, 0, 0.4);
    }
    [_maskView addSubview:_imageGridView];
    [self.view addSubview:_maskView];
     
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _maskView.frame=(CGRect){0,0,440,748};
    }completion:^(BOOL finished) {
    }];
    
}


-(void) expandForumEdit:(PostsEditType)  postType
{
 
    self.forumEditVC.postType = postType;
    UIImage *imgClose=[UIImage imageNamed:@"close@2x.png"];
    UIButton *btnClose=[UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.frame=(CGRect){CGPointZero, imgClose.size};
    [btnClose setImage:imgClose forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(closeForumEditVC) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnClose];
    
    double delayInSeconds = .2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _forumEditVC.navigationBar.topItem.leftBarButtonItem= closeBarButtonItem;
    });
    
    if(!self.maskView){
        self.maskView=[[UIView alloc] initWithFrame:(CGRect){self.view.bounds.size.width,0,504,748}];
        _maskView.backgroundColor=RGBAColor(0, 0, 0, 0.4);
    }
    UIView *editView=_forumEditVC.view;
    
    editView.frame=(CGRect){504-440,0,440,748};
    [_maskView addSubview:editView];
    [self.view addSubview:_maskView];
    
    
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _maskView.frame=(CGRect){0,0,504,748};
    }completion:^(BOOL finished) {
        
    }];
}

-(void) addForum
{
    self.forumEditVC = [[ForumEditViewController alloc] initWithNibName:@"ForumEditViewController" bundle:nil];
    [self expandForumEdit:AddPost];
}

- (void)editForum:(PostDetailCell*) cell editType:(PostsEditType)editType
{
    self.forumEditVC = [[ForumEditViewController alloc] initWithNibName:@"ForumEditViewController" bundle:nil];
    _forumEditVC.postDetail = cell.postDetail;
    [self expandForumEdit:editType];
    
    

}
#pragma mark - IBActions And Custom Methods

// 添加回复后刷新
-(void) replyPosts:(NSNotification *)notification {
    if (notification) {
        [_tvDetail autoLoadData];
        [[[iToast makeText:[[I18NControl bundle] localizedStringForKey:@"submitSuccess" value:nil table:nil]] setGravity:iToastGravityCenter] showInView:self.view];
        [self closeForumEditVC];
    }
}

// 跳转论坛编辑界面
- (void)replyPost
{
    self.forumEditVC = [[ForumEditViewController alloc] initWithNibName:@"ForumEditViewController" bundle:nil];

    // 帖子发表用户信息
    _forumEditVC.postType = ReplyPost;
    _forumEditVC.postDetail = [_arrayReply objectAtIndex:0];
    
    
    
    
    UIImage *imgClose=[UIImage imageNamed:@"close@2x.png"];
    UIButton *btnClose=[UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.frame=(CGRect){CGPointZero, imgClose.size};
    [btnClose setImage:imgClose forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(closeForumEditVC) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnClose];
    
    double delayInSeconds = .2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _forumEditVC.navigationBar.topItem.leftBarButtonItem= closeBarButtonItem;
    });
    
    if(!self.maskView){
        self.maskView=[[UIView alloc] initWithFrame:(CGRect){self.view.bounds.size.width,0,504,748}];
        _maskView.backgroundColor=RGBAColor(0, 0, 0, .3);
    }
    
    UIView *detailView=_forumEditVC.view;
    detailView.frame=(CGRect){504-440,0,440,748};
    [_maskView addSubview:detailView];
    [self.view addSubview:_maskView];
    
    
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _maskView.frame=(CGRect){self.view.bounds.size.width-504,0,504,748};
    }completion:nil];

     
}


// 获取帖子详细信息
-(void) getPostsInfo
{
    NSDictionary *dicParams=@{@"id":self.postID};
    [[AFIntelligentCommunityClient sharedClient] getPath:@"ForumInterface/getPostsInfo"
                                              parameters:dicParams success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                  
        [_arrayReply removeAllObjects];
                                                  
        NSDictionary *dicPost = JSON;
        // 贴子详细信息
        PostDetail *detail = [[PostDetail alloc] init];
        detail.isPost = YES;
        detail.id = dicPost[@"id"];
        detail.postTitle = dicPost[@"title"];
        detail.postContent = dicPost[@"content"];
        detail.dateTime = dicPost[@"createTime"];
        // test 无图片时候？
        detail.pictures = dicPost[@"pictures"];
                                                  
        // 发表用户信息
        NSDictionary *dicSubmitUser = dicPost[@"submitUser"];
        User *submitUser = [[User alloc] init];
        submitUser.userID = dicSubmitUser[@"id"];
        submitUser.userName = dicSubmitUser[@"name"];
        submitUser.avatarUrl = dicSubmitUser[@"iconURL"];
        detail.user = submitUser;
        [_arrayReply addObject:detail];
                                                  
        NSArray* arrayReplies = dicPost[@"replies"];                              
        [arrayReplies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
              
              NSDictionary *dicReply = obj;
              PostDetail *reply = [[PostDetail alloc] init];
              reply.isPost = NO;
              reply.id = dicReply[@"id"];                     // 回复ID
              reply.postContent = dicReply[@"content"];      // 回复内容
              reply.dateTime = dicReply[@"createTime"];       // 回复时间
            
              // test 无图片时候？
              reply.pictures = dicReply[@"pictures"];

              // 回复用户信息
              NSDictionary *dicReplier = dicReply[@"replyUser"];
              User *replyUser = [[User alloc] init];
              replyUser.userID = dicReplier[@"id"];
              replyUser.userName = dicReplier[@"name"];
              replyUser.avatarUrl = dicReplier[@"iconURL"];
              reply.user = replyUser;
            
              [_arrayReply addObject:reply];
          }];
          
          [_tvDetail refreshTableView];
          
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          CLog(@"%@", operation.responseString);
          [Util failOperation:operation.responseData];
          [_tvDetail refreshTableView];
      }];
}

-(void) closeImageGridView
{
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _maskView.frame=(CGRect){self.view.bounds.size.width,0,504,748};
    }completion:^(BOOL finished) {
        [_imageGridView removeFromSuperview];
        [_maskView removeFromSuperview];
        self.imageGridView=nil;
    }];
}

-(void) closeForumEditVC
{
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _maskView.frame=(CGRect){self.view.bounds.size.width,0,504,748};
    }completion:^(BOOL finished) {
        [self.forumEditVC.view removeFromSuperview];
        [_maskView removeFromSuperview];
        self.forumEditVC=nil;
    }];
}

@end
