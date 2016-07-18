//
//  MutualInsStoryAdPicVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/7/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsStoryAdPicVC.h"

@interface MutualInsStoryAdPicVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *activityView;

@end

@implementation MutualInsStoryAdPicVC

-(void)dealloc
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupImg];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Setup

-(void)setupImg
{
    [RACObserve(self, img)subscribeNext:^(id x) {
        if (!self.img)
        {
            self.activityView.hidden = NO;
            [self.activityIndicator startAnimating];
        }
        else
        {
            self.activityView.hidden = YES;
            self.imgView.image = self.img;
        }
    }];
}

@end
