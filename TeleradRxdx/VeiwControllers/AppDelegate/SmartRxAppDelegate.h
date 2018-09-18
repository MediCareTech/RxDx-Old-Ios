//
//  SmartRxAppDelegate.h
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenTok/OpenTok.h>
#import <QuartzCore/QuartzCore.h>

@interface SmartRxAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) OTSubscriber *subscriber;
@property (retain, nonatomic) OTStream *stream;
@property (retain, nonatomic) OTSession *session;
@property (retain, nonatomic) UIScrollView *videoContainerAppDelegate;
@property (strong, nonatomic) UIView *viewSlpash;
@property (strong, nonatomic) UIView *transSlpash;
@property (strong, nonatomic) UIImage *imgSlpash;
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) OTPublisher *publisherAppDelegate;
@property (strong, nonatomic) NSArray *timeStampArray;
@property (strong, nonatomic) UIView *bottomOverlayViewAppDelegate;
@property (strong, nonatomic) UIView *topOverlayViewAppDelegate;
@property (retain, nonatomic) UIButton *cameraToggleButtonAppDelegate;
@property (retain, nonatomic) UIButton *audioPubUnpubButtonAppDelegate;
@property (retain, nonatomic) UILabel *userNameLabelAppDelegate;
@property (retain, nonatomic) NSTimer *overlayTimerAppDelegate;
@property (retain, nonatomic) UIButton *audioSubUnsubButtonAppDelegate;
@property (retain, nonatomic) UIButton *endCallButtonAppDelegate;
@property (retain, nonatomic) UIView *micSeparatorAppDelegate;
@property (retain, nonatomic) UIView *cameraSeparatorAppDelegate;
@property (retain, nonatomic) UIView *archiveOverlayAppDelegate;
@property (retain, nonatomic) UILabel *archiveStatusLblAppDelegate;
@property (retain, nonatomic) UIImageView *archiveStatusImgViewAppDelegate;
@property (retain, nonatomic) NSString *ridAppDelegate;
@property (retain, nonatomic) NSString *publisherNameAppDelegate;
@property (retain, nonatomic) UIImageView *rightArrowImgViewAppDelegate;
@property (retain, nonatomic) UIImageView *leftArrowImgViewAppDelegate;

@end
