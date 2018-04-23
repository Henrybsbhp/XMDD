"use strict";

import React, {Component} from 'react';
import {
    View, StyleSheet, Text, TouchableOpacity, Image, ScrollView, TouchableWithoutFeedback, InteractionManager,
    Animated, Easing, ListView, TextInput,
} from 'react-native';
import UI from '../../constant/UIConstants';
import BlankView from '../general/BlankView';
import net from '../../helper/Network';
import ImageTips from '../general/popup/ImageTips';
import CalculationResultView from './CalculationResultView';
import Toast from 'react-native-root-toast';
import HudView from '../general/HudView';

const TitleWidth = 106

export default class CalculationView extends Component {
    constructor(props) {
        super(props)
        var ds = new ListView.DataSource({
            rowHasChanged: (r1, r2) => r1 !== r2,
        });

        var data = [this.renderInputRow.bind(this), this.renderServiceRow.bind(this), this.renderCouponCell.bind(this)]

        this.state = {
            loading: true, error: null, cars: [], baseInfo: null, index: 0,
            dataSource: ds.cloneWithRows(data),
            searchString: '',
            callImageTipsOpened: false,
        }
    }

    componentDidMount() {
        this.reloadData()
    }

    reloadData() {
        this.setState({loading: true})
        net.postApi({
            method: '/user/car/get', security: true
        }).then(rsp => {
            this.state.cars = rsp.cars
            for (var index in rsp.cars) {
                var car = rsp.cars[index]
                if (car.isdefault == 1) {
                    this.state.index = index
                }
            }
            return net.postApi({method: '/cooperation/premium/baseinfo/get', security: false})
        }).then(rsp => {
            this.setState({loading: false, error: null, baseInfo: rsp})
            this.scrollToIndex(this.state.index)
        }).catch(e => {
            this.setState({error: e.message, loading: false})
        })
    }

    scrollToIndex(index) {
        if (this.state.index == index) {
            return
        }
        this.setState({index: index})
        var count = this.state.cars ? this.state.cars.length : 0
        var scrollX = Math.max(0, index * TitleWidth + TitleWidth/2 - UI.Win.Width/2)
        scrollX = Math.min(count * TitleWidth - UI.Win.Width, scrollX)
        this.refs.topBar.scrollTo({x: scrollX})
    }

    showToast(msg) {
        Toast.show(msg, {
            duration: Toast.durations.SHORT,
            position: Toast.positions.CENTER,
            shadow: false,
        })
    }

    onSearchTextChanged(text) {
        this.setState({ searchString: text});
        console.log('Search String:', this.state.searchString)
    }

    onQuestionMarkButtonPressed() {
        this.setState({callImageTipsOpened: true})
    }

    onCalculateServicePressed() {
        this.refs.hud.showSpinner()
        net.postApi({
            method: '/cooperation/premium/calculate',
            security: true,
            params: {
                frameno: this.state.searchString,
            },
        }).then(rsp => {
            this.refs.hud.hide()
            var route = {
                component: CalculationResultView,
                title: '试算结果',
                passProps: {
                    brandName: rsp.brandname,
                    carFrameNum: rsp.frameno,
                    premiumPrice: rsp.premiumprice,
                    serviceFee: rsp.servicefee,
                    sharingMoney: rsp.sharemoney,
                    tips: rsp.note,
                },
            }
            this.props.navigator.push(route)

        }).catch(error => {
            this.refs.hud.hide()
            this.showToast('费用试算失败请重试')
        })
    }

    renderImageTips() {
        return (
            <ImageTips imageURL='common_carFrameNo_imageView'
                      isOpen = {this.state.callImageTipsOpened}
                    onClosed = {() => {this.state.callImageTipsOpened = false}}/>
        );
    }

    render() {
        var cars = this.state.cars ? this.state.cars : []
        return (
            <HudView ref="hud">
                <BlankView style={styles.container}
                           visible={Boolean(this.state.loading || this.state.error)}
                           text={this.state.error}
                           loading={this.state.loading}
                           onPress={this.reloadData.bind(this)}>
                    <View style={styles.topBarContainer}>
                        <Image style={styles.topLine} source={{uri: 'cm_greenline'}}/>
                        <ScrollView horizontal={true}
                                    ref="topBar"
                                    decelerationRate="fast"
                                    showsHorizontalScrollIndicator={false}
                                    contentContainerStyle={styles.topBar}>
                            {cars.map(this.renderTopBarTitle.bind(this))}
                        </ScrollView>
                    </View>
                    <View style={styles.listViewContainer}>
                        <ListView backgroundColor='#F7F7F8' dataSource={this.state.dataSource}
                                  renderRow={(rowData, sectionID, rowID) => rowData(rowData, sectionID, rowID)}/>
                    </View>
                    {this.renderImageTips()}
                </BlankView>
            </HudView>
        )
    }

    renderInputRow(rowData, sectionID, rowID) {
        return (
            <View style = {styles.inputContainer}>
                <Text style = {styles.inputTitleText}>车辆识别代号</Text>
                <TouchableWithoutFeedback style = {styles.questionButton}
                                onPress = {() => {this.onQuestionMarkButtonPressed()}}>
                    <Image style = {styles.buttonImage} source = {{uri: 'questionMark_300'}}/>
                </TouchableWithoutFeedback>
                <TextInput style = {styles.searchTextInput}
                           onChangeText = {this.onSearchTextChanged.bind(this)}
                           value = {this.state.text}
                           placeholder = '请输入车辆识别代号'/>
                <Image style = {styles.separator} source = {{uri: 'Horizontaline'}}/>
            </View>
        )
    }

    renderServiceRow(rowData, sectionID, rowID) {
        return (
            <View style = {styles.calContainer}>
                <TouchableOpacity style = {styles.calButton}
                                onPress = {() => {this.onCalculateServicePressed()}}>
                    <Text style = {styles.buttonText}>立即试算</Text>
                </TouchableOpacity>
            </View>
        );
    }

    renderTopBarTitle(car, index) {
        return (
            <TouchableWithoutFeedback key={index} onPress={() => {this.scrollToIndex(index)}}>
                <View style={styles.topTitleContainer}>
                    <Text style={this.state.index == index ? styles.topTitleHighlight : styles.topTitle}>
                        {car.licencenumber}
                    </Text>
                    {this.state.index == index && !this.state.topBarAnimating && (
                        <Image style={styles.topArrow} source={{uri: 'mec_greencursor'}}/>
                    )}
                </View>
            </TouchableWithoutFeedback>
        )
    }

    renderCouponCell(rowData, sectionID, rowID) {
        var coupons = this.state.baseInfo;
        var items = [];
        // 保障
        if (coupons && coupons.insurancelist && coupons.insurancelist.length > 0) {
            items.push(this.renderCouponCellTitle({uri: 'mins_ensure'}, '保障', 0));
            items.push(this.renderCouponCellDoubleItems(coupons.insurancelist, 1));
        }
        // 福利
        if (coupons && coupons.couponlist && coupons.couponlist.length > 0) {
            items.push(this.renderCouponCellTitle({uri: 'mins_benefit'}, '福利', 2));
            items.push(this.renderCouponCellDoubleItems(coupons.couponlist, 3));
        }
        // 活动
        if (coupons && coupons.activitylist && coupons.activitylist.length > 0) {
            items.push(this.renderCouponCellTitle({uri: 'mins_activity'}, '活动', 4));
            items.push(this.renderCouponCellSingleItems(coupons.activitylist, 5));
        }

        return (
            <View style={styles.verticalContainer}>
                <View style = {{backgroundColor: '#F7F7F8', height: 10}}/>
                <View style={[styles.horizontalContainer, {height: 34}]}>
                    <View style={styles.line3}/>
                    <Text style={styles.couponCellTip}>加入互助后即享</Text>
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
    container: {flex: 1, backgroundColor: 'white'},

    topBarContainer: {height: 48},
    topBar: {backgroundColor: 'transparent', alignItems: 'center'},
    topLine: {position: 'absolute', left: 0, right: 0, bottom: 0, height: 0.5},
    topArrow: {width: 16, height: 6, position: 'absolute', bottom: 0, left: (TitleWidth-16)/2},
    topTitleContainer: {...UI.Style.Btn, width: TitleWidth, height: 48},
    topTitle: {fontSize: 15, color: UI.Color.GrayText},
    topTitleHighlight: {fontSize: 19, color: UI.Color.DefaultTint},

    pagesContainer: {flex: 1},

    listViewContainer: {flex: 1, flexDirection: 'row'},
    inputContainer: {flexDirection: 'row', backgroundColor: 'white', justifyContent: 'center', alignItems: 'center',},
    inputTitleText: {fontSize: 15, color:UI.Color.DarkText, marginLeft: 17, marginRight: 10, marginVertical: 17},
    questionButton: {width: 18, height: 18, marginLeft: 10},
    buttonImage: {width: 18, height: 18},
    searchContainer: {flex: 1, alignItems: 'center', backgroundColor: 'red'},
    searchTextInput: {
        fontSize: 15, color:UI.Color.DarkText, textAlign: 'right', paddingRight: 10, flex:1,
    },
    separator: {position: 'absolute', left: 0, right: 0, bottom: 0, height: 0.5,},

    calContainer: {backgroundColor: 'white', justifyContent: 'center', alignItems: 'center',},
    calButton: {height: 48, backgroundColor: UI.Color.DefaultTint, borderRadius: 5, marginHorizontal: 34, marginVertical: 20,
                alignSelf: 'stretch', justifyContent: 'center',},
    buttonText: {fontSize: 18, color: 'white', alignSelf: 'center',},

    horizontalContainer: {backgroundColor: 'white', flexDirection: 'row', alignItems: 'center',
        justifyContent: 'center'},
    verticalContainer: {backgroundColor: 'white', flexDirection: 'column'},
    line3: {backgroundColor: UI.Color.DarkText, height: 1, width: 23, marginHorizontal: 5},
    line4: {backgroundColor: UI.Color.Line, height: 0.5, marginHorizontal: 15},
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