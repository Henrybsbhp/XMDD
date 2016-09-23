"use strict";
import React, {Component, PropTypes} from 'react';
import {View, StyleSheet, Text} from 'react-native';
import UI from '../../constant/UIConstants';
import BlankView from '../general/BlankView';
import Store, {Actions} from '../../store/MutualInsStore';

export default class GroupDetailMemberView extends Component {
    componentDidMount() {
        Actions.fetchGroupFundIfNeeded(this.props.group.groupID)
    }
}