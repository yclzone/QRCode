//
//  HYScanViewController.m
//  DiabetesGuard
//
//  Created by YCLZONE on 8/31/16.
//  Copyright © 2016 YCLZONE. All rights reserved.
//

#import "HYScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <HYUIKit.h>

NSString * const HYDeviceStateUpdateNotification = @"HYDeviceStateUpdateNotification";

@interface HYScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (strong,nonatomic)AVCaptureDevice             *device;
@property (strong,nonatomic)AVCaptureDeviceInput        *input;
@property (strong,nonatomic)AVCaptureMetadataOutput     *output;
@property (strong,nonatomic)AVCaptureSession            *session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer  *previewLayer;

@property (weak, nonatomic) IBOutlet UIView *scanHolderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line2borderBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *imageHolder;
@property (weak, nonatomic) IBOutlet UITextField *deviceCodeField;

/** num */
@property (nonatomic, assign) NSInteger num;
/** upOrdown */
@property (nonatomic, assign) BOOL upOrdown;
@property (weak, nonatomic) IBOutlet UIImageView                 *line;

@property (nonatomic,strong)NSTimer                     *timer;
@end

@implementation HYScanViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setupImage];
    self.title = @"扫一扫";
    [self rescanQRCode];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self invalidTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _previewLayer.frame = self.scanHolderView.bounds;
}

#pragma mark - Private Methods

- (void)setups {
    
    if (self.session) {
        return;
    }
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    AVCaptureInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    // Output
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    self.output = output;
    
    CGRect sourceFrame = self.imageHolder.frame;
    
    CGRect bounds = self.scanHolderView.bounds;
    CGFloat x = sourceFrame.origin.x / bounds.size.width;
    CGFloat y = sourceFrame.origin.y / bounds.size.height;
    CGFloat w = sourceFrame.size.width / bounds.size.width;
    CGFloat h = sourceFrame.size.height / bounds.size.height;
    
    self.output.rectOfInterest = CGRectMake(y, x, h, w);
    
    NSLog(@"rectOfInterest: %@", NSStringFromCGRect(self.output.rectOfInterest));
    
    // Session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([session canAddInput:input]) {
        [session addInput:input];
    }
    
    if ([session canAddOutput:output]) {
        [session addOutput:output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    output.metadataObjectTypes =@[AVMetadataObjectTypeEAN13Code,
                                  AVMetadataObjectTypeEAN8Code,
                                  AVMetadataObjectTypeCode128Code,
                                  AVMetadataObjectTypeQRCode];
    
    // Preview
    [_previewLayer removeFromSuperlayer];
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    _previewLayer.frame = self.view.bounds;
    
    
    [self.scanHolderView.layer insertSublayer:_previewLayer atIndex:0];
    
    self.session = session;
    
    //    [self.session startRunning];
}

- (void)rescanQRCode {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied){
        //无权限
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告"
                                                            message:@"相机访问被限制，是否打开？"
                                                           delegate:nil
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"打开", nil];
        NSURL *url = url = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
        [alertView hy_showWithButtonsClickHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                    
                }
            }
        }];
//        [alertView show];
        
        return;
    }
    
    [self setups];
    
    [self.session startRunning];
    [self setupScanAnimation];
}

- (void)setupScanAnimation {
    [self invalidTimer];
    
//    self.imageHolder.hidden = NO;
    
    self.timer = [NSTimer timerWithTimeInterval:0.01
                                         target:self
                                       selector:@selector(animation1)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)invalidTimer {
    
    //    self.imageHolder.hidden = YES;
    
    if (self.timer) {
        if ([self.timer isValid]) {
            [self.timer invalidate];
        }
        self.timer = nil;
    }
}

- (void)animation1 {
    
    CGFloat height = 240;
    
    if (self.upOrdown) {
        self.num++;
    } else {
        self.num--;
    }
    
    //    NSLog(@"%3zd %3.0f", self.num, height);
    
    if (self.num >= height) {
        self.upOrdown = NO;
    }
    
    if (self.num <= 0){
        self.upOrdown = YES;
        self.num = 240;
    }
    
    self.line2borderBottomConstraint.constant = self.num;
}

#pragma mark - Event Response
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
//    [self.session stopRunning];
    
    // Preview
    
    [self rescanQRCode];
    
}

- (IBAction)bindButttonDidClicked:(id)sender {
    
    if (!self.deviceCodeField.text.length) {
        [self.deviceCodeField becomeFirstResponder];
        return;
    }
}


#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSString *stringValue;
    if ([metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject =
        [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    NSLog(@"code: %@", stringValue);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"扫描结果"
                                                        message:stringValue
                                                       delegate:nil
                                              cancelButtonTitle:@"重新扫描"
                                              otherButtonTitles:@"绑定", nil];
//    [alertView show];
    
    __weak typeof(self) weakSelf = self;
    [alertView hy_showWithDismissHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [weakSelf rescanQRCode];
        } else {
//            [weakSelf bindDevice:stringValue];
        }
    }];
//    if (self.scanHandler) {
//        self.scanHandler(stringValue);
//        
//        [self.navigationController popViewControllerAnimated:YES];
//    }
    
    [self.session stopRunning];
    [self invalidTimer];
//    [self getDrugInfo:stringValue];
//    self.session = nil;
}

@end
