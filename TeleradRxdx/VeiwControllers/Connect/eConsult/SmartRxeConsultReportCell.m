//
//  SmartRxeConsultReportCell.m
//  SmartRx
//
//  Created by Anil Kumar on 25/02/15.
//  Copyright (c) 2015 pacewisdom. All rights reserved.
//

#import "SmartRxeConsultReportCell.h"
#import "UIImageView+WebCache.h"

@implementation SmartRxeConsultReportCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setCellData:(NSDictionary *)arrAppDetails row:(NSInteger)rowIndex
{
    NSArray *arrImg = [[arrAppDetails objectForKey:@"filelocation"] componentsSeparatedByString:@"patient/data/patientfiles/"];
    self.reportImageName.text = [arrImg objectAtIndex:1];//[NSString stringWithFormat:@"%@", [arrImg objectAtIndex:1]];
    self.downloadBtn.tag = rowIndex;
    self.viewBtn.tag = rowIndex;
}

- (IBAction)viewBtnClicked:(id)sender {
    NSArray *arrFileType = [NSArray arrayWithObjects:@"pdf", @"doc", @"docx", @"rtf", @"csv", @"text", @"xlsx",@"xlsm", @"xls", @"xlt", nil];
    NSArray *arrExtensionType = [[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"filelocation"] componentsSeparatedByString:@"."];
    if ([arrExtensionType count] && [arrFileType containsObject:arrExtensionType[([arrExtensionType count]-1)]]) {
        [self.delegateImg openQlPreview:[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"filelocation"]];
    }else
        [self.delegateImg ShowImageInMainView:[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"filelocation"]];
}

- (IBAction)downloadBtnClicked:(id)sender
{
    NSArray *arrFileType = [NSArray arrayWithObjects:@"pdf", @"doc", @"docx", @"rtf", @"csv", @"text", @"xlsx",@"xlsm", @"xls", @"xlt", nil];
    NSArray *arrExtensionType = [[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"filelocation"] componentsSeparatedByString:@"."];
    if ([arrExtensionType count] && [arrFileType containsObject:arrExtensionType[([arrExtensionType count]-1)]]) {
        [self.delegateImg openQlPreview:[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"filelocation"]];
    }else
        [self.delegateImg ShowImageInMainView:[[self.arrImages objectAtIndex:((UIButton *)sender).tag] objectForKey:@"filelocation"]];}

@end
