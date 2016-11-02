"use strict";
import React, {Component} from 'react';
import {
    View,
    Text,
    Image,
    TextInput,
    StyleSheet,
    ListView,
    TouchableOpacity,
    TouchableWithoutFeedback,
    Linking,
    InteractionManager,
    NativeModules,
} from 'react-native';
import BlankView from '../general/BlankView';
import UI from '../../constant/UIConstants';
import Constant from '../../constant/Constants';
import RefreshControl from '../general/refresh/RefreshControl';
import PopoverMenu from '../general/popup/PopoverMenu';
import GroupDetailView from './GroupDetailView';
import GroupListView from './GroupListView';
import GroupIntroductionView from './GroupIntroductionView';
import CalculationView from './CalculationView';
import Store, {Actions, Domains} from '../../store/MutualInsStore';
import ImageAlert, {AlertButton} from '../general/popup/ImageAlert';
import Toast from 'react-native-root-toast';
import UploadInfoView from './UploadInfoView';

const NavigationManager = NativeModules.NavigationManager;

export default class MutualInsView extends Component {
    constructor(props) {
        super(props);
        // 设置数据源
        this.ds = new ListView.DataSource({
            rowHasChanged: (r1, r2) => r1 != r2,
            sectionHeaderHasChanged: (s1, s2) => s1 != s2,
        })
        // 初始化状态
        this.state = {
            forceRerend: false,
            loading: true,
            loadedOnce: false,
            dataSource:this.ds,
            menuOpened: false,
            callAlertOpened: false,
        }
    }

    componentDidMount() {
        // 设置导航条
        this.props.navigator.replace({
            ...this.props.route,
            component: MutualInsView,
            renderRightItem: this.renderRightItem.bind(this)
        })

        // 获取数据
        this.unsubscribe = Store.listen(this.onStoreChanged.bind(this))
        Actions.fetchSimpleGroups()
    }

    componentWillUnmount() {
        this.unsubscribe()
    }

    /// Actions
    createDatasource(cars) {
        var dataBlob = [{render: this.renderHeaderSection.bind(this)}]
        if (cars && cars.length > 0) {
            for (var car of cars) {
                dataBlob.push({render: this.renderCarSection.bind(this), car: car})
            }
        }
        else {
            dataBlob.push({render: this.renderCouponCell.bind(this)})
        }
        return this.ds.cloneWithRows(dataBlob)
    }

    showMenu() {
        this.setState({menuOpened: !this.state.menuOpened})
    }

    showToast(msg) {
        Toast.show(msg, {
            duration: Toast.durations.SHORT,
            position: Toast.positions.CENTER,
            shadow: false,
        });
    }

    /// callback
    gotoGroupDetail(car) {
        var route = {
            component: GroupDetailView,
            groupName: car.groupname,
            groupID: car.groupid,
            memberID: car.memberid,
            shouldLogin: true,
            title: car.groupname
        };
        this.props.navigator.push(route);
    }

    onStoreChanged(domain, info, error) {
        if (Domains.SimpleGroups == domain) {
            var state = {groups: info, loading: info.loading}
            if (!info.loading && !error) {
                state.loadedOnce = true
                state.dataSource = this.createDatasource(info.carlist)
            }
            this.setState(state)

            if (this.state.loadedOnce && error) {
                this.showToast(error)
            }
        }
    }

    onCouponCellPress(car) {
        if (car && car.status == 3) {
            this.showToast('车辆审核中，请耐心等待审核结果')
        }
        else {
            this.onJoinGroup()
        }
    }

    onCarCellPress(car) {
        var {callback} = this.configInfoForCarButton(car)
        var hasGroup = car.extendinfo && car.extendinfo.length > 0
        if (callback) {
            callback()
        }
        else if (hasGroup) {
            this.gotoGroupDetail(car)
        }
        else if (car.status == 3) {
            this.showToast('车辆审核中，请耐心等待审核结果')
        }
        else {
            this.onJoinGroup()
        }
    }

    onPayButtonPress(car) {
        NavigationManager.pushViewControllerByUrl(Constant.Link.MutualInsOrder(car.contractid))
    }

    uploadInfo(car) {
        var route = {component: UploadInfoView, title: '完善入团信息', car: car, groupID: car.groupid}
        this.props.navigator.push(route);
    }

    onCallButtonPress() {
        this.setState({menuOpened: false, callAlertOpened: true})
    }

    onJoinGroup() {
        var route = {
            component: GroupIntroductionView,
            title: '小马互助',
        };
        this.props.navigator.push(route);
    }

    onCompensationButtonPress() {
        NavigationManager.pushViewControllerByUrl(Constant.Link.MutualInsCompensation)
    }

    onUsingHelpPress() {
        this.setState({menuOpened: false})
        NavigationManager.pushViewControllerByUrl(Constant.Link.MutualInsUsingHelp)
    }

    onCalculatePress() {
        this.setState({menuOpened: false})
        NavigationManager.pushViewControllerByUrl(Constant.Link.MutualInsCalculate)
        // var route = {component: CalculationView, title: '费用试算'}
        // this.props.navigator.push(route)
    }

    onGotoGroupList() {
        var route = {component: GroupListView, title: '互助团'}
        this.props.navigator.push(route)
    }

    /// render
    render() {
        return (
            <BlankView style={styles.container}
                       visible={!this.state.loadedOnce}
                       text="获取信息失败, 点击重试"
                       onPress={Actions.fetchSimpleGroups}
                       loading={this.state.loading}
            >
                <RefreshControl.ListView
                    onRefresh={Actions.fetchSimpleGroups}
                    style={styles.bg}
                    refreshing={this.state.loading}
                    dataSource={this.state.dataSource}
                    renderRow={(row, sid, rid) => row.render(row, sid, rid)}
                />
                <View style={styles.bottomContainer}>
                    <View style={styles.line}/>
                    <View style={styles.bottomContent}>
                        <TouchableOpacity style={[styles.bottomButton, styles.bottomLeftButton]}
                                          onPress={this.onCompensationButtonPress.bind(this)}>
                            <Text style={styles.bottomButtonText}>我要陪</Text>
                        </TouchableOpacity>
                        <TouchableOpacity style={[styles.bottomButton, styles.bottomRightButton]}
                                          onPress={this.onJoinGroup.bind(this)}>
                            <Text style={styles.bottomButtonText}>加入互助</Text>
                        </TouchableOpacity>
                    </View>
                </View>
                {this.renderMenu()}
                {this.renderImageAlert()}
            </BlankView>
        );
    }

    renderRightItem(route) {
        return (
            <View>
                <TouchableOpacity onPress={this.showMenu.bind(this)} style={{padding: 4}}>
                    <Image source={{uri: 'mins_menu', width: 25, height: 25}}/>
                </TouchableOpacity>
            </View>
        )
    }

    //// renderMenu
    renderMenu() {
        return (
            <PopoverMenu isOpen={this.state.menuOpened}
                         onClosed={() => {this.state.menuOpened = false}}
            >
                <PopoverMenu.MenuCell image={{uri: 'mutualIns_calculateGreen', width: 19, height: 19}} text="费用试算"
                                      onPress={this.onCalculatePress.bind(this)}/>
                {this.state.myGroups && this.state.myGroups.showplanbtn &&
                <PopoverMenu.MenuCell image={{uri: 'mins_person', width: 18, height: 16}} text="内测计划"/>}
                {this.state.myGroups && this.state.myGroups.showregistbtn &&
                <PopoverMenu.MenuCell image={{uri: 'mec_edit', width: 16, height: 17}} text="内测登记"/>}
                <PopoverMenu.MenuCell image={{uri: 'mins_question', width: 19, height: 19}} text="使用帮助"
                                      onPress={this.onUsingHelpPress.bind(this)}/>
                <PopoverMenu.MenuCell image={{uri: 'mins_phone', width: 18, height: 17}} text="联系客服"
                                      onPress={this.onCallButtonPress.bind(this)}/>
            </PopoverMenu>
        );
    }

    /// renderAlert
    renderImageAlert() {
        return (
            <ImageAlert title="温馨提示"　
                        message="如有任何疑问，可拨打客服电话: 4007-111-111"
                        isOpen={this.state.callAlertOpened}
                        onClosed={() => {this.state.callAlertOpened = false}}>
                <AlertButton title="取消"
                             color={UI.Color.GrayText}
                             onPress={() => {this.setState({callAlertOpened: false})}}/>
                <AlertButton title="拨打"
                             color={UI.Color.DarkYellow}
                             onPress={() => {
                                 this.setState({callAlertOpened: false})
                                 Linking.openURL(Constant.Link.Phone)
                             }}/>
            </ImageAlert>
        )
    }

    /// renderSection
    renderHeaderSection(row) {
        var groups = this.state.groups;
        return (
            <View style={{backgroundColor: 'white'}}>
                <View style={styles.headerItemsHContainer}>
                    {this.renderHeaderItem(
                        {uri: 'mutualIns_people', width: 18, height: 22},
                        groups.totalmembercnt,
                        '参加人数'
                    )}
                    <View style={styles.lineV}/>
                    {this.renderHeaderItem(
                        {uri: 'mutualIns_moneySum', width: 21, height: 21},
                        groups.totalpoolamt,
                        '互助金额'
                    )}
                </View>
                <View style={styles.line4}/>
                <View style={styles.headerItemsHContainer}>
                    {this.renderHeaderItem(
                        {uri: 'mutualIns_stack', width: 22, height: 22},
                        groups.totalclaimcnt,
                        '补偿次数'
                    )}
                    <View style={styles.lineV}/>
                    {this.renderHeaderItem(
                        {uri: 'mutualIns_statistics', width: 20, height: 20},
                        groups.totalclaimamt,
                        '补偿金额'
                    )}
                </View>
                <View style={styles.line}/>
                <TouchableOpacity style={styles.allGroupsButton} onPress={this.onGotoGroupList.bind(this)}>
                        <Text style={styles.allGroupsButtonTitle}>
                            {this.state.groups.opengrouptip}
                        </Text>
                        <Image source={UI.Img.ArrowRight} style={styles.arrow}/>
                </TouchableOpacity>
                <View style={styles.sectionCell}>
                    <Text style={styles.sectionCellText}>我的互助</Text>
                </View>
            </View>
        );
    }

    renderHeaderItem(img, title, desc) {
        return (
            <View style={styles.headerItemContainer}>
                <Image source={img} style={styles.headerItemImage}/>
                <View>
                    <Text style={styles.headerItemTitle}>{title}</Text>
                    <Text style={styles.headerItemDesc}>{desc}</Text>
                </View>
            </View>
        )
    }

    renderCarSection(row) {
        var detail = null;
        if (row.car.tip && row.car.tip.length > 0) {
            detail = (
                <View style={styles.horizontalContainer}>
                    <Text style={styles.carCellDetail} numberOfLines={0}>
                        {row.car.tip}
                    </Text>
                </View>
            );
        }
        var logo = row.car.brandlogo  && row.car.brandlogo.length > 0 ? {uri: row.car.brandlogo} : undefined
        var showGroup = row.car.extendinfo && row.car.extendinfo.length > 0
        return (
            <View style={styles.verticalContainer}>
                <TouchableOpacity onPress={() => {this.onCarCellPress(row.car)}}>
                    <View>
                        <View style={[styles.horizontalContainer, {marginTop: 19, marginBottom: 12}]}>
                            <Image source={logo}
                                   defaultSource={UI.Img.DefaultMutInsCarBrand}
                                   style={styles.carCellImage}/>
                            <Text style={styles.carCellTitle}>{row.car.licensenum}</Text>
                        </View>
                        {detail}
                        {this.renderCarButton(row.car)}
                        <View style={styles.carCellTipContainer}>
                            <Image source={{url: 'mins_tip_bg1'}}
                                   capInsets={{top: 0, left: 13, bottom: 0, right: 0}}
                                   style={styles.carCellTipBg}/>
                            <Text style={styles.carCellTipTitle}>{row.car.statusdesc}</Text>
                        </View>
                    </View>
                </TouchableOpacity>
                <View style={styles.line2}/>
                {showGroup ? this.renderGroupInfoCell(row) : this.renderCouponCell(row)}
                <View style={styles.emptyCell}/>
            </View>
        );
    }

    configInfoForCarButton(car) {
        var callback = undefined
        var title = undefined
        if (car.status == 20) { // 审核失败
            callback = this.uploadInfo.bind(this)
            title = '重新上传资料'
        }
        else if (car.status == 5) { // 待支付
            callback = this.onPayButtonPress.bind(this)
            title = '前去支付'
        }
        else if (car.status == 1 || car.status == 2) { // 待完善资料
            callback = this.uploadInfo.bind(this)
            title = '完善资料'
        }
        return {callback: callback, title: title}
    }

    renderCarButton(car) {
        var {callback, title} = this.configInfoForCarButton(car)
        return callback && (
            <TouchableOpacity style={styles.carCellButton}
                              onPress={() => {callback(car)}}>
                <Image style={UI.Style.BgImg}
                       source={{uri: 'btn_bg_green'}}
                       capInsets={{top: 5, left: 5, bottom: 5, right: 5}} />
                <Text style={styles.carCellButtonTitle}>{title}</Text>
            </TouchableOpacity>
        )
    }

    renderCouponCell(row) {
        var coupons = row.car ? row.car.couponlist : row.couponlist;
        var items = [];
        // 保障
        if (coupons && coupons.insurancelist && coupons.insurancelist.length > 0) {
            items.push(this.renderCouponCellTitle({uri: 'mins_ensure'}, '保障', 0));
            items.push(this.renderCouponCellDoubleItems(coupons.insurancelist, 1));
        }
        // 福利
        if (coupons && coupons.couponlist && coupons.couponlist.length > 0) {
            items.push(this.renderCouponCellTitle({uri: 'mins_ensure'}, '福利', 2));
            items.push(this.renderCouponCellDoubleItems(coupons.couponlist, 3));
        }
        // 活动
        if (coupons && coupons.activitylist && coupons.activitylist.length > 0) {
            items.push(this.renderCouponCellTitle({uri: 'mins_ensure'}, '活动', 4));
            items.push(this.renderCouponCellSingleItems(coupons.activitylist, 5));
        }

        return (
            <TouchableOpacity onPress={() => {this.onCouponCellPress(row.car)}}>
                <View style={styles.verticalContainer}>
                    <View style={[styles.horizontalContainer, {height: 34}]}>
                        <View style={styles.line3}/>
                        <Text style={styles.couponCellTip}>加入互助后既享</Text>
                        <View style={styles.line3}/>
                    </View>
                    {items}
                    <View style={{marginBottom: 10}}/>
                </View>
            </TouchableOpacity>
        )
    }

    renderCouponCellTitle(icon, title, key) {
        return (
            <View key={key} style={styles.couponCellTitleContainer}>
                <View style={styles.horizontalContainer}>
                    <Image source={icon} style={styles.couponCellTitleIcon}/>
                    <Text style={styles.couponCellTitileText}>{title}</Text>
                </View>
            </View>
        );
    }

    renderCouponCellItem(item, style, key) {
        return (
            <View key={key} style={[styles.couponCellItemContainer, style]}>
                <Image source={{uri: 'mins_hook'}} style={styles.couponCellItemIcon}/>
                <Text numberOfLines={1}  style={styles.couponCellItemText}>{item}</Text>
            </View>
        )
    }

    renderCouponCellDoubleItems(items, key) {
        var contents = [];
        for (var i = 0; i < Math.ceil(items.length/2); i++) {
            var index = 2 * i;
             contents.push(
                 <View key={i} style={styles.horizontalContainer}>
                     {this.renderCouponCellItem(items[index])}
                     {
                         index + 1 < items.length &&
                         this.renderCouponCellItem(items[index + 1], {marginLeft: 0, marginRight: 14})
                     }
                 </View>
             );
        }
        return (
            <View key={key} style={styles.verticalContainer}>
                {contents}
            </View>
        )
    }

    renderCouponCellSingleItems(items, key) {
        var contents = [];
        for (var i = 0; i < items.length; i++) {
            contents.push(this.renderCouponCellItem(items[i], {marginRight: 14}, i));
        }

        return (
            <View key={key} style={styles.verticalContainer}>
                {contents}
            </View>
        )
    }

    renderGroupInfoCell(row) {
        return (
            <TouchableOpacity style={styles.groupCell}
                              onPress={()=> {this.gotoGroupDetail(row.car)}}>
                <View style={[styles.groupCellHContainer, {marginBottom: 5}]}>
                    <Text style={styles.groupCellGroupName}>{row.car.groupname}</Text>
                    <Text style={styles.groupCellMemberCount}>
                        {row.car.numbercnt}
                        <Text style={styles.groupCellMemberSuffix}>人</Text>
                    </Text>
                </View>
                {row.car.extendinfo.map(x => {
                    var tuple = Object.entries(x)[0]
                    return (
                        <View style={[styles.groupCellHContainer, {marginTop: 9}]} key={tuple[0]}>
                            <Text style={styles.groupCellTimeLeft}>{tuple[0]}</Text>
                            <Text style={styles.groupCellTimeRight}>{tuple[1]}</Text>
                        </View>
                    )
                })}
            </TouchableOpacity>
        )
    }
}

const styles = StyleSheet.create({
    container: {flex: 1},
    bg: {flex: 1, backgroundColor: UI.Color.Background},
    line: {backgroundColor: UI.Color.Line, height: 0.5},
    line2: {backgroundColor: UI.Color.Line, height: 0.5, marginLeft:17},
    line3: {backgroundColor: UI.Color.DarkText, height: 1, width: 23, marginHorizontal: 5},
    line4: {backgroundColor: UI.Color.Line, height: 0.5, marginHorizontal: 15},
    lineV: {backgroundColor: UI.Color.Line,  width: 0.5, marginVertical: 9},

    bottomContainer: {height: 60, backgroundColor: 'white'},
    bottomContent: {flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-around'},
    bottomButton: {flex: 1, height: 50, marginHorizontal: 17, borderRadius: 5, justifyContent: 'center'},
    bottomLeftButton: {backgroundColor: UI.Color.Orange, marginRight: 0},
    bottomRightButton: {backgroundColor: UI.Color.DefaultTint},
    bottomButtonText: {fontSize: 18, color: 'white', textAlign: 'center', alignSelf: 'center'},

    headerItemsHContainer: {...UI.Style.HContainer, height: 86, marginHorizontal: 6},
    headerItemContainer: {flex: 1, flexDirection: 'row', alignItems: 'center'},
    headerItemImage: {marginLeft: 24, marginRight: 10},
    headerItemTitle: {fontSize: 15, color: UI.Color.Orange},
    headerItemDesc: {fontSize: 14, color: UI.Color.GrayText, marginTop: 8},
    arrow: {marginRight: 14},
    allGroupsButton: {...UI.Style.Btn, height: 44,},
    allGroupsButtonTitle: {fontSize: 16, color: UI.Color.DarkText, marginRight: 3},
    sectionCell: {
        backgroundColor: UI.Color.Background, flexDirection: 'row', alignItems: 'center',
        height: 36, justifyContent: 'space-between'
    },
    sectionCellText: {fontSize: 14, color:UI.Color.GrayText, marginLeft: 17},

    horizontalContainer: {backgroundColor: 'white', flexDirection: 'row', alignItems: 'center',
        justifyContent: 'center'},
    verticalContainer: {backgroundColor: 'white', flexDirection: 'column'},

    emptyCell: {height: 10, backgroundColor: UI.Color.Background},

    carCellImage: {width: 40, height: 40, marginLeft: 17},
    carCellTitle: {marginLeft: 10, flex: 1},
    carCellTipContainer: {height: 23, position: 'absolute', right: 0, top: 7, justifyContent: 'center'},
    carCellTipBg: {position: 'absolute', top: 0, left: 0, bottom: 0, right: 0, resizeMode: 'stretch'},
    carCellTipTitle: { color: UI.Color.Orange, marginLeft: 23, marginRight: 14},
    carCellDetail: {marginHorizontal: 17, marginBottom: 14, color: UI.Color.GrayText, fontSize: 13},
    carCellButton: {...UI.Style.Btn, marginHorizontal: 18, height: 50, marginBottom: 14},
    carCellButtonTitle: {fontSize: 17, color: 'white'},

    couponCellTip: {color: UI.Color.DarkText, fontSize: 15},
    couponCellTitleContainer: {backgroundColor: 'white', flexDirection: 'row', alignItems: 'center',
        justifyContent: 'flex-start', marginBottom: 8},
    couponCellTitleIcon: {width: 13, height: 13, marginLeft: 17, marginRight: 8},
    couponCellTitileText: {fontSize: 14, color: UI.Color.DarkText},
    couponCellItemContainer: {flexDirection: 'row', alignItems: 'center', flex: 1, marginBottom: 8,
        backgroundColor: 'white', marginLeft: 38},
    couponCellItemIcon: {width: 12, height: 12, marginRight: 5},
    couponCellItemText: {fontSize: 13, color: UI.Color.GrayText, flex:1},

    groupCell: {paddingTop: 18, paddingBottom: 18},
    groupCellHContainer: {
        flexDirection: 'row', justifyContent: 'space-between', marginHorizontal: 17, alignItems: 'flex-end'},
    groupCellGroupName: {fontSize: 15, color: UI.Color.DarkText, paddingBottom: 3},
    groupCellMemberCount: {fontSize: 24, color: UI.Color.Orange},
    groupCellMemberSuffix: {fontSize: 15},
    groupCellTimeLeft: {fontSize: 13, color: UI.Color.GrayText, textAlign: 'left'},
    groupCellTimeRight: {fontSize: 13, color: UI.Color.DarkText, textAlign: 'right'},
});