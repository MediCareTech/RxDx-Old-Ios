//
//  SmartRxBookAPPointmentVC.m
//  SmartRx
//
//  Created by PaceWisdom on 12/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxBookAPPointmentVC.h"
#import "SmartRxAppointmentsVC.h"
#import "SmartRxCommonClass.h"
#import "NetworkChecking.h"
#import "SmartRxDashBoardVC.h"
#import "NSString+DateConvertion.h"
#import <QuartzCore/QuartzCore.h>

#define kDoctorsTextfieldTag 3000
#define kDateTextfieldTag 3001
#define kTimeTextfieldTag 3002
#define kLocationTextfieldtag 3003
#define kSpecialityTextfiledTag 3004
#define kBookAppSuccesTag 3005
#define kBookAppSuccesTagFindDoctors 3006
#define kKeyBoardHeight 200
#define kNoCreditsAlertTag 8000

@interface SmartRxBookAPPointmentVC ()
{
    UIActivityIndicatorView *spinner;
    NSInteger txtFiledTag;
    NSString *strLoctionId;
    NSString *strSelDocId;
    NSString *strSelctedDate;
    NSString *strRegular;
    NSString *strRegisterCall;
    
    MBProgressHUD *HUD;
    CGSize viewSize;
    CGFloat height;
    NSString *strFrontDeskNum;
    
}
@end

@implementation SmartRxBookAPPointmentVC

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
#pragma mark - View LIfe Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:_strTitle controler:self];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
    {
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"] length] >0)
        {
            self.textName.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserName"];
            self.textMobile.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
        }
    }
    
    self.textReason.layer.cornerRadius=0.0f;
    self.textReason.layer.masksToBounds = YES;
    self.textReason.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.textReason.layer.borderWidth= 1.0f;
    viewSize=[UIScreen mainScreen].bounds.size;
    self.navigationItem.hidesBackButton=YES;
    pickerAction = [[UIView alloc] initWithFrame:CGRectMake ( 0.0, 0.0, 460.0, 1248.0)];
    pickerAction.hidden = YES;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent"]];
    backgroundView.opaque = NO;
    backgroundView.frame = pickerAction.bounds;
    [pickerAction addSubview:backgroundView];
    
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],
                         nil];
    [doneToolbar sizeToFit];
    self.textMobile.inputAccessoryView = doneToolbar;
    
    [self navigationBackButton];
    [self numberKeyBoardReturn];
    self.arrDoctorsList=[[NSMutableArray alloc]init];
    self.arrLoadTbl=[[NSMutableArray alloc]init];
    self.arrSpeclist=[[NSMutableArray alloc]init];
    self.arrSpecAndDocResponse = [[NSMutableArray alloc]init];
    self.arrAppTime=[[NSMutableArray alloc]init];
    self.dictAppTimes=[[NSDictionary alloc]init];
    self.arrLocations=[[NSArray alloc]init];
    if([self.doctorAppointmentDetails count])
    {
        self.arrSpecAndDocResponse = self.dictResponse;
        self.textLocation.text = [self.doctorAppointmentDetails objectForKey:@"locname"];
        self.textSpeciality.text = [self.doctorAppointmentDetails objectForKey:@"deptname"];
        self.textDoctorName.text = [self.doctorAppointmentDetails objectForKey:@"dispname"];
        strLoctionId = [self.doctorAppointmentDetails objectForKey:@"locid"];
        strSlelectedDocID = [self.doctorAppointmentDetails objectForKey:@"recno"];
        strSpecId = [self.doctorAppointmentDetails objectForKey:@"specid"];
    }
    NSDictionary *size = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:17],UITextAttributeFont, nil];
    self.navigationController.navigationBar.titleTextAttributes = size;
    
    CALayer *layer = self.tblDoctorsList.layer;
    [layer setMasksToBounds:YES];
    [layer setCornerRadius: 4.0];
    [layer setBorderWidth:3.0];
    [layer setBorderColor:[[UIColor colorWithWhite: 0.8 alpha: 1.0] CGColor]];
    //[layer setBorderColor:(__bridge CGColorRef)([UIColor darkTextColor])];
    
    self.scrolView.contentSize=CGSizeMake(self.scrolView.frame.origin.x, self.btnBookApp.frame.origin.y+self.btnBookApp.frame.size.height+self.textName.frame.size.height+self.textMobile.frame.size.height);
    self.btnEconsult.selected=NO;
    self.btnRegular.selected=YES;
    
    
    strRegular=@"1";
    
    self.tblDoctorsList.hidden=YES;
    
}
- (void)doneButton:(id)sender
{
    [self.textMobile resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request methods
-(void)makeRequestForCreatdits
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *bodyText=nil;
    bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mpack"];//@"mdocs"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 2 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            strRegisterCall=@"GetDoctor";
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                strFrontDeskNum=[response objectForKey:@"frontdesk"];
                if ([[response objectForKey:@"econsults"]integerValue] > 0)
                {
                    strRegular=@"2";
                    self.btnEconsult.selected=YES;
                    self.btnRegular.selected=NO;
                    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
                    if ([networkAvailabilityCheck reachable])
                    {
                        self.textDoctorName.text=@"";
                        self.textLocation.text=@"";
                        self.textSpeciality.text=@"";
                        self.textTime.text=@"";
                    }
                    else{
                        [self customAlertView:@"" Message:@"Network not available" tag:0];
                    }
                    
                    
                }
                else{
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"No credits available, Please call hospital to buy" delegate:self cancelButtonTitle:@"CALL" otherButtonTitles:@"CANCEL", nil];
                    [alert show];
                    alert.tag=kNoCreditsAlertTag;
                    strRegular=@"1";
                    self.btnEconsult.selected=NO;
                    self.btnRegular.selected=YES;
                    alert=nil;
                    
                }
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}

- (void)makeRequestForDoctorSpecialities
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&cid=%@",@"sessionid",sectionId,@"locid",strLoctionId, strCid];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",@"cid",strCid,@"locid",strLoctionId,@"isopen",@"1"];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mlocdoc"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 3 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            strRegisterCall=@"getDocAndSpecilities";//@"GetDoctor";
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                [self.arrLoadTbl removeAllObjects];
                [self.arrSpeclist removeAllObjects];
                self.dictResponse = nil;
                [self.tblDoctorsList reloadData];
                
                self.dictResponse = [response objectForKey:@"docspec"];
                self.arrSpecAndDocResponse = [response objectForKey:@"docspec"];
                NSString *tempString = @"";
                
                for (int i=0; i< [self.dictResponse count]; i++)
                {
                    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                    tempString = [[self.arrSpecAndDocResponse objectAtIndex:i] objectForKey:@"deptname"];
                    [tempDict setObject:tempString forKey:@"speciality"];
                    [tempDict setObject:[[self.arrSpecAndDocResponse objectAtIndex:i] objectForKey:@"specid"] forKey:@"recNo"];
                    [self.arrSpeclist addObject:tempDict];
                    
                }
                NSSet *removeDuplicates = [NSSet setWithArray:self.arrSpeclist];
                self.arrSpeclist = [[removeDuplicates allObjects] mutableCopy];
                
                self.arrSpeclist = [self.arrSpeclist mutableCopy];
                
                if ([self.arrSpeclist count])
                {
                    self.textSpeciality.text=[[self.arrSpeclist objectAtIndex:0]objectForKey:@"speciality"];
                    strSpecId=[[self.arrSpeclist objectAtIndex:0]objectForKey:@"recNo"];
                    self.arrLoadTbl=[self.arrSpeclist mutableCopy];
                    self.tblDoctorsList.hidden=NO;
                    [self.tblDoctorsList reloadData];
                }
                else{
                    [self customAlertView:@"No Speciality available" Message:@"" tag:0];
                }
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
    
    
}

-(void)makeRequestGetDoctors
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    if ([self.dictResponse
         count] == 0 && [sectionId length] == 0)
    {
        strRegisterCall=@"getDocAndSpecilities";//@"GetDoctor";
        [self makeRequestForUserRegister];
        
    }
    else
    {
        [self.arrLoadTbl removeAllObjects];
        [self.arrDoctorsList removeAllObjects];
        [self.tblDoctorsList reloadData];
        NSString *tempString = @"";
        NSString *specialityString = self.textSpeciality.text;
        
        for (int i=0; i< [self.dictResponse count]; i++)
        {
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
            tempString = [[self.arrSpecAndDocResponse objectAtIndex:i] objectForKey:@"dispname"];
            if ([[[self.arrSpecAndDocResponse objectAtIndex:i] objectForKey:@"deptname"] isEqualToString:specialityString])
            {
                [tempDict setObject:tempString forKey:@"name"];
                [tempDict setObject:[[self.arrSpecAndDocResponse objectAtIndex:i] objectForKey:@"recno"] forKey:@"recNo"];
                [self.arrDoctorsList addObject:tempDict];
            }
        }
        NSSet *removeDuplicates = [NSSet setWithArray:self.arrDoctorsList];
        self.arrDoctorsList = [[removeDuplicates allObjects] mutableCopy];
        if ([self.dictResponse count])
        {
            
            self.textDoctorName.text=[[self.arrDoctorsList objectAtIndex:0]objectForKey:@"name"];
            strSlelectedDocID=[[self.arrDoctorsList objectAtIndex:0]objectForKey:@"recNo"];
            
            self.arrLoadTbl=[self.arrDoctorsList mutableCopy];
            self.tblDoctorsList.hidden=NO;
            [self.tblDoctorsList reloadData];
            [HUD hide:YES];
            [HUD removeFromSuperview];
        }
        else{
            [HUD hide:YES];
            [HUD removeFromSuperview];
            [self customAlertView:@"No Doctor(s) available" Message:@"" tag:0];
        }
    }
    
}

-(void)makeRequestForDoctorAvailablity
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    //    self.arrLoadTbl = nil;
    //    [self.arrLoadTbl removeAllObjects];
    //    [self.tblDoctorsList reloadData];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",@"sessionid",sectionId,@"docid",strSlelectedDocID,@"doa", self.textDate.text,@"locid",strLoctionId,@"apptype",strRegular];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",@"cid",strCid,@"docid",strSlelectedDocID,@"doa", self.textDate.text,@"locid",strLoctionId,@"isopen",@"1",@"apptype",strRegular];
    }
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mavail"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 4 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            strRegisterCall=@"AvialDoctor";
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner stopAnimating];
                [spinner removeFromSuperview];
                spinner = nil;
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                //self.arrAppTime=[[response objectForKey:@"slots"]allValues];
                self.dictAppTimes=[response objectForKey:@"slots"];
                if ([self.dictAppTimes count])
                {
                    
                    if ([self.arrAppTime count])
                    {
                        [self.arrAppTime removeAllObjects];
                    }
                    
                    NSMutableArray *arrToSort = [[NSMutableArray alloc] initWithArray:[self.dictAppTimes allKeys]];
                    
                    NSArray *sortedArray = [arrToSort sortedArrayUsingComparator:^(id obj1, id obj2) {
                        NSNumber *num1 = [NSNumber numberWithInt:[obj1 intValue]];
                        NSNumber *num2 = [NSNumber numberWithInt:[obj2 intValue]];
                        return (NSComparisonResult)[num1 compare:num2];
                        NSLog(@"(NSComparisonResult)[num1 compare:num2] %ld",(NSComparisonResult)[num1 compare:num2]);
                        
                    }];
                    
                    NSLog(@"sorted array == %@",sortedArray);
                    
                    _arrAppTimeIds=sortedArray;
                    
                    
                    for (int i=0; i<[_arrAppTimeIds count]; i++)
                    {
                        
                        
                        if ([self.dictAppTimes objectForKey:[NSString stringWithFormat:@"%@",[_arrAppTimeIds objectAtIndex:i]]])
                        {
                            [self.arrAppTime addObject:[self.dictAppTimes objectForKey:[NSString stringWithFormat:@"%@",[_arrAppTimeIds objectAtIndex:i]]]];
                        }
                        
                    }
                    
                    self.textTime.text=[self.arrAppTime objectAtIndex:0];
                    self.arrLoadTbl=[self.arrAppTime mutableCopy];
                    self.tblDoctorsList.hidden=NO;
                    [self.tblDoctorsList reloadData];
                }
                else{
                    NSLog(@"Not Available");
                    
                    [self customAlertView:@"" Message:@"Slots are not available" tag:0];
                }
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}


-(void)makeRequestBookAppointment
{
    
    //sessionid:0b7d3fecdda3a6cf6e8c598cfe20796b
    //docid:221787
    //doa:28-03-2013
    //hosploc:24
    //apttime:8:00 AM
    //reason:Check this out
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"name=%@&mobile=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@", self.textName.text, self.textMobile.text, @"sessionid",sectionId,@"docid",strSlelectedDocID,@"doa",self.textDate.text,@"apttime",self.textTime.text,@"reason",self.textReason.text,@"hosploc",strLoctionId,@"specilty",strSpecId,@"apptype",strRegular];
    }
    else{
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@***%@***%@&%@=%@&%@=%@&%@=%@&%@=%@", @"cid",strCid ,@"docid",strSlelectedDocID,@"doa",self.textDate.text,@"apttime",self.textTime.text,@"reason",self.textName.text, self.textMobile.text,self.textReason.text,@"hosploc",strLoctionId,@"specilty",strSpecId,@"apptype",strRegular,@"isopen",@"1"];
    }
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"maddapt"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 6 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            strRegisterCall=@"BookApp";
            [self makeRequestForUserRegister];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                
                if ([[response objectForKey:@"result"]integerValue] == 1)
                {
                    NSString *msg = @"Your appointment has been created. You will receive confirmation soon.";
//                    if ([self.btnRegular isSelected])
//                    {
//                        msg = @"Your appointment has been created. You will receive confirmation soon.";
//                    }
//                    else
//                    {
//                        msg = @"E-Consult has been booked successfully";
//                    }
//                    
                    if ([self.doctorAppointmentDetails count] && [[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
                    {
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:msg message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        alert.tag=kBookAppSuccesTagFindDoctors;
                        [alert show];
                    }
                    else
                    {
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Your appointment has been created. You will receive confirmation soon." message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        alert.tag=kBookAppSuccesTag;
                        [alert show];
                    }
                }
                else if ([[response objectForKey:@"result"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"There were some issues booking the appointment. Please try after sometime." message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
            });
        }
    } failureHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"There were some issues booking the appointment. Please try after sometime." Message:@"Try again" tag:0];
    }];
}

-(void)makeRequestForLocations
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    
    NSString *strCid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    NSString *bodyText=nil;
    if ([sectionId length] > 0)
    {
        bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    }
    else{
        
        bodyText = [NSString stringWithFormat:@"%@=%@&%@=%@",@"cid",strCid,@"isopen",@"1"];
    }
    
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mlocation"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 7 %@",response);
        
        if ([response count] == 0 && [sectionId length] == 0)
        {
            strRegisterCall=@"location";
            [self makeRequestForUserRegister];
        }
        else{
            
            if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0 && [[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
            {
                SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
                smartLogin.loginDelegate=self;
                [smartLogin makeLoginRequest];
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [HUD hide:YES];
                    [HUD removeFromSuperview];
                    self.view.userInteractionEnabled = YES;
                    
                    if (![[response objectForKey:@"location"] isKindOfClass:[NSArray class]])
                    {
                        [self customAlertView:@"" Message:@"Locations Not available" tag:0];
                    }
                    else{
                        self.arrLocations=[response objectForKey:@"location"];
                        if ([self.arrLocations count])
                        {
                            self.textLocation.text=[[self.arrLocations objectAtIndex:0]objectForKey:@"locname"];
                            strLoctionId=[[self.arrLocations objectAtIndex:0]objectForKey:@"locid"];
                            //[self makeRequestForSpecialities];
                            self.arrLoadTbl=[self.arrLocations mutableCopy];
                            self.tblDoctorsList.hidden=NO;
                            [self.tblDoctorsList reloadData];
                        }
                        else{
                            NSLog(@"Not Available");
                        }
                    }
                });
            }
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}


-(void)makeRequestForUserRegister
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    
    [self addSpinnerView];
    NSString *strMobile=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
    NSString *strCode=[[NSUserDefaults standardUserDefaults]objectForKey:@"code"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"mobile",strMobile];
    bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"code",strCode]];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mregister"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 8 %@",response);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            [[NSUserDefaults standardUserDefaults]setObject:strCode forKey:@"code"];
            [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cidd"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [self performSegueWithIdentifier:@"RegisterID" sender:[response objectForKey:@"cid"]];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"Y"] )
            {
                [[NSUserDefaults standardUserDefaults]setObject:[response objectForKey:@"cid"] forKey:@"cid"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                if ([strRegisterCall isEqualToString:@"location"])
                {
                    [self makeRequestForLocations];
                }
                else if ([strRegisterCall isEqualToString:@"getDocAndSpecilities"])
                {
                    [self makeRequestForDoctorSpecialities];
                }
                else if ([strRegisterCall isEqualToString:@"GetDoctor"])
                {
                    [self makeRequestGetDoctors];
                }
                //                else if ([strRegisterCall isEqualToString:@"Specilities"])
                //                {
                //                    [self makeRequestForSpecialities];
                //                }
                else if ([strRegisterCall isEqualToString:@"AvialDoctor"])
                {
                    [self makeRequestForDoctorAvailablity];
                }
                else if ([strRegisterCall isEqualToString:@"BookApp"])
                {
                    [self makeRequestBookAppointment];
                }
                
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"N"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:[response objectForKey:@"response"] tag:0];
            }
            else if ([[response objectForKey:@"pvalid"] isEqualToString:@"Y"] && [[response objectForKey:@"cvalid"] isEqualToString:@"N"] )
            {
                [self customAlertView:@"" Message:[response objectForKey:@"response"] tag:0];
            }
            
        });
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

#pragma mark - Action methods

-(void)homeBtnClicked:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
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
    [self hideKeyboardBtnClicked:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)donePikerBtnClicked:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        self.viewForPicker.frame=CGRectMake(self.viewForPicker.frame.origin.x, self.viewForPicker.frame.origin.y+self.viewForPicker.frame.size.height, self.viewForPicker.frame.size.width, self.viewForPicker.frame.size.height);
        [self.pickerView reloadAllComponents];
    }];
}

- (IBAction)bookAppoinmentClicked:(id)sender
{
    
    [self hideKeyboardBtnClicked:nil];
    if ([self.textName.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Name cannot be empty" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else if ([self.textMobile.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Please specify a mobile number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else if ([self.textMobile.text length] <10)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Phone number cannot be less than 10 digits" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else if ([self.textLocation.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Please select a location" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else if([self.textSpeciality.text length] <=0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Please select a Speciality" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else if ([self.textDoctorName.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Please select a Doctor" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else if ([self.textDate.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Appointment date required" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else if ([self.textTime.text length] <= 0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Appointment time required" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    else
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestBookAppointment];
        }
        else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            alertView=nil;
        }
    }
}

- (IBAction)timeBtnClicked:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
    cellTextfield=_textTime;
    //    cellTextfield.tag=kTimeTextfieldTag;
    
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForDoctorAvailablity];
    }
    else{
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
    
}
-(void)checkDoctorAvailableTimes
{
    txtFiledTag=kTimeTextfieldTag;
    cellTextfield=self.textTime;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForDoctorAvailablity];
    }
    else{
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
}

- (IBAction)dateBtnClicked:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
    if ([self.textReason isFirstResponder])
    {
        [self.textReason resignFirstResponder];
    }
    
    txtFiledTag=kDateTextfieldTag;
    cellTextfield=self.textDate;
    [self clearTextfieldData:cellTextfield];
    self.datePickerView.datePickerMode=UIDatePickerModeDate;
    [self ChooseDP:@"Date"];
}

- (IBAction)eConsultBtnClicked:(id)sender
{
    
    if (![self.btnEconsult isSelected])
    {
        [self.btnBookApp setTitle:@"Book E-Consult" forState:UIControlStateNormal];
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
        {
            NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
            if ([networkAvailabilityCheck reachable])
            {
                [self makeRequestForCreatdits];
            }
            else{
                [self customAlertView:@"" Message:@"Network not available" tag:0];
            }
        }
        else
        {
            [self customAlertView:@"" Message:@"Login required" tag:0];
        }
    }
    
}

- (IBAction)regularBtnClicked:(id)sender
{
    
    if (![self.btnRegular isSelected])
    {
        [self.btnBookApp setTitle:@"Book Appointment" forState:UIControlStateNormal];
        strRegular=@"1";
        self.btnEconsult.selected=NO;
        self.btnRegular.selected=YES;
        
        self.textDoctorName.text=@"";
        self.textLocation.text=@"";
        self.textSpeciality.text=@"";
        self.textTime.text=@"";
        
    }
    
    
}

- (IBAction)selectLocationBtnClicked:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
    cellTextfield=self.textLocation;
    [self clearTextfieldData:cellTextfield];
    
    
    
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForLocations];
    }
    else{
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
    
}

- (IBAction)selectSpecBtnClicked:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
    cellTextfield=self.textSpeciality;
    [self clearTextfieldData:cellTextfield];
    
    
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForDoctorSpecialities];
        //        [self makeRequestForSpecialities];
    }
    else
    {
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
    
}

- (IBAction)selectDocBtnClicked:(id)sender
{
    [self hideKeyboardBtnClicked:nil];
    cellTextfield=self.textDoctorName;
    [self clearTextfieldData:cellTextfield];
    
    
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestGetDoctors];
    }
    else{
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
    
}

- (IBAction)hideKeyboardBtnClicked:(id)sender
{
    if ([self.textReason isFirstResponder])
    {
        [self.textReason resignFirstResponder];
    }
    if ([self.textMobile isFirstResponder])
    {
        [self.textMobile resignFirstResponder];
    }
    if ([self.textName isFirstResponder])
    {
        [self.textName resignFirstResponder];
    }

    if (![self.tblDoctorsList isHidden]) {
        self.tblDoctorsList.hidden=YES;
    }
}
-(void)ChooseDP:(id)sender{
//    pickerAction = [[UIActionSheet alloc] initWithTitle:@"Date"
//                                               delegate:nil
//                                      cancelButtonTitle:nil
//                                 destructiveButtonTitle:nil
//                                      otherButtonTitles:nil];
    
    self.datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake ( 0.0, viewSize.height-216, 0.0, 0.0)];
    self.datePickerView.backgroundColor = [UIColor whiteColor];
    NSString *date = self.textDate.text;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    if ([sender isEqualToString:@"Date"])
    {
        [self.datePickerView setMinimumDate:[NSDate date]];
        self.datePickerView.datePickerMode = UIDatePickerModeDate;
    }
    else
    {
        self.datePickerView.datePickerMode = UIDatePickerModeTime;
    }
    if([date length]>0)
    {
        [self.datePickerView setDate:[NSString stringToDate:date]];
    }
    //    //format datePicker mode. in this example time is used
    //    self.datePickerView.datePickerMode = UIDatePickerModeTime;
    //    [dateFormatter setDateFormat:@"h:mm a"];
    //    //calls dateChanged when value of picker is changed
    //    [self.datePickerView addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    toolbarPicker = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewSize.height-260, 320, 44)];
    toolbarPicker.barStyle=UIBarStyleBlackOpaque;
    [toolbarPicker sizeToFit];
    NSMutableArray *itemsBar = [[NSMutableArray alloc] init];
    //calls DoneClicked
    UIBarButtonItem *bbitem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [itemsBar addObject:bbitem];
    
    [toolbarPicker setItems:itemsBar animated:YES];
    [pickerAction addSubview:toolbarPicker];
    [pickerAction addSubview:self.datePickerView];
    [self.view addSubview:pickerAction];
    pickerAction.hidden = NO;
}
- (IBAction)doneClicked:(id)sender
{
    if(txtFiledTag == kDateTextfieldTag)
    {
        NSDate *dateAppointment=self.datePickerView.date;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd-MM-yyy"];
        NSString *strDate = [dateFormat stringFromDate:dateAppointment];
        self.textDate.text=strDate;
        self.datePickerView.hidden=YES;
    }
    else if(txtFiledTag == kTimeTextfieldTag)
    {
        NSDate *dateAppointment=self.datePickerView.date;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"hh:mm a"];
        NSString *strTime = [dateFormat stringFromDate:dateAppointment];
        NSLog(@"time ==== %@",strTime);
        self.textTime.text=strTime;
        self.datePickerView.hidden=YES;
    }
    
    [self closeDatePicker:nil];
    
    //[self checkDoctorAvailableTimes];
    
    
}
-(BOOL)closeDatePicker:(id)sender
{
    pickerAction.hidden = YES;
    return YES;
}

#pragma mark - TableView Datasource/Delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrLoadTbl count];
}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *cellIdentifier=@"BookAppCell";
//    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//    cell.textLabel.textColor=[UIColor whiteColor];
//    if (cellTextfield.tag == kSpecialityTextfiledTag)
//    {
//        cell.textLabel.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"title"];
//    }else if(cellTextfield.tag == kDoctorsTextfieldTag)
//    {
//         cell.textLabel.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"dispname"];
//    }
//    else if(cellTextfield.tag == kLocationTextfieldtag)
//    {
//        cell.textLabel.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"locname"];
//    }
//    else if(cellTextfield.tag == kTimeTextfieldTag)
//    {
//        cell.textLabel.text=[self.arrLoadTbl objectAtIndex:indexPath.row];
//    }
//
//    return cell;
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"BookAppCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.textLabel.textColor=[UIColor whiteColor];
    if (cellTextfield == _textSpeciality)//kSpecialityTextfiledTag)
    {
        cell.textLabel.text = [[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"speciality"];
        //        cell.textLabel.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"deptname"];
        
    }else if(cellTextfield == _textDoctorName)//kDoctorsTextfieldTag)
    {
        cell.textLabel.text = [[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"name"];
        //        cell.textLabel.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"dispname"];
    }
    else if(cellTextfield == _textLocation)//kLocationTextfieldtag)
    {
        cell.textLabel.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"locname"];
    }
    else if(cellTextfield == _textTime)//kTimeTextfieldTag)
    {
        cell.textLabel.text=[self.arrLoadTbl objectAtIndex:indexPath.row];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cellTextfield.tag == kSpecialityTextfiledTag)
    {
        self.textSpeciality.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"speciality"];
        strSpecId=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"recNo"];
        //[self makeRequestGetDoctors];
    }
    else if(cellTextfield.tag == kDoctorsTextfieldTag)
    {
        self.textDoctorName.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"name"];
        strSlelectedDocID=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"recNo"];
    }
    else if(cellTextfield.tag == kLocationTextfieldtag)
    {
        self.textLocation.text=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"locname"];
        strLoctionId=[[self.arrLoadTbl objectAtIndex:indexPath.row]objectForKey:@"locid"];
        //[self makeRequestForSpecialities];
    }
    else if(cellTextfield.tag == kTimeTextfieldTag)
    {
        self.textTime.text=[self.arrLoadTbl objectAtIndex:indexPath.row];
    }
    self.tblDoctorsList.hidden=YES;
}
- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - TextField Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField != self.textMobile || textField != self.textName)
        [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.textMobile || textField == self.textName)
    {
    }
    else
    {
        cellTextfield=textField;
        [self clearTextfieldData:textField];
        [textField resignFirstResponder];
    }
    if (textField.tag == kLocationTextfieldtag)
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForLocations];
        }
        else{
            
            [self customAlertView:@"" Message:@"Network not available" tag:0];
            
        }
    }
    else if (textField.tag == kSpecialityTextfiledTag)
    {
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForDoctorSpecialities];
            //           [self makeRequestForSpecialities];
        }
        else{
            
            [self customAlertView:@"" Message:@"Network not available" tag:0];
            
        }
        
    }
    else if (textField.tag == kDoctorsTextfieldTag)
    {
        if ([self.arrDoctorsList count] > 0)
        {
            
            self.tblDoctorsList.hidden=NO;
            
        }
        else{
            if ([self.textLocation.text length] == 0)
            {
                [self customAlertView:@"Location empty" Message:@"Select location" tag:0];
            }
            else if([self.textSpeciality.text length] == 0)
            {
                [self customAlertView:@"Specialities empty" Message:@"Select specialities" tag:0];
            }
            else
            {
                NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
                if ([networkAvailabilityCheck reachable])
                {
                    [self makeRequestGetDoctors];
                }
                else{
                    
                    [self customAlertView:@"" Message:@"Network not available" tag:0];
                }
                
            }
        }
    }
    else if(textField.tag == kDateTextfieldTag)
    {
        txtFiledTag=kDateTextfieldTag;
        self.datePickerView.datePickerMode=UIDatePickerModeDate;
        [self ChooseDP:@"Date"];
        
    }
    else if(textField.tag == kTimeTextfieldTag)
    {
        txtFiledTag=kTimeTextfieldTag;
        
        NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
        if ([networkAvailabilityCheck reachable])
        {
            [self makeRequestForDoctorAvailablity];
        }
        else{
            [self customAlertView:@"" Message:@"Network not available" tag:0];
        }
    }
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == kDateTextfieldTag)
    {
        //        NSDate *dateAppointment=self.datePickerView.date;
        //        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //        [dateFormat setDateFormat:@"dd MM yyy"];
        //        NSString *strDate = [dateFormat stringFromDate:dateAppointment];
        self.datePickerView.hidden=YES;
    }
    else if (textField.tag == kTimeTextfieldTag)
    {
        //        NSDate *dateAppointment=self.datePickerView.date;
        //        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //        [dateFormat setDateFormat:@"hh:mm a"];
        //        NSString *strTime = [dateFormat stringFromDate:dateAppointment];
        self.datePickerView.hidden=YES;
    }
}
-(void)clearTextfieldData:(UITextField *)selectedTxtField
{
    if (selectedTxtField.tag == kLocationTextfieldtag)
    {
        self.textDoctorName.text=@"";
        self.textLocation.text=@"";
        self.textSpeciality.text=@"";
        self.textTime.text=@"";
        
    }
    else if (selectedTxtField.tag == kSpecialityTextfiledTag)
    {
        self.textDoctorName.text=@"";
        self.textSpeciality.text=@"";
        self.textTime.text=@"";
        
    }
    else if (selectedTxtField.tag == kDoctorsTextfieldTag)
    {
        self.textDoctorName.text=@"";
        self.textTime.text=@"";
    }
    else if (selectedTxtField.tag == kDateTextfieldTag)
    {
        
        self.textTime.text=@"";
        if ([self.arrAppTime count])
        {
            [self.arrAppTime removeAllObjects];
        }
        
    }
}

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kBookAppSuccesTag && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (alertView.tag == kNoCreditsAlertTag && buttonIndex == 0)
    {
        [self emgCall];
    }
    if (alertView.tag == kBookAppSuccesTagFindDoctors && buttonIndex == 0)
    {
        [self performSegueWithIdentifier:@"appointmentList" sender:nil];
    }


}
-(void)emgCall
{
    
    NSString *number = [NSString stringWithFormat:@"%@",strFrontDeskNum];
    NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@",number]];
    
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
#pragma mark - TextView Delegate method

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (![self.tblDoctorsList isHidden])
    {
        self.tblDoctorsList.hidden=YES;
    }
    self.lblTxtView.hidden=YES;
    self.imgTxtViwPecil.hidden=YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.scrolView.frame=CGRectMake(self.scrolView.frame.origin.x, self.scrolView.frame.origin.y-(20+kKeyBoardHeight), self.scrolView.frame.size.width, self.scrolView.frame.size.height);
    }];
    
    //    height=self.scrolView.frame.size.height - (textView.frame.origin.y+textView.frame.size.height);
    //    height=kKeyBoardHeight-height;
    //    [UIView animateWithDuration:0.2 animations:^{
    //
    //        self.scrolView.contentOffset=CGPointMake(self.scrolView.frame.origin.x, self.scrolView.frame.origin.y+height);
    //    }];
    
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.scrolView.frame=CGRectMake(self.scrolView.frame.origin.x, self.scrolView.frame.origin.y+(kKeyBoardHeight+20), self.scrolView.frame.size.width, self.scrolView.frame.size.height);
    }];
    if ([textView.text length] <=0)
    {
        self.lblTxtView.hidden=NO;
        self.imgTxtViwPecil.hidden=NO;
    }
    //    [UIView animateWithDuration:0.2 animations:^{
    //        self.scrolView.contentOffset=CGPointMake(0, 0);
    //    }];
}
- (void)textViewDidChange:(UITextView *)textView {
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}

-(void)numberKeyBoardReturn
{
    UIToolbar* numberToolbar;
    
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(retunWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.textReason.inputAccessoryView = numberToolbar;
}

-(void)retunWithNumberPad
{
    [self.textReason resignFirstResponder];
}
#pragma mark - Picker View Delegate Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.arrLoadTbl count];
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (cellTextfield.tag == kSpecialityTextfiledTag)
    {
        return [[self.arrLoadTbl objectAtIndex:row]objectForKey:@"title"];
    }else if(cellTextfield.tag == kDoctorsTextfieldTag)
    {
        return [[self.arrLoadTbl objectAtIndex:row]objectForKey:@"dispname"];
    }
    else
    {
        return 0;
    }
    
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"selected Component === %@",[[self.arrLoadTbl objectAtIndex:row]objectForKey:@"title"]);
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
        [self makeRequestBookAppointment];
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

#pragma mark - prepareForSegue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((SmartRxAppointmentsVC *)segue.destinationViewController).fromFindDoctors = YES;
}

@end


