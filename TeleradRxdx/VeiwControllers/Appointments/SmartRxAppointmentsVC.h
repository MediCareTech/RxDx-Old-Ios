//
//  SmartRxAppointmentsVC.h
//  SmartRx
//
//  Created by PaceWisdom on 12/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxCommonClass.h"

@interface SmartRxAppointmentsVC : UIViewController<UITableViewDataSource,UITableViewDelegate,loginDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) NSArray *arrAppointments;
@property (weak, nonatomic) IBOutlet UITableView *tblAppointments;
@property (weak, nonatomic) IBOutlet UILabel *lblNoApps;
@property (readwrite, nonatomic) BOOL fromFindDoctors;
@end
