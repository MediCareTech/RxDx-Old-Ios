//
//  SmartRxAppointmentsVC.m
//  SmartRx
//
//  Created by PaceWisdom on 12/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxAppointmentsVC.h"
#import "SmartRxCommonClass.h"
#import "AppointmentTableViewCell.h"
#import "NetworkChecking.h"
#import "SmartRxDashBoardVC.h"
#import "UserDetails.h"
#import "SmartRxEditProfileVC.h"


#define kNoAppsAlertTag 1600

@interface SmartRxAppointmentsVC ()
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    UIRefreshControl *refreshControl;
}

@end

@implementation SmartRxAppointmentsVC

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

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self navigationBackButton];
    self.arrAppointments=[[NSArray alloc]init];
    self.lblNoApps.hidden=YES;
    self.tblAppointments.hidden=YES;
    self.lblNoApps.hidden=YES;
    //[self makeRequestForAppointments];
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tblAppointments addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    [self.tblAppointments setTableFooterView:[UIView new]];
    // Do any additional setup after loading the view.
}
-(void)refreshTable
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForAppointments];
        }
        else{
            
            [self customAlertView:@"" Message:@"Network not available" tag:0];
            
        }
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForAppointments];
        }
        else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            alertView=nil;
        }
    }
    else
    {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
        {
            self.lblNoApps.hidden=NO;
//            self.lblNoApps.text = @"\u2022 No appointments to show. Click “ Book New Appointment” button to book new appointment.";
            self.lblNoApps.text = @"\u2022 Book your appointments here and meet the doctor at the hospital.\n\n\u2022 You will receive a confirmation after you book.";
            
        }
        else
        {
            self.lblNoApps.hidden=NO;
            self.lblNoApps.text = @"\u2022 Login to view the appointment List. Click “Book New Appointment” button to book new appointment.";
        }
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
#pragma mark - Action Methods

-(void)backBtnClicked:(id)sender
{
    if (self.fromFindDoctors)
    {
        for (UIViewController *controller in [self.navigationController viewControllers])
        {
            if ([controller isKindOfClass:[SmartRxDashBoardVC class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(IBAction)clickOnBookAppointmentButton:(id)sender{
    
    
    
    
    
        NSString *mailStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"emailId"];
        
      //  NSString *ageStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"age"];
        // || [ageStr isEqualToString:@"0"]
        if ( mailStr.length <=0 ) {
            
            [self customAlertView:@"Please Update the Email and DOB" Message:@"" tag:333];
            
           
        } else {
            [self performSegueWithIdentifier:@"bookAppointmentVC" sender:nil];
        }
        
    
}
#pragma mark - Request methods
-(void)makeRequestForAppointments
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *userId = [UserDetails getQikWellId];
    
    //userId = @"35633636373836312d623264352d343139622d616339352d656139663138386332336563";
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"userid",userId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"rxdxapt"];
    
    
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 1 %@",response);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            self.arrAppointments=[response objectForKey:@"appointments"];
            if ([self.arrAppointments count])
            {
                self.lblNoApps.hidden=YES;
                self.tblAppointments.hidden=NO;
                [refreshControl endRefreshing];
                [self.tblAppointments reloadData];
            }
            else
            {
                self.tblAppointments.hidden=YES;
                self.lblNoApps.hidden=NO;
//                self.lblNoApps.text = @"\u2022 No appointments to show. Click “ Book New Appointment” button to book new appointment.";
                self.lblNoApps.text = @"\u2022 Book your appointments here and meet the doctor at the hospital.\n\n\u2022 You will receive a confirmation after you book.";
            }
            
        });

    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading appointments failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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

#pragma mark - Tableview Delegate/Datasource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrAppointments count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"APPCell";
    AppointmentTableViewCell *cell=(AppointmentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setCellData:[self.arrAppointments copy] row:indexPath.row];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
#pragma mark - AlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kNoAppsAlertTag && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    } else if(alertView.tag ==333){
        SmartRxEditProfileVC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"profileVC"];
        controller.viewControllerName = @"ConsultaionVC";
        [self.navigationController pushViewController:controller animated:YES];
    }
}
#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}

#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForAppointments];
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


@end
