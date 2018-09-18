//
//  CVCell.m
//  CollectionViewExample
//
//  Created by Manju Basha on 06/07/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import "CVCell.h"

@implementation CVCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backGrndImage = [[UIImageView alloc] initWithFrame:self.backGrndImage.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        self.tileImg = [[UIImageView alloc] initWithFrame:self.tileImg.frame = CGRectMake((frame.size.width/2)-15, (frame.size.height/2)-30, 30, 30)];
        self.titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-50, frame.size.width, 40)];
        self.titleLbl.font = [UIFont systemFontOfSize:16.0];
        self.titleLbl.textColor = [UIColor whiteColor];
        self.titleLbl.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.backGrndImage];
        [self.contentView addSubview:self.tileImg];
        [self.contentView addSubview:self.titleLbl];
        [self.contentView bringSubviewToFront:self.titleLbl];
    }
    
    return self;
    
}
@end