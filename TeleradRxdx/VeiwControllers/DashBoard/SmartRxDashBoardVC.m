//
//  SmartRxDashBoardVC.m
//  SmartRx
//
//  Created by PaceWisdom on 08/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxDashBoardVC.h"
#import "SmartRxLoginViewController.h"
#import "UIImageView+WebCache.h"
#import "MenuTableViewCell.h"
#import "CVCell.h"
#import "UserDetails.h"
#import "SmartRxEditProfileVC.h"
#define kLessThan4Inch 560
#define kLogoutAlertTag 800
#define kAlertLogin 1200
#define pwdResetSuccess 700
#define pwdResetFailure 1400
#define aggrementBtnTag 1500
#define KLogoutAlertTagFromCommon 1040

@interface SmartRxDashBoardVC ()
{
    CGSize viewSize;
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    BOOL isLogin;
    UIRefreshControl *refreshControl;
    BOOL bIsMenuSel, bIsResetPwdSel, fromMenu;
    NSString *termsString, *privacyString, *disclaimerString, *password, *resetPassword;
}

@end

@implementation SmartRxDashBoardVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)checkForAgreement
{   [self SetNavigationBarItems];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        if (self.acceptAgreement == 0)
        {
            [self.termsOfUseAgreeBtn setTitle:@"AGREE" forState:UIControlStateNormal];
            fromMenu = NO;
            [self makeRequestToGetAggrementData];
        }
//            [self loadTermsOfUseView];
            
    }
}
-(void)SetNavigationBarItems
{
    UIButton *btnFaq = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *faqBtnImag = [UIImage imageNamed:@"icon_list.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    [btnFaq addTarget:self action:@selector(menuBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;

}
-(void)logoutBtnClicked:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Logout" message:@"Are you sure? Do you want to logout?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
    alert.tag=kLogoutAlertTag;
    [alert show];
    alert=nil;
    }
}
-(void)logOutId:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Session expired. Please Re-login" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.delegate = self;
    alert.tag = KLogoutAlertTagFromCommon;
    [alert show];
}
#pragma mark -View LIfe Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    password = nil;
    resetPassword = nil;
    self.retypePassword.text = nil;
    self.password.text = nil;
    viewSize=[[UIScreen mainScreen]bounds].size;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    /* uncomment this block to use subclassed cells */
    [self.collectionView registerClass:[CVCell class] forCellWithReuseIdentifier:@"cvCell"];
    /* end of subclass-based cells block */
    
    // Configure layout
    CGSize viewFrame = [UIScreen mainScreen].bounds.size;
    viewFrame.height -= (self.collectionView.frame.origin.y + self.callView.frame.size.height + 5);
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake((viewFrame.width/2)-10, (viewFrame.height/3)-10)];
    [self.collectionView setCollectionViewLayout:flowLayout];
    //Adding image on Navigation bar
    bIsMenuSel = NO;
    bIsResetPwdSel = NO;
    if (viewSize.height < kLessThan4Inch)
    {
      [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height+self.btnEmergency.frame.origin.y+self.btnEmergency.frame.size.height)];
        
    }
    isLogin=NO;

    _arrMenuImages=[[NSArray alloc]initWithObjects:@"icn_home_DB.png",@"icn_profile.png",@"icn_hospital.png",@"icn_refresh.png",@"key.png",@"icn_logout_menu.png", nil];
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    self.password.inputAccessoryView = doneToolbar;
    self.retypePassword.inputAccessoryView = doneToolbar;

}
- (void)doneButton:(id)sender
{
    [self.password resignFirstResponder];
    [self.retypePassword resignFirstResponder];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.acceptAgreement = [[[NSUserDefaults standardUserDefaults] objectForKey:@"agstatus"] integerValue];
    [self checkForAgreement];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
        _arrMenu=[[NSArray alloc]initWithObjects:@"Get Care Plan",@"Book E-Consult",@"Book Appointment",@"View Profile",@"Change Password",@"Terms of use",@"Logout", nil];
    else
        _arrMenu=[[NSArray alloc]initWithObjects:@"Login",@"Get Care Plan",@"Book Appointment", nil];
    bIsMenuSel = NO;
    password = nil;
    resetPassword = nil;
    self.retypePassword.text = nil;
    self.password.text = nil;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"])
            self.navigationItem.title = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"];
    }
    else
    {
        self.navigationItem.title = @"Login";
    }
    
//    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"])
//    {
//        self.navigationItem.title=[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"];
//    }
//    else
//    {
//        [[NSUserDefaults standardUserDefaults]setObject:@"Guest" forKey:@"HosName"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//        self.navigationItem.title=[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"];
//    }
    [self.navigationController.navigationBar setTitleTextAttributes:
                    [NSDictionary dictionaryWithObjectsAndKeys:
                        [UIFont boldSystemFontOfSize:17],NSFontAttributeName, nil]];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
    
    if ( [[NSUserDefaults standardUserDefaults]boolForKey:@"PushNotes"] == YES)
    {
        [self messagesBtnClicked:nil];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"PushNotes"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else if ([[NSUserDefaults standardUserDefaults]boolForKey:@"EConsultPush"] == YES)
    {
        //        [self performSegueWithIdentifier:@"eConsultVC" sender:nil];
        [self performSegueWithIdentifier:@"ConnectID" sender:nil];
    }
    else if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        isLogin=YES;
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForNumberOfMessages];
        }
        else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            alertView=nil;
        }
    }
    else{
       self.lblAppCount.text=@"0";
       self.lblMsgs.text=@"0";
    }
//    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"logo"] length] > 0 && [[NSUserDefaults standardUserDefaults]objectForKey:@"logo"] && [[NSUserDefaults standardUserDefaults]objectForKey:@"logo"] != [NSNull null])
//    {
        UIImageView *imgViewIcon=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rxdxlogo.png"]];
        //change
//      [imgViewIcon  sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://brooke.smartrx.in/admin/",[[NSUserDefaults standardUserDefaults]objectForKey:@"logo"]]] placeholderImage:[UIImage imageNamed:@"logo_DB.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
//          if (!error)
//          {
              UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
              [negativeSpacer setWidth:-5];

              imgViewIcon.frame = CGRectMake(0, 5, 105, 33);
              UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:imgViewIcon];
              [item setWidth:imgViewIcon.frame.size.width];
              //self.navigationItem.leftBarButtonItem = item;
              self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,item,nil];
//          }
//      }];
//    } 
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"] && [[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"])
    {
//        [self makeRequestForUserRegister];
    }
    
    
}
-(void)makeRequestForUserRegister
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    
    [self addSpinnerView];
    
    NSString *strMobNum=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    NSString *strCodee=[[NSUserDefaults standardUserDefaults]objectForKey:@"code"];
    
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"mobile",strMobNum];
    bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"code",strCodee]];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mregister"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 13 %@",response);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            [[NSUserDefaults standardUserDefaults]setObject:strCodee forKey:@"code"];
            [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cidd"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [self performSegueWithIdentifier:@"RegisterID" sender:[response objectForKey:@"cid"]];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cid"];
                NSString *strFrontDestNum=[[response objectForKey:@"hinfo"]objectForKey:@"frontDeskNo" ];
                
                [[NSUserDefaults standardUserDefaults]setObject:strFrontDestNum forKey:@"EmNumber"];
                
                NSString *strHospName=[[response objectForKey:@"hinfo"]objectForKey:@"hospitalName" ];
                
                [[NSUserDefaults standardUserDefaults]setObject:strHospName forKey:@"HosName"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                //[self customAlertView:@"User already registered" Message:@"Login now" tag:kRegistredUserAlertTag];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:[response objectForKey:@"response"] tag:0];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:[response objectForKey:@"response"] tag:0];
            }
            [[NSUserDefaults standardUserDefaults] setObject:[[response objectForKey:@"hinfo"] objectForKey:@"splash_screen"] forKey:@"splash_screen"];//logo
            if ([[response objectForKey:@"hinfo"] objectForKey:@"mlogo"] && [[response objectForKey:@"hinfo"] objectForKey:@"mlogo"] != [NSNull null])
                [[NSUserDefaults standardUserDefaults] setObject:[[response objectForKey:@"hinfo"] objectForKey:@"mlogo"] forKey:@"logo"];
            else
                [[NSUserDefaults standardUserDefaults] setObject:[[response objectForKey:@"hinfo"] objectForKey:@"logo"] forKey:@"logo"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            //[[NSUserDefaults standardUserDefaults]setObject:self.txtMobile.text forKey:@"MobilNumber"];
            
        });
    } failureHandler:^(id response) {
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Error occur" Message:@"Try again" tag:0];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Requesting To server

- (void)makeRequestToResetPassword
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"sessionid",sectionId, @"txtpass", self.password.text];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mcpass"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response)
     {
         NSLog(@"sucess 15 %@",response);
         if (response == nil)
         {
             [HUD hide:YES];
             [HUD removeFromSuperview];
             [self customAlertView:@"" Message:@"Internal server error" tag:0];
         }
         else{
             if ([[response objectForKey:@"cpstatus"] integerValue] == 1)
             {
                 [self customAlertView:@"" Message:@"Password reset successfully. Please relogin using new password." tag:pwdResetSuccess];
             }
             else{
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [spinner stopAnimating];
                     [spinner removeFromSuperview];
                     spinner = nil;
                     [HUD hide:YES];
                     [HUD removeFromSuperview];
                     [self customAlertView:@"" Message:@"Password reset failed. Please try again." tag:pwdResetSuccess];
                 });
             }
             
         } }failureHandler:^(id response) {
             NSLog(@"failure %@",response);
             [HUD hide:YES];
             [HUD removeFromSuperview];
             [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
         }];
}
- (void)makeRequestToGetAggrementData
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"magreeview"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response)
     {
         NSLog(@"sucess 14 %@",response);
         if (response == nil)
         {
             [HUD hide:YES];
             [HUD removeFromSuperview];
             [self customAlertView:@"" Message:@"Internal server error" tag:0];
         }
         else{
             dispatch_async(dispatch_get_main_queue(), ^{
                 if ([[response objectForKey:@"result"]integerValue] == 0)
                 {
                     SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                     smartLogin.loginDelegate=self;
                     [smartLogin makeLoginRequest];
//                     [self makeRequestToGetAggrementData];
                 }
                 else
                 {
                     termsString = [response objectForKey:@"tc"];
                     privacyString = [response objectForKey:@"privacy"];
                     disclaimerString = [response objectForKey:@"disc"];
                     [self showTermsOfUse];
                 }
             });
         } }failureHandler:^(id response) {
             NSLog(@"failure %@",response);
             [HUD hide:YES];
             [HUD removeFromSuperview];
             
         }];
}
- (void)showTermsOfUse
{
    self.navigationItem.rightBarButtonItem = nil;
    self.termOfUseSelectedView.hidden = NO;
    self.privacySelectedView.hidden = YES;
    self.disclaimerSelectedView.hidden = YES;
    [self.webView loadHTMLString:termsString baseURL:nil];
    [self loadTermsOfUseView];
    [HUD hide:YES];
    [HUD removeFromSuperview];
}
- (void)makeRequestForUserAggrement
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"magree"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response)
     {
         NSLog(@"sucess 16 %@",response);
         if (response == nil)
         {
             [HUD hide:YES];
             [HUD removeFromSuperview];
             [self customAlertView:@"" Message:@"Internal server error" tag:0];
         }
         else{
             dispatch_async(dispatch_get_main_queue(), ^{
                 if ([[response objectForKey:@"result"]integerValue] == 0)
                 {
                     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error occured. Please re-login to continue" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Logout", nil];
                     alert.tag=kLogoutAlertTag;
                     [alert show];
                     alert=nil;
                 }
                 else
                 {
                     if ([[response objectForKey:@"result"]integerValue] == 0)
                     {
                         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error occured. Please re-login to continue" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Logout", nil];
                         alert.tag=kLogoutAlertTag;
                         [alert show];
                         alert=nil;
                     }
                     else
                     {
                         [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"astatus"] forKey:@"agstatus"];
                         [self hideTermsOfUseView];
                         [self SetNavigationBarItems];
                         [HUD hide:YES];                         
                     }
                 }
             });
         } }failureHandler:^(id response) {
             NSLog(@"failure %@",response);
             [HUD hide:YES];
             [HUD removeFromSuperview];
         }];

}
-(void)makeRequestForNumberOfMessages
{
    
//    if (![HUD isHidden]) {
//        [HUD hide:YES];
//    }
//    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mdash"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response)
    {
        NSLog(@"sucess 17 %@",response);
        if (response == nil)
        {
            [HUD hide:YES];
            [HUD removeFromSuperview];
            [self customAlertView:@"" Message:@"Internal server error" tag:0];
        }
        else{
            if ([[[response objectAtIndex:0] objectForKey:@"authorized"]integerValue] == 0 && [[[response objectAtIndex:0] objectForKey:@"result"]integerValue] == 0 && [[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
            {
                SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                smartLogin.loginDelegate=self;
                [smartLogin makeLoginRequest];
                
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    [spinner removeFromSuperview];
                    spinner = nil;
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
                    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
                    double appVersion = [version doubleValue];
                    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
                    NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
                    double serverVersion = [[[response objectAtIndex:0] objectForKey:@"ios_app_version"] doubleValue];
                    if (serverVersion > [[[NSUserDefaults standardUserDefaults] objectForKey:@"versionNumber"] doubleValue])
                    {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showUpdateAlert"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    
                    if (serverVersion > appVersion && [[[NSUserDefaults standardUserDefaults] objectForKey:@"showUpdateAlert"] boolValue])
                    {
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showUpdateAlert"];
                        [[NSUserDefaults standardUserDefaults] setDouble:serverVersion forKey:@"versionNumber"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Update(s) Available" message:@"There is a new version of Telerad RxDx available. Would you like to download now or later?" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Now", nil];
                        alert.tag=9909;
                        [alert show];
                        alert=nil;

                    }
                    
                    NSString *quikWeelID = [[response objectAtIndex:0] objectForKey:@"QikwellID"];
                    [UserDetails setQikWellApi:[[response objectAtIndex:0] objectForKey:@"QikwellAppUrl"]];
                    if ([quikWeelID isKindOfClass:[NSString class] ]) {
                        
                         [UserDetails setQikWellId:[[response objectAtIndex:0] objectForKey:@"QikwellID"]];
                    }
                   
                    self.view.userInteractionEnabled = YES;
                    //self.arrMsgs=[response objectForKey:@"msg"];
                    self.lblMsgs.text=[NSString stringWithFormat:@"%@",[[response objectAtIndex:0] objectForKey:@"messages"]];//[NSString stringWithFormat:@"%d",[self.arrMsgs count]];
                    self.lblAppCount.text=[NSString stringWithFormat:@"%@",[[response objectAtIndex:0] objectForKey:@"aptc"]];
                    
                });
            }
        
        } }failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];
}
-(void)makeRequestToLogout
{
    
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    
    [self addSpinnerView];
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mlogout"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 15 %@",response);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                if ([[[response objectAtIndex:0] objectForKey:@"result"]intValue] == 1)
                {
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"sessionid"];
//                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"HosName"];
                     [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserName"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    [self performSegueWithIdentifier:@"DBLoginID" sender:@"Lougout"];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Logout" message:@"Logout failed due to network issues. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alert show];
                    alert=nil;

                }
                
            });
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Logout" message:@"Logout failed due to network issues. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        alert=nil;
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


#pragma mark -Action Methods

- (IBAction)fbButtonClicked:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.facebook.com/rxdxhealthcare"]];
}

- (IBAction)linkedInButtonClicked:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.linkedin.com/company/rxdx"]];
}

- (IBAction)connectBtnClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"ConnectID" sender:nil];
    
}

- (IBAction)carePlansBtnClicked:(id)sender {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        [self performSegueWithIdentifier:@"DBCarePlanID" sender:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"getCareplan" sender:nil];
    }
    
}
- (IBAction)appointmentsBtnClicked:(id)sender

{
    
    
    NSString *mailStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"emailId"];
    
    //  NSString *ageStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"age"];
    // || [ageStr isEqualToString:@"0"]
    if ( mailStr.length <=0 ) {
        
        [self customAlertView:@"Please Update the Email and DOB" Message:@"" tag:222];
        
        
    } else {
        
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
        {
            [self performSegueWithIdentifier:@"consultationList" sender:nil];
        }
        else
        {
            [self performSegueWithIdentifier:@"bookApt" sender:nil];
        }

    }
    

    
}

- (IBAction)hsBtnClicked:(id)sender {

    [self performSegueWithIdentifier:@"HsDashboardId" sender:nil];
    
}

- (IBAction)messagesBtnClicked:(id)sender {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
         [self performSegueWithIdentifier:@"DBMessagesID" sender:nil];
    }
    else
    {
        [self showALertView];
    }
}

- (IBAction)myRecordsBtnClicked:(id)sender {
    NSLog(@"Into records thing.");
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        [self performSegueWithIdentifier:@"MyRecordID" sender:nil];
    }
    else
    {
        [self showALertView];
    }
    
}

- (IBAction)loginBtnClicked:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"])
        [self performSegueWithIdentifier:@"EditProfileID" sender:nil];
    else
        [self performSegueWithIdentifier:@"DBLoginID" sender:@"Login"];

    
}

- (IBAction)emergencyBtnClicked:(id)sender {
    
    [self emgCall];
//    NSURL *phoneNumberURL = [NSURL URLWithString:@"tel:80001212"];
//    [[UIApplication sharedApplication] openURL:phoneNumberURL];
}

- (IBAction)profileBtnClicked:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        [self performSegueWithIdentifier:@"EditProfileID" sender:nil];
    }
    else
    {
        [self showALertView];
    }
    
}

- (IBAction)resetPwdClicked:(id)sender
{
    if ([self.password.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter password"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self.retypePassword.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Please retype your password"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self.password.text length] < 6)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Your password should have atleast 6 characters"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self.password.text length] > 12)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Your password should have minimum of 6 and maximum of 12 characters"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if (![self.retypePassword.text isEqualToString:self.password.text])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Password mismatch. Please retype your password"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self makeRequestToResetPassword];
    }
    
}

- (IBAction)resetPwdCancelClicked:(id)sender
{
    password = nil;
    resetPassword = nil;
    self.retypePassword.text = nil;
    self.password.text = nil;
    [self hideResetPasswordView];
}
-(void)emgCall
{
    NSString *phoneNumber=nil;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"EmNumber"])
    {
        phoneNumber=[[NSUserDefaults standardUserDefaults]objectForKey:@"EmNumber"];
    }
    else
        phoneNumber=@"9986589899";
    
    NSString *number = [NSString stringWithFormat:@"%@",phoneNumber];
    NSURL* callUrl=[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",number]];
    //check  Call Function available only in iphone
    if([[UIApplication sharedApplication] canOpenURL:callUrl])
    {
        [[UIApplication sharedApplication] openURL:callUrl];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"ALERT" message:@"This function is only available on the iPhone"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
       
    }
}


-(IBAction)menuBtnClicked:(id)sender
{
    if (bIsResetPwdSel)
        [self hideResetPasswordView];
    if (!bIsMenuSel)
    {
        [_tblMenu reloadData];
        [self loadMenu];
    }
    else
        [self hideMenu];
}
- (IBAction)termsOfUseBtnClicked:(id)sender
{
    self.termOfUseSelectedView.hidden = NO;
    self.privacySelectedView.hidden = YES;
    self.disclaimerSelectedView.hidden = YES;
    [self.webView loadHTMLString:termsString baseURL:nil];
    
//    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:request];
}

- (IBAction)privacyBtnClicked:(id)sender
{
    self.termOfUseSelectedView.hidden = YES;
    self.privacySelectedView.hidden = NO;
    self.disclaimerSelectedView.hidden = YES;
    [self.webView loadHTMLString:privacyString baseURL:nil];
}

- (IBAction)disclaimerBtnClicked:(id)sender
{
    self.termOfUseSelectedView.hidden = YES;
    self.privacySelectedView.hidden = YES;
    self.disclaimerSelectedView.hidden = NO;
    [self.webView loadHTMLString:disclaimerString baseURL:nil];
}

- (IBAction)agreeBtnClicked:(id)sender
{
    if (fromMenu)
    {
        [self hideTermsOfUseView];
        [self SetNavigationBarItems];
        [HUD hide:YES];
    }
    else

        [self makeRequestForUserAggrement];
}

- (IBAction)hideMenuBtnClicked:(id)sender
{
    [self hideMenu];
}

#pragma mark -prepare Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DBLoginID"])
    {
        ((SmartRxLoginViewController *)segue.destinationViewController).strIsLogout=sender;
    }
}
-(void)showALertView
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Login required" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.tag=kAlertLogin;
    [alert show];
    alert=nil;
}
#pragma mark - Alert View Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kLogoutAlertTag && buttonIndex == 1)
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestToLogout];
        }
        else{
            
            [self customAlertView:@"" Message:@"Network not available" tag:0];
            
        }
        
    }
    else if (alertView.tag == kAlertLogin && buttonIndex == 0)
    {
         [self performSegueWithIdentifier:@"DBLoginID" sender:@"Login"];
    }
    else if (alertView.tag == pwdResetSuccess)
    {
        [self hideResetPasswordView];
        [self makeRequestToLogout];
    }
    else if (alertView.tag == KLogoutAlertTagFromCommon)
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        self.view.userInteractionEnabled = YES;
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"sessionid"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"profilePicLink"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Qualification"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self performSegueWithIdentifier:@"DBToLogin" sender:@"Lougout"];
    }
    else if (alertView.tag == 9909 && buttonIndex == 1)
    {
        NSString *iTunesLink = @"https://itunes.apple.com/in/app/telerad-rxdx/id1019412742?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    } else if(alertView.tag == 222){
         [self performSegueWithIdentifier:@"EditProfileID" sender:nil];
    }
}
-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

#pragma mark - Menu Methods
- (void)loadResetPasswordView
{
    [UIView animateWithDuration:0.2 animations:^{
        _viewReset.frame=CGRectMake(0,  _viewReset.frame.origin.y,  _viewReset.frame.size.width,  _viewReset.frame.size.height);
    } completion:^(BOOL finished) {
        bIsResetPwdSel=YES;
        bIsMenuSel = NO;
    }];
}
-(void)hideResetPasswordView
{
    [UIView animateWithDuration:0.2 animations:^{
        _viewReset.frame=CGRectMake(viewSize.width,  _viewReset.frame.origin.y,  _viewReset.frame.size.width,  _viewReset.frame.size.height);
    } completion:^(BOOL finished) {
        bIsResetPwdSel=NO;
    }];
}
-(void)loadMenu
{
    [UIView animateWithDuration:0.2 animations:^{
        _viwMenu.frame=CGRectMake(0,  _viwMenu.frame.origin.y,  _viwMenu.frame.size.width,  _viwMenu.frame.size.height);
    } completion:^(BOOL finished) {
        bIsMenuSel=YES;
    }];
}
-(void)hideMenu
{
    [UIView animateWithDuration:0.2 animations:^{
        _viwMenu.frame=CGRectMake(viewSize.width,  _viwMenu.frame.origin.y,  _viwMenu.frame.size.width,  _viwMenu.frame.size.height);
    } completion:^(BOOL finished) {
        bIsMenuSel=NO;
    }];
}

-(void)loadTermsOfUseView
{
    [UIView animateWithDuration:0.2 animations:^{
        _termsOfUseView.frame=CGRectMake(0,  _termsOfUseView.frame.origin.y,  _termsOfUseView.frame.size.width,  _termsOfUseView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}
-(void)hideTermsOfUseView
{
    [UIView animateWithDuration:0.2 animations:^{
        _termsOfUseView.frame=CGRectMake(viewSize.width,  _termsOfUseView.frame.origin.y,  _termsOfUseView.frame.size.width,  _termsOfUseView.frame.size.height);
    } completion:^(BOOL finished) {

    }];
    
}

#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForNumberOfMessages];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
    
}
-(void)errorSectionId:(id)sender
{
    NSLog(@"error");
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
    self.view.userInteractionEnabled = YES;
}
#pragma mark - Collection View Delegate/Datasource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    CVCell *cell = (CVCell *)[cv dequeueReusableCellWithReuseIdentifier:@"cvCell" forIndexPath:indexPath];
    NSString *imageToLoad = [NSString stringWithFormat:@"h%ld.png", (long)indexPath.row];
    cell.backGrndImage.image = [UIImage imageNamed:imageToLoad];
    imageToLoad = [NSString stringWithFormat:@"h%lda.png", (long)indexPath.row];
    cell.tileImg.image = [UIImage imageNamed:imageToLoad];
    
    if (indexPath.row == 0)
        cell.titleLbl.text = @"Book Services";
    else if (indexPath.row == 1)
        cell.titleLbl.text = @"My Records";
    else if (indexPath.row == 2)
        cell.titleLbl.text = @"Info & Services";
    else if (indexPath.row == 3)
        cell.titleLbl.text = @"My Messages";
    else if (indexPath.row == 4)
        cell.titleLbl.text = @"Care Plans";
    else if (indexPath.row == 5)
        cell.titleLbl.text = @"Connect";
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CVCell *cell=(CVCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if([cell.titleLbl.text isEqualToString:@"My Messages"])
        [self messagesBtnClicked:nil];
    else if([cell.titleLbl.text isEqualToString:@"My Records"])
        [self myRecordsBtnClicked:nil];
    else if([cell.titleLbl.text isEqualToString:@"Care Plans"])
        [self carePlansBtnClicked:nil];
    else if ([cell.titleLbl.text isEqualToString:@"Book Services"])
        [self appointmentsBtnClicked:nil];
    else if ([cell.titleLbl.text isEqualToString:@"Info & Services"])
        [self hsBtnClicked:nil];
    else if ([cell.titleLbl.text isEqualToString:@"Connect"])
        [self connectBtnClicked:nil];
}



#pragma mark - Tableview Delegate/Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrMenu count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"MenuCellID";
    MenuTableViewCell *cell=(MenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
//    _tblMenu.separatorStyle = UITableViewCellSeparatorStyleNone;
//    //To customize the separatorLines
//    UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, cell.frame.size.height-1, tableView.frame.size.width-1, 1)];
//    separatorLine.backgroundColor = [UIColor lightGrayColor];
//    [cell addSubview:separatorLine];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.lblMenu.text=[_arrMenu objectAtIndex:indexPath.row];
//    cell.imgViwMenu.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@",[_arrMenuImages objectAtIndex:indexPath.row ]]];
    cell.imgViwMenu.image = [UIImage imageNamed:@"menu-arrow.png"];
    cell.lblMenu.font = [UIFont systemFontOfSize:14];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        MenuTableViewCell *cell=(MenuTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [self hideMenu];
        if ([cell.lblMenu.text isEqualToString:@"Home"])
            [self hideMenu];
        else if([cell.lblMenu.text isEqualToString:@"Get Care Plan"])
            [self performSegueWithIdentifier:@"getCareplan" sender:nil];
        else if([cell.lblMenu.text isEqualToString:@"View Profile"])
            [self performSegueWithIdentifier:@"EditProfileID" sender:nil];
        else if([cell.lblMenu.text isEqualToString:@"Hospital Info"])
            [self performSegueWithIdentifier:@"HsDashboardId" sender:nil];
        else if ([cell.lblMenu.text isEqualToString:@"Book Appointment"])
            [self moveToAppointmentController];
            //[self performSegueWithIdentifier:@"bookAppoitmentVc" sender:nil];
        else if ([cell.lblMenu.text isEqualToString:@"Book E-Consult"])
            [self performSegueWithIdentifier:@"eConsult_book" sender:nil];
        else if ([cell.lblMenu.text isEqualToString:@"Login"])
            [self performSegueWithIdentifier:@"DBLoginID" sender:@"Login"];
        else if ([cell.lblMenu.text isEqualToString:@"Terms of use"])
        {
            fromMenu = YES;
            [self.termsOfUseAgreeBtn setTitle:@"OK" forState:UIControlStateNormal];
            if ([termsString length] == 0 || termsString == nil)
                [self makeRequestToGetAggrementData];
            else
                [self showTermsOfUse];
        }
        else if([cell.lblMenu.text isEqualToString:@"Refresh"])
        {
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isAppDelegateCalls"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self makeRequestForNumberOfMessages];
        }
        else if([cell.lblMenu.text isEqualToString:@"Change Password"])
        {
            if (!bIsResetPwdSel)
            {
                [self loadResetPasswordView];
            }
            else
                [self hideResetPasswordView];
        }
    if (indexPath.row == [_arrMenu count]-1)
    {
        [self logoutBtnClicked:nil];
    }
}
-(void)moveToAppointmentController{
    NSString *mailStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"emailId"];
    
    //  NSString *ageStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"age"];
    // || [ageStr isEqualToString:@"0"]
    if ( mailStr.length <=0 ) {
        SmartRxEditProfileVC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"profileVC"];
        controller.viewControllerName = @"ConsultaionVC";
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self performSegueWithIdentifier:@"bookAppoitmentVc" sender:nil];
    }
}
#pragma mark - Textfield Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.password)
    {
        if ([password length] > 0)
        {
            self.password.text = password;
        }
    }
    else if (textField == self.retypePassword)
    {
        if ([resetPassword length] > 0)
        {
            self.retypePassword.text = resetPassword;
        }
    }
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.password)
    {
        password = self.password.text;
    }
    else if (textField == self.retypePassword)
    {
        resetPassword = self.retypePassword.text;
    }
}
@end
