//
//  CalculatorViewController.h
//  IntelligenceCommunity
//
//  Created by Aidan on 5/19/14.
//  Copyright (c) 2014 com.ideal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController
{

    //Where all the calculations are shown
    IBOutlet UILabel *mainLabel;

    //Stores the last known value before an operand is pressed
    double lastKnownValue;

    NSString *operand;


    BOOL isMainLabelTextTemporary;
}

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

- (IBAction)clearPressed:(id)sender;
- (IBAction)numberButtonPressed:(id)sender;
- (IBAction)decimalPressed:(id)sender;
- (IBAction)operandPressed:(id)sender;
- (IBAction)equalsPressed:(id)sender;
- (IBAction)exchangePressed:(id)sender;

@end
