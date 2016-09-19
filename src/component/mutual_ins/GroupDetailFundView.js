"use strict";
import React, {Component, PropTypes} from 'react';
import {View, StyleSheet, Animated, Easing, Text} from 'react-native';
import UI from '../../constant/UIConstants';
import progress from '../general/progress/CircleGradientProgress';

const AnimatedProgress = Animated.createAnimatedComponent(progress);
const CircleRadius = 110;

export default class GroupDetailFundView extends Component {
    constructor(props) {
        super(props)
        this.state = {progressValue: new Animated.Value(0)}
    }

    componentDidMount() {
        this.setProgressValue(0.4);
    }

    setProgressValue(value) {
        Animated.timing(
            this.state.progressValue,
            {toValue: value, duration: 600, easing: Easing.inOut(Easing.quad)},
        ).start();
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
                <AnimatedProgress value={this.state.progressValue} radius={CircleRadius}>
                    <View style={styles.HContainer}>
                        <Text></Text>
                    </View>
                </AnimatedProgress>
            </View>
        )

    }
}

const styles = StyleSheet.create({
    container: {backgroundColor: 'white', marginTop: 8},
    progressContainer: {
        width: 2 * CircleRadius, height: 2 * CircleRadius, alignSelf: 'center', marginTop: 20, marginBottom: 15
    },
    HContainer: {flexDirection: 'row'},
    VContainer: {flexDirection: 'column'}
})