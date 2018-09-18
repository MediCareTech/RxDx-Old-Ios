//
//  SmartRxMessageDetailsVC.m
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxMessageDetailsVC.h"
#import "SmartRxDashBoardVC.h"
#import "NSString+DateConvertion.h"


@interface SmartRxMessageDetailsVC ()

@end

@implementation SmartRxMessageDetailsVC

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
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self navigationBackButton];
    [self estimatedHeight];
    self.lblSenderName.text=[self.dictMsgDetails objectForKey:@"title"];//@"Care Message";
    self.lblDateTime.text=[NSString timeFormating:[self.dictMsgDetails objectForKey:@"time"] funcName:@"messagedetails"];
    self.imgMessage.image=[self.dictMsgDetails objectForKey:@"images"];//[UIImage imageNamed:];
	// Do any additional setup after loading the view.
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
#pragma mark - Calculating Label Height

-(void)setLblYPostionAndHeight:(CGFloat )height{
    self.lblMessage.frame = CGRectMake(self.lblMessage.frame.origin.x, self.lblMessage.frame.origin.y, self.lblMessage.frame.size.width, height);
    
    self.lblMessage.text=[self.dictMsgDetails objectForKey:@"msg"];
    self.lblMessage.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    self.lblMessage.numberOfLines=10000;
    
    self.lblDateTime.frame=CGRectMake(self.lblDateTime.frame.origin.x, self.lblMessage.frame.origin.y+self.lblMessage.frame.size.height,  self.lblDateTime.frame.size.width, self.lblDateTime.frame.size.height);
}
-(void)estimatedHeight
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(2, 0, 320,21)];
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    CGSize maximumLabelSize = CGSizeMake(296,9999);
    CGSize expectedLabelSize;
    
    expectedLabelSize = [[self.dictMsgDetails objectForKey:@"msg"]  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    [self setLblYPostionAndHeight:expectedLabelSize.height+20];
}

@end
