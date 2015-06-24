//
//  ViewController.m
//  DribbbleSDKDemo
//
//  Created by Dmitry Salnikov on 6/11/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "ViewController.h"
#import "LoginViewController.h"
#import "DribbbleSDK.h"
#import <BlocksKit+UIKit.h>

typedef void(^UserUploadImageBlock)(NSURL *fileUrl, NSData *imageData);

// SDK setup constants

//valid
static NSString * const kIDMOAuth2ClientId = @"d1bf57813d51b916e816894683371d2bcfaff08a5a5f389965f1cf779e7da6f8";

// invalid
//static NSString * const kIDMOAuth2ClientId = @"00d1bf57813d51b916e816894683371d2bcfaff08a5a5f389965f1cf779e7da6f8";

// valid
static NSString * const kIDMOAuth2ClientSecret = @"305fea0abc1074b8d613a05790fba550b56d93023995fdc67987eed288cd1af5";

// invalid
//static NSString * const kIDMOAuth2ClientSecret = @"00305fea0abc1074b8d613a05790fba550b56d93023995fdc67987eed288cd1af5";

static NSString * const kIDMOAuth2ClientAccessToken = @"ebc7adb327f3ae4cf2517de0a37b483a0973d932b3187578501c55b9f5ede17b";

static NSString * const kIDMOAuth2RedirectURL = @"apitestapp://authorize";
static NSString * const kIDMOAuth2AuthorizationURL = @"https://dribbble.com/oauth/authorize";
static NSString * const kIDMOAuth2TokenURL = @"https://dribbble.com/oauth/token";

static NSString * const kBaseApiUrl = @"https://api.dribbble.com/v1/";

// ---

NSString * kSegueIdentifierAuthorize = @"authorizeSegue";

@interface ViewController () <UIImagePickerControllerDelegate>

@property (strong, nonatomic) DRApiClient *apiClient;

@property (strong, nonatomic) IBOutlet LoginViewController *loginViewController;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (copy, nonatomic) UserUploadImageBlock userUploadImageBlock;

@end

@implementation ViewController

#pragma View LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    UIButton *pickImg = [[UIButton alloc] initWithFrame:CGRectMake(20.f, 100.f, 100.f, 40.f)];
    [self.view addSubview:pickImg];
    [pickImg bk_addEventHandler:^(id sender) {
        [weakSelf showPickerUploadImageWithCompletion:^(NSURL *fileUrl, NSData *imageData) {
            [weakSelf.apiClient uploadShotWithParams:@{@"image" : imageData} responseHandler:^(DRApiResponse *response) {
                NSLog(@"response - %@", response.object);
            }];
        } fromView:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self setupApiClient];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadSomeData];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - IBAction

- (void)setupApiClient {
    DRApiClientSettings *settings = [[DRApiClientSettings alloc] initWithBaseUrl:kBaseApiUrl
                                                               oAuth2RedirectUrl:kIDMOAuth2RedirectURL
                                                          oAuth2AuthorizationUrl:kIDMOAuth2AuthorizationURL
                                                                  oAuth2TokenUrl:kIDMOAuth2TokenURL
                                                                        clientId:kIDMOAuth2ClientId
                                                                    clientSecret:kIDMOAuth2ClientSecret
                                                               clientAccessToken:kIDMOAuth2ClientAccessToken
                                                                          scopes:[NSSet setWithObjects:kDRPublicScope, kDRWriteScope, nil]];
    self.apiClient = [[DRApiClient alloc] initWithSettings:settings];
    __weak typeof(self) weakSelf = self;
    self.apiClient.defaultErrorHandler = ^ (NSError *error) {
        if (error.domain == NSURLErrorDomain && ![weakSelf.apiClient isUserAuthorized]) {
            [weakSelf performSegueWithIdentifier:kSegueIdentifierAuthorize sender:nil];
        } else {
            [UIAlertView bk_showAlertViewWithTitle:@"Error" message:[error localizedDescription] cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
        }
    };
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdentifierAuthorize]) {
        LoginViewController *loginViewController = (LoginViewController *)segue.destinationViewController;
        loginViewController.apiClient = self.apiClient;
        __weak typeof(self) weakSelf = self;
        loginViewController.authCompletionHandler = ^(BOOL success) {
            if (success) {
                [weakSelf loadSomeData];
            }
        };
    }
}


- (void)loadSomeData {

    if (![self.apiClient isUserAuthorized]) {
        [self performSegueWithIdentifier:kSegueIdentifierAuthorize sender:nil];
    } else {
        
        [self.apiClient loadUserInfoWithResponseHandler:^(DRApiResponse *response) {
            NSLog(@"USER INFO: %@", response.object);
        }];
    }
    
//    [self.apiClient loadProjectsOfUser:@"597558" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
//        NSLog(@"response - %@", response.object);
//    }];
    
//    [self.apiClient loadLikesOfUser:@"597558" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
//        NSLog(@"response - %@", response.object);
//    }];
    
//    [self.apiClient loadUserInfo:@"597558" responseHandler:^(DRApiResponse *response) {
//        NSLog(@"response - %@", response.object);
//    }];
    
//    [self.apiClient loadTeamsOfUser:@"597558" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
//        NSLog(@"response - %@", response.object);
//    }];
    
//    [self.apiClient loadShotsOfUser:@"597558" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
//        NSLog(@"response - %@", response.object);
//    }];
    
//    [self.apiClient loadReboundsOfShot:@"472178" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
//        NSLog(@"response - %@", response.object);
//    }];
    
//    [self.apiClient loadShot:@"2037338" responseHandler:^(DRApiResponse *response) {
//        NSLog(@"response - %@", response.object);
//    }];
    
//    [self.apiClient loadLikesOfShot:@"2037338" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
//        NSLog(@"response - %@", response.object);
//    }];

//    [self.apiClient loadCommentsOfShot:@"2037338" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
//        NSLog(@"response - %@", response.object);
//    }];

//    [self.apiClient loadComment:@"4526047" forShot:@"2037338" responseHandler:^(DRApiResponse *response) {
//        NSLog(@"response - %@", response.object);
//    }];

//    [self.apiClient loadLikesOfComment:@"4526047" forShot:@"2037338" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
//        NSLog(@"response - %@", response.object);
//    }];

//    [self.apiClient checkLikeComment:@"4526047" forShot:@"2037338" responseHandler:^(DRApiResponse *response) {
//        NSLog(@"response - %@", response.object);
//    }];
    
//    [self.apiClient loadAttachmentsOfShot:@"471756" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
//        NSLog(@"response - %@", response.object);
//    }];
    
//    [self.apiClient loadProjectsOfShot:@"471756" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
//        NSLog(@"response - %@", response.object);
//    }];
    
//    [self.apiClient loadProject:@"48926" responseHandler:^(DRApiResponse *response) {
//        NSLog(@"response - %@", response.object);
//    }];

    //    [self.apiClient loadMembersOfTeam:@"834683" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
    //        NSLog(@"response - %@", response.object);
    //    }];
    
    //    [self.apiClient loadShotsOfTeam:@"834683" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
    //        NSLog(@"response - %@", response.object);
    //    }];

}


- (void)showPickerUploadImageWithCompletion:(UserUploadImageBlock)completionHandler fromView:(UIView *)sourceView {
    self.userUploadImageBlock = completionHandler;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select image" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        [actionSheet bk_addButtonWithTitle:@"Choose From Gallery" handler:^{
            [self choosePhotoFromGallery];
        }];
        [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
        [actionSheet showInView:self.view];
    }
}

- (void)choosePhotoFromGallery {
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSMutableArray *dataTypes = [NSMutableArray arrayWithArray:self.imagePicker.mediaTypes];
    [dataTypes addObject:(NSString*)kUTTypeImage];
    self.imagePicker.mediaTypes = dataTypes;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark - ImagePicker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([[info valueForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *img = [info valueForKey:UIImagePickerControllerEditedImage];
        if (!img) {
            img = [info valueForKey:UIImagePickerControllerOriginalImage];
        }
        if (img) {
            NSData *imageData = UIImageJPEGRepresentation(img, 0.7);
            NSString *imagePath = [NSString stringWithFormat:@"%@%@.jpg", NSTemporaryDirectory(), [[NSProcessInfo processInfo] globallyUniqueString]];
            [imageData writeToFile:imagePath atomically:YES];
            if (self.userUploadImageBlock) {
                self.userUploadImageBlock([NSURL fileURLWithPath:imagePath], imageData);
            }
        }
    }
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

@end
