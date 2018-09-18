//
//  SmartRxAppDelegate.m
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxAppDelegate.h"
#import "UIImageView+WebCache.h"

@implementation SmartRxAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
//    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
//    {
//        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
//    }
//    else
//    {
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
//    }
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    __weak __block SmartRxAppDelegate *blockSelf = self;
    
    self.imgSlpash = [UIImage imageNamed:@"splash_iphone5@2x.png"];
    if (([UIImagePNGRepresentation(self.imgSlpash) isEqualToData:UIImagePNGRepresentation([UIImage imageNamed:@"splash_iphone5@2x.png"])]) && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"splash_screen"] isEqualToString:@"splash_iphone5@2x.png"]){
        //change
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/%@",kAdminBaseInUrl,[[NSUserDefaults standardUserDefaults] objectForKey:@"splash_screen"]]] placeholderImage:[UIImage imageNamed:@"splash_iphone5@2x.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (error) {
                [[NSUserDefaults standardUserDefaults] setObject:@"splash_iphone5@2x.png" forKey:@"splash_screen"];
            }
            blockSelf.imgView.image = image;
            blockSelf.imgSlpash = image;
        }];
    }
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"PushNotes"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"EConsultPush"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"FromLogin"];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Reinstalling"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    return YES;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        NSLog(@"didRegisterUser");
        [application registerForRemoteNotifications];
    }
    //register to receive notifications
//    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    [self createSplashScreenonView:self];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
   [self animateSplashScreen];
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    [[NSUserDefaults standardUserDefaults]setObject:deviceToken forKey:@"PushToken"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

#pragma mark - SplashScreen
-(void)createSplashScreenonView:(id)screenName{
    _viewSlpash.center = self.window.center;
    _transSlpash.alpha = 0.7f;
    if (!_viewSlpash) {
        _viewSlpash = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.window.frame.size.height)];
        _transSlpash = [[UIView alloc] initWithFrame:_viewSlpash.frame];
        _imgView = [[UIImageView alloc] initWithFrame:_viewSlpash.frame];
        _transSlpash.backgroundColor = [UIColor grayColor];
        _transSlpash.alpha = 0.7f;
        _viewSlpash.backgroundColor  = [UIColor whiteColor];
        [self.window addSubview:_transSlpash];
        [_viewSlpash addSubview:_imgView];
        [self.window addSubview:_viewSlpash];
    }else{
        [_viewSlpash setHidden:NO];
        [_transSlpash setHidden:NO];
    }
    
    __weak __block SmartRxAppDelegate *blockSelf = self;
    if (([UIImagePNGRepresentation(self.imgSlpash) isEqualToData:UIImagePNGRepresentation([UIImage imageNamed:@"splash_iphone5@2x.png"])]) && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"splash_screen"] isEqualToString:@"splash_iphone5@2x.png"]){
        //change
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/%@",kAdminBaseInUrl,[[NSUserDefaults standardUserDefaults] objectForKey:@"splash_screen"]]] placeholderImage:[UIImage imageNamed:@"splash_iphone5@2x.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (error) {
                [[NSUserDefaults standardUserDefaults] setObject:@"splash_iphone5@2x.png" forKey:@"splash_screen"];
            }
            blockSelf.imgView.image = image;
            blockSelf.imgSlpash = image;
        }];
    }else{
        if (!self.imgSlpash) {
            self.imgView.image = [UIImage imageNamed:@"splash_iphone5@2x.png"];
            return;
        }
        self.imgView.image = self.imgSlpash;
    }
}

-(void)animateSplashScreen{
    CGPoint centerOffScreen = self.window.center;
    centerOffScreen.y = self.window.center.y + 60.f;
    [UIView animateWithDuration:0.3 delay:2.f options:UIViewAnimationOptionLayoutSubviews animations:^{
        _viewSlpash.center = centerOffScreen;
    } completion:^(BOOL finished) {
        if (finished) {
            CGPoint centerOffScreen1 = self.window.center;
            centerOffScreen1.y = (-1)*self.window.frame.size.height;
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                _viewSlpash.center = centerOffScreen1;
                _transSlpash.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [_viewSlpash setHidden:YES];
                [_transSlpash setHidden:YES];
            }];
        }
    }];
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"push recived  %@",userInfo);
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Reinstalling"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    if ( application.applicationState == UIApplicationStateActive )
    {
        // app was already in the foreground, hence showing as a seperate message
        NSString *strHspName = nil;
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"] length] > 0)
            strHspName=[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"];
        if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 1)
        {
            NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
            NSString *htmlString=[message stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            message = [attrStr string];
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"PushNotes"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            UIStoryboard *storyBoardID=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *mainVC=[storyBoardID instantiateInitialViewController];
            self.window.rootViewController = mainVC;
            [self.window makeKeyAndVisible];
        }
        else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 3)
        {
            NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
            NSArray *strArray = [message componentsSeparatedByString:@"***"];
            message = [strArray objectAtIndex:5];
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"EConsultPush"];
            [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"keyid"] forKey:@"pushEconsultID"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            UIStoryboard *storyBoardID=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *mainVC=[storyBoardID instantiateInitialViewController];
            self.window.rootViewController = mainVC;
            [self.window makeKeyAndVisible];
        }
        else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 4)
        {
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"InEconsult"] != YES)
            {
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"EConsultPush"];
                [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"keyid"] forKey:@"pushEconsultID"];
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"EConsultVideoPush"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                UIStoryboard *storyBoardID=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *mainVC=[storyBoardID instantiateInitialViewController];
                self.window.rootViewController = mainVC;
                [self.window makeKeyAndVisible];
            }
        }
        
    }
    else if ( application.applicationState == UIApplicationStateBackground || application.applicationState == UIApplicationStateInactive)
    {
        if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 1)
        {
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"PushNotes"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            UIStoryboard *storyBoardID=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *mainVC=[storyBoardID instantiateInitialViewController];
            self.window.rootViewController = mainVC;
            [self.window makeKeyAndVisible];
        }
        else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 3)
        {
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"EConsultPush"];
            [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"keyid"] forKey:@"pushEconsultID"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            UIStoryboard *storyBoardID=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *mainVC=[storyBoardID instantiateInitialViewController];
            self.window.rootViewController = mainVC;
            [self.window makeKeyAndVisible];
        }
        else if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 4)
        {
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"EConsultPush"];
            [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"keyid"] forKey:@"pushEconsultID"];
            if ([[[userInfo valueForKey:@"aps"] valueForKey:@"type"] integerValue] == 4)
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"EConsultVideoPush"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            UIStoryboard *storyBoardID=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *mainVC=[storyBoardID instantiateInitialViewController];
            self.window.rootViewController = mainVC;
            [self.window makeKeyAndVisible];
        }
        
    }

    
//    if ( application.applicationState == UIApplicationStateActive )
//    {
//        
//        // app was already in the foreground, hence showing as a seperate message
//        NSString *strHspName=[[NSUserDefaults standardUserDefaults]objectForKey:@"HosName"];
//        NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
//        if (!([message rangeOfString:@"e-Consult"].location == NSNotFound))
//        {
//            NSArray *strArray = [message componentsSeparatedByString:@"***"];           
//            message = [strArray objectAtIndex:5];
//        }
//        else if (!([message rangeOfString:@"<br>"].location == NSNotFound) || !([message rangeOfString:@"<br/>"].location == NSNotFound) )
//        {
//            NSString *htmlString=[message stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
//            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//            message = [attrStr string];
//        }
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:strHspName message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//    }   
}

@end
