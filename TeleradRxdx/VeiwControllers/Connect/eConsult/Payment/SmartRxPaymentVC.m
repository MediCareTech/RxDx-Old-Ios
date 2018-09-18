//
//  SmartRxPaymentVC.m
//  SmartRx
//
//  Created by Manju Basha on 07/04/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import "SmartRxPaymentVC.h"
#import "SmartRxDashBoardVC.h"
#import "UIUtility.h"
#import "MerchantConstants.h"
#import "WebViewViewController.h"
#define toErrorDescription(error) [error.userInfo objectForKey:NSLocalizedDescriptionKey]

@interface SmartRxPaymentVC ()
{
    MBProgressHUD *HUD;
    CGFloat viewWidth, viewHeight;
    UIToolbar* numberToolbar;
    UIView *debitView, *creditView;
    CTSPaymentLayer *paymentLayer;
    CTSContactUpdate *debitContactInfo, *creditContactInfo;
    CTSUserAddress* addressInfo;
    UIScrollView *debitScrollView, *creditScrollView;
    NSString *cardType;
    int kOFFSET_FOR_KEYBOARD;
    BOOL keyboardHide;
}
@end

@implementation SmartRxPaymentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    keyboardHide = YES;
    paymentLayer = [[CTSPaymentLayer alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self navigationBackButton];
    viewWidth = CGRectGetWidth(self.view.frame);
    
    addressInfo = [[CTSUserAddress alloc] init];
    addressInfo.city = @"city";
    addressInfo.country = @"country";
    addressInfo.state = @"state";
    addressInfo.street1 = @"street1";
    addressInfo.street2 = @"street2";
    addressInfo.zip = @"401209";
    UIGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(doneButton:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    // Tying up the segmented control to a scroll view
    self.segmentedControl4 = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 40)];
    self.segmentedControl4.sectionTitles = @[@"Debit Card", @"Credit Card"];
    //    self.segmentedControl4.selectedSegmentIndex = 0;
    self.segmentedControl4.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    self.segmentedControl4.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor],  UITextAttributeFont:[UIFont systemFontOfSize:16]};//@{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.segmentedControl4.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:7.0/255.0 green:92.0/255.0 blue:176.0/255.0 alpha:1]};//@{NSForegroundColorAttributeName : [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]};
    self.segmentedControl4.borderType = HMSegmentedControlBorderTypeRight;
    self.segmentedControl4.borderWidth = 1.0;
    self.segmentedControl4.borderColor = [UIColor lightGrayColor];
    self.segmentedControl4.selectionIndicatorColor = [UIColor colorWithRed:7.0/255.0 green:92.0/255.0 blue:176.0/255.0 alpha:1];
    self.segmentedControl4.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl4.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl4.tag = 3;
    
    __weak typeof(self) weakSelf = self;
    [self.segmentedControl4 setIndexChangeBlock:^(NSInteger index) {
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(viewWidth * index, 0, viewWidth, 200) animated:YES];
    }];
    
    [self.view addSubview:self.segmentedControl4];
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, self.segmentedControl4.frame.size.height, viewWidth, 1)];
    bottomBorder.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:bottomBorder];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 41, viewWidth, 400)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    // colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1];// colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(viewWidth * [self.segmentedControl4.sectionTitles count], 200);
    self.scrollView.delegate = self;
    [self.scrollView scrollRectToVisible:CGRectMake(viewWidth, 0, viewWidth, 400) animated:NO];
    [self.view addSubview:self.scrollView];
    
    [self setDebitCardView];
    [self setCreditCardView];
    //    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 400)];
    //    [self setApperanceForLabel:label1];
    //    label1.text = @"Debit Card";
    //    [self.scrollView addSubview:label1];
    //
    //    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth, 0, viewWidth, 400)];
    //    [self setApperanceForLabel:label2];
    //    label2.text = @"Credit card";
    //    [self.scrollView addSubview:label2];
    
    [self.segmentedControl4 setSelectedSegmentIndex:0 animated:YES];
    kOFFSET_FOR_KEYBOARD = 0.0;
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    keyboardHide = YES;
    kOFFSET_FOR_KEYBOARD = 0.0;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(void)setViewMovedUp:(BOOL)movedUp
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
        
    }
    else
    {
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
        
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

-(void)keyboardWillShow
{
    keyboardHide = NO;
    
    if(([self.debitEmailTextField isFirstResponder])||([self.creditEmailTextField isFirstResponder])||([self.debitCardNumTextField isFirstResponder])||([self.creditCardNumTextField isFirstResponder]))
    {
        if (!keyboardHide)
            [self checkKoffset];
        kOFFSET_FOR_KEYBOARD = 0.0;
    }
    if(([self.debitExpTextField isFirstResponder])||([self.debitCvvTextField isFirstResponder])||([self.creditExpTextField isFirstResponder])||([self.creditCvvTextField isFirstResponder]))
    {
        if (!keyboardHide)
            [self checkKoffset];
        kOFFSET_FOR_KEYBOARD = 20.0;
    }
    else if(([self.debitAmountTextField isFirstResponder])||([self.creditAmountTextField isFirstResponder]))
    {
        if (!keyboardHide)
            [self checkKoffset];
        kOFFSET_FOR_KEYBOARD = 60.0;
    }
    else if(([self.debitNameTextField isFirstResponder])||([self.creditNameTextField isFirstResponder]))
    {
        if (!keyboardHide)
            [self checkKoffset];
        kOFFSET_FOR_KEYBOARD = 100.0;
    }
    
    NSLog(@"ssss %f",self.view.frame.origin.y);
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
    
}

-(void)keyboardWillHide
{
    keyboardHide=YES;
    NSLog(@"ssss %f",self.view.frame.origin.y);
    //    kOFFSET_FOR_KEYBOARD = keyboardOffset;
    if ((self.view.frame.origin.y >= 0) || ((([self.debitNameTextField isFirstResponder])||([self.creditNameTextField isFirstResponder])) && keyboardHide))
    {
        [self setViewMovedUp:NO];
    }
    else if (self.view.frame.origin.y < 0 && !((([self.debitNameTextField isFirstResponder])||([self.creditNameTextField isFirstResponder])) && keyboardHide))
    {
        [self setViewMovedUp:YES];
    }
    kOFFSET_FOR_KEYBOARD = 0.0;
}

- (void)checkKoffset
{
    if (kOFFSET_FOR_KEYBOARD > 0)
    {
        [self setViewMovedUp:NO];
    }
    
}
- (void)adjustViewAndKeyboard
{
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    UIButton *btnFaq = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_home.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    [btnFaq addTarget:self action:@selector(homeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;
    
}

- (void)setApperanceForLabel:(UILabel *)label {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    label.backgroundColor = color;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:21.0f];
    label.textAlignment = NSTextAlignmentCenter;
}

#pragma mark Action Methods

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

- (void)doneButton:(id)sender {
    
    [self.debitAmountTextField resignFirstResponder];
    [self.debitEmailTextField resignFirstResponder];
    [self.debitCardNumTextField resignFirstResponder];
    [self.debitCvvTextField resignFirstResponder];
    [self.debitExpTextField resignFirstResponder];
    [self.debitNameTextField resignFirstResponder];
    
    [self.creditAmountTextField resignFirstResponder];
    [self.creditEmailTextField resignFirstResponder];
    [self.creditCardNumTextField resignFirstResponder];
    [self.creditCvvTextField resignFirstResponder];
    [self.creditExpTextField resignFirstResponder];
    [self.creditNameTextField resignFirstResponder];
    
}

#pragma mark spinner alert & picker
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
#pragma mark - AlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - setView methods
- (void)setDebitCardView
{
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    debitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 400)];
    self.debitEmailTextField = [[SmartRxTextFieldLeftImage alloc] initWithFrame:CGRectMake(10, 20, viewWidth-20, 30)];
    self.debitEmailTextField.delegate = self;
    self.debitEmailTextField.placeholder = @"Email";
    self.debitEmailTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mail.png"]];
    self.debitEmailTextField.leftView.frame = CGRectMake(self.debitEmailTextField.leftView.frame.origin.x, self.debitEmailTextField.leftView.frame.origin.y, self.debitEmailTextField.leftView.frame.size.width-10, self.debitEmailTextField.leftView.frame.size.height-10);
    self.debitEmailTextField.layer.cornerRadius=0.0f;
    self.debitEmailTextField.layer.masksToBounds = YES;
    self.debitEmailTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.debitEmailTextField.layer.borderWidth= 1.0f;
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"emailId"] length] >0 && [[NSUserDefaults standardUserDefaults]objectForKey:@"emailId"]!=nil)
        self.debitEmailTextField.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"emailId"];
    else
        if ([self.email length] > 0 && self.email != nil)
            self.debitEmailTextField.text = self.email;
    [debitView addSubview:self.debitEmailTextField];
    
    self.debitCardNumTextField = [[SmartRxTextFieldLeftImage alloc] initWithFrame:CGRectMake(10, 60, viewWidth-20, 30)];
    self.debitCardNumTextField.delegate = self;
    [self.debitCardNumTextField setKeyboardType:UIKeyboardTypeNumberPad];
    self.debitCardNumTextField.placeholder = @"Card Number";
    self.debitCardNumTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card.png"]];
    self.debitCardNumTextField.leftView.frame = CGRectMake(self.debitCardNumTextField.leftView.frame.origin.x, self.debitCardNumTextField.leftView.frame.origin.y, self.debitCardNumTextField.leftView.frame.size.width-10, self.debitCardNumTextField.leftView.frame.size.height-10);
    
    self.debitCardNumTextField.layer.cornerRadius=0.0f;
    self.debitCardNumTextField.layer.masksToBounds = YES;
    self.debitCardNumTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.debitCardNumTextField.layer.borderWidth= 1.0f;
    
    [debitView addSubview:self.debitCardNumTextField];
    
    
    self.debitExpTextField = [[SmartRxTextFieldLeftImage alloc] initWithFrame:CGRectMake(10, 100, (viewWidth/2)+20, 30)];
    self.debitExpTextField.delegate = self;
    self.debitExpTextField.placeholder = @"Expiry Date (mm/yy)";
    [self.debitExpTextField setValue:[UIFont systemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    //    self.debitExpTextField.attributedPlaceholder =
    //    [[NSAttributedString alloc] initWithString:@"Expiry Date (mm/yyyy)"
    //                                    attributes:@{
    //                                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
    //                                                 NSFontAttributeName : [UIFont systemFontOfSize:10]
    //                                                 }
    //     ];
    self.debitExpTextField.leftView = [[UIImageView alloc] init];
    self.debitExpTextField.leftView.frame = CGRectMake(self.debitExpTextField.leftView.frame.origin.x, self.debitExpTextField.leftView.frame.origin.y, self.debitExpTextField.leftView.frame.size.width-10, self.debitExpTextField.leftView.frame.size.height-10);
    [self.debitExpTextField setLeftViewMode:UITextFieldViewModeUnlessEditing];
    self.debitExpTextField.layer.cornerRadius=0.0f;
    self.debitExpTextField.layer.masksToBounds = YES;
    self.debitExpTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.debitExpTextField.layer.borderWidth= 1.0f;
    [debitView addSubview:self.debitExpTextField];
    
    self.debitCvvTextField = [[SmartRxTextFieldLeftImage alloc] initWithFrame:CGRectMake(self.debitExpTextField.frame.origin.x + self.debitExpTextField.frame.size.width+10, 100, 110, 30)];
    self.debitCvvTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cvv.png"]];
    self.debitCvvTextField.leftView.frame = CGRectMake(self.debitCvvTextField.leftView.frame.origin.x, self.debitCvvTextField.leftView.frame.origin.y, self.debitCvvTextField.leftView.frame.size.width-10, self.debitCvvTextField.leftView.frame.size.height-10);
    [self.debitCvvTextField setLeftViewMode:UITextFieldViewModeUnlessEditing];
    self.debitCvvTextField.secureTextEntry = YES;
    self.debitCvvTextField.delegate = self;
    [self.debitCvvTextField setKeyboardType:UIKeyboardTypeNumberPad];
    self.debitCvvTextField.placeholder = @"CVV";
    self.debitCvvTextField.layer.cornerRadius=0.0f;
    self.debitCvvTextField.layer.masksToBounds = YES;
    self.debitCvvTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.debitCvvTextField.layer.borderWidth= 1.0f;
    [debitView addSubview:self.debitCvvTextField];
    
    self.debitAmountTextField = [[SmartRxTextFieldLeftImage alloc] initWithFrame:CGRectMake(10, 140, viewWidth-20, 30)];
    self.debitAmountTextField.delegate = self;
    self.debitAmountTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"amount.png"]];
    self.debitAmountTextField.leftView.frame = CGRectMake(self.debitAmountTextField.leftView.frame.origin.x, self.debitAmountTextField.leftView.frame.origin.y, self.debitAmountTextField.leftView.frame.size.width-15, self.debitAmountTextField.leftView.frame.size.height-15);
    self.debitAmountTextField.layer.cornerRadius=0.0f;
    self.debitAmountTextField.layer.masksToBounds = YES;
    [self.debitAmountTextField setKeyboardType:UIKeyboardTypeNumberPad];
    self.debitAmountTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.debitAmountTextField.layer.backgroundColor=[[UIColor colorWithRed:(226/255.0) green:(226/255.0) blue:(226/255.0) alpha:1.0]CGColor];
    self.debitAmountTextField.layer.borderWidth= 1.0f;
    if (self.costValue)
        self.debitAmountTextField.text = self.costValue;
    [debitView addSubview:self.debitAmountTextField];
    
    self.debitNameTextField = [[SmartRxTextFieldLeftImage alloc] initWithFrame:CGRectMake(10, 180, viewWidth-20, 30)];
    self.debitNameTextField.delegate = self;
    self.debitNameTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"name.png"]];
    self.debitNameTextField.leftView.frame = CGRectMake(self.debitNameTextField.leftView.frame.origin.x, self.debitNameTextField.leftView.frame.origin.y, self.debitNameTextField.leftView.frame.size.width-10, self.debitNameTextField.leftView.frame.size.height-10);
    
    self.debitNameTextField.layer.cornerRadius=0.0f;
    self.debitNameTextField.placeholder = @"Name on card";
    self.debitNameTextField.layer.masksToBounds = YES;
    self.debitNameTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.debitNameTextField.layer.borderWidth= 1.0f;
    [debitView addSubview:self.debitNameTextField];
    
    self.debitPayBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, self.debitNameTextField.frame.origin.y+self.debitNameTextField.frame.size.height+40, viewWidth-20, 50)];
    [self.debitPayBtn setTitle:@"Pay" forState:UIControlStateNormal] ;//@"Pay";
    [self.debitPayBtn setBackgroundImage:[UIImage imageNamed:@"bg_register.png"] forState:UIControlStateNormal];
    [self.debitPayBtn addTarget:self action:@selector(debitCardPayment:) forControlEvents:UIControlEventTouchUpInside];
    [debitView addSubview:self.debitPayBtn];
    
    debitScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, viewWidth-10, viewHeight)];
    NSLog(@"********************Debit value is : %f", self.debitPayBtn.frame.origin.y + self.debitPayBtn.frame.size.height+10);
    debitScrollView.contentSize = CGSizeMake(viewWidth-10, self.debitPayBtn.frame.origin.y + self.debitPayBtn.frame.size.height+10);
    debitScrollView.delegate = self;
    
    //    [debitScrollView addSubview:debitView];
    //    [self.scrollView addSubview:debitScrollView];
    [self.scrollView addSubview:debitView];
    
    //
    //    self.debitEmailTextField.text = @"manjubasha1090@gmail.com";
    //    self.debitCardNumTextField.text = @"4293932027990029";
    //    self.debitExpTextField.text = @"07/2024";
    //    self.debitCvvTextField.text = @"987";
    //    self.debitNameTextField.text = @"Manju Basha";
    
}

- (void)setCreditCardView
{
    creditView = [[UIView alloc] initWithFrame:CGRectMake(viewWidth, 0, viewWidth, 400)];
    self.creditEmailTextField = [[SmartRxTextFieldLeftImage alloc] initWithFrame:CGRectMake(10, 20, viewWidth-20, 30)];
    self.creditEmailTextField.delegate = self;
    self.creditEmailTextField.placeholder = @"Email";
    self.creditEmailTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mail.png"]];
    self.creditEmailTextField.leftView.frame = CGRectMake(self.creditEmailTextField.leftView.frame.origin.x, self.creditEmailTextField.leftView.frame.origin.y, self.creditEmailTextField.leftView.frame.size.width-10, self.creditEmailTextField.leftView.frame.size.height-10);
    self.creditEmailTextField.layer.cornerRadius=0.0f;
    self.creditEmailTextField.layer.masksToBounds = YES;
    self.creditEmailTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"emailId"] length] > 0 && [[NSUserDefaults standardUserDefaults]objectForKey:@"emailId"]!=nil)
        self.creditEmailTextField.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"emailId"];
    else
        if ([self.email length] > 0 && self.email != nil)
            self.creditEmailTextField.text = self.email;
    self.creditEmailTextField.layer.borderWidth= 1.0f;
    [creditView addSubview:self.creditEmailTextField];
    
    
    self.creditCardNumTextField = [[SmartRxTextFieldLeftImage alloc] initWithFrame:CGRectMake(10, 60, viewWidth-20, 30)];
    self.creditCardNumTextField.delegate = self;
    [self.creditCardNumTextField setKeyboardType:UIKeyboardTypeNumberPad];
    self.creditCardNumTextField.placeholder = @"Card number";
    self.creditCardNumTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card.png"]];
    self.creditCardNumTextField.leftView.frame = CGRectMake(self.creditCardNumTextField.leftView.frame.origin.x, self.creditCardNumTextField.leftView.frame.origin.y, self.creditCardNumTextField.leftView.frame.size.width-10, self.creditCardNumTextField.leftView.frame.size.height-10);
    self.creditCardNumTextField.layer.cornerRadius=0.0f;
    self.creditCardNumTextField.layer.masksToBounds = YES;
    self.creditCardNumTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.creditCardNumTextField.layer.borderWidth= 1.0f;
    [creditView addSubview:self.creditCardNumTextField];
    
    
    self.creditExpTextField = [[SmartRxTextFieldLeftImage alloc] initWithFrame:CGRectMake(10, 100, (viewWidth/2)+20, 30)];
    self.creditExpTextField.delegate = self;
    self.creditExpTextField.placeholder = @"Expiry Date (mm/yy)";
    [self.creditExpTextField setValue:[UIFont systemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    self.creditExpTextField.leftView = [[UIImageView alloc] init];
    self.creditExpTextField.leftView.frame = CGRectMake(self.creditExpTextField.leftView.frame.origin.x, self.creditExpTextField.leftView.frame.origin.y, self.creditExpTextField.leftView.frame.size.width-10, self.creditExpTextField.leftView.frame.size.height-10);
    [self.creditExpTextField setLeftViewMode:UITextFieldViewModeUnlessEditing];
    self.creditExpTextField.layer.cornerRadius=0.0f;
    self.creditExpTextField.layer.masksToBounds = YES;
    self.creditExpTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.creditExpTextField.layer.borderWidth= 1.0f;
    [creditView addSubview:self.creditExpTextField];
    
    self.creditCvvTextField = [[SmartRxTextFieldLeftImage alloc] initWithFrame:CGRectMake(self.creditExpTextField.frame.origin.x + self.creditExpTextField.frame.size.width+10, 100, 110, 30)];
    self.creditCvvTextField.delegate = self;
    self.creditCvvTextField.secureTextEntry = YES;
    [self.creditCvvTextField setKeyboardType:UIKeyboardTypeNumberPad];
    self.creditCvvTextField.leftView = [[UIImageView alloc] init];
    self.creditCvvTextField.leftView.frame = CGRectMake(self.creditCvvTextField.leftView.frame.origin.x, self.creditCvvTextField.leftView.frame.origin.y, self.creditCvvTextField.leftView.frame.size.width-10, self.creditCvvTextField.leftView.frame.size.height-10);
    [self.creditCvvTextField setLeftViewMode:UITextFieldViewModeUnlessEditing];
    self.creditCvvTextField.placeholder = @"CVV";
    self.creditCvvTextField.layer.cornerRadius=0.0f;
    self.creditCvvTextField.layer.masksToBounds = YES;
    self.creditCvvTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.creditCvvTextField.layer.borderWidth= 1.0f;
    [creditView addSubview:self.creditCvvTextField];
    
    
    self.creditAmountTextField = [[SmartRxTextFieldLeftImage alloc] initWithFrame:CGRectMake(10, 140, viewWidth-20, 30)];
    self.creditAmountTextField.delegate = self;
    [self.creditAmountTextField setKeyboardType:UIKeyboardTypeNumberPad];
    self.creditAmountTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"amount.png"]];
    self.creditAmountTextField.leftView.frame = CGRectMake(self.creditAmountTextField.leftView.frame.origin.x, self.creditAmountTextField.leftView.frame.origin.y, self.creditAmountTextField.leftView.frame.size.width-15, self.creditAmountTextField.leftView.frame.size.height-15);
    self.creditAmountTextField.layer.cornerRadius=0.0f;
    self.creditAmountTextField.layer.masksToBounds = YES;
    self.creditAmountTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.creditAmountTextField.layer.backgroundColor=[[UIColor colorWithRed:(226/255.0) green:(226/255.0) blue:(226/255.0) alpha:1.0]CGColor];
    self.creditAmountTextField.layer.borderWidth= 1.0f;
    if (self.costValue)
        self.creditAmountTextField.text = self.costValue;
    [creditView addSubview:self.creditAmountTextField];
    
    self.creditNameTextField = [[SmartRxTextFieldLeftImage alloc] initWithFrame:CGRectMake(10, 180, viewWidth-20, 30)];
    self.creditNameTextField.delegate = self;
    self.creditNameTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"name.png"]];
    self.creditNameTextField.leftView.frame = CGRectMake(self.creditNameTextField.leftView.frame.origin.x, self.creditNameTextField.leftView.frame.origin.y, self.creditNameTextField.leftView.frame.size.width-10, self.creditNameTextField.leftView.frame.size.height-10);
    
    self.creditNameTextField.layer.cornerRadius=0.0f;
    self.creditNameTextField.layer.masksToBounds = YES;
    self.creditNameTextField.placeholder = @"Name on card";
    self.creditNameTextField.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.creditNameTextField.layer.borderWidth= 1.0f;
    [creditView addSubview:self.creditNameTextField];
    
    
    self.creditPayBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, self.creditNameTextField.frame.origin.y+self.creditNameTextField.frame.size.height+40, viewWidth-20, 50)];
    [self.creditPayBtn setTitle:@"Pay" forState:UIControlStateNormal] ;//@"Pay";
    [self.creditPayBtn setBackgroundImage:[UIImage imageNamed:@"bg_register.png"] forState:UIControlStateNormal];
    [self.creditPayBtn addTarget:self action:@selector(creditCardPayment:) forControlEvents:UIControlEventTouchUpInside];
    [creditView addSubview:self.creditPayBtn];
    
    
    [self.scrollView addSubview:creditView];
    
}


- (IBAction)debitCardPayment:(id)sender
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *scheme;
    if (self.debitCardNumTextField.text)
        scheme = [CTSUtility fetchCardSchemeForCardNumber:self.debitCardNumTextField.text];
    
    if (self.debitCardNumTextField.text == nil || !self.debitCardNumTextField.text || ![self.debitCardNumTextField.text length])
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please enter a valid card number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if (self.debitExpTextField.text == nil || ![self.debitExpTextField.text length])
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please enter a valid expiry date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if ([self.debitCvvTextField.text length] != 3 && ![scheme isEqualToString:@"MAESTRO"])
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please enter a valid CVV" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if (self.debitNameTextField.text == nil || ![self.debitNameTextField.text length])
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please enter a name " delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else
    {
        CTSPaymentDetailUpdate* debitCardInfo = [[CTSPaymentDetailUpdate alloc] init];
        CTSElectronicCardUpdate* debitCard =
        [[CTSElectronicCardUpdate alloc] initDebitCard];
        debitCard.number = self.debitCardNumTextField.text;
        debitCard.expiryDate = self.debitExpTextField.text;
        debitCard.scheme = [CTSUtility fetchCardSchemeForCardNumber:self.debitCardNumTextField.text];// @"visa";
        cardType = [CTSUtility fetchCardSchemeForCardNumber:self.debitCardNumTextField.text];
        debitCard.ownerName = self.debitNameTextField.text;
        debitCard.name = self.debitNameTextField.text;
        debitCard.cvv = self.debitCvvTextField.text;
        [debitCardInfo addCard:debitCard];
        
        CTSPaymentDetailUpdate *paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
        
        [paymentInfo addCard:debitCard];
        
        // Get your bill here.
        CTSBill *bill = [self getBillFromServer:[self.debitAmountTextField.text floatValue]];
        
        debitContactInfo = [[CTSContactUpdate alloc] init];
        debitContactInfo.firstName = self.debitNameTextField.text;
        debitContactInfo.lastName = @"";
        debitContactInfo.email = self.debitEmailTextField.text;
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"] length] >0)
            debitContactInfo.mobile = [[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
        
        // Configure your request here.
        [paymentLayer requestChargePayment:paymentInfo withContact:debitContactInfo withAddress:addressInfo bill:bill withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
            [self handlePaymentResponse:paymentInfo error:error];
        }];
    }
}

- (IBAction)creditCardPayment:(id)sender
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    NSString *scheme;
    if (self.creditCardNumTextField.text)
        scheme = [CTSUtility fetchCardSchemeForCardNumber:self.creditCardNumTextField.text];
    
    [self addSpinnerView];
    if (self.creditCardNumTextField.text == nil || !self.creditCardNumTextField.text || ![self.creditCardNumTextField.text length])
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please enter a valid credit card number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if (self.creditExpTextField.text == nil || ![self.creditExpTextField.text length])
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please enter a valid expiry date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if ([self.creditCvvTextField.text length] != 3 && ![scheme isEqualToString:@"MAESTRO"])
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please enter a valid CVV" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if (self.creditNameTextField.text == nil || ![self.creditNameTextField.text length])
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please enter a name " delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else
    {
        
        CTSPaymentDetailUpdate *creditCardInfo = [[CTSPaymentDetailUpdate alloc] init];
        // Update card for card payment.
        CTSElectronicCardUpdate *creditCard = [[CTSElectronicCardUpdate alloc] initCreditCard];
        creditCard.number = self.creditCardNumTextField.text;;
        creditCard.expiryDate = self.creditExpTextField.text;
        creditCard.scheme = [CTSUtility fetchCardSchemeForCardNumber:self.creditCardNumTextField.text];
        creditCard.ownerName = self.creditNameTextField.text;
        creditCard.name = self.creditNameTextField.text;
        creditCard.cvv = self.creditCvvTextField.text;
        [creditCardInfo addCard:creditCard];
        
        CTSPaymentDetailUpdate *paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
        
        [paymentInfo addCard:creditCard];
        
        // Get your bill here.
        
        NSMutableString *costStr = [[NSMutableString alloc]initWithString:self.costValue];
        
        //[costStr deleteCharactersInRange:NSMakeRange(0,3)];
        
        CTSBill *bill = [self getBillFromServer:[costStr floatValue]];
        creditContactInfo = [[CTSContactUpdate alloc] init];
        creditContactInfo.firstName = self.creditNameTextField.text;
        creditContactInfo.lastName = @"";
        creditContactInfo.email = self.creditEmailTextField.text;
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"] length] >0)
            creditContactInfo.mobile = [[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];;
        
        // Configure your request here.
        [paymentLayer requestChargePayment:paymentInfo withContact:creditContactInfo withAddress:addressInfo bill:bill withCompletionHandler:^(CTSPaymentTransactionRes *paymentInfo, NSError *error) {
            [self handlePaymentResponse:paymentInfo error:error];
        }];
    }
    
}
-(void)handlePaymentResponse:(CTSPaymentTransactionRes *)paymentInfo error:(NSError *)error
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    BOOL hasSuccess =
    ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
     (error == nil))
    ? YES
    : NO;
    if(hasSuccess){
        // Your code to handle success.
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIUtility dismissLoadingAlertView:YES];
            if (hasSuccess && error.code != ServerErrorWithCode) {
                [UIUtility didPresentLoadingAlertView:@"Connecting to the Payment Gateway" withActivity:YES];
                [self loadRedirectUrl:paymentInfo.redirectUrl];
            }else{
                [UIUtility didPresentErrorAlertView:error];
            }
        });
        
    }
    else{
        // Your code to handle error.
        NSString *errorToast;
        if(error== nil){
            errorToast = [NSString stringWithFormat:@" payment failed : %@",paymentInfo.txMsg] ;
        }else{
            errorToast = [NSString stringWithFormat:@" payment failed : %@",toErrorDescription(error)] ;
        }
        [UIUtility toastMessageOnScreen:errorToast];
    }
}

- (void)loadRedirectUrl:(NSString*)redirectURL {
    [self performSegueWithIdentifier:@"webViewSegue" sender:redirectURL];
}
#pragma mark - Storyboard Preapare segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"webViewSegue"]) {
        //        WebViewViewController* webViewViewController = [[WebViewViewController alloc] init];
        //        webViewViewController.redirectURL = redirectURL;
        ((WebViewViewController *)segue.destinationViewController).redirectURL =sender;
        [UIUtility dismissLoadingAlertView:YES];
        
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
#pragma mark - SegmentedControl methods

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
}

- (void)uisegmentedControlChangedValue:(UISegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld", (long)segmentedControl.selectedSegmentIndex);
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView)
    {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger page = scrollView.contentOffset.x / pageWidth;
        
        [self.segmentedControl4 setSelectedSegmentIndex:page animated:YES];
    }
}

#pragma mark - Textfield Delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide the keyboard
    [textField resignFirstResponder];
    
    //return NO or YES, it doesn't matter
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.debitAmountTextField || textField == self.creditAmountTextField)
        return NO;
    else
        return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    textField.inputAccessoryView = doneToolbar;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (!textField.tag)
    {
        if(textField == self.debitCardNumTextField)
        {
            UIImageView *img = [[UIImageView alloc] initWithImage:[CTSUtility getSchmeTypeImage:str]];
            self.debitCardNumTextField.leftView = img;
            self.debitCardNumTextField.leftView.frame = CGRectMake(self.debitCardNumTextField.leftView.frame.origin.x, self.debitCardNumTextField.leftView.frame.origin.y, self.debitCardNumTextField.leftView.frame.size.width+10, self.debitCardNumTextField.leftView.frame.size.height+10);
        }
        else if (textField == self.creditCardNumTextField)
        {
            self.creditCardNumTextField.leftView = [[UIImageView alloc] initWithImage:[CTSUtility getSchmeTypeImage:str]];
            self.creditCardNumTextField.leftView.frame = CGRectMake(self.creditCardNumTextField.leftView.frame.origin.x, self.creditCardNumTextField.leftView.frame.origin.y, self.creditCardNumTextField.leftView.frame.size.width+10, self.creditCardNumTextField.leftView.frame.size.height+10);
        }
        
    }
    if ((textField == self.debitCvvTextField && [str length] > 3)|| (textField == self.creditCvvTextField && [str length] > 3))
        return NO;
    else if((textField == self.debitCardNumTextField && [str length] > 19)|| (textField == self.creditCardNumTextField && [str length] > 19))
        return NO;
    else if((textField == self.debitExpTextField && [str length] > 7)|| (textField == self.creditExpTextField && [str length] > 7))
        return NO;
    else
        return YES;
    //getSchmeTypeImage
}


- (CTSBill*)getBillFromServer:(CGFloat) amount{
    // Configure your request here.
    
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:
                                   [NSURL URLWithString:BillUrl]];
    [urlReq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlReq setHTTPMethod:@"POST"];
    [urlReq setHTTPBody:[[NSString stringWithFormat:@"amount=%f",amount] dataUsingEncoding:NSUTF8StringEncoding]];
    NSError* error = nil;
    NSData* signatureData = [NSURLConnection sendSynchronousRequest:urlReq
                                                  returningResponse:nil
                                                              error:&error];
    //    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    //    dict = [NSJSONSerialization JSONObjectWithData:signatureData options:kNilOptions error:&error];
    NSString* billJson = [[NSString alloc] initWithData:signatureData
                                               encoding:NSUTF8StringEncoding];
    JSONModelError *jsonError;
    CTSBill* sampleBill = [[CTSBill alloc] initWithString:billJson
                                                    error:&jsonError];
    
    NSLog(@"billJson %@",billJson);
    NSLog(@"signature %@ ", sampleBill);
    return sampleBill;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
