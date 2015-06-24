//
//  ViewController.m
//  DribbbleSDKDemo
//
//  Created by Dmitry Salnikov on 6/11/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"
#import "DribbbleSDK.h"
#import <BlocksKit+UIKit.h>
#import "ApiCallFactory.h"
#import "ApiCallWrapper.h"
#import "TestApiViewController.h"

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

static NSString * kCellIdentifier = @"cellIdentifier";
static NSString * kSegueIdentifierAuthorize = @"authorizeSegue";
static NSString * kSegueIdentifierTestApi = @"testApiSegue";


@interface MainViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) DRApiClient *apiClient;

@property (strong, nonatomic) IBOutlet LoginViewController *loginViewController;

@property (strong, nonatomic) NSArray *apiCallWrappers;


@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (copy, nonatomic) UserUploadImageBlock userUploadImageBlock;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;

@end

@implementation MainViewController

#pragma View LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
//    __weak typeof(self)weakSelf = self;
    
    self.apiCallWrappers = [ApiCallFactory demoApiCallWrappers];
    
//    __weak typeof(self)weakSelf = self;
//    UIButton *pickImg = [[UIButton alloc] initWithFrame:CGRectMake(20.f, 100.f, 100.f, 40.f)];
//    [pickImg setTitle:@"Pick image" forState:UIControlStateNormal];
//    [pickImg setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.view addSubview:pickImg];
//    [pickImg bk_addEventHandler:^(id sender) {
//        [weakSelf showPickerUploadImageWithCompletion:^(NSURL *fileUrl, NSData *imageData) {
//            [weakSelf.apiClient uploadShotWithParams:@{@"image" : imageData} responseHandler:^(DRApiResponse *response) {
//                NSLog(@"response - %@", response.object);
//            }];
//        } fromView:nil];
//    } forControlEvents:UIControlEventTouchUpInside];
//    
//    UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(20.f, 300.f, 100.f, 40.f)];
//    [logoutBtn setTitle:@"logout" forState:UIControlStateNormal];
//    [logoutBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.view addSubview:logoutBtn];
//    [logoutBtn bk_addEventHandler:^(id sender) {
//        [self.apiClient logout];
//    } forControlEvents:UIControlEventTouchUpInside];
    
    [self setupApiClient];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self loadSomeData];
//    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.signOutButton.hidden = ![self.apiClient isUserAuthorized];
    self.signInButton.hidden = [self.apiClient isUserAuthorized];
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
                                                                          scopes:[NSSet setWithObjects:kDRPublicScope, kDRWriteScope, kDRUploadScope, nil]];
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
    } else if ([segue.identifier isEqualToString:kSegueIdentifierTestApi]) {
        TestApiViewController *testApiController = (TestApiViewController *)segue.destinationViewController;
        testApiController.apiCallWrapper = sender;
        testApiController.apiClient = self.apiClient;
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
}

#pragma mark - Table View Delegate + Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.apiCallWrappers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ApiCallWrapper *wrapper = self.apiCallWrappers[indexPath.row];
    
    cell.textLabel.text = wrapper.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ApiCallWrapper *wrapper = self.apiCallWrappers[indexPath.row];
    [self performSegueWithIdentifier:kSegueIdentifierTestApi sender:wrapper];
}

#pragma mark - Getters

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.allowsEditing = YES;
        _imagePicker.delegate = self;
    }
    return _imagePicker;
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
        
#warning TODO: use here original image only, because edited can't be exact 400x300 or 800x600 size
        
        UIImage *img = nil; //[info valueForKey:UIImagePickerControllerEditedImage];
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

- (IBAction)pressSignOut:(id)sender {
    [self.apiClient logout];
    self.signOutButton.hidden = ![self.apiClient isUserAuthorized];
    self.signInButton.hidden = [self.apiClient isUserAuthorized];
}

@end
