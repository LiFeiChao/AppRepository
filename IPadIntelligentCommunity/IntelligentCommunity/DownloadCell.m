//
//  DownloadCell.m
//  IntelligenceCommunity
//
//  Created by IdealRD on 13-7-30.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "DownloadCell.h"
#import "FCaches.h"
#import "DocumentInfo.h"
#import "DAO.h"
#import "Util.h"
#import "I18NControl.h"

#define FRAME_BUTTON_DELETE       CGRectMake(120, 50, 50, 20)

@interface DownloadCell()
{
    IBOutlet UIImageView *_imgIcon;
    IBOutlet UILabel *_lblTitle;
    
    AFURLConnectionOperation *operation;
}
//
//- (IBAction)clickDownload:(id)sender;
//- (IBAction)clickDelete:(id)sender;

@end

@implementation DownloadCell 
@synthesize docStatus;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib
{
    _proView.hidden = YES;
    [_proView setProgress:0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
#pragma mark Private methods

-(void) setDownload:(Download *)download
{
    _download = download;
    
    // 文件类型
    int docType = [download.docType intValue];
    // 根据类型变更图片
    switch (docType) {
        case 0:     // 表示txt文档
            _imgIcon.image=[UIImage imageNamed:@"txt.png"];
            break;
        case 1:     // 表示word文档
            _imgIcon.image=[UIImage imageNamed:@"word.png"];
            break;
        case 2:     // 表示excel文档
            _imgIcon.image=[UIImage imageNamed:@"excel.png"];
            break;
        case 3:     // 表示ppt文档
            _imgIcon.image=[UIImage imageNamed:@"ppt.png"];
            break;
        case 4:     // 表示pdf文档
            _imgIcon.image=[UIImage imageNamed:@"pdf.png"];
            break;
        case 5:     // 表示图片格式文档
            _imgIcon.image=[UIImage imageNamed:@"imageicon.png"];
            break;
        case 6:    // 表示zip压缩格式文档
            _imgIcon.image=[UIImage imageNamed:@"zip.png"];
            break;
        case 9:     // 表示其他
            break;
        default:
            break;
    }
    
    switch (download.currentStatus) {
        case 0:
            //未下载
            docStatus.text = [[I18NControl bundle] localizedStringForKey:@"Not Download" value:nil table:nil];
            break;
        case 1:
            //已下载
            docStatus.text =[[I18NControl bundle] localizedStringForKey:@"Downloaded" value:nil table:nil];
            break;
        case 2:
            //更新
            docStatus.text =[[I18NControl bundle] localizedStringForKey:@"Update" value:nil table:nil];
            break;
        default:
              docStatus.text =@"Unknown";
            break;
    }
    
//    if (download.btnDelTitle){
//        [_btnDelete setTitle: download.btnDelTitle forState:UIControlStateNormal];
//    } else {
//        _btnDelete.hidden = YES;
//    }
//    
//    if (download.btnDowTitle){
//        [_btnDownload setTitle: download.btnDowTitle forState:UIControlStateNormal];
//    } else {
//        _btnDownload.hidden = YES;
//       // _btnDelete.frame = _btnDownload.frame;
//    }
    
    _lblTitle.text = download.docName;

}

// 下载／更新资料文件
- (IBAction)clickDownload:(id)sender
{
//    //删除现有文件
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    [fileManager removeItemAtPath:_filePath error:nil];
   
    NSDictionary *dicParams=@{@"download":_download,
                              @"downloadCell":self,
                              @"language":[Util getCurrentLanguage]};
    // 下载资料通知
    [[NSNotificationCenter defaultCenter] postNotificationName:DFNotificationDownload object:nil userInfo:dicParams];
    
//    // 下载资料
//    NSString *url=[_docURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    operation = [[AFURLConnectionOperation alloc] initWithRequest:request];
//    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:_filePath append:NO];
//    
//    // ［取消］按钮设置
//    [_btnDownload setTitle: @"" forState:UIControlStateNormal];
//    _btnDownload.hidden = YES;
//    [_btnDelete setTitle: @"取消" forState:UIControlStateNormal];
//    _btnDelete.hidden = NO;
//    _btnDelete.frame = _btnDownload.frame;
//    // 显示进度条
//    _proView.hidden = NO;
//    
//    __block UIProgressView*  blockView = _proView;
//    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
//     {
//         float newProgress = (float)totalBytesRead / (float)totalBytesExpectedToRead;
//         CLog(@"Sent %lld of %lld bytes", totalBytesRead, totalBytesExpectedToRead);
//
//         // 设置进度
//         [blockView setProgress:newProgress];
//     }];
//    
//    [operation setCompletionBlock:^
//     {
//         CLog(@"Successfully complite downloaded!");
//         
//         dispatch_async(dispatch_get_main_queue(), ^{
//             NSPredicate *predicate=[NSPredicate predicateWithFormat:@"productID == %@", self.productID];
//             NSArray *arrayData = [[DAO shareDAO] queryObjectWithEntityName:@"DocumentInfo" Predicate:predicate SortKeys:nil];
//             DocumentInfo *documentInfo;
//             if(arrayData.count){
//                 documentInfo=(DocumentInfo*)arrayData[0];
//             }else{
//                 documentInfo=(DocumentInfo*)[[DAO shareDAO] newInsertObject:@"DocumentInfo"];
//             }
//             documentInfo.productID = self.productID;
//             documentInfo.docURL=url;
//             documentInfo.downLoadDate=[Util NSStringDateToNSDate:_docUpdateTime format:@"yyyy-MM-dd HH:mm:ss"];
//             [[DAO shareDAO] saveObject];
//             
//             // 隐藏进度条
//          //   [_proView removeFromSuperview];
//             _proView.hidden = YES;
//             _btnDelete.hidden = NO;
//         
//         });
//     }];
//    
//    [operation start];
}

// 删除现有文件
- (IBAction)clickDelete:(id)sender
{
//    if (operation.isExecuting == YES)
//    {
//        [operation cancel];
//    }
//    
//    // 删除现有文件
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    [fileManager removeItemAtPath:_filePath error:nil];
//
//    _btnDelete.hidden = YES;
//    
//    [_btnDownload setTitle: @"下载" forState:UIControlStateNormal];
//    _btnDownload.hidden = NO;
    
    NSDictionary *dicParams=@{@"download":_download,
                              @"downloadCell":self,
                              @"language":[Util getCurrentLanguage]};
    // 下载资料通知
    [[NSNotificationCenter defaultCenter] postNotificationName:DFNotificationDownloadDelete object:nil userInfo:dicParams];
    
}

@end
