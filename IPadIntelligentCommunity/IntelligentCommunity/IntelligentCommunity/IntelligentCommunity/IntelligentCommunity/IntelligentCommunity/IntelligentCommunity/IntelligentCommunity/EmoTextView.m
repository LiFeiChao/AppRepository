//
//  EmoTextView.m
//  MeetingCloud
//
//  Created by 高 欣 on 12-11-9.
//  Copyright (c) 2012年 Ideal. All rights reserved.
//

#import "EmoTextView.h"
#define ControlsBaseY 0
@interface EmoTextView(){
    HPGrowingTextView *_textView;
//    TSEmojiView *_emoView;
//    CMPopTipView *_popTipView;
}
@end
@implementation EmoTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(36, ControlsBaseY+3, frame.size.width-110, 30)];
        _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        _textView.delegate=self;
        _textView.minNumberOfLines = 1;
        _textView.maxNumberOfLines = 6;
        _textView.returnKeyType = UIReturnKeyDone; //just as an example
        _textView.font = [UIFont systemFontOfSize:15.0f];

        _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        _textView.backgroundColor = [UIColor whiteColor];
        
        // test
        _textView.returnKeyType = UIReturnKeyDone;
        // textView.text = @"test\n\ntest";
        // textView.animateHeightChange = NO; //turns off animation
    
        
        UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
        UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
        entryImageView.frame = CGRectMake(36, ControlsBaseY, frame.size.width-104, 40);
        entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
        UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
        imageView.frame = CGRectMake(0, ControlsBaseY, self.frame.size.width, self.frame.size.height);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // view hierachy
        [self addSubview:imageView];
        [self addSubview:_textView];
        [self addSubview:entryImageView];
        
        UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        
        UIButton *emoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        emoBtn.frame = CGRectMake(0, ControlsBaseY+2, 38, 38);
        emoBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
//        [emoBtn setTitle:@"表情" forState:UIControlStateNormal];
        [emoBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
        emoBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
        emoBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        
//        [emoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [emoBtn addTarget:self action:@selector(popEmoView:) forControlEvents:UIControlEventTouchUpInside];
        [emoBtn setImage:[UIImage imageNamed:@"emo_001"] forState:UIControlStateNormal];
//        [emoBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
//        [emoBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
        [self addSubview:emoBtn];
        
        
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = CGRectMake(self.frame.size.width - 69, ControlsBaseY+8, 63, 27);
        doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [doneBtn setTitle:@"发送" forState:UIControlStateNormal];
        
        [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
        doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
        doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        
        [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(sendData) forControlEvents:UIControlEventTouchUpInside];
        [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
        [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
        [self addSubview:doneBtn];
        
//        UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        //[returnBtn setBackgroundColor:[UIColor redColor]];
//        returnBtn.frame = CGRectMake(0, 0, self.frame.size.width, ControlsBaseY);
//        [returnBtn addTarget:self action:@selector(resignTextViewFirstResponder) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:returnBtn];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark -
#pragma mark HPGrowingTextViewDelegate Methods
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
	CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.frame = r;
}
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    [_textView resignFirstResponder];
    return NO;
}
#pragma mark -
#pragma mark TSEmojiViewDelegate Methods
- (void)didTouchEmojiView:(TSEmojiView*)emojiView touchedEmoji:(NSString*)str
{
    NSRange selectedRange=_textView.selectedRange;
    NSString* orginString=_textView.text;
    NSString *prefixString=[orginString substringToIndex:selectedRange.location];
    NSString *suffixString=[orginString substringFromIndex:selectedRange.location+selectedRange.length];
    _textView.text = [NSString stringWithFormat:@"%@%@%@", prefixString, str,suffixString];
    selectedRange.location=selectedRange.location+1;
    selectedRange.length=0;
    _textView.selectedRange=selectedRange;
    //选择一个表情后界面就消失
    [self.delegate willDismissPopEmoView:self];
}

#pragma mark -
#pragma mark Private methods

-(NSString*) getText
{
    return _textView.text;
}
-(void) setText:(NSString *)text
{
    _textView.text=text;
}
-(void) clearText
{
    _textView.text=@"";
    [_textView resignFirstResponder];
}
-(void) resignTextViewFirstResponder
{
    [_textView resignFirstResponder];
}
-(void) sendData
{
    [self.delegate sendData];
}
 
-(void) popEmoView:(id) sender
{
    
    [self.delegate emoTextView:self willPopEmoViewAnView:sender];
    
//    if(_popTipView.superview){
//        [_popTipView dismissAnimated:YES];
//    }else{
//        if(!_emoView){
//            _emoView = [[TSEmojiView alloc] initWithFrame:CGRectMake(0, 0, 290, 104)];
//            _emoView.delegate = self;
//        }
//        if(!_popTipView){
//            _popTipView = [[CMPopTipView alloc] initWithCustomView:_emoView]; 
//        }
//        _popTipView.animation=CMPopTipAnimationPop;
//        _popTipView.pointDirection=PointDirectionDown;
//        [_popTipView presentPointingAtView:sender inView:self animated:YES];
//    }
}
 
@end
