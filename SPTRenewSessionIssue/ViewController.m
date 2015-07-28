//
//  ViewController.m
//  SPTRenewSessionIssue
//
//  Copyright (c) 2015 Yourei. All rights reserved.
//

#import "ViewController.h"
#import "SPTRSConstants.h"
#import <Spotify/Spotify.h>

@interface ViewController ()<SPTAuthViewDelegate>

@property (atomic, readwrite) SPTAuthViewController *spotifyAuthViewController;
@property (weak, nonatomic) IBOutlet UISwitch *sptSwitch;
@property (weak, nonatomic) IBOutlet UIButton *sptRenewSessionButton;
@property (weak, nonatomic) IBOutlet UILabel *sptLoginStatusLabel;
@property (strong, nonatomic) SPTSession *currentSpotifySession;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)loginToSpotify:(UISwitch *)sender {
    if (sender.on) {
//        NSURL *loginURL = [SPTAuth loginURLForClientId:kSpotifyClientId
//                                       withRedirectURL:[NSURL URLWithString:kSpotifyCallbackURL]
//                                                scopes:@[SPTAuthStreamingScope,
//                                                         SPTAuthPlaylistReadPrivateScope,
//                                                         SPTAuthPlaylistModifyPublicScope,
//                                                         SPTAuthPlaylistModifyPrivateScope,
//                                                         SPTAuthUserFollowModifyScope,
//                                                         SPTAuthUserFollowReadScope,
//                                                         SPTAuthUserLibraryReadScope,
//                                                         SPTAuthUserLibraryModifyScope,
//                                                         SPTAuthUserReadPrivateScope,
//                                                         SPTAuthUserReadBirthDateScope,
//                                                         SPTAuthUserReadEmailScope,
//                                                         @"user-read-private"]
//                                          responseType:@"code"];
        
//        [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:loginURL afterDelay:0.1];
        [[SPTAuth defaultInstance] setClientID:kSpotifyClientId];
        [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:kSpotifyCallbackURL]];
        [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope,
                                                        SPTAuthPlaylistReadPrivateScope,
                                                        SPTAuthPlaylistModifyPublicScope,
                                                        SPTAuthPlaylistModifyPrivateScope,
                                                        SPTAuthUserFollowModifyScope,
                                                        SPTAuthUserFollowReadScope,
                                                        SPTAuthUserLibraryReadScope,
                                                        SPTAuthUserLibraryModifyScope,
                                                        SPTAuthUserReadPrivateScope,
                                                        SPTAuthUserReadBirthDateScope,
                                                        SPTAuthUserReadEmailScope,
                                                        @"user-read-private"]];
        [[SPTAuth defaultInstance] setTokenSwapURL:[NSURL URLWithString:kTokenSwapURL]];
        [[SPTAuth defaultInstance] setTokenRefreshURL:[NSURL URLWithString:kTokenRefreshServiceURL]];
        
        //[[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:loginURL afterDelay:0.1];
        self.spotifyAuthViewController = [SPTAuthViewController authenticationViewController];
        self.spotifyAuthViewController.delegate = self;
        self.spotifyAuthViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.spotifyAuthViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.definesPresentationContext = YES;
        [self.spotifyAuthViewController clearCookies:nil];
        [self presentViewController:self.spotifyAuthViewController animated:NO completion:nil];
    } else {
        self.sptLoginStatusLabel.text = @"Spotify Login/Renewal Status";
    }
}

- (IBAction)renewSpotifySession:(id)sender {
    SPTAuth *auth = [SPTAuth defaultInstance];
    [auth setTokenSwapURL:[NSURL URLWithString:kTokenSwapURL]];
    [auth setTokenRefreshURL:[NSURL URLWithString:kTokenRefreshServiceURL]];
    [auth setSession:self.currentSpotifySession];
    [auth setSessionUserDefaultsKey:kSpotifySessionUserDefaultsKey];
    [auth setClientID:kSpotifyClientId];
    
    if(auth.session) {
        [auth renewSession:auth.session callback:^(NSError *error, SPTSession *session) {
            if (error) { // An error occured during the renewal process so turn off the settings for Spotify.
                NSLog(@"The error during the Spotify renewal session process is - %@", error);
                self.sptLoginStatusLabel.text = @"Failed to renew Spotify session!";
            }
            if (session) { // The renewal of the Spotify session was successful.
                NSLog(@"The renewed Spotify session is - %@", session);
                NSLog(@"The renewed canonical user name in the session is - %@", session.canonicalUsername);
                NSLog(@"The renewed access Spotify token in session is - %@", auth.session.accessToken);
                NSLog(@"The renewed encrypted refresh Spotify token in session is - %@", auth.session.encryptedRefreshToken);
                NSLog(@"The renewed expiration date of the Spotify access token is - %@", auth.session.expirationDate);
                self.sptLoginStatusLabel.text = @"Successfully renewed Spotify session!";
            }
        }];
    }
}

- (void)authenticationViewController:(SPTAuthViewController *)viewcontroller didFailToLogin:(NSError *)error {
    NSLog(@"*** Spotify Failed to log in: %@", error);
    [self.sptSwitch setOn:NO];
}

- (void)authenticationViewController:(SPTAuthViewController *)viewcontroller didLoginWithSession:(SPTSession *)session {
    NSLog(@"*** Spotify successfully logged in: %@", session);
    self.currentSpotifySession = session;
    self.sptLoginStatusLabel.text = @"Successfully logged into Spotify!";
}

- (void)authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController {
    NSLog(@"*** Spotify canceled log in. ***");
    [self.sptSwitch setOn:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
