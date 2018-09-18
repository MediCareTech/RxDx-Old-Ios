
//
//  SmartRxForgotPasswordVC.m
//  SmartRx
//
//  Created by PaceWisdom on 21/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxForgotPasswordVC.h"
#import "SmartRxDashBoardVC.h"

#define kSuccessAlertTag 345

@interface SmartRxForgotPasswordVC ()
{
    MBProgressHUD *HUD;
    UIToolbar* numberToolbar;
}

@end

@implementation SmartRxForgotPasswordVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)navigationBackButton
{
    self.navigationItem.hidesBackButton=YES;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage = [UIImage imageNamed:@"icn_back.png"];
    [backBtn setImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(-40, -2, 100, 40);
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    backButtonView.bounds = CGRectOffset(backButtonView.bounds, 0, -7);
    [backButtonView addSubview:backBtn];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    
    self.navigationItem.leftBarButtonItem = backButton;
    
}
-(void)numberKeyBoardReturn
{
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           //[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"return" style:UIBarButtonItemStyleDone target:self action:@selector(returnWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtMobileNum.inputAccessoryView = numberToolbar;
}
-(void)returnWithNumberPad
{
    [self.txtMobileNum resignFirstResponder];
}
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    [self navigationBackButton];
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    self.txtMobileNum.inputAccessoryView = doneToolbar;
    //[self numberKeyBoardReturn];
   // [self numberKeyBoardReturn];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"])
    {
        self.txtMobileNum.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    }
    
    // Do any additional setup after loading the view.
}
- (void)doneButton:(id)sender
{
    [self.txtMobileNum  resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Request Method
-(void)makeRequestToGetPassword
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"mobile",self.txtMobileNum.text];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mreset"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 22 %@",response);
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        if ([[[response objectAtIndex:0]objectForKey:@"result"]integerValue] == 1)
            
        {
            [[NSUserDefaults standardUserDefaults]setObject:self.txtMobileNum.text forKey:@"MobileNumber"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Your password has been sent to your mobile. Please enter the password to continue" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag=kSuccessAlertTag;
            [alert show];
            
        }
        else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Mobile number you entered is not registered." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Resending password failed. Please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}

-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
}
#pragma mark - Action Methods

- (IBAction)sendPasswordBtnClicked:(id)sender
{
    [self.txtMobileNum resignFirstResponder];
    if ([self.txtMobileNum.text length]> 9)
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestToGetPassword];
        }
        else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            alertView=nil;
        }
    }
    else if([self.txtMobileNum.text length] == 0)
            {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Mobile number cannot be empty" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;

    }
    else if([self.txtMobileNum.text length] < 10)
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Mobile number cannot be less than 10 digits." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;
    }
    
    
}
-(void)homeBtnClicked:(id)sender
{
    
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[SmartRxDashBoardVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)hideKeyBoard:(id)sender
{
    [self.txtMobileNum resignFirstResponder];
}

#pragma mark - Text field delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-numberToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    }];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+numberToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    }];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.txtMobileNum)
    {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 10) ? NO : YES;
    }
    return YES;
}
#pragma mark - Alert Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kSuccessAlertTag && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [HUD hide:YES];
    [HUD removeFromSuperview];

    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestToGetPassword];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
}
-(void)errorSectionId:(id)sender
{
    [HUD hide:YES];
    [HUD removeFromSuperview];

    self.view.userInteractionEnabled = YES;
}
#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

@end
