//
//  AwardOtherSheetVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/27.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "AwardOtherSheetVC.h"

@interface AwardOtherSheetVC ()

@property (weak, nonatomic) IBOutlet UIView *successView;
@property (weak, nonatomic) IBOutlet UIView *failureView;
@property (weak, nonatomic) IBOutlet UIView *alreadygetView;
@property (weak, nonatomic) IBOutlet UIView *commonView;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLbel;

@end

@implementation AwardOtherSheetVC
- (void)dealloc
{
    DebugLog(@"AwardOtherSheetVC dealloc ~");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.sheetType == AwardSheetTypeSuccess) {
        self.successView.hidden = NO;
        self.failureView.hidden = YES;
        self.alreadygetView.hidden = YES;
        self.commonView.hidden = YES;
    }
    else if (self.sheetType == AwardSheetTypeAlreadyget) {
        self.successView.hidden = YES;
        self.failureView.hidden = YES;
        self.alreadygetView.hidden = NO;
        self.commonView.hidden = YES;
    }
    else if (self.sheetType == AwardSheetTypeCommon || self.sheetType == AwardSheetTypeCommon) {
        self.successView.hidden = YES;
        self.failureView.hidden = YES;
        self.alreadygetView.hidden = YES;
        self.commonView.hidden = NO;
        
        NSString * defaultUrl = self.isSuccess ? @"award_logo_arrival" : @"award_logo_unarrival";
        NSString * imageUrl = self.isSuccess ? [self.infoDic stringParamForName:@"successpic"] : [self.infoDic stringParamForName:@"failpic"];
        NSString * contentStr = self.isSuccess ? [self.infoDic stringParamForName:@"successtip"] : [self.infoDic stringParamForName:@"failtip"];
        
        [self.imageView setImageByUrl:imageUrl withType:ImageURLTypeThumbnail defImage:defaultUrl errorImage:defaultUrl];
        self.contentLbel.text = contentStr;
    }
    else {
        if (self.sheetType == AwardSheetTypeCancel) {
            self.stateLabel.text = @"分享已取消";
        }
        else {
            self.stateLabel.text = @"分享失败";
        }
        self.successView.hidden = YES;
        self.failureView.hidden = NO;
        self.alreadygetView.hidden = YES;
        self.commonView.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
