"use strict";
import React, {Component} from 'react';
import {View, StyleSheet} from 'react-native';
import SegmentView from '../general/SegmentView';
import UI from '../../constant/UIConstants';
import FundView from './GroupDetailFundView';
import MemberView from './GroupDetailMembersView';
import Store, {Actions, Domains} from '../../store/MutualInsStore';
import BlankView from '../general/BlankView';

export default class MutualInsGroupDetailView extends Component {
    constructor(props) {
        super(props);
        this.state = {
            group: {},
            items: ['互助金', '成员', '动态'],
            segmentIndex: 0,
            forceRerend: false,
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
        return (
            <BlankView
                style={styles.container}
                visible={group.baseLoading || group.baseError}
                text={group.baseError}
                loading={group.baseLoading}
                onPress={() => Actions.fetchGroupBase(this.props.route.groupID, this.props.route.memberID)}
            >
                {this.renderSegmentView()}
                {this.state.segmentIndex == 0 && (<FundView {...this.props} group={this.state.group}/>)}
                {this.state.segmentIndex == 1 && (<MemberView {...this.props} group={this.state.group}/>)}
            </BlankView>
        );
    }
    renderSegmentView() {
        return (
            <SegmentView
                items={this.state.items}
                selectedIndex={this.state.segmentIndex}
                onChanged={index => {this.setState({segmentIndex: index})}}
            />
        );
    }
}

const styles = StyleSheet.create({
    container: {flex: 1, flexDirection: 'column', backgroundColor: UI.Color.Background},
});