"use strict";
import React, {Component} from 'react';
import {View, StyleSheet, TouchableOpacity, Image, Linking, NativeModules} from 'react-native';
import SegmentView from '../general/SegmentView';
import UI from '../../constant/UIConstants';
import Constant from '../../constant/Constants';
import FundView from './GroupDetailFundView';
import MemberView from './GroupDetailMembersView';
import MessageView from './GroupDetailMessagesView';
import MeView from './GroupDetailMeView';
import Store, {Actions, Domains} from '../../store/MutualInsStore';
import MyUserStore from '../../store/MyUserStore';
import BlankView from '../general/BlankView';
import PopoverMenu from '../general/popup/PopoverMenu';
import ImageAlert, {AlertButton} from '../general/popup/ImageAlert';

const NavigationManager = NativeModules.NavigationManager;


export default class MutualInsGroupDetailView extends Component {
    constructor(props) {
        super(props);
        var titles = ['互助金', '成员', '动态']
        if (props.route.shouldLogin && MyUserStore.isLogin) {
            titles.splice(0, 0, '我的')
        }
        this.state = {
            group: Store.getOrCreateDetailGroup(props.route.groupID),
            titles: titles,
            segmentIndex: 0,
            menuOpened: false,
            callAlertOpened: false,
        };
    }

    componentDidMount() {
        this.unsubscribe = Store.listen(this.onStoreChanged.bind(this))
        Actions.fetchGroupBase(this.props.route.groupID, this.props.route.memberID)
        if (this.props.route.shouldLogin) {
            this.props.navigator.replace({
                ...this.props.route,
                component: MutualInsGroupDetailView,
                renderRightItem: this.renderRightItem.bind(this),
            })
        }
    }

    componentWillUnmount() {
        this.unsubscribe()
    }

    //// Action
    onStoreChanged(domain, info) {
        if (Domains.GroupDetail == domain && this.props.route.groupID == info.groupID) {
            this.setState({group: info})
        }
    }

    onUsingHelpPress() {
        this.setState({menuOpened: false})
        NavigationManager.pushViewControllerByUrl(Constant.Link.MutualInsDetailUsingHelp)
    }

    onCallButtonPress() {
        this.setState({menuOpened: false, callAlertOpened: true})
    }

    onMyOrderPress() {
        this.setState({menuOpened: false})
        var baseInfo = this.state.group.base
        NavigationManager.pushViewControllerByUrl(Constant.Link.MutualInsOrder(baseInfo.contractid))
    }

    onInvitePress() {
        this.setState({menuOpened: false})
        NavigationManager.pushViewControllerByUrl(Constant.Link.MutualInsInvite(this.props.route.groupID))
    }

    onClaimPress() {
        this.setState({menuOpened: false})
        NavigationManager.pushViewControllerByUrl(Constant.Link.MutualInsClaims(this.props.route.groupID))
    }

    //// render
    render() {
        var group = this.state.group
        var base = group.base
        var currentTab = this.state.titles[this.state.segmentIndex]
        return (
            <BlankView
                style={styles.container}
                visible={Boolean(base.loading || base.error)}
                text={base.error}
                loading={base.loading}
                onPress={() => {Actions.fetchGroupBase(this.props.route.groupID, this.props.route.memberID)}}
            >
                {this.renderSegmentView()}
                {currentTab === '我的' && <MeView {...this.props} myInfo={group.myInfo}/>}
                {currentTab === '互助金' && <FundView {...this.props} fund={group.fund}/>}
                {currentTab === '成员' && <MemberView {...this.props} members={group.members}/>}
                {currentTab == '动态' && (<MessageView {...this.props} messages={group.messages}/>)}
                {this.renderMenu()}
                {this.renderImageAlert()}
            </BlankView>
        );
    }

    renderRightItem(route) {
        return (
            <View>
                <TouchableOpacity style={{padding: 4}}
                                  onPress={() => {this.setState({menuOpened: true})}}>
                    <Image source={{uri: 'mins_menu', width: 25, height: 25}}/>
                </TouchableOpacity>
            </View>
        )
    }

    renderSegmentView() {
        return (
            <SegmentView
                items={this.state.titles}
                selectedIndex={this.state.segmentIndex}
                onChanged={index => {this.setState({segmentIndex: index})}}
            />
        );
    }

    renderMenu() {
        var base = this.state.group.base
        return (
            <PopoverMenu isOpen={this.state.menuOpened}
                         onClosed={() => {this.state.menuOpened = false}}
            >
                {base.contractid > 0 && (
                    <PopoverMenu.MenuCell image={{uri: 'mins_order', width: 18, height: 18}}
                                          text="我的订单"
                                          onPress={this.onMyOrderPress.bind(this)}/>
                )}
                {base.invitebtnflag == 1 && (
                    <PopoverMenu.MenuCell image={{uri: 'mins_person', width: 18, height: 17}}
                                          text="邀请好友"
                                          onPress={this.onInvitePress.bind(this)}/>
                )}
                <PopoverMenu.MenuCell image={{uri: 'mins_question', width: 19, height: 19}}
                                      text="使用帮助"
                                      onPress={this.onUsingHelpPress.bind(this)}/>
                <PopoverMenu.MenuCell image={{uri: 'mins_phone', width: 18, height: 17}}
                                      text="联系客服"
                                      onPress={this.onCallButtonPress.bind(this)}/>
                {base.claimbtnflag == 1 && (
                    <PopoverMenu.MenuCell image={{uri: 'mins_history', width: 20, height: 20}}
                                          text="补偿记录"
                                          onPress={this.onClaimPress.bind(this)}/>
                )}
            </PopoverMenu>
        );
    }

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
}

const styles = StyleSheet.create({
    container: {flex: 1, flexDirection: 'column', backgroundColor: UI.Color.Background},
});