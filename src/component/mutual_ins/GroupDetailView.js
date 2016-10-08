"use strict";
import React, {Component} from 'react';
import {View, StyleSheet} from 'react-native';
import SegmentView from '../general/SegmentView';
import UI from '../../constant/UIConstants';
import FundView from './GroupDetailFundView';
import MemberView from './GroupDetailMembersView';
import MessageView from './GroupDetailMessagesView';
import MeView from './GroupDetailMeView';
import Store, {Actions, Domains} from '../../store/MutualInsStore';
import MyUserStore from '../../store/MyUserStore';
import BlankView from '../general/BlankView';


export default class MutualInsGroupDetailView extends Component {
    constructor(props) {
        super(props);
        var titles = ['互助金', '成员', '动态']
        if (MyUserStore.isLogin) {
            titles.splice(0, 0, '我的')
        }
        this.state = {
            group: Store.getOrCreateDetailGroup(props.route.groupID),
            titles: titles,
            segmentIndex: 0,
        };
    }

    componentDidMount() {
        this.unsubscribe = Store.listen(this.onStoreChanged.bind(this))
        Actions.fetchGroupBase(this.props.route.groupID, this.props.route.memberID)
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
            </BlankView>
        );
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
}

const styles = StyleSheet.create({
    container: {flex: 1, flexDirection: 'column', backgroundColor: UI.Color.Background},
});