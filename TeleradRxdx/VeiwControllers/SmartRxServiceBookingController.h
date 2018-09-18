//
//  SmartRxServiceBookingController.h
//  TeleradRxdx
//
//  Created by Gowtham on 24/05/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxServiceBookingController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (readwrite, nonatomic) BOOL fromFindDoctors;
@property (weak, nonatomic) IBOutlet UIButton *serviceTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *servicesButton;

@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) UIButton *currentButton;
@property (weak, nonatomic) IBOutlet UILabel *servieTypeLbl;
@property (weak, nonatomic) IBOutlet UILabel *servicesLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLbl;



@end
