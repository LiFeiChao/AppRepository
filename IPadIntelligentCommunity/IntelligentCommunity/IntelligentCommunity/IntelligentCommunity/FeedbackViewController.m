//
//  FeedbackViewController.m
//  IntelligentCommunity
//
//  Created by 高 欣 on 13-4-16.
//  Copyright (c) 2013年 com.ideal. All rights reserved.
//

#import "FeedbackViewController.h"
#import "I18NControl.h"

#define kMaxTextLength 140
@interface FeedbackViewController (){
    IBOutlet UITextView *_txtSuggestion;
    IBOutlet UILabel *_lblLength;
    IBOutlet UIButton *_btnSend;
    IBOutlet UIView *_viewBg;
}

-(IBAction)submitSuggestion:(id)sender;
@end

@implementation FeedbackViewController

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
    self.navigationBar.topItem.title=[[I18NControl bundle] localizedStringForKey:@"suggest" value:nil table:nil];
    _viewBg.layer.cornerRadius=8.0f;
    _viewBg.layer.borderWidth=1.0f;
    _viewBg.layer.borderColor=[UIColor grayColor].CGColor;
    [_btnSend setTitleColor:RGBColor(4, 114, 170) forState:UIControlStateNormal];
    //[_btnSend setTitleColor:RGBColor(4, 114, 170) forState:UIControlStateHighlighted];
    //[_btnSend setTitleColor:RGBColor(4, 114, 170) forState:UIControlStateSelected];
    self.view.backgroundColor=RGBColor(0xf4, 0xf4, 0xf4);
    _lblLength.text=[NSString stringWithFormat:[[I18NControl bundle] localizedStringForKey:@"remainHowManyChat" value:nil table:nil],kMaxTextLength];
}
//-(void) viewWillAppear:(BOOL)animated
//{
//    [AppController sharedInstance].navigationController.navigationBarHidden=NO;
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    _lblLength.text=[NSString stringWithFormat:[[I18NControl bundle] localizedStringForKey:@"remianHowManyChat" value:nil table:nil],kMaxTextLength-textView.text.length];
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
#pragma mark - IBActions And Custom Methods
-(IBAction)submitSuggestion:(id)sender
{
    if(_txtSuggestion.text.length==0){
        [[[iToast makeText:[[I18NControl bundle] localizedStringForKey:@"pleaseInputSuggest" value:nil table:nil]] setGravity:iToastGravityCenter] showInView:self.view];
        return;
    }
    if(_txtSuggestion.text.length>kMaxTextLength){
        [[[iToast makeText:[NSString stringWithFormat:[[I18NControl bundle] localizedStringForKey:@"maxLimitChats" value:nil table:nil],kMaxTextLength]] setGravity:iToastGravityCenter] showInView:self.view];
        return;
    }
    
    
    NSDictionary *dicParams=@{@"suggestion":_txtSuggestion.text,
                              @"userID":[AppController sharedInstance].userInfo.userID
                              };
    [Util showLoadingDialog];
    [[AFIntelligentCommunityClient sharedClient] postPath:@"feedback/submitSuggestion" parameters:dicParams success:^(AFHTTPRequestOperation *operation, id JSON) {
        [Util dismissDialog];
        _txtSuggestion.text=@"";
        _lblLength.text=[NSString stringWithFormat:[[I18NControl bundle] localizedStringForKey:@"ramainHowManyChat" value:nil table:nil],kMaxTextLength];
        [[[iToast makeText:[[I18NControl bundle] localizedStringForKey:@"submitSuccess" value:nil table:nil]] setGravity:iToastGravityCenter] showInView:self.view];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Util dismissDialog];
        [Util failOperation:operation.responseData];
    }];
}



@end
