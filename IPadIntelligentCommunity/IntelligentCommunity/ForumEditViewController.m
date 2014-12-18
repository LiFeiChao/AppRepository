//
//  ForumEditViewController.m
//  IntelligenceCommunity
//
//  Created by IdealRD on 13-7-17.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import<QuartzCore/QuartzCore.h>
#import "ForumEditViewController.h"
#import "GTMBase64.h"
#import "PHTextView.h"
#import "Util.h"
#import "I18NControl.h"
#import "CMPopTipView.h"
#import "I18NControl.h"

// test (temp)
#define MaxTitleLength      40
#define MaxContentLength    140
#define MaxPictureCount     4

#define kImageViewSize (CGSize){80,80}
#define kResultFrame (CGRect){0,self.view.bounds.size.height-200+20,self.view.bounds.size.width,100}


#define FRAME_IMAGE_VIEW_NEW       CGRectMake(10, 220, 420, 100)
#define FRAME_IMAGE_VIEW_REPLY     CGRectMake(10, 220, 420, 100)

@interface ForumEditViewController ()
{
    IBOutlet PHTextView *_txtTitle;
    IBOutlet PHTextView *_txtContent;
    
    IBOutlet UIView *_viewImage;
    IBOutlet UIImageView *_imgPicture1;
    IBOutlet UIImageView *_imgPicture2;
    IBOutlet UIImageView *_imgPicture3;
    IBOutlet UIImageView *_imgPicture4;
    
    IBOutlet UIView *_viewContent;
    IBOutlet UIButton *_btnCamera;
    IBOutlet UIButton *_btnImage;
    
    NSMutableArray *_arrayReply;
    NSMutableArray *_arrayImage;    // 帖子插图数组
    NSArray *_arrayPicture;         // 缩略图数组
    

    CMPopTipView *_popTipView;
    TSEmojiView *_emoView;
    
    IDGridView *_gridView;
    
}

- (IBAction)getPictures:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction) sendPost:(id)sender;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, retain) NSMutableArray *imageViewArray;

@end

@implementation ForumEditViewController

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
    
    // 数组初始化
    _arrayImage=[[NSMutableArray alloc] init];
    _arrayPicture=[[NSArray alloc] initWithObjects:_imgPicture1, _imgPicture2, _imgPicture3, _imgPicture4, nil];

    // test
    self.imageViewArray=[NSMutableArray array];
    // 界面布局初始化（发帖／回复／编辑）
    [self initPostType: self.postType];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *title;
    if(self.postType==ReplyPost){
        title=[[I18NControl bundle] localizedStringForKey:@"reply" value:nil table:nil];
    }else if(self.postType==AddPost){
        title=[[I18NControl bundle] localizedStringForKey:@"post" value:nil table:nil];
    }else{
        title=[[I18NControl bundle] localizedStringForKey:@"edit" value:nil table:nil];
    }
    self.navigationBar.topItem.title=title;
}

- (void)viewDidUnload
{
    _imgPicture1 = nil;
    _imgPicture2 = nil;
    _viewImage = nil;
    _viewContent = nil;
    _btnCamera = nil;
    _btnImage = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITextViewDelegate
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if ([string isEqualToString:@"\n"]) {
//        
//        int tag=textField.tag;
//        
//        tag++;
//        UIView *view=[self.view viewWithTag:tag];
//        [view becomeFirstResponder];
//        // Return FALSE so that the final '\n' character doesn't get added
//        return NO;
//    }
//    // For any other character return TRUE so that the text gets added to the view
//    return YES;
//}
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    int tag=textField.tag;
//    if(tag==1000){
//        _validateMobileImage.hidden=[Util IsValidateMobile:textField.text];
//    }else if(tag==1001){
//        _validateEmailImage.hidden=[Util isValidateEmail:textField.text];
//    }
//}
//#pragma mark -
//#pragma mark UITextViewDelegate
//- (void)textViewDidChange:(UITextView *)textView
//{
//    [textView setNeedsDisplay];
//}
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
// replacementText:(NSString *)text
//{
//    if ([text isEqualToString:@"\n"]) {
//        
//        int tag=textView.tag;
//        tag++;
//        UIView *view=[self.view viewWithTag:tag];
//        if(view){
//            [view becomeFirstResponder];
//        }else{//如果没找到说明到最后一行了,跳回第一行
//            UIView *view=[self.view viewWithTag:1000];
//            [view becomeFirstResponder];
//        }
//        // Return FALSE so that the final '\n' character doesn't get added
//        return NO;
//    }
//    // For any other character return TRUE so that the text gets added to the view
//    return YES;
//}

//- (void)textViewDidEndEditing:(UITextView *)textView
//{
//    if(textView.tag==1004){
//        [UIView animateWithDuration:0.25 animations:^{
//            _contentView.center = CGPointMake(_contentView.center.x, _contentView.center.y+offset4Edit);
//        }];
//    }
//}


- (void)textViewDidChange:(UITextView *)textView
{
//    _lblLength.text=[NSString stringWithFormat:@"还剩下%d个字符",kMaxTextLength-textView.text.length];
    
    [textView setNeedsDisplay];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

#pragma mark -

// 界面布局初始化（发帖／回复／编辑）
-(void) initPostType:(PostsEditType)postType
{
    [self.submitButtonItem setTitle:[[I18NControl bundle] localizedStringForKey:@"submit" value:nil table:nil]];

    
    // 编辑框初始化
    _txtTitle.placehold=[[I18NControl bundle] localizedStringForKey:@"inputPostTitle" value:nil table:nil];
    _txtTitle.layer.borderColor = [UIColor grayColor].CGColor;
    _txtTitle.layer.borderWidth = 1.0;
    _txtTitle.layer.cornerRadius = 6.0;
    _txtContent.placehold=[[I18NControl bundle] localizedStringForKey:@"inputContent" value:nil table:nil];
    _viewContent.layer.borderColor = [UIColor grayColor].CGColor;
    _viewContent.layer.borderWidth = 1.0;
    _viewContent.layer.cornerRadius = 6.0;
    
    _gridView=[[IDGridView alloc] initWithFrame:FRAME_IMAGE_VIEW_NEW];
    _gridView.delegate=self;
    _gridView.top=5;
    _gridView.left=4;
    _gridView.col=4;
    _gridView.row=1;
    _gridView.hidePageControl=YES;
    [self.view addSubview:_gridView];
    
    if (_arrayImage.count < MaxPictureCount)
    {
        UIView *subView=[[UIView alloc] initWithFrame:(CGRect){CGPointZero,kImageViewSize}];
        [subView setUserInteractionEnabled:YES];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){CGPointZero, subView.bounds.size.width-4, subView.bounds.size.height-4}];
        imageView.image = [UIImage imageNamed:@"add_button_p"];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.center = subView.center;
        [subView addSubview:imageView];
        
        [self.imageViewArray addObject:subView];
    }
    _gridView.arrayViews=self.imageViewArray;
    [_gridView setNeedsLayout];
    
    // 界面布局类型设定
    CGRect frameContent = _viewContent.frame;
    CGRect frameImage = _gridView.frame; //_viewImage.frame;
    switch (postType) {
        case AddPost:
            self.title = [[I18NControl bundle] localizedStringForKey:@"post" value:nil table:nil];
            break;
        case ReplyPost:
            self.title = [[I18NControl bundle] localizedStringForKey:@"reply" value:nil table:nil];
            _txtTitle.hidden = YES;
            frameContent.origin.y = _txtTitle.frame.origin.y;
            _viewContent.frame = frameContent;
            break;
        case EditPost:
            self.title =[[I18NControl bundle] localizedStringForKey:@"edit" value:nil table:nil];
            //_txtTitle.editable=NO;
            _txtTitle.text = _postDetail.postTitle;
            [_txtTitle setNeedsDisplay];
            _txtContent.text = _postDetail.postContent;
            [_txtContent setNeedsDisplay];
            
            // 编辑时暂不能修改图片
            _btnCamera.enabled = NO;
            _btnImage.enabled = NO;
            _viewImage.hidden = YES;
            break;
        case EditReply:
            self.title = [[I18NControl bundle] localizedStringForKey:@"edit" value:nil table:nil];
            _txtTitle.hidden = YES;
            frameContent.origin.y = _txtTitle.frame.origin.y;
            _viewContent.frame = frameContent;
            _txtContent.text = _postDetail.postContent;
            [_txtContent setNeedsDisplay];
            
            // 编辑时暂不能修改图片
            _btnCamera.enabled = NO;
            _btnImage.enabled = NO;
            _viewImage.hidden = YES;
            break;
        default:
            break;
    }
    
    // 设置插图区域
    frameImage.origin.y = frameContent.origin.y + frameContent.size.height + 2;
    _gridView.frame = frameImage;
}
 

// 发帖／回帖／编辑
- (IBAction) sendPost:(id)sender
{
    [_txtTitle resignFirstResponder];
    [_txtContent resignFirstResponder];
    
    // check
    if(_arrayImage.count > 4){
        [[[iToast makeText:[[I18NControl bundle] localizedStringForKey:@"maxLimitUploadPics" value:nil table:nil]] setGravity:iToastGravityCenter] showInView:self.view];
        return;
    }
    if (self.postType == AddPost || self.postType == EditPost)
    {
        if(_txtTitle.text.length==0){
            [[[iToast makeText:[[I18NControl bundle] localizedStringForKey:@"inputPostTitle" value:nil table:nil]] setGravity:iToastGravityCenter] showInView:self.view];
            return;
        }
        if(_txtTitle.text.length > MaxTitleLength){
            [[[iToast makeText:[NSString stringWithFormat:[[I18NControl bundle] localizedStringForKey:@"maxLimitChats" value:nil table:nil], MaxTitleLength]] setGravity:iToastGravityCenter] showInView:self.view];
            return;
        }
    }
    if(_txtContent.text.length==0){
        [[[iToast makeText:[[I18NControl bundle] localizedStringForKey:@"inputContent" value:nil table:nil]] setGravity:iToastGravityCenter] showInView:self.view];
        return;
    }
    if(_txtContent.text.length > MaxContentLength){
        [[[iToast makeText:[NSString stringWithFormat:[[I18NControl bundle] localizedStringForKey:@"maxLimitChats" value:nil table:nil], MaxContentLength]] setGravity:iToastGravityCenter] showInView:self.view];
        return;
    }
  
    [Util showLoadingDialog];
    
    // 帖子插图
    NSMutableArray *arrayImage=[[NSMutableArray alloc] init];
    switch (self.postType) {
        case AddPost:
        {
            // 添加图片
            for (int i=0; i<_arrayImage.count; i++) {
                UIImage *image=_arrayImage[i];
                NSData *imageData = UIImageJPEGRepresentation(image,0.5);
                NSData *tmpData=[GTMBase64 encodeData:imageData];
                NSString *baseString = [[NSString alloc] initWithData:tmpData encoding:NSUTF8StringEncoding];
                [arrayImage addObject:baseString];
            }
            
            NSDictionary *dicParams=@{@"title":_txtTitle.text,
                                      @"content":_txtContent.text,
                                      @"clientType":ClientType,
                                      @"pictures":arrayImage,
                                      @"submitUserID":[AppController sharedInstance].userInfo.userID
                                      };
            [[AFIntelligentCommunityClient sharedClient] postPath:@"ForumInterface/submitPosts" parameters:dicParams
                                                          success:^(AFHTTPRequestOperation *operation, id JSON) {
                 [Util dismissDialog];
                 _txtTitle.text=@"";   
                 _txtContent.text=@"";
                _viewImage.hidden = YES;
                [self.imageViewArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [obj removeFromSuperview];
                 }];
                                                              
                //[[[iToast makeText:@"提交成功"] setGravity:iToastGravityCenter] showInView:self.view];
                // 发布帖子成功通知                                              
                [[NSNotificationCenter defaultCenter] postNotificationName:DFNotificationAddPosts object:nil userInfo:nil];
//                //为了关闭新建帖子页面
//                [[NSNotificationCenter defaultCenter] postNotificationName:DFNotificationReplyPosts object:nil userInfo:nil];
                                                              

            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [Util dismissDialog];
                [Util failOperation:operation.responseData];
//                [[[iToast makeText:@"提交失败"] setGravity:iToastGravityCenter] show];
            }];
            break;
        }
        case ReplyPost:
        {
            // 添加图片
            for (int i=0; i<_arrayImage.count; i++) {
                UIImage *image=_arrayImage[i];
                NSData *imageData = UIImageJPEGRepresentation(image,0.5);
                NSData *tmpData=[GTMBase64 encodeData:imageData];
                NSString *baseString = [[NSString alloc] initWithData:tmpData encoding:NSUTF8StringEncoding];
                [arrayImage addObject:baseString];
            }
            
            NSDictionary *dicParams=@{@"id":_postDetail.id,
                                      @"content":_txtContent.text,
                                      @"clientType":ClientType,
                                      @"pictures":arrayImage,
                                      @"submitUserID":[AppController sharedInstance].userInfo.userID
                                      };
            [[AFIntelligentCommunityClient sharedClient] postPath:@"ForumInterface/submitReply" parameters:dicParams
                                                          success:^(AFHTTPRequestOperation *operation, id JSON) {
                [Util dismissDialog];
                _txtTitle.text=@""; 
                _txtContent.text=@"";
                _viewImage.hidden = YES;
                //[[[iToast makeText:@"提交成功"] setGravity:iToastGravityCenter] show];
                // 回复帖子成功通知
                [[NSNotificationCenter defaultCenter] postNotificationName:DFNotificationReplyPosts object:nil userInfo:nil];

            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [Util dismissDialog];
                [Util failOperation:operation.responseData];
                //[[[iToast makeText:@"提交失败"] setGravity:iToastGravityCenter] show];
            }];
            break;
        }
        case EditPost:
        {
            NSDictionary *dicParams=@{@"id":_postDetail.id,
                                      @"content":_txtContent.text,
                                      @"pictures":arrayImage,
                                      @"submitUserID":[AppController sharedInstance].userInfo.userID
                                      };
            
            [[AFIntelligentCommunityClient sharedClient] postPath:@"ForumInterface/updatePost" parameters:dicParams
                                                          success:^(AFHTTPRequestOperation *operation, id JSON) {
                [Util dismissDialog];
                _txtContent.text=@"";
                _viewImage.hidden = YES;
                //[[[iToast makeText:@"提交成功"] setGravity:iToastGravityCenter] show];
                [[NSNotificationCenter defaultCenter] postNotificationName:DFNotificationReplyPosts object:nil userInfo:nil];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [Util dismissDialog];
                [Util failOperation:operation.responseData];
                //[[[iToast makeText:@"提交失败"] setGravity:iToastGravityCenter] show];
            }];
            break;
        }
        case EditReply:
        {
            NSDictionary *dicParams=@{@"id":_postDetail.id,
                                      @"content":_txtContent.text,
                                      @"pictures":arrayImage,
                                      @"submitUserID":[AppController sharedInstance].userInfo.userID
                                      };
            [[AFIntelligentCommunityClient sharedClient] postPath:@"ForumInterface/updateReply" parameters:dicParams
                                                          success:^(AFHTTPRequestOperation *operation, id JSON) {
                [Util dismissDialog];
                _txtContent.text=@"";
                _viewImage.hidden = YES;
                //[[[iToast makeText:@"提交成功"] setGravity:iToastGravityCenter] show];
                [[NSNotificationCenter defaultCenter] postNotificationName:DFNotificationReplyPosts object:nil userInfo:nil];                                              
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [Util dismissDialog];
                [Util failOperation:operation.responseData];
                //[[[iToast makeText:@"提交失败"] setGravity:iToastGravityCenter] show];
            }];
            break;
        }
        default:
            break;
    }
    

}

// 选择相机图片
- (IBAction)getPictures:(id)sender
{
    [_txtContent resignFirstResponder];
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    self.popover=popover;
    
    [self.popover presentPopoverFromRect:CGRectMake(116, 0, 320, 480) inView:self.
     view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
//    [self presentViewController:navigationController animated:YES completion:NULL];
}

//// 打开摄像头
//- (IBAction)takePhoto:(id)sender
//{
//    //检查相机模式是否可用
//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        NSLog(@"sorry, no camera or camera is unavailable.");
//        return;
//    }
//    
//    //创建图像选取控制器
//    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
//    
//    //设置图像选取控制器的来源模式为相机模式
//    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//    
//    //设置图像选取控制器的类型为静态图像
//    imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
//    
//    //允许用户进行编辑
//    imagePickerController.allowsEditing = YES;
//    
//    //设置委托对象
//    imagePickerController.delegate = self;
//    
//    //以模视图控制器的形式显示
//    [self presentModalViewController:imagePickerController animated:YES];
//}

- (IBAction)showExpression:(id)sender
{
    if(_popTipView.superview){
        [_popTipView dismissAnimated:YES];
    }else{
        if(!_emoView){
            _emoView = [[TSEmojiView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-30, 104)];
            _emoView.delegate = self;
        }
        if(!_popTipView){
            _popTipView = [[CMPopTipView alloc] initWithCustomView:_emoView];
        }
        _popTipView.animation=CMPopTipAnimationPop;
        _popTipView.pointDirection=PointDirectionDown;
        [_popTipView presentPointingAtView:sender inView:self.view animated:YES];
    }
}

#pragma mark -
#pragma mark TSEmojiViewDelegate
- (void)didTouchEmojiView:(TSEmojiView*)emojiView touchedEmoji:(NSString*)str
{
    NSRange selectedRange;
    NSString* orginString, *prefixString, *suffixString;
    
    if (_txtTitle.isFirstResponder)
    {
        selectedRange = _txtTitle.selectedRange;
        orginString = _txtTitle.text;
        prefixString=[orginString substringToIndex:selectedRange.location];
        suffixString=[orginString substringFromIndex:selectedRange.location+selectedRange.length];
        _txtTitle.text = [NSString stringWithFormat:@"%@%@%@", prefixString, str,suffixString];
        selectedRange.location=selectedRange.location+1;
        selectedRange.length=0;
        _txtTitle.selectedRange=selectedRange;
        [_txtTitle setNeedsDisplay];
    }
    else if (_txtContent.isFirstResponder)
    {
        selectedRange = _txtContent.selectedRange;
        orginString = _txtContent.text;
        prefixString=[orginString substringToIndex:selectedRange.location];
        suffixString=[orginString substringFromIndex:selectedRange.location+selectedRange.length];
        _txtContent.text = [NSString stringWithFormat:@"%@%@%@", prefixString, str,suffixString];
        selectedRange.location=selectedRange.location+1;
        selectedRange.length=0;
        _txtContent.selectedRange=selectedRange;
        [_txtContent setNeedsDisplay];
    }
    
    //选择一个表情后界面就消失
    [_popTipView dismissAnimated:YES];
}

#pragma mark -
#pragma mark QBImagePickerControllerDelegate
- (void)imagePickerControllerWillFinishPickingMedia:(QBImagePickerController *)imagePickerController
{
    NSLog(@"imagePickerControllerWillFinishPickingMedia: ");
}

- (void)imagePickerController:(UIImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    //打印出字典中的内容
    NSLog(@"get the media info: %@", info);
    NSArray *mediaInfo = (NSArray *)info;
    
    if ((mediaInfo.count + _arrayImage.count) > MaxPictureCount) {
        NSString *strText = [NSString stringWithFormat:[[I18NControl bundle] localizedStringForKey:@"deleteSurplusPicMsg" value:nil table:nil], MaxPictureCount, _arrayImage.count];
        [[[iToast makeText:strText] setGravity:iToastGravityCenter] showInView:self.view];
        return;
    }
    
    // test
    //    [self.imageViewArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //        [obj removeFromSuperview];
    //    }];
    //    [self.imageViewArray removeAllObjects];
    //    [_arrayImage removeAllObjects];
    int count = _arrayImage.count;
    if (self.imageViewArray.count > count)
    {
        [self.imageViewArray[count] removeFromSuperview];
        [self.imageViewArray removeObjectAtIndex:count];
    }
    
    [mediaInfo enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary* infoDic=obj;
        UIImage *image = infoDic[@"UIImagePickerControllerOriginalImage"];
        
        UIView *subView=[[UIView alloc] initWithFrame:(CGRect){CGPointZero,kImageViewSize}];
        [subView setUserInteractionEnabled:YES];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){CGPointZero, subView.bounds.size.width-4, subView.bounds.size.height-4}];
        imageView.image=image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.center = subView.center;
        [subView addSubview:imageView];
        
        UIImageView *closeImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"delete"]];
        closeImageView.center=CGPointMake(imageView.bounds.size.width+imageView.frame.origin.x, imageView.frame.origin.y);
        [subView addSubview:closeImageView];
        
        [self.imageViewArray addObject:subView];
        
        // 添加已选图片信息
        [_arrayImage addObject:image];
    }];
    
    // test
    //    if (_arrayImage.count > 0 && _arrayImage.count < MaxPictureCount)
    if (_arrayImage.count < MaxPictureCount)
    {
        UIView *subView=[[UIView alloc] initWithFrame:(CGRect){CGPointZero,kImageViewSize}];
        [subView setUserInteractionEnabled:YES];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){CGPointZero, subView.bounds.size.width-4, subView.bounds.size.height-4}];
        imageView.image = [UIImage imageNamed:@"add_button_p"];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.center = subView.center;
        [subView addSubview:imageView];
        
        [self.imageViewArray addObject:subView];
    }
    
    _gridView.arrayViews=self.imageViewArray;
    [_gridView setNeedsLayout];
    
    //[self dismissViewControllerAnimated:YES completion:NULL];
    [self.popover dismissPopoverAnimated:YES];
    [_txtTitle resignFirstResponder];
    [_txtContent resignFirstResponder];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)imagePickerController
{
    NSLog(@"Cancelled");
    [self dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark -
#pragma mark IDGridViewDelegate

// 单击缩略图显示完整大图
-(void)IDGridView:(IDGridView *)IDGridView didSelectAtIndex:(NSUInteger)index
{
    // 添加图片
    if ((index < MaxPictureCount) && (index == _arrayImage.count))
    {
        [self getPictures:nil];
    }
    // 删除所选图片
    else
    {
        // 是否需添加“加号”图标
        BOOL isNeedAddPic = (_arrayImage.count == MaxPictureCount)? YES : NO;
        
        // 清空插图界面
        [self.imageViewArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj removeFromSuperview];
        }];
        
        // 删除所选插图
        [self.imageViewArray removeObjectAtIndex:index];
        [_arrayImage removeObjectAtIndex:index];
        
        // 添加“加号”图标
        if (isNeedAddPic)
        {
            UIView *subView=[[UIView alloc] initWithFrame:(CGRect){CGPointZero,kImageViewSize}];
            [subView setUserInteractionEnabled:YES];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){CGPointZero, subView.bounds.size.width-4, subView.bounds.size.height-4}];
            imageView.image = [UIImage imageNamed:@"add_button_p"];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.center = subView.center;
            [subView addSubview:imageView];
            
            [self.imageViewArray addObject:subView];
        }
        
        //        // 无选中图片时不显示“加号”图标
        //        if (_arrayImage.count == 0)
        //        {
        //            [self.imageViewArray removeAllObjects];
        //        }
        
        _gridView.arrayViews=self.imageViewArray;
        [_gridView setNeedsLayout];
    }
}

@end
