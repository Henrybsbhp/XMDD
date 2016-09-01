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
import BlankView from '../../general/BlankView';
import ADView from '../../general/ADView';
import UI from '../../../constant/UIConstants';
import {NavBarRightItem} from '../../general/NavigatorView';
import RefreshControl from '../../general/refresh/RefreshControl';
import MutualInsStore from '../../../model/mutual_ins/MutualInsStore';

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
        }
    }

    componentWillMount() {
        this.setState({loading: true});
        this.store.fetchMyGroups()
            .then(this.reloadDatasource.bind(this))
            .catch(e=>{this.setState({loading: false})});
    }

    // 设置导航条
    setupNavigator(props) {
        props.route.rightItem = {
            component: NavBarRightItem,
            image: {uri: 'mins_menu', width: 25, height: 25},
            onPress: this.showOrHideMenu.bind(this),
        }
    }

    /// Actions
    showOrHideMenu() {

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
                       loading={this.state.loading}>
                <RefreshControl.ListView
                    onRefresh={this._onRefresh.bind(this)}
                    style={styles.bg}
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
            </BlankView>
        );
    }

    _onRefresh(endRefresh) {
        console.log('onRefreshing');
        setTimeout(()=>{
            endRefresh();
            this.setState({forceRerend: !this.state.forceRerend});
        }, 0.05)
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
        return (
            <View>
                <View style={styles.horizontalContainer}>
                    <Image source={{uri: row.car.brandlogo}}
                           defaultSource={UI.Img.DefaultMutInsCarBrand}
                           style={styles.carCellImage}/>
                    <Text style={styles.carCellTitle}>{row.car.licensenum}</Text>
                </View>
            </View>
        );
    }

    renderCouponCell(row) {
        return (
            <View>
                <Text>empty!</Text>
            </View>
        )
    }
}

const styles = StyleSheet.create({
    container: {flex: 1},
    bg: {flex: 1, backgroundColor: UI.Color.Background},
    ad: {height: Math.ceil(UI.Win.Width/4.15), flex:1},
    line: {backgroundColor: UI.Color.Line, height: 1},

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

    horizontalContainer: {backgroundColor: 'white', flexDirection: 'row', alignItems: 'center'},
    verticalContainer: {backgroundColor: 'white', flexDirection: 'column'},
    carCellImage: {width: 40, height: 40},
    carCellTitle: {marginLeft: 10, flex: 1}
});