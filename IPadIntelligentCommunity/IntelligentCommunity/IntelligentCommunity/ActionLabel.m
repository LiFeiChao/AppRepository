//
//  ActionLabel.m
//  BestPay
//
//  Created by 高 欣 on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ActionLabel.h"
#import "AppController.h"
@implementation ActionLabel
@synthesize type;
-(id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchWithTapGestureRecognizer:)];
        [self addGestureRecognizer:tapGestureRecognizer];
//        [tapGestureRecognizer release];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)awakeAfterUsingCoder:(NSCoder*)aDecoder {
     UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchWithTapGestureRecognizer:)];
     [self addGestureRecognizer:tapGestureRecognizer];
     //[tapGestureRecognizer release];
    return self;
}

//-(void) awakeFromNib {
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchWithTapGestureRecognizer:)];
//    [self addGestureRecognizer:tapGestureRecognizer];
//    [tapGestureRecognizer release];
//}
-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext(); 
    CGSize fontSize =[self.text sizeWithFont:self.font 
                                    forWidth:self.bounds.size.width
                               lineBreakMode:UILineBreakModeTailTruncation];
    
    // Get the fonts color. 
    const float * colors = CGColorGetComponents([UIColor blueColor].CGColor);
    // Sets the color to draw the line
    CGContextSetRGBStrokeColor(ctx, colors[0], colors[1], colors[2], 1.0f); // Format : RGBA
    
    // Line Width : make thinner or bigger if you want
    CGContextSetLineWidth(ctx, 1.0f);
    
    
    
    // Calculate the starting point (left) and target (right)
    CGPoint l = CGPointMake(0, 
                            self.frame.size.height/2.0 +fontSize.height/2.0);
    CGPoint r = CGPointMake(fontSize.width, 
                            self.frame.size.height/2.0 + fontSize.height/2.0);
    
    // Add Move Command to point the draw cursor to the starting point
    CGContextMoveToPoint(ctx, l.x, l.y);
    
    // Add Command to draw a Line
    CGContextAddLineToPoint(ctx, r.x, r.y);
    
    // Actually draw the line.
    CGContextStrokePath(ctx);
    
    // should be nothing, but who knows...
    [super drawRect:rect];   
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
didFinishWithResult:(MFMailComposeResult)result 
error:(NSError *)error __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0)
{
	switch (result) {
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSent: {           
            //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sharing" 
            //                                                                message:@"Succeed to send email!"
            //                                                               delegate:nil 
            //                                                      cancelButtonTitle:@"OK"
            //                                                      otherButtonTitles:nil];
            //            [alertView show];
            //            [alertView release];
 
        }
			break;
		case MFMailComposeResultFailed: {           
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sharing" 
                                                                message:@"Fail to send email!"
                                                               delegate:nil 
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            //[alertView release];
            
        }
			break;
		default:
			break;
            
	}
    [[AppController sharedInstance].navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark private methods

- (void) didTouchWithTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateRecognized){
        NSString *strType=[type lowercaseString];
        NSString *url;
        if([strType isEqualToString:@"tel"]){
            NSString* tel=[self.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
            url=[NSString stringWithFormat:@"tel://%@",tel];
        }else if([strType isEqualToString:@"web"]){
            url=[NSString stringWithFormat:@"%@",self.text];
        }else if([strType isEqualToString:@"mail"]){
            NSArray *to=[[NSArray alloc] initWithObjects:self.text, nil];
            [self shareViaMail:to body:nil subject:nil];
//            [to release];
            return;
            //url=[NSString stringWithFormat:@"mailto://%@",self.text];
            
        }else {
            return;
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}
- (void)shareViaMail:(NSArray*)to body:(NSString *)mailBody subject:(NSString *)subject
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil) {
		if ([mailClass canSendMail]) [self displayShareComposerSheet:to body:mailBody 
                                                             subject:subject];
		else [self launchShareMailAppOnDevice:to body:mailBody subject:subject];
	}
	else [self launchShareMailAppOnDevice:to body:mailBody subject:subject];
}
- (void)displayShareComposerSheet:(NSArray*)to body:(NSString *)mailBody 
                          subject:(NSString *)subject 
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	[[picker navigationBar] setTintColor:[UIColor blackColor]];
	picker.mailComposeDelegate = self;
    [picker setToRecipients:to];
	[picker setSubject:subject];
	[picker setMessageBody:mailBody isHTML:NO];
	[[AppController sharedInstance].navigationController presentModalViewController:picker animated:YES];
    
	//[picker release];
}

- (void)launchShareMailAppOnDevice:(NSArray*)to body:(NSString *)mailBody 
                           subject:(NSString *)subject
{
	NSString* email=[NSString stringWithFormat:@"mailto:%@to=%@&subject=%@&body=%@",
                     [to objectAtIndex:0],
                     [to objectAtIndex:0],
                     [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                     [mailBody stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

 
//-(void) dealloc{
//    self.type=nil;
//    [super dealloc];
//}
@end
