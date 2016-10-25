//
//  ViolationInputNameVC.m
//  XMDD
//
//  Created by RockyYe on 2016/10/21.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKLine.h"
#import "ViolationInputNameVC.h"

@interface ViolationInputNameVC ()
@property (weak, nonatomic) IBOutlet CKLine *line;

@end

@implementation ViolationInputNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.line.lineAlignment = CKLineAlignmentHorizontalTop;
    [self setupNameField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNameField
{
    self.nameField.textLimit = 18;
    [self.nameField setDidBeginEditingBlock:^(CKLimitTextField *field) {
        field.placeholder = nil;
    }];
    
    [self.nameField setDidEndEditingBlock:^(CKLimitTextField *field) {
        field.placeholder = @"因业务需要，需提供身份证号码";
    }];
}

@end
