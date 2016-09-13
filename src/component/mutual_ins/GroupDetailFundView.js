"use strict";
import React, {Component} from 'react';
import {View, StyleSheet, ART} from 'react-native';
import SegmentView from '../general/SegmentView';
import UI from '../../constant/UIConstants';


export default class GroupDetailFundView extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <View style={styles.container}>

            </View>
        )
    }
}

const styles = StyleSheet.create({
    container: {backgeoundColor: 'white', flex: 1},
})