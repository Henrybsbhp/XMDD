//
//  PickCarVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/4/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "PickCarVC.h"
#import "MyCarStore.h"
#import "EditCarVC.h"

@interface PickCarVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *carNumLabel;
- (IBAction)joinAction:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (nonatomic, strong) MyCarStore *carStore;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, assign) NSInteger checkIndex;

@end

@implementation PickCarVC

-(void)dealloc
{
    DebugLog(@"PickCarVC dealloc~~~~");
}

- (void)awakeFromNib
{
    _model = [[MyCarListVModel alloc] init];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpUI];
    [self setupCarStore];
    [[self.carStore getAllCars] send];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUpUI
{
    self.bottomView.hidden = !self.isShowBottomView;
    self.bottomConstraint.constant = self.isShowBottomView ? 70 : 0;
}

- (void)setupCarStore
{
    self.carStore = [MyCarStore fetchOrCreateStore];
    
    @weakify(self);
    [self.carStore subscribeWithTarget:self domain:@"cars" receiver:^(CKStore *store, CKEvent *evt) {
        @strongify(self);
        [self reloadDataWithEvent:evt];
    }];
}

- (void)reloadDataWithEvent:(CKEvent *)evt
{
    @weakify(self);
    [[[[evt.signal deliverOn:[RACScheduler mainThreadScheduler]] initially:^{
        
        @strongify(self);
        self.tableView.hidden = YES;
        [self.view hideDefaultEmptyView];
        
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] finally:^{
        [self.view stopActivityAnimation];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        self.datasource = [self.carStore.cars allObjects];
        
        if (self.datasource.count ==0) {
            self.carNumLabel.text = @"";
        }
        else {
            if (self.defaultCar){
                self.checkIndex = [self.datasource indexOfObject:self.defaultCar];
                self.carNumLabel.text = self.defaultCar.licencenumber;
                self.model.selectedCar = self.defaultCar;
            }
            else {
                self.checkIndex = 100;
                self.carNumLabel.text = @"";
            }
        }
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        [self.view showDefaultEmptyViewWithText:@"获取爱车信息失败，点击重试" tapBlock:^{
            @strongify(self);
            [[self.carStore getAllCars] send];
        }];
    }];
}

#pragma mark TableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.datasource.count < 5) {
        return self.datasource.count + 1;
    }
    return self.datasource.count;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    if (indexPath.row < self.datasource.count) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"CarCell"];
        UIImageView * brandImageV = [cell.contentView viewWithTag:1001];
        UILabel * licensenoL = [cell.contentView viewWithTag:1002];
        UILabel * brandLabel = [cell.contentView viewWithTag:1003];
        UIImageView * checkImageV = [cell.contentView viewWithTag:1004];
        
        HKMyCar *car = [self.datasource safetyObjectAtIndex:indexPath.row];
        
        [brandImageV setImageByUrl:car.brandLogo withType:ImageURLTypeOrigin defImage:@"avatar_default" errorImage:@"avatar_default"];
        licensenoL.text = car.licencenumber;
        NSString *brandAndSeries = [NSString stringWithFormat:@"%@ %@", car.brand, car.seriesModel.seriesname];
        brandLabel.text = brandAndSeries;
        checkImageV.hidden = self.checkIndex == indexPath.row ? NO : YES;
    }
    else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"AddCarCell"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.datasource.count) {
        if (self.isShowBottomView) {
            self.checkIndex = indexPath.row;
            self.model.selectedCar = [self.datasource safetyObjectAtIndex:indexPath.row];
            self.carNumLabel.text = self.model.selectedCar.licencenumber;
            [self.tableView reloadData];
        }
        else {
            HKMyCar *car = [self.datasource safetyObjectAtIndex:indexPath.row];
            self.model.selectedCar = car;
            if (self.finishPickCar) {
                self.finishPickCar(self.model, self.view);
            }
            if (self.model.originVC) {
                [self.navigationController popToViewController:self.model.originVC animated:YES];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    else {
        EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
        [vc.model setFinishBlock:^(HKMyCar *car) {
            self.checkIndex = [self.datasource indexOfObject:car];
            self.carNumLabel.text = car.licencenumber;
            self.model.selectedCar = car;
            [self.tableView reloadData];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)joinAction:(id)sender {
    if (self.model.selectedCar) {
        if (self.finishPickCar) {
            self.finishPickCar(self.model, self.view);
        }
    }
    else {
        [gToast showText:@"请先选择爱车"];
    }
}

@end
