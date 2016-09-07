import React, {Component} from 'react';
import {
    View,
    Text,
    Image,
    TextInput,
    StyleSheet,
    ListView,
    TouchableOpacity,
} from 'react-native';
import Modal from 'react-native-modalbox';
import Toast from 'react-native-root-toast';
import BlankView from '../../general/BlankView';
import ADView from '../../general/ADView';
import UI from '../../../constant/UIConstants';
import {NavBarRightItem} from '../../general/NavigatorView';
import RefreshControl from '../../general/refresh/RefreshControl';
import MutualInsStore from '../../../model/mutual_ins/MutualInsStore';
import PopoverMenu from './PopoverMenu';

export default class MutualInsView extends Component {
    constructor(props) {
        super(props);
        // 设置导航条
        this.setupNavigator(props);

        // 设置store
        this.store = new MutualInsStore();

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
            menuVisible: false
        }
    }

    componentWillMount() {
        this._onRefresh();
        this.menu = this.props.createModal(this._renderMenu());
    }

    // 设置导航条
    setupNavigator(props) {
        props.route.rightItem = {
            component: NavBarRightItem,
            image: {uri: 'mins_menu', width: 25, height: 25},
            onPress: this.showMenu.bind(this),
        }
    }

    /// Actions
    showMenu() {
        this.menu.open();
        // this.setState({menuVisible: true})
    }

    /// Reload
    reloadDatasource(rsp) {
        var dataBlob = [{render: this.renderHeaderSection.bind(this)}];
        if (rsp.carlist.length > 0) {
            for (var car of rsp.carlist) {
                dataBlob.push({render: this.renderCarSection.bind(this), car: car})
            }
        }
        else {
            dataBlob.push({render: this.renderCouponCell.bind(this)})
        }

        this.setState({loading: false, loadedOnce: true, dataSource: this.ds.cloneWithRows(dataBlob)});
    }

    /// render
    render() {
        return (
            <BlankView style={styles.container}
                       visible={!this.state.loadedOnce}
                       text="获取信息失败, 点击重试"
                       onPress={this._onRefresh.bind(this)}
                       loading={this.state.loading}>
                <RefreshControl.ListView
                    onRefresh={this._onRefresh.bind(this)}
                    style={styles.bg}
                    refreshing={this.state.loading}
                    dataSource={this.state.dataSource}
                    renderRow={(row, sid, rid) => row.render(row, sid, rid)}
                />
                <View style={styles.bottomContainer}>
                    <View style={styles.line}/>
                    <View style={styles.bottomContent}>
                        <TouchableOpacity style={[styles.bottomButton, styles.bottomLeftButton]}>
                            <Text style={styles.bottomButtonText}>我要陪</Text>
                        </TouchableOpacity>
                        <TouchableOpacity style={[styles.bottomButton, styles.bottomRightButton]}>
                            <Text style={styles.bottomButtonText}>加入互助</Text>
                        </TouchableOpacity>
                    </View>
                </View>
                <PopoverMenu visible={this.state.menuVisible} onDismiss={this._onMenuDismiss.bind(this)}>
                    {this.store.myGroups && this.store.myGroups.showplanbtn &&
                        <PopoverMenu.MenuCell image={{uri: 'mins_person', width: 18, height: 16}} text="内测计划"/>}
                    {this.store.myGroups && this.store.myGroups.showregistbtn &&
                        <PopoverMenu.MenuCell image={{uri: 'mec_edit', width: 16, height: 17}} text="内测登记"/>}
                    <PopoverMenu.MenuCell image={{uri: 'mins_question', width: 19, height: 19}} text="使用帮助"/>
                    <PopoverMenu.MenuCell image={{uri: 'mins_phone', width: 18, height: 17}} text="联系客服"/>
                </PopoverMenu>
            </BlankView>
        );
    }

    _renderMenu() {
        return (
            <Modal style={{flex: 1, backgroundColor: 'red'}}>

            </Modal>
        );
    }

    _onMenuDismiss() {
        this.state.menuVisible = false;
    }

    _onRefresh() {
        this.setState({loading: true});
        this.store.fetchMyGroups()
            .then(this.reloadDatasource.bind(this))
            .catch(e=>{
                if (this.state.loadedOnce) {
                    Toast.show(e.message, {
                        duration: Toast.durations.LONG,
                        position: Toast.positions.CENTER,
                        shadow: false,
                    });
                }
                this.setState({loading: false})});
    }

    /// renderSection
    renderHeaderSection(row) {
        return (
            <View style={{backgroundColor: 'white'}}>
                <ADView
                    style={styles.ad}
                    defaultImage={UI.Img.DefaultADMutIns}
                />
                <View style={styles.line}/>
                <TouchableOpacity onPress={()=>{}}>
                    <View style={styles.calculateCell}>
                        <Image source={{uri: 'mins_calculate'}} style={styles.calculateCellImage}/>
                        <Text style={styles.calculateCellText}>互助费用试算</Text>
                        <Image source={UI.Img.ArrowRight} style={styles.arrow}/>
                    </View>
                </TouchableOpacity>
                <View style={styles.sectionCell}>
                    <Text style={styles.sectionCellText}>我的互助</Text>
                </View>
            </View>
        );
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
        return (
            <View style={styles.verticalContainer}>
                <View style={[styles.horizontalContainer, {marginTop: 19, marginBottom: 12}]}>
                    <Image source={{uri: row.car.brandlogo}}
                           defaultSource={UI.Img.DefaultMutInsCarBrand}
                           style={styles.carCellImage}/>
                    <Text style={styles.carCellTitle}>{row.car.licensenum}</Text>
                </View>
                {detail}
                <View style={styles.carCellTipContainer}>
                    <Image source={{url: 'mins_tip_bg1'}}
                           capInsets={{top: 0, left: 13, bottom: 0, right: 0}}
                           style={styles.carCellTipBg} />
                    <Text style={styles.carCellTipTitle}>{row.car.statusdesc}</Text>
                </View>
                <View style={styles.line2}/>
                {this.renderCouponCell(row)}
                <View style={styles.emptyCell}/>
            </View>
        );
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
            items.push(this.renderCouponCellTitle({uri: 'mins_ensure'}, '保障', 2));
            items.push(this.renderCouponCellDoubleItems(coupons.couponlist, 3));
        }
        // 活动
        if (coupons && coupons.activitylist && coupons.activitylist.length > 0) {
            items.push(this.renderCouponCellTitle({uri: 'mins_ensure'}, '活动', 4));
            items.push(this.renderCouponCellSingleItems(coupons.activitylist, 5));
        }

        return (
            <View style={styles.verticalContainer}>
                <View style={[styles.horizontalContainer, {height: 34}]}>
                    <View style={styles.line3}/>
                    <Text style={styles.couponCellTip}>加入互助后既享</Text>
                    <View style={styles.line3}/>
                </View>
                {items}
                <View style={{marginBottom: 10}}/>
            </View>
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
}

const styles = StyleSheet.create({
    container: {flex: 1},
    bg: {flex: 1, backgroundColor: UI.Color.Background},
    ad: {height: Math.ceil(UI.Win.Width/4.15), flex:1},
    line: {backgroundColor: UI.Color.Line, height: 1},
    line2: {backgroundColor: UI.Color.Line, height: 0.5, marginLeft:17},
    line3: {backgroundColor: UI.Color.DarkText, height: 1, width: 23, marginHorizontal: 5},

    bottomContainer: {height: 60, backgroundColor: 'white'},
    bottomContent: {flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-around'},
    bottomButton: {flex: 1, height: 50, marginHorizontal: 17, borderRadius: 5, justifyContent: 'center'},
    bottomLeftButton: {backgroundColor: UI.Color.Orange, marginRight: 0},
    bottomRightButton: {backgroundColor: UI.Color.DefaultTint},
    bottomButtonText: {fontSize: 18, color: 'white', textAlign: 'center', alignSelf: 'center'},

    arrow: {marginRight: 14},
    calculateCell: {
        height: 48, flexDirection: 'row', backgroundColor: 'white', alignItems: 'center',
        justifyContent: 'space-between'
    },
    calculateCellImage: {width: 16, height: 16, marginLeft: 17},
    calculateCellText: {fontSize: 16, color: UI.Color.DarkText, marginLeft: 10, flex: 1},
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

    couponCellTip: {color: UI.Color.DarkText, fontSize: 15},
    couponCellTitleContainer: {backgroundColor: 'white', flexDirection: 'row', alignItems: 'center',
        justifyContent: 'flex-start', marginBottom: 8},
    couponCellTitleIcon: {width: 13, height: 13, marginLeft: 17, marginRight: 8},
    couponCellTitileText: {fontSize: 14, color: UI.Color.DarkText},
    couponCellItemContainer: {flexDirection: 'row', alignItems: 'center', flex: 1, marginBottom: 8,
        backgroundColor: 'white', marginLeft: 38},
    couponCellItemIcon: {width: 12, height: 12, marginRight: 5},
    couponCellItemText: {fontSize: 13, color: UI.Color.GrayText, flex:1},
});