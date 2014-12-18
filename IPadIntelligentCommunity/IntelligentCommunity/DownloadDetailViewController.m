//
//  DownloadDetailViewController.m
//  IntelligenceCommunity
//
//  Created by 王飞 on 14-6-1.
//  Copyright (c) 2014年 com.ideal. All rights reserved.
//

#import "DownloadDetailViewController.h"
#import "I18NControl.h"
#define RCellHeight 75

@interface DownloadDetailViewController ()

@end



@implementation DownloadDetailViewController
@synthesize docArray;
@synthesize tableview;
@synthesize downloadArray;
@synthesize navigationItem;
 AFURLConnectionOperation *connectOperation;

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
    self.tableview.contentInset = UIEdgeInsetsMake(0, 0, RCellHeight *2 , 0);
    [self setExtraCellLineHidden:tableview];
    downloadArray = [[NSMutableArray alloc]init];
    [self InitDownloadView];
    
   // [self.tableview setEditing:YES];
    
    self.navigationItem.title = [[I18NControl bundle] localizedStringForKey:@"Doucments" value:nil table:nil];
    // 消息通知
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(download:) name:DFNotificationDownload object:nil];
    [notificationCenter addObserver:self selector:@selector(downloadDelete:) name:DFNotificationDownloadDelete object:nil];
}



-(void) InitDownloadView
{
    if(docArray != nil)
    {
         for (int i = 0; i < docArray.count; i++)
         {
             NSString *url = [docArray[i] objectForKey:@"docURL"];
             NSString * docID = [docArray[i] objectForKey:@"docID"];
             if (url.length)
             {
                 Download *download = [[Download alloc] init];
                 
                 // 资料是否存在
                 if([FCaches isFileExists:[url lastPathComponent] For:@"data"]){
//                     download.btnDelTitle = [[I18NControl bundle] localizedStringForKey:@"delete" value:nil table:nil];
                     download.currentStatus = 1;
                     /*-------- ADD Start for 多文档下载 2013/12/04 ----------*/
                     //判断以前下载过的文档是否已被更新
                     NSString *urlUTF=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                     NSPredicate *predicate=[NSPredicate predicateWithFormat:@"productID == %@ AND docURL == %@", docID, urlUTF];
                     
                     NSArray *arrayData = [[DAO shareDAO] queryObjectWithEntityName:@"DocumentInfo" Predicate:predicate SortKeys:nil];
                     if(arrayData.count){
                         NSString *updateDateString=[docArray[i] objectForKey:@"docUpdateTime"];
                         NSDate *updateDate=[Util  NSStringDateToNSDate:updateDateString format:@"yyyy-MM-dd HH:mm:ss"];
                         CLog(@"%@", updateDate);
                         
                         // 对应唯一的文件
                         DocumentInfo *documentInfo=(DocumentInfo*)arrayData[0];
                         CLog(@"%@", documentInfo.downLoadDate);
                         
                         NSComparisonResult result=[documentInfo.downLoadDate compare:updateDate];
                         if(result==NSOrderedAscending){
//                             download.btnDowTitle= [[I18NControl bundle] localizedStringForKey:@"update" value:nil table:nil];
                             download.currentStatus = 2;
                         }
                     }
                     /*-------- ADD End   for 多文档下载 2013/12/04 ----------*/
                 }
                 else
                 {
//                     download.btnDowTitle = [[I18NControl bundle] localizedStringForKey:@"download" value:nil table:nil];
                     download.currentStatus = 0;
                 }
                 
                 
                 download.docName = [docArray[i] objectForKey:@"docName"];
                 download.docURL = [docArray[i] objectForKey:@"docURL"];
                 download.docType = [docArray[i] objectForKey:@"docType"];
                 download.docUpdateTime = [docArray[i] objectForKey:@"docUpdateTime"];
                 download.productID =docID;
                 
                 [downloadArray addObject:download];
             }

         }
    }
             
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)GoBack:(id)sender {
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.frame=(CGRect){self.view.frame.size.width + 447,0,447,748};
    }completion:^(BOOL finished) {
        //        self.view.frame=(CGRect){523+447,0,464,748};
        [self.view removeFromSuperview];
    }];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return RCellHeight;
}

//是否分组
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //now only support production information, resource information, others
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( downloadArray!= nil)
    {
        return downloadArray.count;
    }
    else
        return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DownloadCell";
    
     DownloadCell *cell = (DownloadCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if(cell == nil)
    {
        cell = (DownloadCell *)[DownloadCell loadInstanceFromNib];
        //cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.contentView.backgroundColor = DefaultBackgroundColor;
    }
    
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    Download *fCell = [downloadArray objectAtIndex:indexPath.row];
    cell.download = fCell;


    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[I18NControl bundle] localizedStringForKey:@"delete" value:nil table:nil];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Download *doc=[downloadArray objectAtIndex:indexPath.row];
        NSString* _filePath = [NSString stringWithFormat:@"%@/%@",[FCaches pathForData], [doc.docURL lastPathComponent]];
        
        if(doc.currentStatus == 0)
        {
            IAlertView *alertView=[[IAlertView alloc] initWithTitle:[[I18NControl bundle] localizedStringForKey:@"warmTip" value:nil table:nil] message:[[I18NControl bundle] localizedStringForKey:@"No File" value:nil table:nil]];
            [alertView addButtonWithTitle:[[I18NControl bundle] localizedStringForKey:@"confirm" value:nil table:nil] callback:^(int index, NSString *title) {
            }];
            [alertView show];

            
            [tableview setEditing:NO animated:YES];
            return ;
        }
        
        if (connectOperation.isExecuting == YES)
        {
            [connectOperation cancel];
        }
        
        IAlertView *alertView=[[IAlertView alloc] initWithTitle:[[I18NControl bundle] localizedStringForKey:@"warmTip" value:nil table:nil] message:[[I18NControl bundle] localizedStringForKey:@"Delete File" value:nil table:nil]];
        [alertView addButtonWithTitle:[[I18NControl bundle] localizedStringForKey:@"confirm" value:nil table:nil] callback:^(int index, NSString *title) {
            
            // 删除现有文件
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:_filePath error:nil];
            doc.currentStatus = 0;
            DownloadCell * cell = (DownloadCell*)[tableView cellForRowAtIndexPath:indexPath];
            cell.docStatus.text = [[I18NControl bundle] localizedStringForKey:@"Not Download" value:nil table:nil];
            
        }];
        [alertView addButtonWithTitle:[[I18NControl bundle] localizedStringForKey:@"cancel" value:nil table:nil] callback:nil];
        [alertView show];
        
        [tableview setEditing:NO animated:YES];
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取资料下载地址
    Download *doc=[downloadArray objectAtIndex:indexPath.row];
    DownloadCell * cell = (DownloadCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSString *url =doc.docURL;
    CLog(@"docURL: %@", url);
    
    // 文件保存地址
    NSString *fileName=[url lastPathComponent];
    NSString *filePath=[NSString stringWithFormat:@"%@/%@",[FCaches pathForData],fileName];
    CLog(@"filePath：%@", filePath);
    
    if(doc.currentStatus == 0)
    {
      //not downloaded
        IAlertView *alertView=[[IAlertView alloc] initWithTitle:[[I18NControl bundle] localizedStringForKey:@"warmTip" value:nil table:nil] message:[[I18NControl bundle] localizedStringForKey:@"downloadFileFirst" value:nil table:nil]];
        [alertView addButtonWithTitle:[[I18NControl bundle] localizedStringForKey:@"confirm" value:nil table:nil] callback:^(int index, NSString *title) {
            
            // 下载文件
            NSDictionary *dicParams=@{@"download":doc,
                                      @"downloadCell":cell,
                                      @"language":[Util getCurrentLanguage]};
            // 下载资料通知
            [[NSNotificationCenter defaultCenter] postNotificationName:DFNotificationDownload object:nil userInfo:dicParams];
            
        }];
        [alertView addButtonWithTitle:[[I18NControl bundle] localizedStringForKey:@"cancel" value:nil table:nil] callback:nil];
        [alertView show];
        return;
    }
    
    
    // 打开文件
    if(doc.currentStatus == 1)
    {
        //已下载
        if([FCaches isFileExists:fileName For:@"data"]){
            if([doc.docType intValue]==9){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:[[I18NControl bundle] localizedStringForKey:@"cannotOpenDoc" value:nil table:nil]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }else{
                [self openFile:filePath type:[doc.docType intValue]];
            }
        }
        else
        {
            
            // 下载文件
            NSDictionary *dicParams=@{@"download":doc,
                                      @"downloadCell":cell,
                                      @"language":[Util getCurrentLanguage]};
            // 下载资料通知
            [[NSNotificationCenter defaultCenter] postNotificationName:DFNotificationDownload object:nil userInfo:dicParams];
        }
        return;
    }
    
    //更新文件
    if(doc.currentStatus == 2)
    {
        
        IAlertView *alertView=[[IAlertView alloc] initWithTitle:[[I18NControl bundle] localizedStringForKey:@"warmTip" value:nil table:nil] message:[[I18NControl bundle] localizedStringForKey:@"" value:nil table:nil]];
        [alertView addButtonWithTitle:[[I18NControl bundle] localizedStringForKey:@"Update" value:nil table:nil] callback:^(int index, NSString *title) {
            
            // 下载文件
            NSDictionary *dicParams=@{@"download":doc,
                                      @"downloadCell":cell,
                                      @"language":[Util getCurrentLanguage]};
            // 下载资料通知
            [[NSNotificationCenter defaultCenter] postNotificationName:DFNotificationDownload object:nil userInfo:dicParams];
            
        }];
        
        [alertView addButtonWithTitle:[[I18NControl bundle] localizedStringForKey:@"Open File" value:nil table:nil] callback:^(int index, NSString *title) {
            
            //已下载
            if([FCaches isFileExists:fileName For:@"data"]){
                if([doc.docType intValue]==9){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                        message:[[I18NControl bundle] localizedStringForKey:@"cannotOpenDoc" value:nil table:nil]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }else{
                    
                    [self openFile:filePath type:[doc.docType intValue]];
                }
            }
            else
            {
                
                // 下载文件
                NSDictionary *dicParams=@{@"download":doc,
                                          @"downloadCell":cell,
                                          @"language":[Util getCurrentLanguage]};
                // 下载资料通知
                [[NSNotificationCenter defaultCenter] postNotificationName:DFNotificationDownload object:nil userInfo:dicParams];
            }

            
        }];

        
        [alertView addButtonWithTitle:[[I18NControl bundle] localizedStringForKey:@"cancel" value:nil table:nil] callback:nil];
        [alertView show];
    }
    
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
            // test
            //        case 9:     // 表示其他
            //            docController.UTI = @"public.item";
            //            break;
        default:
            [[[iToast makeText:[[I18NControl bundle] localizedStringForKey:@"unknowFileType" value:nil table:nil]] setGravity:iToastGravityCenter] show];
            return;
    }
    
    [docController presentPreviewAnimated:YES];
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
        [cell.proView setProgress:0.0];
        cell.proView.hidden = NO;
        
        // ［取消］按钮设置
//        [cell.btnDownload setTitle: @"" forState:UIControlStateNormal];
//        cell.btnDownload.hidden = YES;
//        [cell.btnDelete setTitle: [[I18NControl bundle] localizedStringForKey:@"cancel" value:nil table:nil] forState:UIControlStateNormal];
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
                 
                 download.currentStatus = 1;
                 cell.docStatus.text = [[I18NControl bundle] localizedStringForKey:@"Downloaded" value:nil table:nil];
//                 [cell.btnDelete setTitle: [[I18NControl bundle] localizedStringForKey:@"delete" value:nil table:nil] forState:UIControlStateNormal];
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
//        
//        [cell.btnDownload setTitle: [[I18NControl bundle] localizedStringForKey:@"download" value:nil table:nil] forState:UIControlStateNormal];
//        cell.btnDownload.hidden = NO;
    }
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



-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

@end
