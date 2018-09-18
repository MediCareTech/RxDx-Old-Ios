//
//  SmartRxRecordsVC.h
//  SmartRx
//
//  Created by PaceWisdom on 08/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxCommonClass.h"

@interface SmartRxRecordsVC : UIViewController<NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIWebViewDelegate,loginDelegate,MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *reportWebView;

@end
