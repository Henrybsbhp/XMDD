//
//  RescueRatingVM.m
//  XMDD
//
//  Created by St.Jimmy on 19/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "RescueRatingVM.h"
#import "NSString+RectSize.h"
#import "HKProgressView.h"
#import "JTRatingView.h"
#import "RescueRecordVC.h"
#import "GetRescueCommentRescueOp.h"
#import "GetRescueCommentOp.h"

@interface RescueRatingVM () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) UIViewController *targetVC;

@property (nonatomic, strong) GetRescueCommentOp *commentOp;

@property (nonatomic, strong) NSNumber *commentStar1;
@property (nonatomic, strong) NSNumber *commentStar2;
@property (nonatomic, strong) NSNumber *commentStar3;
@property (nonatomic, copy) NSString *commentText;

@end

@implementation RescueRatingVM

- (instancetype)initWithTableView:(UITableView *)tableView andTargetVC:(UIViewController *)targetVC
{
    if (self = [super init]) {
        self.tableView = tableView;
        self.targetVC = targetVC;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    
    return self;
}

#pragma mark - Initial setup
- (void)initialSetup
{
    [self setupNavigationBar];
    if (self.commentStatus == 1) {
        [self requestForRescueDetailData];
    } else {
        [self setDataSource];
    }
}

- (void)setDataSource
{
    if (self.commentStatus == 1) {
        self.dataSource = $($([self setupProgressViewCellWithIndex:self.rescueDetialOp.rsp_rescueStatus],
                              [self setupPaymentInfoCellWithArray:@[@"申请服务", self.rescueDetialOp.rsp_serviceName] isHighlighted:NO],
                              [self setupPaymentInfoCellWithArray:@[@"项目价格", [NSString stringWithFormat:@"￥%.2f", self.rescueDetialOp.rsp_pay]] isHighlighted:YES],
                              [self setupPaymentInfoCellWithArray:@[@"我的车辆", self.rescueDetialOp.rsp_licenseNumber] isHighlighted:NO], [self setupBlankCell]),
                            $([self setupRatingTitleCell],
                              [self setupRescueRatingCell],
                              [self setupRescueRatingCell],
                              [self setupRescueRatingCell],
                              [self setupCommentDisplayCellWithText:self.commentOp.comment]));
    } else {
        self.dataSource = $($([self setupProgressViewCellWithIndex:self.rescueDetialOp.rsp_rescueStatus],
                              [self setupPaymentInfoCellWithArray:@[@"申请服务", self.rescueDetialOp.rsp_serviceName] isHighlighted:NO],
                              [self setupPaymentInfoCellWithArray:@[@"项目价格", [NSString stringWithFormat:@"￥%.2f", self.rescueDetialOp.rsp_pay]] isHighlighted:YES],
                              [self setupPaymentInfoCellWithArray:@[@"我的车辆", self.rescueDetialOp.rsp_licenseNumber] isHighlighted:NO],
                              [self setupBlankCell]),
                            $([self setupRatingTitleCell],
                              [self setupRescueRatingCell],
                              [self setupRescueRatingCell],
                              [self setupRescueRatingCell],
                              [self setupTextCommentCell]),
                            $([self setupSendCommentCell]));
    }
    
    [self.tableView reloadData];
}

- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
    self.targetVC.navigationItem.leftBarButtonItem = back;
}

#pragma mark - Actions
/// 发表评论
- (void)actionSendComment
{
    GetRescueCommentRescueOp *op = [GetRescueCommentRescueOp operation];
    if ([self.commentStar1 integerValue] > 0 && [self.commentStar2 integerValue] > 0 && [self.commentStar3 integerValue] > 0) {
        op.applyId = self.applyID;
        op.responseSpeed = self.commentStar1;
        op.arriveSpeed = self.commentStar2;
        op.serviceAttitude = self.commentStar3;
        op.rescueType = @(1);
        
        if (self.commentText.length > 0) {
            op.comment = self.commentText;
        }else {
            op.comment = @"";
        }
        @weakify(self);
        [[[op rac_postRequest] initially:^{
            [gToast showText:@"提交评论中"];
        }] subscribeNext:^(GetRescueCommentRescueOp *op) {
            @strongify(self);
            [gToast dismiss];
            [gToast showText:@"评论成功"];
            self.commentStatus = 1;
            [self postCustomNotificationName:kNotifyRescueRecordVC object:nil];
            [self requestForRescueDetailData];
        } error:^(NSError *error) {
            [gToast showError:@"评论失败, 请尝试重新提交"];
        }] ;
        
    }else {
        [gToast showText:@"请给所有评分项给个星吧!"];
    }
}

- (void)actionBack
{
    [MobClick event:@"jiuyuanzhuangtai" attributes:@{@"navi" : @"back"}];
    
    for (UIViewController *vc in self.targetVC.navigationController.viewControllers) {
        if ([vc isKindOfClass:[RescueRecordVC class]]) {
            [self.targetVC.router.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    
    [self.targetVC.router.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Obtain data
- (void)requestForRescueDetailData
{
    GetRescueCommentOp *op = [GetRescueCommentOp operation];
    op.applyId = self.applyID;
    op.type = @(1);
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        @strongify(self);
        // 防止有数据的时候，下拉刷新导致页面会闪一下
        CGFloat reducingY = self.targetVC.view.frame.size.height * 0.1056;
        [self.targetVC.view hideDefaultEmptyView];
        [self.targetVC.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.targetVC.view.center.x, self.targetVC.view.center.y - reducingY)];
        self.tableView.hidden = YES;
    }] subscribeNext:^(GetRescueCommentOp *rop) {
        @strongify(self);
        [self.targetVC.view stopActivityAnimation];
        self.tableView.hidden = NO;
        self.commentOp = rop;
        [self setDataSource];
        
    } error:^(NSError *error) {
        @strongify(self);
        [self.targetVC.view stopActivityAnimation];
        [self.targetVC.view showImageEmptyViewWithImageName:@"def_withoutAssistHistory" text:@"暂无救援记录" tapBlock:^{
            @strongify(self);
            [self requestForRescueDetailData];
        }];
    }];
}

#pragma mark - The settings of the UITableViewCell
/// 顶部状态进度条 Cell
- (CKDict *)setupProgressViewCellWithIndex:(CGFloat)index
{
    CKDict *progressCell = [CKDict dictWith:@{kCKItemKey: @"ProgressCell", kCKCellID: @"ProgressCell"}];
    progressCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 55;
    });
    
    progressCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        HKProgressView *progressView = (HKProgressView *)[cell.contentView viewWithTag:100];
        progressView.normalColor = kBackgroundColor;
        progressView.normalTextColor = HEXCOLOR(@"#BCBCBC");
        progressView.titleArray = @[@"申请救援", @"救援调度", @"救援中", @"救援完成"];
        progressView.selectedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, index)];
    });
    
    return progressCell;
}

/// 支付的信息 Cell
- (CKDict *)setupPaymentInfoCellWithArray:(NSArray *)infoArray isHighlighted:(BOOL)isHighlighted
{
    CKDict *paymentInfoCell = [CKDict dictWith:@{kCKItemKey: @"PaymentInfoCell", kCKCellID: @"PaymentInfoCell"}];
    paymentInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 25;
    });
    paymentInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *descLabel = (UILabel *)[cell.contentView viewWithTag:100];
        UILabel *infoLabel = (UILabel *)[cell.contentView viewWithTag:101];
        if (isHighlighted) {
            infoLabel.textColor = HEXCOLOR(@"#FF7428");
        }
        
        descLabel.text = infoArray[0];
        infoLabel.text = infoArray[1];
    });
    
    return paymentInfoCell;
}

/// 空白的占位 Cell
- (CKDict *)setupBlankCell
{
    CKDict *blankCell = [CKDict dictWith:@{kCKItemKey: @"BlankCell", kCKCellID: @"BlankCell"}];
    blankCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 10;
    });
    blankCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return blankCell;
}

/// 评论的 Title cell
- (CKDict *)setupRatingTitleCell
{
    CKDict *ratingTitleCell = [CKDict dictWith:@{kCKItemKey: @"RatingTitleCell", kCKCellID: @"RatingTitleCell"}];
    
    @weakify(self);
    ratingTitleCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 40;
    });
    
    ratingTitleCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UILabel *titleLabel = (UILabel *)[cell.contentView searchViewWithTag:1010];
        if (self.commentStatus == 1) {
            titleLabel.text = @"您已经评价";
        }
    });
    
    return ratingTitleCell;
}

/// 评星打分 Cell
- (CKDict *)setupRescueRatingCell
{
    CKDict *rescueRatingCell = [CKDict dictWith:@{kCKItemKey: @"RescueRatingCell", kCKCellID: @"RescueRatingCell"}];
    
    rescueRatingCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 45;
    });
    
    rescueRatingCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *titleLabel = (UILabel *)[cell.contentView searchViewWithTag:1002];
        JTRatingView *ratingView = (JTRatingView *)[cell.contentView searchViewWithTag:1003];
        CGFloat space = (gAppMgr.deviceInfo.screenSize.width - 173 - 27 * 5) / 4;
        
        [ratingView setupImgWidth:27 andImgHeight:27 andSpace:space];
        
        @weakify(self)
        [[ratingView rac_subject] subscribeNext:^(NSNumber * number) {
            @strongify(self)
            if (indexPath.row == 1) {
                self.commentStar1 = number;
            }else if (indexPath.row == 2){
                self.commentStar2  = number;
            }else if (indexPath.row == 3){
                self.commentStar3 = number;
            }
        }];
        
        if (indexPath.row == 1) {
            titleLabel.text = @"客服反应速度：";
        }else if (indexPath.row == 2) {
            titleLabel.text = @"救援到达速度：";
        }else if (indexPath.row == 3) {
            titleLabel.text = @"救援服务态度：";
        }
        
        if (self.commentStatus == 1) {
            if (indexPath.row == 1) {
                ratingView.ratingValue = self.commentOp.responseSpeed;
            }else if (indexPath.row == 2){
                ratingView.ratingValue  = self.commentOp.arriveSpeed;
            }else if (indexPath.row == 3){
                ratingView.ratingValue = self.commentOp.serviceAttitude;
            }
            ratingView.userInteractionEnabled = NO;
        }
    });
    
    return rescueRatingCell;
}

/// 文字评价 Cell
- (CKDict *)setupTextCommentCell
{
    CKDict *textCommentCell = [CKDict dictWith:@{kCKItemKey: @"TextCommentCell", kCKCellID: @"TextCommentCell"}];
    
    textCommentCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 136;
    });
    
    textCommentCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UITextView *commentTextView = (UITextView *)[cell.contentView searchViewWithTag:100];
        UIView *containerView = (UIView *)[cell searchViewWithTag:1001];
        commentTextView.layer.borderColor = HEXCOLOR(@"#DEDFE0").CGColor;
        commentTextView.layer.borderWidth = 0.5;
        commentTextView.layer.cornerRadius = 3;
        commentTextView.layer.masksToBounds = YES;
        commentTextView.textContainerInset = UIEdgeInsetsMake(10, 7, 7, 7);
        commentTextView.delegate = self;
        
        if (!containerView) {
            containerView = [[UIView alloc] initWithFrame:CGRectMake(10, 7, commentTextView.frame.size.width - 17, 21)];
            containerView.tag = 1001;
            UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, containerView.frame.size.width, 21)];
            containerView.userInteractionEnabled = NO; // 防止视图截取 textView 获取焦点
            [containerView addSubview:placeholderLabel];
            placeholderLabel.text = @"您的评论将是其他用户的重要参考！";
            placeholderLabel.font = [UIFont systemFontOfSize:13];
            placeholderLabel.textColor = HEXCOLOR(@"#C6C6CC");
            [commentTextView addSubview:containerView];
        }
        
        @weakify(self);
        [[[commentTextView rac_textSignal] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self);
            if (commentTextView.text.length < 1) {
                containerView.hidden = NO;
            } else {
                containerView.hidden = YES;
            }
            self.commentText = commentTextView.text;
        }];
    });
    
    return textCommentCell;
}

/// 发表评论 Cell
- (CKDict *)setupSendCommentCell
{
    CKDict *sendCommentCell = [CKDict dictWith:@{kCKItemKey: @"ButtonCell", kCKCellID: @"ButtonCell"}];
    
    sendCommentCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 68;
    });
    
    sendCommentCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIButton *sendButton = (UIButton *)[cell.contentView viewWithTag:100];
        sendButton.backgroundColor = HEXCOLOR(@"#FF7428");
        [sendButton setTitle:@"发表评论" forState:UIControlStateNormal];
        
        @weakify(self);
        [[[sendButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self);
            [MobClick event:@"jiuyuanzhuangtai" attributes:@{@"jiuyuanwancheng" : @"fabiaopinglun"}];
            [self actionSendComment];
        }];
    });
    
    return sendCommentCell;
}

/// 已发表文字评论 Cell
- (CKDict *)setupCommentDisplayCellWithText:(NSString *)textString
{
    CKDict *commentDisplayCell = [CKDict dictWith:@{kCKItemKey: @"CommentDisplayCell", kCKCellID: @"CommentDisplayCell"}];
    
    commentDisplayCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        CGSize labelSize = [textString labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 34 font:[UIFont systemFontOfSize:13]];
        if (textString.length > 0) {
            return labelSize.height + 10;
        }
        
        return 10;
    });
    
    commentDisplayCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *commentLabel = (UILabel *)[cell.contentView searchViewWithTag:1001];
        commentLabel.text = textString.length > 0 ? textString : @"";
    });
    
    return commentDisplayCell;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [MobClick event:@"jiuyuanzhuangtai" attributes:@{@"jiuyuanwancheng" : @"pinglunjiju"}];
}

#pragma mark - UITableViewDelagate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

@end
