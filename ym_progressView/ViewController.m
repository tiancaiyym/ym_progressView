//
//  ViewController.m
//  ym_progressView
//
//  Created by 熊雯婷 on 2017/8/3.
//  Copyright © 2017年 rionsoft. All rights reserved.
//

#import "ViewController.h"
#import "ym_progressView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet ym_progressView *progressView;
@property (weak, nonatomic) IBOutlet UITextField *progressField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)begin:(UIButton *)sender {
    self.progressView.progress = [self.progressField.text floatValue];
}

@end
