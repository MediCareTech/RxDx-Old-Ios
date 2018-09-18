//
//  SmartRxMessageTVC.h
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxMessageTVC : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgViewMessages;
@property (strong, nonatomic) IBOutlet UILabel *lblSenderName;
@property (strong, nonatomic) IBOutlet UILabel *lblMessage;
@property (strong, nonatomic) IBOutlet UILabel *lblTime;

-(void)setmessageInfo:(NSDictionary *)messageDict;
@end
