//
//  SmartRxAddPhr.h
//  SmartRx
//
//  Created by Anil Kumar on 10/09/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxAddPhrUIPicker : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource,loginDelegate,MBProgressHUDDelegate,  UITextFieldDelegate, UIActionSheetDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *measureLabel;
@property (weak, nonatomic) IBOutlet UITextField *measureTextField;
@property (weak, nonatomic) IBOutlet UITextField *levelTextField;
@property (retain, nonatomic) UIPickerView *picker;
@property (assign, nonatomic) NSString *strTitle;
@property (weak, nonatomic) IBOutlet UIButton *transparentImgView;
@property (nonatomic, readwrite) float selectedComponentOne;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (retain, nonatomic) UIDatePicker *datePicker;
@property (retain, nonatomic) UIDatePicker *timePicker;
@property (strong, nonatomic) UIButton *currentButton;
@property (nonatomic, readwrite)  NSUInteger selectedComponentTwo, selectedComponentThree;

@property (strong, nonatomic) UIView *actionSheet;
@property (nonatomic, strong) UIToolbar *pickerToolbar;

@property (nonatomic, readwrite) BOOL mmolSelected;
@property (nonatomic, readwrite) int numberOfComponents;
@property (nonatomic, readwrite) NSInteger numberOfRowsInComponent;
@property (nonatomic, readwrite) int feetRowCount;
@property (nonatomic, retain) NSMutableArray *feetMeasures;
@property (nonatomic, retain) NSMutableDictionary *selectedArray;
@property (nonatomic, retain) NSMutableArray *componentOneArray;
@property (nonatomic, retain) NSMutableArray *componentTwoArray;
@property (nonatomic, retain) NSMutableDictionary *phrDetailsDictionary;
@property (nonatomic, retain) NSString *addOrUpdateButtonText;
@property (weak, nonatomic) IBOutlet UIButton *addOrUpdatebutton;
@property (nonatomic, readwrite) NSUInteger phrID;
- (IBAction)makeRequestToAddPhrDetails:(id)sender;
- (IBAction)updateBackBtnClicked;
- (IBAction)dateBtnClicked:(id)sender;
- (IBAction)timeBtnClicked:(id)sender;
@end
