"use strict";
import React, {Component} from 'react';
import {View, StyleSheet} from 'react-native';
import SegmentView from '../general/SegmentView';
import UI from '../../constant/UIConstants';
import FundView from './GroupDetailFundView';

export default class MutualInsGroupDetailView extends Component {
    constructor(props) {
        super(props);
        this.state = {
            items: ['互助金', '成员', '动态'],
            segmentIndex: 0,
        };
    }
    render() {
        return (
            <View style={styles.container}>
                {this.renderSegmentView()}
                {this.state.segmentIndex == 0 && (<FundView />)}
            </View>
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