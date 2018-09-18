//
//  SmartRxBookAPPointmentVC.h
//  SmartRx
//
//  Created by PaceWisdom on 12/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxAppointmentsVC.h"
@interface SmartRxBookAPPointmentVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate,MBProgressHUDDelegate,UITextViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,loginDelegate>
{
//    UIActionSheet *pickerAction;
    UIView *pickerAction;
    UIToolbar *toolbarPicker;
    UITextField *cellTextfield;
    NSString *strSpecId;
    NSString *strSlelectedDocID;
}
@property (nonatomic, retain) NSMutableDictionary *getAppointmentDoctorDetails;
@property (weak, nonatomic) IBOutlet UIButton *btnRegular;
@property (weak, nonatomic) IBOutlet UIButton *btnEconsult;
@property (weak, nonatomic) IBOutlet UIButton *btnBookApp;
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (weak, nonatomic) IBOutlet UITableView *tblDoctorsList;
@property (weak, nonatomic) IBOutlet UITextField *textDoctorName;
@property (weak, nonatomic) IBOutlet UITextField *textDate;
@property (weak, nonatomic) IBOutlet UITextField *textTime;
@property (weak, nonatomic) IBOutlet UITextField *textLocation;
@property (weak, nonatomic) IBOutlet UITextField *textSpeciality;
@property (weak, nonatomic) IBOutlet UITextField *textName;
@property (weak, nonatomic) IBOutlet UITextField *textMobile;
@property (weak, nonatomic) IBOutlet UIImageView *imgTxtViwPecil;
@property (weak, nonatomic) IBOutlet UILabel *lblTxtView;
@property (weak, nonatomic) IBOutlet UITextView *textReason;
@property (strong, nonatomic) NSMutableDictionary *doctorAppointmentDetails;

@property (strong, nonatomic) NSMutableArray *arrDoctorsList;
@property (strong, nonatomic) NSMutableArray *arrSpeclist;
@property (strong, nonatomic) NSMutableArray *arrSpecAndDocResponse;
@property (strong, nonatomic) NSMutableArray *arrLoadTbl;
@property (strong, nonatomic) NSArray *arrLocations;
@property (strong, nonatomic) NSMutableArray *arrAppTime;
@property (strong, nonatomic) NSDictionary *dictResponse;
@property (weak, nonatomic) IBOutlet UIView *viewForPicker;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIButton *btnDonePIcker;
@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (strong, nonatomic) NSDictionary *dictAppTimes;
@property (strong, nonatomic) NSArray *arrAppTimeIds;
@property (assign, nonatomic) NSString *strTitle;
- (IBAction)donePikerBtnClicked:(id)sender;
- (IBAction)bookAppoinmentClicked:(id)sender;
- (IBAction)timeBtnClicked:(id)sender;
- (IBAction)dateBtnClicked:(id)sender;
- (IBAction)eConsultBtnClicked:(id)sender;
- (IBAction)regularBtnClicked:(id)sender;
- (IBAction)selectLocationBtnClicked:(id)sender;
- (IBAction)selectSpecBtnClicked:(id)sender;
- (IBAction)selectDocBtnClicked:(id)sender;
- (IBAction)hideKeyboardBtnClicked:(id)sender;

@end
