//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "POSRootResource.h"
#import "POSFolder+Methods.h"
#import "POSDocumentsViewController.h"
#import "SHCLoginViewController.h"
#import "SHCOAuthViewController.h"
#import "POSModelManager.h"
#import "POSMailbox+Methods.h"
#import "POSFoldersViewController.h"
#import "POSOAuthManager.h"
#import "SHCSplitViewController.h"
#import "SHCAppDelegate.h"
#import "Digipost-Swift.h"

// Storyboard identifiers (to enable programmatic storyboard instantiation)
NSString *const kLoginNavigationControllerIdentifier = @"LoginNavigationController";
NSString *const kLoginViewControllerIdentifier = @"LoginViewController";

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPresentLoginModallyIdentifier = @"PresentLoginModally";
NSString *const kRegistrationWebViewIdentifier = @"registrationWebView";
NSString *const kForgotPasswordWebViewIdentifier = @"forgotPasswordWebView";

// Notification names
NSString *const kShowLoginViewControllerNotificationName = @"ShowLoginViewControllerNotification";

// Google Analytics screen name
NSString *const kLoginViewControllerScreenName = @"Login";

@interface SHCLoginViewController () <SHCOAuthViewControllerDelegate, OnboardingLoginViewControllerDelegate, NewFeaturesViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet UIImageView *loginBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (strong, nonatomic) UIImageView *titleImageView;
@property (strong, nonatomic) IBOutlet UIButton *replayOnboardingButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@end

@interface SHCLoginViewController () <SFSafariViewControllerDelegate>
@end

@implementation SHCLoginViewController

#pragma mark - NSObject

- (void)dealloc
{
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:kShowLoginViewControllerNotificationName
                                                      object:nil];
    }
    @catch (NSException *exception) {
        //        DDLogWarn(@"Caught an exception: %@", exception);
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginButton.accessibilityLabel = @"Login Digipost";
    
    [self.replayOnboardingButton addTarget:self action:@selector(presentOnboarding) forControlEvents:UIControlEventTouchUpInside];
    
    self.screenName = kLoginViewControllerScreenName;
    
    @try {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(popToSelf:)
                                                     name:kShowLoginViewControllerNotificationName
                                                   object:nil];
    }
    @catch (NSException *exception) {
        //        DDLogWarn(@"Caught an exception: %@", exception);
    }
    
    [self.loginButton setTitle:NSLocalizedString(@"LOGIN_VIEW_CONTROLLER_LOGIN_BUTTON_TITLE", @"Sign In")
                      forState:UIControlStateNormal];
    [self.registerButton setTitle:NSLocalizedString(@"LOGIN_VIEW_CONTROLLER_REGISTER_BUTTON_TITLE", @"New user")
                         forState:UIControlStateNormal];
    [self.privacyButton setTitle:NSLocalizedString(@"LOGIN_VIEW_CONTROLLER_PRIVACY_BUTTON_TITLE", @"Privacy")
                        forState:UIControlStateNormal];
    
    [self.forgotPasswordButton setTitle:NSLocalizedString(@"LOGIN_VIEW_CONTROLLER_FORGOT_PASSWORD_BUTTON", @"Forgot password")
                               forState:UIControlStateNormal];
    
    if ([OAuthToken isUserLoggedIn]) {
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            [self presentAppropriateViewControllerForIPhone];
        }
        
        [Guide setOnboaringHasBeenWatched];
        
    } else {
        
        if ([Guide shouldShowOnboardingGuide]) {
            [self presentOnboarding];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[POSModelManager sharedManager] deleteAllGCMTokens];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //    self.navigationItem.leftBarButtonItem = nil;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationItem.rightBarButtonItem = nil;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        //        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
        //                                                                              style:UIBarButtonItemStylePlain
        //                                                                             target:nil
        //                                                                             action:nil];
        //        self.navigationItem.backBarButtonItem = backBarButtonItem;
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)presentOnboarding
{
    [self.loginView setHidden:YES];
    
    UIStoryboard *onboardingStoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    __block OnboardingViewController *onboardingViewController = (id)[onboardingStoryboard instantiateInitialViewController];
    
    [self presentViewController:onboardingViewController
                       animated:NO
                     completion:^{
                         onboardingViewController.onboardingLoginViewController.delegate = self;
                     }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPresentOAuthModallyIdentifier]) {
        SHCOAuthViewController *oAuthViewController;
        UINavigationController *navigationController = segue.destinationViewController;
        
        if ([navigationController isKindOfClass:[UINavigationController class]]) {
            oAuthViewController = (id)navigationController.topViewController;
        } else {
            oAuthViewController = (id)segue.destinationViewController;
        }
        oAuthViewController.delegate = self;
        oAuthViewController.scope = kOauth2ScopeFull;
        
        [self performSelector:@selector(showLoginButtonsIfHidden) withObject:nil afterDelay:0.5];
        
    }else if ([segue.identifier isEqualToString:kRegistrationWebViewIdentifier]) {
        [self sendAnalyticsEvent:@"registrering"];
        
        SingleUseWebViewController *webView = (SingleUseWebViewController*) segue.destinationViewController;
        UINavigationController *navigationController = segue.destinationViewController;
        webView = (id)navigationController.topViewController;
        webView.viewTitle = NSLocalizedString(@"LOGIN_VIEW_CONTROLLER_REGISTER_BUTTON_TITLE", "New user");
        webView.initUrl = [__SERVER_URI__ stringByAppendingString: @"/app/registrering?utm_source=iOS_app&utm_medium=app&utm_campaign=app-link&utm_content=ny_bruker#/"];
        
    
    }else if ([segue.identifier isEqualToString:kForgotPasswordWebViewIdentifier]) {
        
        [self sendAnalyticsEvent:@"glemt-passord"];        
        SingleUseWebViewController *webView = (SingleUseWebViewController*) segue.destinationViewController;
        UINavigationController *navigationController = segue.destinationViewController;
        webView = (id)navigationController.topViewController;
        webView.viewTitle = NSLocalizedString(@"forgot password title", "Forgot Password");
        webView.initUrl = @"https://www.digipost.no/app/#/person/glemt";
        
    }
}

- (void)showLoginButtonsIfHidden
{
    if ([self.loginView isHidden]) {
        [self.loginView setHidden:NO];
    }
}

- (void)presentNewFeatures
{
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        UIStoryboard *newFeaturesStoryboard = [UIStoryboard storyboardWithName:@"NewFeatures" bundle:nil];
        UINavigationController *navigationController = (id)[newFeaturesStoryboard instantiateInitialViewController];
        NewFeaturesViewController *newFeaturesController = (id)navigationController.viewControllers.firstObject;
        newFeaturesController.delegate = self;
        [self presentViewController:navigationController animated:NO completion:nil];
    }
}

#pragma mark - SHCOAuthViewControllerDelegate

- (void)OAuthViewControllerDidAuthenticate:(SHCOAuthViewController *)OAuthViewController scope:(NSString *)scope
{
    
    //successfull login
    //initialize gcm notification, if its not already existing.
    SHCAppDelegate *appDelegate = (id)[UIApplication sharedApplication].delegate;
    [appDelegate initGCM];
    
    if ([Guide shouldShowWhatsNewGuide] && [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        [self presentNewFeatures];
    } else {
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            
            [self.navigationController dismissViewControllerAnimated:YES
                                                          completion:^{
                                                          }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDocumentsContentNotificationName
                                                                object:@NO];
        } else {
            [self presentAppropriateViewControllerForIPhone];
        }
    }
    
    [InvoiceBankAgreement updateActiveBankAgreementStatus];
}

- (void)onboardingLoginViewControllerDidTapLoginButtonWithBackgroundImage:(OnboardingLoginViewController *)onboardingLoginViewController backgroundImage:(UIImage *)backgroundImage
{
    if (backgroundImage != nil) {
        self.loginBackgroundImageView.image = backgroundImage;
    }
    
    [onboardingLoginViewController.presentingViewController dismissViewControllerAnimated:NO
                                                                               completion:^{
                                                                                   [self performSegueWithIdentifier:kPresentOAuthModallyIdentifier sender:self];
                                                                               }];
}

#pragma mark - NewFeatures dismiss controller delegate

- (void)newFeaturesViewControllerDidDismiss:(NewFeaturesViewController *)newFeaturesViewController
{
    [newFeaturesViewController dismissViewControllerAnimated:NO
                                                  completion:^{
                                                      [self.loginView setHidden:NO];
                                                      [self presentAppropriateViewControllerForIPhone];
                                                  }];
}

#pragma mark - IBActions

- (IBAction)didTapPrivacyButton:(UIButton *)sender
{
    [self sendAnalyticsEvent:@"personvern"];
    NSURL* url = [NSURL URLWithString:@"https://www.digipost.no/juridisk/#personvern"];
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:url];
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:NO completion:nil];
}

- (IBAction)unwindToLoginViewController:(UIStoryboardSegue *)unwindSegue
{
}

-(void) sendAnalyticsEvent: (NSString*) event {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"innlogging"
                                                          action:@"klikk-link"
                                                           label:event
                                                           value:nil] build]];
}

#pragma mark - Private methods

- (void)popToSelf:(NSNotification *)notification
{
    
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        
        [self.navigationController popToViewController:self
                                              animated:YES];
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            if ([userInfo[@"alert"] isMemberOfClass:[UIAlertController class]]) {
                UIAlertController *alertController = userInfo[@"alert"];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
}

- (void)presentAppropriateViewControllerForIPhone
{
    POSRootResource *resource = [POSRootResource existingRootResourceInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    
    if ([Guide shouldShowWhatsNewGuide]) {
        [self presentNewFeatures];
    } else if ([resource.mailboxes.allObjects count] == 1) {
        [self presentDocumentsViewControllerWithViewControllerStack];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    } else {
        [self performSegueWithIdentifier:@"accountSegue"
                                  sender:self];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

- (void)presentDocumentsViewControllerWithViewControllerStack
{
    // Instantiate view controllers for the navigation controller stack
    SHCLoginViewController *loginViewController = self;
    AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"accountViewController"];
    
    POSFoldersViewController *foldersViewController = [self.storyboard instantiateViewControllerWithIdentifier:kFoldersViewControllerIdentifier];
    
    POSDocumentsViewController *documentsViewController = [self.storyboard instantiateViewControllerWithIdentifier:kDocumentsViewControllerIdentifier];
    
    POSMailbox *mailbox = [POSMailbox mailboxOwnerInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    
    documentsViewController.folderName = kFolderInboxName;
    documentsViewController.mailboxDigipostAddress = mailbox.digipostAddress;
    
    // Add the view controllers to the stack
    NSMutableArray *viewControllerStack = [NSMutableArray array];
    [viewControllerStack addObject:loginViewController];
    [viewControllerStack addObject:accountViewController];
    [viewControllerStack addObject:foldersViewController];
    [viewControllerStack addObject:documentsViewController];
    
    // Set the new view controller stack for the navigation controller
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController setViewControllers:viewControllerStack animated:NO];
    });
}

@end
