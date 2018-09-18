//
//  SmartRxReportsListController.h
//  TeleradRxdx
//
//  Created by Gowtham on 29/05/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxCommonClass.h"

@interface SmartRxReportsListController : UIViewController<MBProgressHUDDelegate>

@property(nonatomic,weak) IBOutlet UITableView *tableView;

@end
