"use strict";
import React, {Component} from 'react';
import {View, StyleSheet} from 'react-native';
import SegmentView from '../general/SegmentView';
import UI from '../../constant/UIConstants';

export default class MutualInsGroupDetailView extends Component {
    constructor(props) {
        super(props);
    }
    render() {
        return (
            <View style={styles.container}>
                {this.renderSegmentView()}
            </View>
        );
    }
    renderSegmentView() {
        var items = ['互助金', '成员', '动态']
        return (
            <SegmentView
                items={items}
                selectedIndex={0}
            />
        );
    }
}

const styles = StyleSheet.create({
    container: {flex: 1, flexDirection: 'column', backgroundColor: UI.Color.Background},
});