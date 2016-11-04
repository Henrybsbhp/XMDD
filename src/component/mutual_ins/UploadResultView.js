"use strict";

import React, {Component} from 'react';
import {
    View, StyleSheet, Text, Image, ScrollView,
} from 'react-native';
import UI from '../../constant/UIConstants';
import GroupDetailView from './GroupDetailView';

export default class UploadResultView extends Component {
    componentDidMount() {
        // 设置导航条
        this.props.navigator.replace({
            ...this.props.route,
            component: UploadResultView,
            onBack: this.onBack.bind(this),
        })
    }

    onBack() {
        if (this.props.route.groupID && this.props.route.memberID) { // 到团详情
            var route = {
                component: GroupDetailView,
                groupName: group.groupname,
                groupID: group.groupid,
                shouldLogin: false,
                title: group.groupname
            };
            this.props.navigator.push(route);

        } else  { // 到小马互助首页
            var notify = {name:'GotoMutualInsHomeView', time: new Date().getTime()}
            this.props.navigator.popToHrefInNative('/MutualIns/Home', notify, true)
        }
    }

    render() {
        return (
            <ScrollView style={styles.container}
                        automaticallyAdjustContentInsets={false}
            >
                <View style={styles.content}>
                    <View style={styles.successCell}>
                        <Image source={{uri: 'MutualIns_paySuccessed'}} style={styles.successImage}/>
                        <Text style={styles.successText}>您的申请已提交成功</Text>
                    </View>
                    <Text style={styles.noteText}>我们会尽快审核，审核通过且成功支付后，将获得如下权益</Text>
                    <View style={styles.HLine}/>
                    {this.renderCouponCell(this.props.route.couponList)}
                </View>
            </ScrollView>
        )
    }

    renderCouponCell(coupons) {
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
            <View>
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
    container: {flex: 1, backgroundColor: UI.Color.Background},
    content: {backgroundColor: 'white'},
    HLine: {height: 0.5, marginHorizontal: 17, backgroundColor: UI.Color.Line},
    successCell: {...UI.Style.Btn, height: 86},
    successImage: {width: 19, height: 19, marginRight: 6},
    successText: {fontSize: 17, color: UI.Color.DefaultTint},
    noteText: {fontSize: 13, color: UI.Color.DarkText, marginHorizontal: 17, marginBottom: 12},

    horizontalContainer: {flexDirection: 'row', alignItems: 'center', justifyContent: 'center'},
    couponCellTip: {color: UI.Color.DarkText, fontSize: 15},
    couponCellTitleContainer: {backgroundColor: 'white', flexDirection: 'row', alignItems: 'center',
        justifyContent: 'flex-start', marginBottom: 8},
    couponCellTitleIcon: {width: 13, height: 13, marginLeft: 17, marginRight: 8},
    couponCellTitileText: {fontSize: 14, color: UI.Color.DarkText},
    couponCellItemContainer: {flexDirection: 'row', alignItems: 'center', flex: 1, marginBottom: 8,
        backgroundColor: 'white', marginLeft: 38},
    couponCellItemIcon: {width: 12, height: 12, marginRight: 5},
    couponCellItemText: {fontSize: 13, color: UI.Color.GrayText, flex:1},
})