//
//  InsInputNameVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/8.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "InsInputNameVC.h"
#import "CKLine.h"

@interface InsInputNameVC ()
@property (nonatomic, weak) IBOutlet CKLine *line;
@end

@implementation InsInputNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.line.lineAlignment = CKLineAlignmentHorizontalTop;
    [self setupNameField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNameField
{
    self.nameField.textLimit = 20;
    [self.nameField setDidBeginEditingBlock:^(CKLimitTextField *field) {
        [MobClick event:@"rp1000_5"];
        field.placeholder = nil;
    }];
    
    [self.nameField setDidEndEditingBlock:^(CKLimitTextField *field) {
        field.placeholder = @"请输入姓名";
    }];
}

- (IBAction)actionCancel:(id)sender
{
    [MobClick event:@"rp1000_4"];
}

- (IBAction)actionEnsure:(id)sender
{
    [MobClick event:@"rp1000_6"];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
