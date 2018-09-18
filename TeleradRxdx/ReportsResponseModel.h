//
//  ReportsResponseModel.h
//  TeleradRxdx
//
//  Created by Gowtham on 30/05/17.
//  Copyright © 2017 smartrx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReportsResponseModel : NSObject

@property(nonatomic,strong) NSString *date;
@property(nonatomic,strong) NSString *reportDescrption;
@property(nonatomic,strong) NSString *imagePath;
@property(nonatomic,strong) NSString *category;


@end
