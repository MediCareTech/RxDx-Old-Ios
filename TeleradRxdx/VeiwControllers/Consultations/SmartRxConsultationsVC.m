//
//  SmartRxConsultationsVC.m
//  SmartRx
//
//  Created by Manju Basha on 08/05/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import "SmartRxConsultationsVC.h"
#import "SmartRxEditProfileVC.h"

@interface SmartRxConsultationsVC ()

@end

@implementation SmartRxConsultationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBackButton];
    // Do any additional setup after loading the view.
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
    
}
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Table view data source
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    //Cell text attributes
    [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    
    self.consultationTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //To customize the separatorLines
    UIView *separatorLine = [[UIView alloc]initWithFrame:CGRectMake(1, cell.frame.size.height-1, self.consultationTable.frame.size.width-1, 1)];
    separatorLine.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:separatorLine];
    
    // To bring the arrow mark on right end of each cell.
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"E-Consult";
        cell.imageView.image = [UIImage imageNamed:@"eConsult.png"];
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Appointment";
        cell.imageView.image = [UIImage imageNamed:@"calender-Consult.png"];
    }
    else if (indexPath.row == 2)
    {
        cell.textLabel.text = @"Services Booked";
        cell.imageView.image = [UIImage imageNamed:@"calender-Consult.png"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"eConsultID" sender:nil];
    }
    else if (indexPath.row == 1)
    {
        [self performSegueWithIdentifier:@"AppointmentsID" sender:nil];
    }
    else if (indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"servicesVC" sender:nil];
    }
}
-(void)moveToBookAppointmentController{
    
    NSString *mailStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"emailId"];
    
    NSString *ageStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"age"];
   
    if (mailStr ==nil || [ageStr isEqualToString:@"0"]) {
        SmartRxEditProfileVC *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"profileVC"];
        controller.viewControllerName = @"ConsultaionVC";
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self performSegueWithIdentifier:@"AppointmentsID" sender:nil];
    }
    
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
