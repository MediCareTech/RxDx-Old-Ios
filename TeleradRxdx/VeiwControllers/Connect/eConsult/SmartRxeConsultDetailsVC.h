//
//  SmartRxeConsultDetailsVC.h
//  smartRxDoctor
//
//  Created by Manju Basha on 14/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenTok/OpenTok.h>
#import <QuartzCore/QuartzCore.h>
#import "HMSegmentedControl.h"

@interface SmartRxeConsultDetailsVC : UIViewController<UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate,loginDelegate,UIAlertViewDelegate,ImageSelected, OTSessionDelegate, OTPublisherDelegate, OTSubscriberKitDelegate,  UIGestureRecognizerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, AVAudioPlayerDelegate>
{
    NSMutableDictionary *allStreams;
    NSMutableDictionary *allSubscribers;
    NSMutableArray *allConnectionsIds;
    NSMutableArray *backgroundConnectedStreams;
    
    OTSession *_session;
    OTPublisher *_publisher;
    OTSubscriber *_currentSubscriber;
    CGPoint _startPosition;
    
    BOOL initialized;
}
@property (strong, nonatomic) NSMutableDictionary *dictResponse;
@property (retain, nonatomic) IBOutlet UIImageView *phoneOrVideoImg;
@property (weak, nonatomic) IBOutlet UILabel *docName;
@property (weak, nonatomic) IBOutlet UILabel *eConsultDateTime;
@property (weak, nonatomic) IBOutlet UIImageView *eConsultStatusImage;
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;
@property (weak, nonatomic) IBOutlet UILabel *econsultMethodLbl;
@property (weak, nonatomic) IBOutlet UIImageView *onlineStatusImage;
@property (retain, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIScrollView *suggestionScroll;
@property (retain, nonatomic) IBOutlet UIScrollView *symptomScroll;
@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIView *videoConsultView;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl4;

@property (strong, nonatomic) UIView *currentView;
@property (retain, nonatomic) NSString *publisherName;

@property (weak, nonatomic) IBOutlet UIView *symptomsViewEdit;
@property (weak, nonatomic) IBOutlet UIButton *symptomsContent;
@property (weak, nonatomic) IBOutlet UITextView *symptomsContentLabel;
@property (nonatomic, strong) NSString *pdfPath;
@property (assign, nonatomic) NSString *strTitle;

@property (weak, nonatomic) IBOutlet UIView *suggestionViewEdit;
@property (weak, nonatomic) IBOutlet UIButton *suggestionContent;
@property (weak, nonatomic) IBOutlet UILabel *suggestionContentLabel;
@property (weak, nonatomic) IBOutlet UITableView *suggestionContentTable;

@property (weak, nonatomic) IBOutlet UIView *reportViewEdit;
@property (weak, nonatomic) IBOutlet UIButton *reportContent;
@property (retain, nonatomic) IBOutlet UIScrollView *reportScroll;
@property (weak, nonatomic) IBOutlet UITableView *reportContentTable;

@property (weak, nonatomic) IBOutlet UIView *requestViewEdit;
@property (weak, nonatomic) IBOutlet UIButton *requestContent;
@property (weak, nonatomic) IBOutlet UITableView *requestContentTable;

@property (strong, nonatomic) NSArray *arrayReportFiles;
@property (strong, nonatomic) NSArray *arrayDoctorSuggestionFiles;
@property (strong, nonatomic) NSArray *arrayData;
@property (strong, nonatomic) NSMutableArray *arrayRequestData;

@property (weak, nonatomic) IBOutlet UIView *updateView;
@property (weak, nonatomic) IBOutlet UILabel *updateLbl;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UITextView *updateTextView;
@property (weak, nonatomic) IBOutlet UILabel *updateViewTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imgViwPhoto;

@property (weak, nonatomic) IBOutlet UIButton *connectBtn;



@property (retain, nonatomic)  NSString *apiKey;
@property (retain, nonatomic)  NSString *sessionId;
@property (retain, nonatomic)  NSString *token;
@property (strong, nonatomic) IBOutlet UIScrollView *videoContainerView;
@property (strong, nonatomic) IBOutlet UIView *bottomOverlayView;
@property (strong, nonatomic) IBOutlet UIView *topOverlayView;
@property (retain, nonatomic) IBOutlet UIButton *cameraToggleButton;
@property (retain, nonatomic) IBOutlet UIButton *audioPubUnpubButton;
@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;
@property (retain, nonatomic) NSTimer *overlayTimer;
@property (retain, nonatomic) IBOutlet UIButton *audioSubUnsubButton;
@property (retain, nonatomic) IBOutlet UIButton *endCallButton;
@property (retain, nonatomic) IBOutlet UIButton *videoPauseButton;
@property (retain, nonatomic) IBOutlet UIView *micSeparator;
@property (retain, nonatomic) IBOutlet UIView *cameraSeparator;
@property (retain, nonatomic) IBOutlet UIView *archiveOverlay;
@property (retain, nonatomic) IBOutlet UILabel *archiveStatusLbl;
@property (retain, nonatomic) IBOutlet UIImageView *archiveStatusImgView;
@property (retain, nonatomic)  NSString *rid;
//@property (retain, nonatomic)  NSString *publisherName;
@property (retain, nonatomic) IBOutlet UIImageView *rightArrowImgView;
@property (retain, nonatomic) IBOutlet UIImageView *leftArrowImgView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *spinningWheel;

- (IBAction)toggleAudioSubscribe:(id)sender;
- (IBAction)toggleCameraPosition:(id)sender;
- (IBAction)toggleAudioPublish:(id)sender;
- (IBAction)endCallAction:(UIButton *)button;


+ (id)sharedManager;

- (IBAction)connectBtnClicked:(id)sender;
- (IBAction)cancelBtnClicked:(id)sender;
- (IBAction)updateBtnClicked:(id)sender;
- (IBAction)symptomsBtnClicked:(id)sender;
- (IBAction)suggestionBtnClicked:(id)sender;
- (IBAction)suggesstionEditClicked:(id)sender;
- (IBAction)reportBtnClicked:(id)sender;
- (IBAction)requestBtnClicked:(id)sender;
- (IBAction)symptomsEditClicked:(id)sender;
- (IBAction)reportsAddClicked:(id)sender;
- (IBAction)requestAddClicked:(id)sender;
@end
