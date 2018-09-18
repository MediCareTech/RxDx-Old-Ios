//
//  SmartRxMessageViewController.h
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxCommonClass.h"
@interface SmartRxMessageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,loginDelegate,MBProgressHUDDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tblMessages;
@property (strong, nonatomic) NSMutableDictionary *dstMsgDetails;
@property (strong, nonatomic) NSArray *arrMsgDetails;
@property (strong, nonatomic) IBOutlet UIButton *btnMoreMsgs;
@property (strong, nonatomic) IBOutlet UILabel *lblmsgs;
- (IBAction)moreMsgBtnClicked:(id)sender;


@end
