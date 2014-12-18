//
//  BECheckBox.m
//  
//
//  Created by jordenwu-Mac on 10-11-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "CheckBox.h"
@implementation CheckBox

@synthesize isChecked;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.contentHorizontalAlignment  = UIControlContentHorizontalAlignmentLeft;		
//		[self setImage:[UIImage imageNamed:@"btn_check.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_check.png"] forState:UIControlStateNormal];
		[self addTarget:self action:@selector(checkBoxClicked) forControlEvents:UIControlEventTouchDown];
	}
    return self;
}

- (id) awakeAfterUsingCoder:(NSCoder*)aDecoder {
    self.contentHorizontalAlignment  = UIControlContentHorizontalAlignmentLeft;	
    [self addTarget:self action:@selector(checkBoxClicked) forControlEvents:UIControlEventTouchDown];
    return self;
}

-(void)setTarget:(id)tar fun:(SEL)ff
{
	target=tar;
	fun=ff;
}
-(void)setIsChecked:(BOOL)check
{   
    NSLog(@"check:%d",check);
	isChecked=check;
    NSLog(@"is:%d",isChecked);
	if (check) {
	//	[self setImage:[UIImage imageNamed:@"btn_checked.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_checked.png"]forState:UIControlStateNormal];
	}
	else {
	//	[self setImage:[UIImage imageNamed:@"btn_check.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_check.png"]forState:UIControlStateNormal];

	}
}

-(IBAction) checkBoxClicked
{
	if(self.isChecked ==NO){
		self.isChecked =YES;
//		[self setImage:[UIImage imageNamed:@"btn_checked.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_checked.png"]forState:UIControlStateNormal];
		
	}else{
		self.isChecked =NO;
//		[self setImage:[UIImage imageNamed:@"btn_check.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_check.png"]forState:UIControlStateNormal];
		
	}
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[target performSelector:fun];
    #pragma clang diagnostic pop
}

/*- (void)dealloc {
	target=nil;
    [super dealloc];
}*/


@end

