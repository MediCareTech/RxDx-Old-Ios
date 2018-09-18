//
//  SmartRxRegisterValidVC.h
//  SmartRx
//
//  Created by PaceWisdom on 30/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxValidRegisterVC : UIViewController<MBProgressHUDDelegate,UITextFieldDelegate,UIAlertViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtCode;
@property (weak, nonatomic) IBOutlet UITextField *txtMobile;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UIButton *clickHereButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIImageView *closeImg;
@property (weak, nonatomic) IBOutlet UIImageView *mainContainer;
@property (weak, nonatomic) IBOutlet UIView *closeViewContainer;
@property (weak, nonatomic) IBOutlet UIView *codeEnterHereContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) BOOL isFromLogin;

- (IBAction)validateBtnClicked:(id)sender;
- (IBAction)cnacelBtnClicked:(id)sender;
- (IBAction)tapToResignKeyBoard:(id)sender;
- (IBAction)clickHereBtnClicked:(id)sender;
- (IBAction)closeBtnClicked:(id)sender;

@end
