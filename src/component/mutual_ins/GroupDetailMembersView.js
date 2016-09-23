"use strict";
import React, {Component, PropTypes} from 'react';
import {View, StyleSheet, Text} from 'react-native';
import UI from '../../constant/UIConstants';
import BlankView from '../general/BlankView';
import Store, {Actions} from '../../store/MutualInsStore';

export default class GroupDetailMemberView extends Component {
    componentDidMount() {
        Actions.fetchGroupMembersIfNeeded(this.props.group.groupID)
    }

    render() {
        var group = this.props.group ? this.props.group : {fundLoading: true}
        var fund = group.fund ? group.fund : {}
        return (
            <BlankView loading={!group.fundUsable || group.fundLoading}
                       loadingOffset={-72}
                       visible={!group.fundUsable || group.fundLoading || Boolean(group.fundError)}
                       text={group.fundError}
            >
                <View style={styles.container}>
                    {this.renderProgress(fund)}
                    {this.renderLabelTuples(fund)}
                    {this.renderTipLabel(fund)}
                </View>
            </BlankView>
        )
    }
}