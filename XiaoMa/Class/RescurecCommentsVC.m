//
//  RescurecCommentsVC.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/10.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "RescurecCommentsVC.h"
#import "GetRescueCommentRescueOp.h"
#import "HKBigRatingView.h"
#import "JTRatingView.h"
#import "GetRescueCommentOp.h"
#import "UIView+DefaultEmptyView.h"
#import "UIView+JTLoadingView.h"
#import "NSString+RectSize.h"
#import "HKRescueHistory.h"
#define kWidth [UIScreen mainScreen].bounds.size.width

@interface RescurecCommentsVC ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView        * headerView;
@property (nonatomic, strong) UIImageView   * titleImg;
@property (nonatomic, strong) UILabel       * titleLb;
@property (nonatomic, strong) UIView        * footerView;
@property (nonatomic, strong) UITextView    * commentsTV;
@property (nonatomic, strong) UILabel       * placeholderLb;
@property (nonatomic, strong) UIButton      * submitBtn;
@property (nonatomic, strong) NSNumber      * starNum1;
@property (nonatomic, strong) NSNumber      * starNum2;
@property (nonatomic, strong) NSNumber      * starNum3;
@property (nonatomic, strong) NSMutableArray * dataSourceArray;
@property (nonatomic, strong) NSMutableArray * evaluationArray;
@end

@implementation RescurecCommentsVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"RescurecCommentsVC dealloc");
}
- (void)viewDidDisappear:(BOOL)animated {
    
}
- (void)viewWillDisappear:(BOOL)animated {
    
}
- (void)viewWillAppear:(BOOL)animated {
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setImageAndLbText];
    [self.headerView addSubview:self.titleImg];
    [self.headerView addSubview:self.titleLb];
    [self.footerView addSubview:self.commentsTV];
    [self.commentsTV addSubview:self.placeholderLb];
    [self.footerView addSubview:self.submitBtn];
    self.tableView.tableHeaderView = self.headerView;
    
    if ([self.applyType integerValue] == 1){
        self.navigationItem.title = @"救援完成";
        
    }else {
        self.navigationItem.title = @"协办完成";
    }
    
    @weakify(self)
    [self.commentsTV.rac_textSignal subscribeNext:^(NSString * x) {
        @strongify(self)
        if (x.length > 0) {
            self.placeholderLb.hidden = YES;
            self.placeholderLb.text = @"";
        }else {
            self.placeholderLb.hidden = NO;
            self.placeholderLb.text = @"其他建议或意见";
        }
    }];
    
    if (self.history.commentStatus == HKCommentStatusYes) {
        [self alreadyNetwork];
        
        
    }else{
        self.tableView.tableFooterView = self.footerView;
    }
}

- (void)setImageAndLbText {
    if (self.history.type == HKRescueTrailer ) {
        self.titleImg.image = [UIImage imageNamed:@"rescue_trailer"];
        self.titleLb.text = @"拖车服务";
    }else if (self.history.type == HKRescuePumpPower ){
        self.titleImg.image = [UIImage imageNamed:@"pump_power"];
        self.titleLb.text = @"泵电服务";
    }else if (self.history.type == HKRescuetire){
        self.titleImg.image = [UIImage imageNamed:@"rescue_tire"];
        self.titleLb.text = @"换胎服务";
    }else{
        self.titleImg.image = [UIImage imageNamed:@"commission_annual"];
        self.titleLb.text = @"年检协办";
    }
}

#pragma mark - Action
- (void) alreadyNetwork {
    GetRescueCommentOp *op = [GetRescueCommentOp operation];
    op.applyId = self.history.applyId;
    op.type = self.applyType;
    self.tableView.hidden = YES;
    @weakify(self)
    [[[[op rac_postRequest] initially:^{
        @strongify(self)
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        
    }] finally:^{
        @strongify(self)
        [self.view stopActivityAnimation];
        
    }] subscribeNext:^(GetRescueCommentOp *op) {
        @strongify(self)
        self.tableView.hidden = NO;
        self.evaluationArray = op.rescueDetailArray;
        self.tableView.hidden = NO;
        self.footerView.hidden = YES;
        [self.tableView reloadData];
        
    } error:^(NSError *error) {
        @strongify(self)
        self.tableView.hidden = YES;
        [self.view showDefaultEmptyViewWithText:kDefErrorPormpt tapBlock:^{
            [self alreadyNetwork];
        }];
    }] ;
}
- (void)actionCommentsClick {
    GetRescueCommentRescueOp *op = [GetRescueCommentRescueOp operation];
    if ([self.starNum1 integerValue]> 0 && [self.starNum2 integerValue] > 0 && [self.starNum3 integerValue] > 0) {
        op.applyId = self.history.applyId;
        op.responseSpeed = self.starNum1;
        op.arriveSpeed = self.starNum2;
        op.serviceAttitude = self.starNum3;
        op.rescueType = self.applyType;
        
        if (self.commentsTV.text != nil) {
            op.comment = self.commentsTV.text;
        }else {
            op.comment = @"";
        }
        
        @weakify(self)
        [[[[op rac_postRequest] initially:^{
            [gToast showText:@"提交评论中"];
        }] finally:^{
            @strongify(self)
            [gToast dismiss];
            [gToast showText:@"评论成功"];
            self.history.commentStatus = HKCommentStatusYes;
            [self alreadyNetwork];
        }] subscribeNext:^(GetRescueCommentRescueOp *op) {
            
        } error:^(NSError *error) {
            [gToast showError:@"评论失败, 请尝试重新提交"];
        }] ;
        
    }else {
        [gToast showText:@"请给所有评分项给个星吧!"];
    }
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.history.commentStatus == HKCommentStatusYes && self.evaluationArray.count != 0){
        return 8;
    }else {
        return 7;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < 3) {
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"RescurecContent" forIndexPath:indexPath];
        UILabel *nameLabel = (UILabel *)[cell1 searchViewWithTag:1000];
        UILabel *textLb = (UILabel *)[cell1 searchViewWithTag:1001];
        
        if (indexPath.row == 0) {
            nameLabel.text = @"申请时间";
            textLb.text = [[NSDate dateWithUTS:self.history.appointTime] dateFormatForYYMMdd2];
        }else if (indexPath.row == 1){
            nameLabel.text = @"申请服务";
            textLb.text = self.history.serviceName;
        }else if (indexPath.row == 2){
            nameLabel.text = @"服务车牌";
            textLb.text = self.history.licenceNumber;
        }
        return cell1;
        
    }else if (indexPath.row == 3){
        
        UITableViewCell *cell3 = [tableView dequeueReusableCellWithIdentifier:@"RescurecCommentsText" forIndexPath:indexPath];
        UILabel * stateLb      = (UILabel *)[cell3 searchViewWithTag:1010];
        UILabel * evaluationLb = (UILabel *)[cell3 searchViewWithTag:1011];
        
        if (self.history.commentStatus == HKCommentStatusYes && self.evaluationArray.count != 0) {
            stateLb.text = @"感谢您的评价";
            evaluationLb.hidden = YES;
        }
        return cell3;
        
    }else  if(indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 6){
        UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"RescureStar" forIndexPath:indexPath];
        UILabel *serviceLb = (UILabel *)[cell2 searchViewWithTag:1002];
        JTRatingView *ratingView = (JTRatingView *)[cell2 searchViewWithTag:1003];
        ratingView.imgWidth = 20;
        ratingView.imgHeight = 20;
        ratingView.imgSpacing = (self.view.frame.size.width - 128 - 20 * 5)/6;
        
        [[ratingView rac_subject] subscribeNext:^(NSNumber * number) {
            if (indexPath.row == 4) {
                self.starNum1 = number;
            }else if (indexPath.row == 5){
                self.starNum2  = number;
            }else if (indexPath.row == 6){
                self.starNum3 = number;
            }
        }];
        
        if (self.history.commentStatus == HKCommentStatusYes && self.evaluationArray.count != 0) {
            [ratingView setUserInteractionEnabled:NO];
            if (indexPath.row == 4) {
                ratingView.ratingValue = [[self.evaluationArray safetyObjectAtIndex:0] floatValue];
            }else if (indexPath.row == 5){
                ratingView.ratingValue = [[self.evaluationArray safetyObjectAtIndex:1] floatValue];
            }else if (indexPath.row == 6){
                ratingView.ratingValue = [[self.evaluationArray safetyObjectAtIndex:2] floatValue];
            }
        }
        
        if (indexPath.row == 4) {
            serviceLb.text = @"客服反应速度:";
        }else if (indexPath.row == 5){
            serviceLb.text = @"救援到达速度:";
        }else if (indexPath.row == 6){
            serviceLb.text = @"救援服务态度:";
        }
        return cell2;
    } else{
        
        UITableViewCell *cell4 = [tableView dequeueReusableCellWithIdentifier:@"EvaluationContent" forIndexPath:indexPath];
        UILabel *textLb = (UILabel *)[cell4 searchViewWithTag:1004];
        textLb.text = [self.evaluationArray safetyObjectAtIndex:3];
        return cell4;
    }
}

#pragma mark - UITableViewdelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        return 25;
    }else if (indexPath.row < 4){
        if (self.evaluationArray.count != 0) {
            return 36;
        }else{
            return 50;
        }
    }else if (indexPath.row == 7){
        if (self.history.commentStatus == HKCommentStatusYes && self.evaluationArray.count != 0){
            NSString * str = [self.evaluationArray safetyObjectAtIndex:3];
            CGFloat width = kWidth - 20;
            CGSize size = [str labelSizeWithWidth:width font:[UIFont systemFontOfSize:12]];
            return size.height;
        }else{
            return 36;
        }
    }else {
        return 36;
    }
}
#pragma mark - lazyLoading
- (UIView *)headerView {
    if (!_headerView) {
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 0.193 * kWidth)];
    }
    return _headerView;
}

- (UIImageView *)titleImg {
    if (!_titleImg) {
        self.titleImg = [[UIImageView alloc] initWithFrame:CGRectMake(13, 15, 35, 35)];
    }
    return _titleImg;
}

- (UILabel *)titleLb {
    if (!_titleLb) {
        self.titleLb = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.titleImg.frame) + 15, CGRectGetMinY(self.titleImg.frame), kWidth - 35 - 26 - 15, self.titleImg.frame.size.height)];
        _titleLb.font = [UIFont systemFontOfSize:18];
        _titleLb.textColor = [UIColor colorWithHex:@"#111111" alpha:1.0];
    }
    return _titleLb;
}

- (UIView *)footerView {
    if (!_footerView) {
        self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 0.4 * kWidth)];
    }
    return _footerView;
}

- (UITextView *)commentsTV {
    if (!_commentsTV) {
        self.commentsTV = [[UITextView alloc] initWithFrame:CGRectMake(9, 0, kWidth - 18, 0.24 * (kWidth - 18))];
        _commentsTV.layer.backgroundColor = [[UIColor clearColor] CGColor];
        _commentsTV.layer.borderColor = [UIColor colorWithHex:@"#bfbfbf" alpha:1.0].CGColor;
        _commentsTV.layer.borderWidth = 0.5;
    }
    return _commentsTV;
}

- (UILabel *)placeholderLb {
    if (!_placeholderLb) {
        self.placeholderLb = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.commentsTV.frame), CGRectGetMinY(self.commentsTV.frame) + 3, 100, 20)];
        _placeholderLb.text = @"其他建议或意见";
        _placeholderLb.textColor = [UIColor colorWithHex:@"#e3e3e3" alpha:1.0];
        _placeholderLb.font = [UIFont systemFontOfSize:12];
        _placeholderLb.hidden = NO;
    }
    return _placeholderLb;
}

- (NSMutableArray *)dataSourceArray {
    if (!_dataSourceArray) {
        self.dataSourceArray = [[NSMutableArray alloc] init];
    }
    return _dataSourceArray;
}

- (NSMutableArray *)evaluationArray {
    if (!_evaluationArray) {
        self.evaluationArray = [[NSMutableArray alloc] init];
    }
    return _evaluationArray;
}


- (UIButton *)submitBtn {
    if (!_submitBtn) {
        self.submitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _submitBtn.frame = CGRectMake(5, CGRectGetMaxY(_commentsTV.frame) + 12, kWidth - 10, (kWidth - 10) * 0.128);
        _submitBtn.backgroundColor = [UIColor colorWithHex:@"#ffa800" alpha:1.0];
        [_submitBtn addTarget:self action:@selector(actionCommentsClick) forControlEvents:UIControlEventTouchUpInside];
        _submitBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_submitBtn setTintColor:[UIColor whiteColor]];
        _submitBtn.cornerRadius = 5;
        [_submitBtn setTitle:@"发表评论" forState:UIControlStateNormal];
    }
    return _submitBtn;
}

@end
