//
//  SmartRxReportsListController.m
//  TeleradRxdx
//
//  Created by Gowtham on 29/05/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import "SmartRxReportsListController.h"
#import "SmartRxReportsListCell.h"
#import "SmartRxReportImageVC.h"
#import "ReportsResponseModel.h"


@interface SmartRxReportsListController ()<UITableViewDataSource,UITableViewDelegate,CellDelegate>
{
    CGFloat rowHeight;
     MBProgressHUD *HUD;
     UIActivityIndicatorView *spinner;
}

@property(nonatomic,strong) NSMutableArray *arrEstimatedHeight;
@property(nonatomic,strong) NSArray *recordsArray;

@end

@implementation SmartRxReportsListController
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
    btnFaq.tag=1;
    
    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_add_report.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    
    [btnFaq addTarget:self action:@selector(addReport:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;

   
}
-(void)addReport:(id)sender{
    [self performSegueWithIdentifier:@"addReportsVC" sender:nil];
}
-(void)backBtnClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tableView.estimatedRowHeight = 1000;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.arrEstimatedHeight = [[NSMutableArray alloc]init];
    [_arrEstimatedHeight addObject:[NSNumber numberWithFloat:68.28f]];
    rowHeight = 110.0f;
    self.tableView.hidden = YES;
    [self navigationBackButton];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self makeGetReportsRequest];
}
-(void)makeGetReportsRequest{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *strMobile=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobilNumber"];
     NSString *patientId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&mobile=%@&patid=%@",@"sessionid",sectionId,strMobile,patientId];
    
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"rxreport"];
    
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        NSLog(@"sucess 29 %@",response);
        
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tableView.hidden = NO;
                [HUD hide:YES];
                [HUD removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                NSMutableArray *array = [[NSMutableArray alloc]init];
                
                NSArray *tempArr = response[@"report"];
                for (NSDictionary *dict in tempArr) {
                    ReportsResponseModel *model = [[ReportsResponseModel alloc]init];
                    model.category = [self getCategory:dict[@"category"]];
                     model.date = [self getDate:dict[@"uploaded_date"]];
                     model.reportDescrption = dict[@"description"];
                    model.imagePath = [self getImagePath:dict[@"path"]];
                    [array addObject:model];
                }
                
                self.recordsArray = [array copy];
                //self.arrRecords=[response objectForKey:@"report"];
                [self.tableView reloadData];
            });
    
    } failureHandler:^(id response) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Loading Reports Failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }];

}
-(NSString *)getCategory:(NSString *)key{
    NSString *tempKey = [NSString stringWithFormat:@"%@",key];
    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:@"Lab",@"1",@"Radiology",@"2",@"MI",@"3",@"Discharge summary",@"4",@"Prescriptions",@"5",@"Case sheet",@"6",@"Others",@"7", nil];
    return dict[tempKey];
}
-(NSString *)getImagePath:(NSString *)imageStr{
    NSMutableString *str = [[NSMutableString alloc]initWithString:imageStr];
    [str deleteCharactersInRange:NSMakeRange(0, 2)];
    return str;
}
-(NSString *)getDate:(NSString *)dateStr{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    
     [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    
    return [dateFormatter stringFromDate:date];
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
#pragma mark - TableView DataSource/Delegate Methods

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGRect size = [UIScreen mainScreen].bounds;
    
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, size.size.width-110 ,21)];
    
     CGSize maximumLabelSize = CGSizeMake(220, 9999);
    
    NSString *htmlString=@"wueioagh uwjeahp u9iehw q u9jega ioj ag  jios;dbisjkdg iosdfjgh jpios;dfhb  siodj;h jiopsd;hbkljsdfjhg jidfbh ";
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    CGSize expectedLabelSize = [[attrStr string] sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    
    if (expectedLabelSize.height > 50) {
        float tempValue = expectedLabelSize.height - 50.0;
        rowHeight = 115.0+tempValue;
        return  rowHeight;
    }
    return 110.0f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return rowHeight;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    int numberOFSections = 0;
    if (self.recordsArray.count >0 ) {
        
        numberOFSections = 1;
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    } else {
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(12, 16, self.tableView.frame.size.width-28, 80)];
        label.text = [NSString stringWithFormat:@"\u2022 No Health Records found. \n\u2022 Use (+) icon to add reports"];
        label.numberOfLines = 5;
        label.textAlignment = NSTextAlignmentCenter;
        self.tableView.backgroundView = label;
        self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        
    }
    return numberOFSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.recordsArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SmartRxReportsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reportsCell"];
    cell.delagte = self;
    cell.cellId = indexPath;
    ReportsResponseModel *model = self.recordsArray[indexPath.row];
    cell.addedByLabel.text = @"By me";
    cell.dateLabel.text = model.date;
    
    cell.reportTypeLabel.text = model.category;
    cell.descriptionLabel.text = model.reportDescrption;
    //[cell.descriptionLabel sizeToFit];
    [cell.imageButton setImage:[UIImage imageNamed:@"tif.png"] forState:UIControlStateNormal];
    NSString *urlStr = [NSString stringWithFormat:@"%s%@",kBaseUrlQAImg,model.imagePath];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    SmartRxReportsListCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                    
                    if (updateCell)
                        [updateCell.imageButton setImage:image forState:UIControlStateNormal];
                    
                    
                });
            }
        }
    }];
    [task resume];

    return cell;
    
}
-(void)clickOnImageButton:(NSIndexPath *)indexpath{
    
    ReportsResponseModel *model = self.recordsArray[indexpath.row];

    SmartRxReportImageVC *imageVc = [self.storyboard instantiateViewControllerWithIdentifier:@"imageVC"];
    imageVc.strImage = model.imagePath;
    [self presentViewController:imageVc animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
