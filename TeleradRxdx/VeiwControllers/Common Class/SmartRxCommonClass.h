//
//  SmartRxCommonClass.h
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol loginDelegate <NSObject>

-(void)sectionIdGenerated:(id)sender;
-(void)errorSectionId:(id)sender;
-(void)logOutId:(id)sender;

@end

@protocol ImageSelected <NSObject>

-(void)imageSelected:(UIImage *)image;

@end


@interface SmartRxCommonClass : NSObject<UIImagePickerControllerDelegate>

////TEST
//#define kBaseUrl "https://odev.smartrx.in/api"
//#define kAdminBaseUrl  "https://odev.smartrx.in/admin"
//#define kAdminBaseInUrl  "https://odev.smartrx.in/admin/in"
//#define kBaseUrlLabReport "https://odev.smartrx.in/patient/"
//#define kBaseProfileImage "https://odev.smartrx.in/admin/"
//#define kBaseUrlQAImg "https://odev.smartrx.in"
//#define reportURL @"https://175.41.143.62/instahms/patient/login.do"
//#define BOOK_APPOITMENT_API  @"https://qikwell.com/widget_book/chain/d22e3bda-705c-11e3-85b3-1231391ccc72?"


//LIVE
#define kBaseUrl "https://engage.medcall.in/api"
#define kAdminBaseUrl  "https://engage.medcall.in/admin"
#define kAdminBaseInUrl  "https://engage.medcall.in/admin/in"
#define kBaseUrlLabReport "https://engage.medcall.in/patient/"
#define kBaseProfileImage "https://engage.medcall.in/admin/"
#define kBaseUrlQAImg "https://engage.medcall.in"
#define reportURL @"https://175.41.143.62/instahms/patient/login.do"
#define BOOK_APPOITMENT_API  @"https://qikwell.com/widget_book/chain/d22e3bda-705c-11e3-85b3-1231391ccc72?"


#define kBundleID "in.smartrx.patient"

@property (strong,nonatomic) id loginDelegate;
@property (assign, nonatomic) id < ImageSelected > imageDelegate;
-(void)openGallary:(UIViewController *)controller;
+ (id)sharedManager;
-(void)postOrGetData:(NSString *)UrlString postPar:(id )postParaDict method:(NSString *)methodType setHeader:(BOOL)header  successHandler:(void(^)(id response))successHandler failureHandler:(void(^)(id response))failureHandler;

-(void)postingImageWithText:(NSString *)urlString postData:(id)postParaDict camImg:(UIImage *)img successHandler:(void(^)(id response))successHandler failureHandler:(void(^)(id response))failureHandler;


-(void)makeLoginRequest;

-(void)setNavigationTitle:(NSString *)title controler:(UIViewController *)controller;
@end
