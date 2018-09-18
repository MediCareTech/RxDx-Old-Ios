//
//  SmartRxPaymentVC.h
//  SmartRx
//
//  Created by Manju Basha on 07/04/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMSegmentedControl.h"
#import "SmartRxTextFieldLeftImage.h"
#import "CitrusSdk.h"

@interface SmartRxPaymentVC : UIViewController<UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSString *costValue;
@property (nonatomic, strong) NSString *email;
@property (strong, nonatomic) NSMutableDictionary *packageResponse;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl4;
@property (retain, nonatomic) SmartRxTextFieldLeftImage *debitEmailTextField;
@property (retain, nonatomic) SmartRxTextFieldLeftImage *debitCardNumTextField;
@property (retain, nonatomic) SmartRxTextFieldLeftImage *debitExpTextField;
@property (retain, nonatomic) SmartRxTextFieldLeftImage *debitCvvTextField;
@property (retain, nonatomic) SmartRxTextFieldLeftImage *debitAmountTextField;
@property (retain, nonatomic) SmartRxTextFieldLeftImage *debitNameTextField;
@property (retain, nonatomic) UIButton *debitPayBtn;

@property (retain, nonatomic) SmartRxTextFieldLeftImage *creditEmailTextField;
@property (retain, nonatomic) SmartRxTextFieldLeftImage *creditCardNumTextField;
@property (retain, nonatomic) SmartRxTextFieldLeftImage *creditExpTextField;
@property (retain, nonatomic) SmartRxTextFieldLeftImage *creditCvvTextField;
@property (retain, nonatomic) SmartRxTextFieldLeftImage *creditAmountTextField;
@property (retain, nonatomic) SmartRxTextFieldLeftImage *creditNameTextField;
@property (retain, nonatomic) UIButton *creditPayBtn;

@end
