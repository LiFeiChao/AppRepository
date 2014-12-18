//
//  EmoTextView.h
//  MeetingCloud
//
//  Created by 高 欣 on 12-11-9.
//  Copyright (c) 2012年 Ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "TSEmojiView.h"
#import "CMPopTipView.h"
@protocol EmoTextViewDelegate;
@interface EmoTextView : UIView<HPGrowingTextViewDelegate,TSEmojiViewDelegate>
@property (nonatomic,unsafe_unretained) id<EmoTextViewDelegate> delegate;
@property (nonatomic,copy,getter = getText,setter = setText:) NSString* text;
-(void) clearText;
-(void) resignTextViewFirstResponder;
@end
@protocol EmoTextViewDelegate

- (void)emoTextView:(EmoTextView *)emoTextView willPopEmoViewAnView:(id) sender;
- (void)willDismissPopEmoView:(EmoTextView *)emoTextView;
- (void) sendData;

@end
