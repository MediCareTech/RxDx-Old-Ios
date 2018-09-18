//
//  SmartRxMessageViewController.m
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxMessageViewController.h"
#import "SmartRxMessageTVC.h"
#import "SmartRxMessageDetailsVC.h"
#import "SmartRxCommonClass.h"
#import "NetworkChecking.h"
#define kIntalMsgRow 3
#define kNoMsgsAlertTag 1600

@interface SmartRxMessageViewController ()
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *HUD;
    CGSize viewSize;
    BOOL isMoreSelected;
    UIRefreshControl *refreshControl;
    BOOL isRefreshClicked;
}

@end

@implementation SmartRxMessageViewController

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
    viewSize=[UIScreen mainScreen].bounds.size;
    self.dstMsgDetails=[[NSMutableDictionary alloc]init];
    self.arrMsgDetails=[[NSArray alloc]init];
    self.tblMessages.hidden=YES;
    self.btnMoreMsgs.hidden=YES;
    self.lblmsgs.text = @"No messages to show.\n\u2022 You can get regular advice, tips and alert messages related to your health condition\n\u2022 Ask your doctor or hospital to subscribe for Messages";
    self.lblmsgs.hidden=YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForMessages];
    }
    else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Network not available" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;
    }
    
    isMoreSelected=NO;
    isRefreshClicked=NO;
    
    
    
	refreshControl = [[UIRefreshControl alloc]init];
    [self.tblMessages addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    [self.tblMessages setTableFooterView:[UIView new]];
    // Do any additional setup after loading the view.
}
-(void)refreshTable
{
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        isRefreshClicked=YES;
        [self makeRequestForMessages];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
        
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
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)moreMsgBtnClicked:(id)sender
{
    if ([self.arrMsgDetails count] > 3)
    {
        isMoreSelected=YES;
        self.btnMoreMsgs.hidden=YES;
        self.tblMessages.frame=CGRectMake(self.tblMessages.frame.origin.x, self.tblMessages.frame.origin.y, self.tblMessages.frame.size.width, viewSize.height-20);
        [self.tblMessages reloadData];
        self.tblMessages.contentSize = CGSizeMake(self.tblMessages.frame.size.width, self.tblMessages.contentSize.height + 150);
    }
    else{
        self.btnMoreMsgs.hidden=YES;
        [self customAlertView:@"No more messages" Message:@"" tag:0];
    }
}

#pragma mark - Custom Methods

-(NSString *)convertHTML :(NSString *)html {
    
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        
        [myScanner scanUpToString:@"<" intoString:NULL] ;
        
        [myScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}
-(void)makeRequestForMessages
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mmsg"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 24 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
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
            self.arrMsgDetails=[response objectForKey:@"msg"];
            if ([self.arrMsgDetails count])
            {
                self.tblMessages.hidden=NO;
                [refreshControl endRefreshing];
                if (!isRefreshClicked) {
                   // self.btnMoreMsgs.hidden=NO;
                }
                
                [self.tblMessages reloadData];
            }
            else
            {
                //self.btnMoreMsgs.hidden=YES;
                self.lblmsgs.hidden=NO;
                
            }
            
        });
        }
    } failureHandler:^(id response) {
        NSLog(@"failure %@",response);
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self customAlertView:@"Some error occur" Message:@"Try again" tag:0];
    }];
}
-(void)addSpinnerView
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	[HUD show:YES];
}

#pragma mark - TableView DataSource/Delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.arrMsgDetails count])
    {
        
        if (isMoreSelected)
        {
            return [self.arrMsgDetails count];
        }
        else{
            if ([self.arrMsgDetails count] < 4)
            {
                self.btnMoreMsgs.hidden=YES;
                return [self.arrMsgDetails count];
            }
            else{
                self.btnMoreMsgs.hidden=NO;
                return kIntalMsgRow;
            }
        }
    }
    else{
        return 0;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"messageCell";
    SmartRxMessageTVC *cell=(SmartRxMessageTVC *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self.dstMsgDetails setObject:[[self.arrMsgDetails objectAtIndex:indexPath.row]objectForKey:@"updateddate"] forKey:@"Time"];
    NSString *alerttxt=[NSString stringWithFormat:@"%@", [[self.arrMsgDetails objectAtIndex:indexPath.row]objectForKey:@"alerttxt"]];
    [self.dstMsgDetails setObject:@"Care Message" forKey:@"Name"];
    [self.dstMsgDetails setObject:[[self.arrMsgDetails objectAtIndex:indexPath.row]objectForKey:@"operation"] forKey:@"operation"];
    [self.dstMsgDetails setObject:[self convertHTML:alerttxt] forKey:@"Msg"];
    [(SmartRxMessageTVC *)cell setmessageInfo:self.dstMsgDetails];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *alerttxt=[NSString stringWithFormat:@"%@", [[self.arrMsgDetails objectAtIndex:indexPath.row]objectForKey:@"alerttxt"]];
    
    SmartRxMessageTVC *cell=(SmartRxMessageTVC *)[tableView cellForRowAtIndexPath:indexPath];
    NSString *strTitle=cell.lblSenderName.text;
    UIImage *imgMessages=cell.imgViewMessages.image;
    
     NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:[self convertHTML:alerttxt],@"msg",[[self.arrMsgDetails objectAtIndex:indexPath.row]objectForKey:@"updateddate"],@"time",strTitle,@"title",imgMessages,@"images", nil];
    [self performSegueWithIdentifier:@"MessageDetails" sender:dictTemp];
}
#pragma mark - TableView Storyboard Preapare segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MessageDetails"]) {
        
        SmartRxMessageDetailsVC *controller = segue.destinationViewController;
        controller.dictMsgDetails = sender;
       // ((SmartRxMessageDetailsVC *)segue.destinationViewController).dictMsgDetails=sender;
    }
}
#pragma mark - AlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kNoMsgsAlertTag && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
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
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForMessages];
    }
    else{
        
        [self customAlertView:@"" Message:@"Network not available" tag:0];
    }
}
-(void)errorSectionId:(id)sender
{
    self.view.userInteractionEnabled = YES;
}


@end
