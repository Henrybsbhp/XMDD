"use strict";
import React, {Component, PropTypes} from 'react';
import {View, ScrollView, Image, StyleSheet, Text, TouchableOpacity, NativeModules} from 'react-native';
import UI from '../../constant/UIConstants';
import Constant from '../../constant/Constants';
import BlankView from '../general/BlankView';
import Store, {Actions} from '../../store/MutualInsStore';
const NavigationManager = NativeModules.NavigationManager;

export default class GroupDetailMeView extends Component {
    constructor(props) {
        super(props)
        this.state = {
            myInfo: props.myInfo,
        }
    }

    componentDidMount() {
        Actions.fetchGroupMyInfoIfNeeded(this.props.route.groupID, this.props.route.memberID)
    }

    componentWillReceiveProps(props) {
        if (props.myInfo) {
            this.setState({myInfo: props.myInfo})
        }
    }

    onBottomButtonPress() {
        switch (this.state.myInfo.status) {
            case 5:
                this.onPaymentButtonPress()
                break
            case 6: case 7: case 8:
                this.onAgreementButtonPress()
                break
        }
    }

    onPaymentButtonPress() {
        var baseInfo = Store.detailGroups[this.props.route.groupID]['base']
        NavigationManager.pushViewControllerByUrl(Constant.Link.MutualInsOrder(baseInfo.contractid))
    }

    onAgreementButtonPress() {
        NavigationManager.pushViewControllerByUrl(this.state.myInfo.contracturl)
    }

    render() {
        var myInfo = this.state.myInfo
        var renderSimple = true
        switch (myInfo.status) {
            case 5: case 6: case 7: case 8:
                renderSimple = false;
        }
        return (
            <BlankView loading={!myInfo.usable || myInfo.loading}
                       loadingOffset={-72}
                       visible={Boolean(!myInfo.usable || myInfo.loading || myInfo.error)}
                       text={myInfo.error}
                       onPress={() => {
                           Actions.fetchGroupMyInfoIfNeeded(this.props.route.groupID, this.props.route.memberID, true)
                       }}>
                <ScrollView style={styles.container}>
                    <View style={styles.content}>
                        {renderSimple ? this.renderSimple(myInfo) : this.renderDetail(myInfo)}
                        {this.renderTip(myInfo.statusdesc)}
                    </View>
                </ScrollView>
            </BlankView>
        )
    }

    renderSimple(m) {
        return (
            <View style={styles.simpleContainer}>
                <View style={styles.simpleHeaderContainer}>
                    <Image source={m.carlogourl ? {uri: m.carlogourl} : undefined}
                           defaultSource={UI.Img.DefaultMutInsCarBrand}
                           style={styles.simpleLogo}/>
                    <Text style={styles.simpleTitle}>{m.licensenumber}</Text>
                </View>
                {m.tip && <Text style={styles.simpleDesc}>{m.tip}</Text>}
                {m.buttonname && m.buttonname.length > 0 && (
                    <TouchableOpacity style={styles.simpleButtonContainer}>
                        <Image style={styles.simpleButtonBackground}
                               capInsets={{top: 5, left: 5, bottom: 5, right: 5}}
                               source={{uri: 'btn_bg_green'}} />
                        <Text style={styles.simpleButtonTitle}>{m.buttonname}</Text>
                    </TouchableOpacity>
                )}
            </View>
        )
    }

    renderDetail(m) {
        return (
            <View>
                <View style={styles.detailContainer}>
                    <View style={styles.detailHeaderContainer}>
                        <Image source={m.carlogourl ? {uri: m.carlogourl} : undefined}
                               defaultSource={UI.Img.DefaultMutInsCarBrand}
                               style={styles.detailLogo}/>
                        <Text style={styles.detailTitle}>{m.licensenumber}</Text>
                    </View>
                    <Text style={styles.detailFee}>{m.fee}</Text>
                    <Text style={styles.detailFeeDesc}>{m.feedesc}</Text>
                    {this.renderFunItems(m)}
                    {this.renderTimeItems(m)}
                    {m.tip && m.tip.length > 0 && (<Text style={styles.detailDesc}>{m.tip}</Text>)}
                </View>
                {m.buttonname && m.buttonname.length > 0 && this.renderBottomButton(m)}
            </View>
        )
    }

    renderFunItems(m) {
        // 生成金额数据
        var items = []
        if (m.status == 5) {
            items.push(this.renderFundItem('互助金', m.sharemoney, true), this.renderFundItem('服务费', m.servicefee))
            if (m.forcefee && m.forcefee.length > 0) {
                items.push(this.renderFundItem('交强险', m.forcefee))
            }
            if (m.shiptaxfee && m.shiptaxfee.length > 0) {
                items.push(this.renderFundItem('车船税', m.shiptaxfee))
            }
        }
        else if (m.status == 6 || m.status == 7 || m.status == 8) {
            items.push(
                this.renderFundItem('补偿次数', `${Number(m.claimcnt ? m.claimcnt : 0)}次`, true),
                this.renderFundItem('补偿金额', m.claimfee),
                this.renderFundItem('补偿均摊', m.helpfee),
            )
        }

        return (
            <View style={styles.fundItemsContainer}>
                {items}
            </View>
        )
    }

    renderFundItem(title, desc, hideLine=false) {
        return (
            <View style={{flexDirection: 'row'}} key={title}>
                {!hideLine && (<View style={styles.fundHalvingLine}/>)}
                <View style={styles.fundItem}>
                    <Text style={styles.fundTitle}>{title}</Text>
                    <Text style={styles.fundDesc}>{desc}</Text>
                </View>
            </View>
        )
    }

    renderTimeItems(m) {
        var times = [['保障开始时间', m.insstarttime], ['保障结束时间', m.insendtime]]
        return (
            <View style={styles.timeItemsContainer}>
                {times.map(x => (
                    <View style={styles.timeItem} key={x[0]}>
                        <Text style={styles.timeTitle}>{x[0]}</Text>
                        <Text style={styles.timeDetail}>{x[1]}</Text>
                    </View>
                ))}
            </View>
        )
    }

    renderBottomButton(m) {
        return (
            <View>
                <View style={styles.line} />
                <TouchableOpacity style={styles.bottomButton} onPress={this.onBottomButtonPress.bind(this)}>
                    <Text style={styles.bottomButtonTitle}>{m.buttonname}</Text>
                </TouchableOpacity>
            </View>
        )
    }

    renderTip(text) {
        return (
            <View style={styles.tipContainer}>
                <Image source={{url: 'mins_tip_bg1'}}
                       capInsets={{top: 0, left: 13, bottom: 0, right: 0}}
                       style={styles.tipBg}/>
                <Text style={styles.tipTitle}>
                    {text}
                </Text>
            </View>
        )
    }
}

const styles = StyleSheet.create({
    container: {flex: 1},
    content: {marginTop: 8, backgroundColor: 'white'},

    tipContainer: {height: 23, position: 'absolute', right: 0, top: 7, justifyContent: 'center'},
    tipBg: {position: 'absolute', top: 0, left: 0, bottom: 0, right: 0, resizeMode: 'stretch'},
    tipTitle: {color: UI.Color.Orange, marginLeft: 23, marginRight: 14, backgroundColor: UI.Color.Clear},

    simpleContainer: {flexDirection: 'column', marginBottom: 12},
    simpleHeaderContainer: {flexDirection: 'row', alignItems: 'center', marginTop: 21},
    simpleLogo: {width: 40, height: 40, marginLeft: 16},
    simpleTitle: {fontSize: 17, color: UI.Color.DarkText, marginLeft: 10, marginRight: 16},
    simpleDesc: {
        marginTop: 12, marginLeft: 16, marginRight: 16, fontSize: 13, color: UI.Color.GrayText,
        alignSelf: 'center'
    },
    simpleButtonContainer: {
        marginTop: 12, marginLeft: 16, marginRight: 16, marginBottom: 7, height: 50, flex: 1,
        justifyContent: 'center', alignItems: 'center',
    },
    simpleButtonTitle: {fontSize: 17, color: 'white', textAlign: 'center', backgroundColor: UI.Color.Clear},
    simpleButtonBackground: {position: 'absolute', left: 0, right: 0, top: 0, bottom: 0, resizeMode: 'stretch'},

    detailContainer: {paddingBottom: 19},
    detailHeaderContainer: {flexDirection: 'row', alignItems: 'center', justifyContent: 'center', marginTop: 21},
    detailLogo: {width: 29, height: 29},
    detailTitle: {marginLeft: 7, fontSize: 13, color: UI.Color.DarkText},

    detailFee: {
        fontSize: 40, textAlign: 'center', color: UI.Color.DarkText, marginLeft: 16, marginRight: 16, marginTop: 18
    },
    detailFeeDesc: {
        fontSize: 13, textAlign: 'center', color: UI.Color.GrayText, marginLeft: 16, marginRight: 16, marginTop: 10
    },

    fundItemsContainer: {flexDirection: 'row', justifyContent: 'center', marginTop: 22, marginBottom: 14},
    fundItem: {
        width: Math.floor(UI.Win.Width / 4), height: 39, flexDirection: 'column', alignItems: 'center',
        justifyContent: 'space-between',
    },
    fundTitle: {fontSize: 13, color: UI.Color.Orange, textAlign: 'center'},
    fundDesc: {fontSize: 13, color: UI.Color.GrayText, textAlign: 'center'},
    fundHalvingLine: {width: 1, backgroundColor: UI.Color.Line, height: 39},

    timeItemsContainer: {marginTop: 4},
    timeItem: {marginLeft: 16, marginRight: 16, justifyContent: 'space-between', marginTop: 8, flexDirection: 'row'},
    timeTitle: {fontSize: 13, color: UI.Color.GrayText},
    timeDetail: {fontSize: 13, color: UI.Color.DarkText, textAlign: 'right'},

    line: {height: 1, backgroundColor: UI.Color.Line},
    bottomButton: {...UI.Style.Btn, height: 50},
    bottomButtonTitle: {fontSize: 17, color: UI.Color.DefaultTint},

    detailDesc: {
        marginTop: 21, marginLeft: 16, marginRight: 16, textAlign: 'center', fontSize: 15, color: UI.Color.DarkText
    },
})