"use strict";
import React, {Component} from 'react';
import {View, StyleSheet, ART} from 'react-native';
import SegmentView from '../general/SegmentView';
import UI from '../../constant/UIConstants';
import Art from '../general/shaps/Arc';

const CircleLength = 110;

export default class GroupDetailFundView extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <View style={styles.container}>
                {this.renderProgress()}
            </View>
        )
    }

    renderProgress() {
        return (
            <View style={styles.progressContainer}>
            <ART.Surface width={2*CircleLength} height={2*CircleLength}>
                <Art
                    radius={CircleLength - 0.5}
                    stroke={UI.Color.Background}
                    strokeWidth={3}
                    offset={{top: 0.5, left: 0.5}}
                    startAngle={0}
                    endAngle={2 * Math.PI}
                />
                <Art
                    radius={CircleLength}
                    stroke={UI.Color.DefaultTint}
                    strokeWidth={4}
                    offset={{top: 0, left: 0}}
                    startAngle={0}
                    endAngle={Math.PI}
                />
            </ART.Surface>
                </View>
        )
    }
}

const styles = StyleSheet.create({
    container: {backgroundColor: 'white', marginTop: 8},
    progressContainer: {
        width: 2 * CircleLength, height: 2 * CircleLength, alignSelf: 'center', marginTop: 20, marginBottom: 15
    },
})