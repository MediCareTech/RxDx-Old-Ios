//
//  SmartRxMessageTVC.m
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxMessageTVC.h"
#import "NSString+DateConvertion.h"

@implementation SmartRxMessageTVC

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setmessageInfo:(NSDictionary *)messageDict
{
    //
    
    NSLog(@"operation === %@",[messageDict objectForKey:@"operation"]);
    if([[messageDict objectForKey:@"operation"] isEqualToString:@"1"])
    {
         self.lblSenderName.text=@"Care Message";
        self.imgViewMessages.image=[UIImage imageNamed:@"icn_care_msg.png"];
        
    }
    else if([[messageDict objectForKey:@"operation"] isEqualToString:@"2"])
    {
         self.lblSenderName.text=@"Promotions";
        self.imgViewMessages.image=[UIImage imageNamed:@"icn_msg_promotion.png"];
    }
    else if([[messageDict objectForKey:@"operation"] isEqualToString:@"3"])
    {
         self.lblSenderName.text=@"Communication";
        self.imgViewMessages.image=[UIImage imageNamed:@"icn_communication.png"];
    }
    else if([[messageDict objectForKey:@"operation"] isEqualToString:@"4"])
    {
         self.lblSenderName.text=@"Appointment";
        self.imgViewMessages.image=[UIImage imageNamed:@"icn_msg_app.png"];
    }
    else if([[messageDict objectForKey:@"operation"] isEqualToString:@"5"])
    {
         self.lblSenderName.text=@"Question & Answer Alert";
        self.imgViewMessages.image=[UIImage imageNamed:@"icn_qna.png"];
    }
    else if([[messageDict objectForKey:@"operation"] isEqualToString:@"6"])
    {
      self.lblSenderName.text=@"Feedback Alert";
        self.imgViewMessages.image=[UIImage imageNamed:@"icn_feedback.png"];
    }
    
   // self.lblSenderName.text=[messageDict objectForKey:@"Name"];
    self.lblMessage.text=[messageDict objectForKey:@"Msg"];
    self.lblTime.text=[NSString convertStringToDate:[NSString stringWithFormat:@"%@",[messageDict objectForKey:@"Time"]]];
    
}
@end
