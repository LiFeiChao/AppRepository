//
//  CommentViewController.m
//  IntelligenceCommunity
//
//  Created by IdealRD on 13-7-12.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentCell.h"
#import "Comment.h"
#import "User.h"
#import "Util.h"
#import "UIView+NibLoading.h"
#import "I18NControl.h"

#define EmoTextViewHeight   40
#define FontSize            15
#define ContentWidth        240
#define CellHeight          38//74

@interface CommentViewController ()
{
    EmoTextView *_emoTextView;
    CMPopTipView *_popTipView;
    TSEmojiView *_emoView;
    
    IBOutlet EGOTableView *_tvComment;
    
    NSMutableArray *_arrayComments;
}

@end

@implementation CommentViewController

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
    self.navigationBar.topItem.title=[[I18NControl bundle] localizedStringForKey:@"comment" value:nil table:nil];
    //评论页面增加表情输入框
    _emoTextView=[[EmoTextView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-EmoTextViewHeight,
                                                                self.view.frame.size.width, EmoTextViewHeight)];
    _emoTextView.delegate=self;
    [self.view addSubview:_emoTextView];
    
 

    // 键盘切换事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    _arrayComments=[[NSMutableArray alloc] init];

}

-(void) viewDidAppear:(BOOL)animated
{
    if(_arrayComments.count==0){
        [_tvComment autoLoadData];
    }
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    _tvComment = nil;
    [super viewDidUnload];
}

#pragma mark -
#pragma mark EmoTextViewDelegate Methods
-(void) sendData
{
    // 提交产品评论
    [self submitComments];
}

- (void)emoTextView:(EmoTextView *)emoTextView willPopEmoViewAnView:(id) sender
{
    if(_popTipView.superview){
        [_popTipView dismissAnimated:YES];
    }else{
        if(!_emoView){
            _emoView = [[TSEmojiView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-30, 104)];
            _emoView.delegate = emoTextView;
        }
        if(!_popTipView){
            _popTipView = [[CMPopTipView alloc] initWithCustomView:_emoView];
        }
        _popTipView.animation=CMPopTipAnimationPop;
        _popTipView.pointDirection=PointDirectionDown;
        [_popTipView presentPointingAtView:sender inView:self.view animated:YES];
    }
}

- (void)willDismissPopEmoView:(EmoTextView *)emoTextView
{
    [_popTipView dismissAnimated:YES];
}

#pragma mark -
#pragma mark Keyboard Methods
-(void) keyboardWillShow:(NSNotification *)note
{
    // 抬高输入框
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        CGFloat keyboardHeight = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.width;
        
        CGRect emoTextViewFrame = _emoTextView.frame;
        emoTextViewFrame.origin.y = self.view.frame.size.height - (keyboardHeight + _emoTextView.frame.size.height);
        _emoTextView.frame = emoTextViewFrame;
    }];
}

-(void) keyboardWillHide:(NSNotification *)note
{
    [_popTipView dismissAnimated:YES];
    
    // 还原输入框
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        CGRect emoTextViewFrame = _emoTextView.frame;
        emoTextViewFrame.origin.y = self.view.frame.size.height - _emoTextView.frame.size.height;
        _emoTextView.frame = emoTextViewFrame;
    }];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
// 页面滚动时回调
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_tvComment egoRefreshScrollViewDidScroll:scrollView];
}

// 滚动结束时回调
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_tvComment egoRefreshScrollViewDidEndDragging:scrollView];
}
#pragma mark -
#pragma mark EGOTableViewDelegate Methods
- (void) startLoadData:(id) sender
{
    [self getComments];
}

#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayComments.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CommentCell";
    
    CommentCell *cell = (CommentCell*)[_tvComment dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (CommentCell *)[CommentCell loadInstanceFromNib];
        cell.contentView.backgroundColor = DefaultBackgroundColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	Comment* fCell=[_arrayComments objectAtIndex:indexPath.row];
    cell.comment = fCell;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment* comment=[_arrayComments objectAtIndex:indexPath.row];
    NSString* content = comment.content;
    CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:FontSize] constrainedToSize:CGSizeMake(ContentWidth, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    
    int height = (contentSize.height> 40) ? contentSize.height: 40;
    
    return height+CellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tvComment deselectRowAtIndexPath:indexPath animated:YES];
    [_emoTextView resignTextViewFirstResponder];
}

#pragma mark - IBActions And Custom Methods
-(void) getComments
{
    NSDictionary *dicParams=@{@"productID":self.product.productID,
                              @"userID":[AppController sharedInstance].userInfo.userID};
    [[AFIntelligentCommunityClient sharedClient] postPath:@"productInterface/getProductComment"
                                              parameters:dicParams success:^(AFHTTPRequestOperation *operation, id JSON) {
        CLog(@"%@",JSON);                                
        NSDictionary *dicRet = JSON;
        NSArray *arrayCommentInfo=dicRet[@"comment"];
                                                  
        [_arrayComments removeAllObjects];
                                                  
        [arrayCommentInfo enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dicComment=obj;
            Comment *comment=[[Comment alloc] init];
            
            // 提交用户信息
            NSDictionary *dicSubmitUser=[dicComment objectForKey:@"submitUser"];
            User *submitUser = [[User alloc] init];
            submitUser.userID = dicSubmitUser[@"id"];
            submitUser.userName = dicSubmitUser[@"name"];
            submitUser.avatarUrl = dicSubmitUser[@"iconURL"];

            comment.submitUser = submitUser;
            comment.commentID = dicComment[@"id"];
            comment.createTime = dicComment[@"createTime"];
            comment.content = dicComment[@"content"];
            
            [_arrayComments addObject:comment];
        }];
                                                  
        [_tvComment refreshTableView];   
                                                  
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%@", operation.responseString);
        [Util failOperation:operation.responseData];
        [_tvComment refreshTableView];
    }];

}

// 提交产品评论
-(void) submitComments
{
    [Util showLoadingDialog];
    NSDictionary *dicParams=@{@"productID":self.product.productID,
                              @"userID":[AppController sharedInstance].userInfo.userID,
                              @"clientVersion":DeviceVersion,
                              @"deviceModel":DeviceModel,
                              @"content":_emoTextView.text};
    
    [[AFIntelligentCommunityClient sharedClient] postPath:@"productInterface/submitProductComment"
                                              parameters:dicParams success:^(AFHTTPRequestOperation *operation, id JSON) {
        [Util dismissDialog];  
        [[[iToast makeText:[[I18NControl bundle] localizedStringForKey:@"submitSuccess" value:nil table:nil]] setGravity:iToastGravityCenter] showInView:self.view];
        _emoTextView.text = @"";
                                                  
        // 刷新评论内容
        [_tvComment autoLoadData];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Util dismissDialog];
        [Util failOperation:operation.responseData];
        //[[[iToast makeText:@"提交失败"] setGravity:iToastGravityCenter] showInView:self.view];
        [_tvComment refreshTableView];
    }];
}

 

@end
