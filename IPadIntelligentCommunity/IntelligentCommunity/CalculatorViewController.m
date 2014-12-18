//
//  CalculatorViewController.m
//  IntelligenceCommunity
//
//  Created by Aidan on 5/19/14.
//  Copyright (c) 2014 com.ideal. All rights reserved.
//

#import "CalculatorViewController.h"
#import "I18NControl.h"

#define defaultChangeRate   7.75

#define changeMode_To_US    @"toUSD"

#define changeMode_To_HK    @"toHKD"

@interface CalculatorViewController ()
@property (weak, nonatomic) IBOutlet UITextField *changeRateText;
@property (weak, nonatomic) IBOutlet UIButton *btChange;
@property (weak, nonatomic) IBOutlet UILabel *lbMoney;
@property (weak, nonatomic) IBOutlet UILabel *lbChangeRate;

@end

@implementation CalculatorViewController



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
        
    // ［返回］按钮
//    UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnLeft.frame = CGRectMake(0, 0, 46, 42);
//    [btnLeft setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//    [btnLeft addTarget:self action:@selector(showBackView) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    
   
    
    [self.changeRateText setDelegate:self];
    [self.changeRateText setReturnKeyType:UIReturnKeyDone];
    [self.changeRateText addTarget:self
                       action:@selector(textFieldFinished:)
             forControlEvents:UIControlEventEditingDidEndOnExit];
    
    self.changeRateText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    //read changeRate and changeMode, if null use default value
   
    if (self.changeRate == nil)
        self.changeRate = [NSString stringWithFormat:@"%.2f", defaultChangeRate];
    
    self.changeRateText.text = self.changeRate;

    
    if (self.changeMode == nil)
        self.changeMode = changeMode_To_US;
    
    [self updateUI];
    
    self.lbChangeRate.text = [[I18NControl bundle] localizedStringForKey:@"changeRate" value:nil table:nil];
    [self.navigationBar.topItem setTitle:[[I18NControl bundle] localizedStringForKey:@"calculator" value:nil table:nil]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [AppController sharedInstance].navigationController.navigationBarHidden=YES;
}

// 返回
//- (void)showBackView
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else
    {
        return YES;
    }
}

//calculator

- (IBAction)clearPressed:(id)sender
{
    lastKnownValue = 0;
    mainLabel.text = @"0";
    isMainLabelTextTemporary = NO;
    operand = @"";
}

- (BOOL)doesStringContainDecimal:(NSString*) string
{
    NSString *searchForDecimal = @".";
    NSRange range = [string rangeOfString:searchForDecimal];
    
    //If we find a decimal return YES. Otherwise, NO
    if (range.location != NSNotFound)
        return YES;
    return NO;
}

- (IBAction)numberButtonPressed:(id)sender
{
    //Resets label after calculations are shown from previous operations
    if (isMainLabelTextTemporary)
    {
        mainLabel.text = @"0";
        isMainLabelTextTemporary = NO;
    }
    
    //Get the string from the button label and main label
    NSString *numString = ((UIButton*)sender).titleLabel.text;
    NSString *mainLabelString = mainLabel.text;
    
    //If mainLabel = 0 and does not contain a decimal then remove the 0
    if ([mainLabelString doubleValue] == 0 && [self doesStringContainDecimal:mainLabelString] == NO)
        mainLabelString = @"";
    
    //Combine the two strings together
    mainLabel.text = [mainLabelString stringByAppendingFormat:numString];
}

- (IBAction)decimalPressed:(id)sender
{
    //Only add a decimal if the string doesnt already contain one.
    if ([self doesStringContainDecimal:mainLabel.text] == NO)
        mainLabel.text = [mainLabel.text stringByAppendingFormat:@"."];
}

- (void)calculate
{
    //Get the current value on screen
    double currentValue = [mainLabel.text doubleValue];
    
    // If we already have a value stored and the current # is not 0 , add/subt/mult/divide the values
    if (lastKnownValue != 0 && currentValue != 0)
    {
        if ([operand isEqualToString:@"+"])
            lastKnownValue += currentValue;
        else if ([operand isEqualToString:@"-"])
            lastKnownValue -= currentValue;
        else if ([operand isEqualToString:@"x"])
            lastKnownValue *= currentValue;
        else if ([operand isEqualToString:@"/"])
        {
            //You can't divide by 0!
            if (currentValue == 0)
                [self clearPressed:nil];
            else
                lastKnownValue /= currentValue;
        }
    }
    else
        lastKnownValue = currentValue;
    
    //Set the new value to the main label
    mainLabel.text = [NSString stringWithFormat:@"%g",lastKnownValue];
    
    //Make the main label text temp, so we can erase when the next value is entered
    isMainLabelTextTemporary = YES;
}

- (IBAction)operandPressed:(id)sender
{
    //Calculate from previous operand
    [self calculate];
    
    //Get the NEW operand from the button pressed
    operand = ((UIButton*)sender).titleLabel.text;
}

- (IBAction)equalsPressed:(id)sender
{
    [self calculate];
    
    //reset operand;
    operand = @"";
}

//exchange rate
- (IBAction)exchangePressed:(id)sender
{
    
    [self calculateExchange];

}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    
    // allow backspace
    if (range.length > 0 && [string length] == 0) {
        return YES;
    }
    
    
    
    // do not allow . at the beggining
    if (range.location == 0 && [string isEqualToString:@"."]) {
        
        return NO;
    }
    
    //
    if ([string isEqualToString:@"."] && [self doesStringContainDecimal:textField.text] == YES) {
        
        return NO;
        
    }
    
    
    // set the text field value manually
    NSString *newValue = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    newValue = [[newValue componentsSeparatedByCharactersInSet:nonNumberSet] componentsJoinedByString:@""];
    textField.text = newValue;
    // return NO because we're manually setting the value
    return NO;
}

- (void)calculateExchange
{
    
    if(lastKnownValue == 0){
    
        lastKnownValue = [mainLabel.text doubleValue];
    }
    
    double changeRate = [self.changeRateText.text doubleValue];
    
    
  
    if ([self.changeMode isEqualToString:changeMode_To_US]){
        lastKnownValue /= changeRate;
        self.changeMode = changeMode_To_HK;
    }
    
    else if ([self.changeMode isEqualToString:changeMode_To_HK]){
        lastKnownValue *= changeRate;
        self.changeMode = changeMode_To_US;
    }
    
    [self updateUI];
    

    //Set the new value to the main label
    mainLabel.text = [NSString stringWithFormat:@"%.2f",lastKnownValue];
    
    //Make the main label text temp, so we can erase when the next value is entered
    isMainLabelTextTemporary = YES;
}

- (void)updateUI {
    
    
    if ([self.changeMode isEqualToString:changeMode_To_US]){
        [self.btChange setTitle:[[I18NControl bundle] localizedStringForKey:@"toUSD" value:nil table:nil] forState:UIControlStateNormal];
        self.lbMoney.text = [[I18NControl bundle] localizedStringForKey:@"HKD" value:nil table:nil];
    }
    
    else if ([self.changeMode isEqualToString:changeMode_To_HK]){
        
        [self.btChange setTitle:[[I18NControl bundle] localizedStringForKey:@"toHKD" value:nil table:nil] forState:UIControlStateNormal];
        self.lbMoney.text = [[I18NControl bundle] localizedStringForKey:@"USD" value:nil table:nil];
    }
    
}



- (IBAction)changeRateValueChanged:(UITextField *)sender {
    
    self.changeRate = sender.text;
}

- (NSString *)changeMode {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    return [def valueForKey:@"changeMode"];
}

- (void)setChangeMode:(NSString *)changeMode{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    //持久化
    [def setValue:changeMode forKey:@"changeMode"];
    
}

- (NSString *)changeRate {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    return [def valueForKey:@"changeRate"];
}

- (void)setChangeRate:(NSString *)changeRate{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    //持久化
    [def setValue:changeRate forKey:@"changeRate"];
    
}


@end
