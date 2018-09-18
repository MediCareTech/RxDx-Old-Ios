//
//  AppointmentTableViewCell.m
//  SmartRx
//
//  Created by PaceWisdom on 12/05/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "AppointmentTableViewCell.h"
#import "NSString+DateConvertion.h"
@implementation AppointmentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setCellData:(NSArray *)arrAppDetails row:(NSInteger)rowIndex
{
    
    self.lblDoctorName.text=[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"doctor"];
    NSString *strDatTime=[NSString stringWithFormat:@"%@ %@",[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"date"],[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"time"]];
    
   self.lblDate.text = [self getDate:strDatTime];
    
    //self.lblDate.text=[NSString timeFormating:strDatTime funcName:@"appointment"];
    
    self.lblReason.text = [[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"procedure"];
    
//    self.lblStauts.text=[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"];
    
    
//    if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 1)
//        self.lblStauts.text = @"Pending";
//    else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 2)
//        self.lblStauts.text = @"Confirmed";
//    else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 3)
//        self.lblStauts.text = @"Completed";
//    else if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"status"] integerValue] == 4)
//        self.lblStauts.text = @"Cancelled";
//    
//    
//    NSString *htmlString=[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"reason"];
//    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//    
//    if ([[attrStr string] length] > 0)
//    {
//        self.lblReason.text=[attrStr string];
//        self.lblDate.hidden=NO;
//    }
//    else{
//        self.lblReason.text=[NSString timeFormating:strDatTime funcName:@"appointment"];
//        self.lblDate.hidden=YES;
//    }
//    //[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"reason"];
//    NSLog(@"apptype ==== %@",[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptype"]);
//    if ([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptype"]intValue] == 1)
//    {
//        self.cellImagView.image=[UIImage imageNamed:@"icn_appointment.png"];
//    }else if([[[arrAppDetails objectAtIndex:rowIndex]objectForKey:@"apptype"]intValue] == 2)
//    {
//        self.cellImagView.image=[UIImage imageNamed:@"icn_econsult.png"];
//    }
    
}
-(NSString *)getDate:(NSString *)dateStr{
    
    NSString *strFormatedDate=nil;
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT+5:30"];
    [format setTimeZone:gmt];
    [format setDateFormat:@"dd/MM/yyyy HH:mm"];
    NSDate *serverDate = [format dateFromString:dateStr];
    [format setDateFormat:@"dd-MMM-yyyy h:mm: a"];
    strFormatedDate=[format stringFromDate:serverDate];
    return strFormatedDate;
}

@end
