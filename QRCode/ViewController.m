//
//  ViewController.m
//  QRCode
//
//  Created by YCLZONE on 9/6/16.
//  Copyright © 2016 YCLZONE. All rights reserved.
//

#import "ViewController.h"
#import "HYQRCodeTools.h"
#import "HYScanViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *codeImageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIColor *color = [UIColor groupTableViewBackgroundColor];
    CGFloat R = 0.0F;
    CGFloat G = 0.0F;
    CGFloat B = 0.0F;
    CGFloat A = 0.0F;
    
    if ([color getRed:&R green:&G blue:&B alpha:&A]) {
        NSLog(@"%.2f %.2f %.2f %.2f", R*255, G*255, B*255, A*255);
    }
    
    self.codeImageView.layer.borderWidth = 1;
    self.codeImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.codeImageView.layer.cornerRadius = 4;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Response
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
//    [self createQRCode];
    
    HYQRCodeTools *codeTools = [HYQRCodeTools new];
    self.codeImageView.image = [codeTools QRCodeImageWithString:self.textField.text logo:[UIImage imageNamed:@"180"] size:500];
}

- (IBAction)barButtonDidClicked:(id)sender {
    HYScanViewController *scanVC = [HYScanViewController new];
    [self.navigationController pushViewController:scanVC animated:YES];

}

@end
