//
//  PhotoBrowserVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "PhotoBrowserVC.h"

@interface PhotoBrowserVC ()
@property (strong, nonatomic) IBOutlet UIImageView *imgView;

@end

@implementation PhotoBrowserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imgView.image = self.img;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
