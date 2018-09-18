//
//  SmartRxHsDashBoardVC.m
//  SmartRx
//
//  Created by PaceWisdom on 09/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxHsDashBoardVC.h"
#import "SmartRxSpecialityVC.h"
#import "SmartRxSelectDocLocation.h"
#import "SmartRxHospitalDetailsVC.h"
@interface SmartRxHsDashBoardVC ()
{
    MBProgressHUD *HUD;
    NSString *hospitalName;
}

@end

@implementation SmartRxHsDashBoardVC

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

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"])
    {
        hospitalName = [NSString stringWithFormat:@"About %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"]];
    }
    
    self.navigationItem.hidesBackButton=YES;
    [self navigationBackButton];
//    UIBarButtonItem *leftItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icn_back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backBtnClicked:)];
//    self.navigationItem.leftBarButtonItem=leftItem;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)makeRequestForAboutUsPage
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"isopen",@"1"];
    }
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mhservice"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 7 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            [HUD hide:YES];
            [HUD removeFromSuperview];
            //[self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                [self performSegueWithIdentifier:@"hospitalDetailVC" sender:response];
                
                
            });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
#pragma mark - Action Methods
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showALertView
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Login Required" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
}

- (IBAction)ipBtnClicked:(id)sender {
}

- (IBAction)contctUsbtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"ContactID" sender:nil];
}
- (IBAction)feedbackBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"FeedBackID" sender:nil];
}
- (IBAction)inquiryBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"EnquiryID" sender:nil];
}
- (IBAction)servicesClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"selLocation" sender:@"ServicesLocation"];
//    [self performSegueWithIdentifier:@"ServicesID" sender:nil];
}

- (IBAction)findDoctorsBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"selLocation" sender:@"Doctor"];
}

- (IBAction)specilalitiesBtnClicked:(id)sender {
    [self performSegueWithIdentifier:@"HsID" sender:@"Spec"];
    
}

- (IBAction)aboutUsClicked:(id)sender
{
    
    [self makeRequestForAboutUsPage];
   // [self performSegueWithIdentifier:@"hospitalDetailVC" sender:@"aboutus"];

    //[self performSegueWithIdentifier:@"aboutUs" sender:@"aboutus"];
}
#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
#pragma mark - Prepare Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"HsID"])
    {
        ((SmartRxSpecialityVC *)segue.destinationViewController).strDocOrSpec=sender;
    }
    else if ([segue.identifier isEqualToString:@"hospitalDetailVC"])
    {
       // ((SmartRxHospitalDetailsVC *)segue.destinationViewController).navigationItem.title = hospitalName;
        SmartRxHospitalDetailsVC *controller = segue.destinationViewController;
        controller.navigationItem.title = hospitalName;
        controller.dataArray = sender;
//        ((SmartRxHospitalDetailsVC *)segue.destinationViewController).dataArray = [[NSMutableArray alloc] init];
//        ((SmartRxHospitalDetailsVC *)segue.destinationViewController).dataArray = sender;
        
    } else {
    if([sender isEqualToString:@"ServicesLocation"])
    {
        ((SmartRxSelectDocLocation *)segue.destinationViewController).fromServices = YES;
    }
    if([sender isEqualToString:@"Doctor"])
    {
        ((SmartRxSelectDocLocation *)segue.destinationViewController).fromServices = NO;
    }
    }
}
@end
