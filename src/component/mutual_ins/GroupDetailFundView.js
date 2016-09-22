"use strict";
import React, {Component, PropTypes} from 'react';
import {View, StyleSheet, Animated, Easing, Text} from 'react-native';
import UI from '../../constant/UIConstants';
import progress from '../general/progress/CircleGradientProgress';
import BlankView from '../general/BlankView';
import Store, {Actions, Domains} from '../../store/MutualInsStore';

const AnimatedProgress = Animated.createAnimatedComponent(progress);
const CircleRadius = 110;

export default class GroupDetailFundView extends Component {
    constructor(props) {
        super(props)
        this.state = {
            progressValue: new Animated.Value(this.getProgressValue(props.group)),
        }
    }

    componentDidMount() {
        Actions.fetchGroupFundIfNeeded(this.props.group.groupID)
    }

    componentWillReceiveProps(props) {
        var group = props.group
        if (!group.fundLoading && !group.fundError) {
            this.setProgressValue(this.getProgressValue(group))
        }

    }

    getProgressValue(group) {
        var progress = 0
        if (group && group.fundUsable && group.fundProgress != NaN) {
            progress = group.fundProgress
        }
        return progress
    }

    setProgressValue(value) {
        Animated.timing(
            this.state.progressValue,
            {toValue: value, duration: 600, easing: Easing.inOut(Easing.quad)},
        ).start(() => {
            this.state.progressValue.setValue(value)
        });
    }

    //// render
    render() {
        var group = this.props.group ? this.props.group : {fundLoading: true}
        return (
            <BlankView loading={!group.fundUsable || group.fundLoading}
                       loadingOffset={-72}
                       visible={!group.fundUsable || group.fundLoading || Boolean(group.fundError)}
                       text={group.fundError}
            >
                <View style={styles.container}>
                {this.renderProgress()}
                </View>
            </BlankView>
        )
    }

    renderProgress() {
        var percent = this.props.group.presentpoolpresent ? this.props.group.presentpoolpresent : '0';
        return (
            <View style={styles.progressContainer}>
                <AnimatedProgress value={this.state.progressValue} radius={CircleRadius}>
                    <View style={styles.percentContainer}>
                        <Text style={styles.percentText}>{percent}
                            <Text style={styles.percentSuffix}>%</Text>
                        </Text>

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
    VContainer: {flexDirection: 'column'},
    percentContainer: {flexDirection: 'row', justifyContent: 'center', alignItems: 'flex-end', backgroundColor: 'red'},
    percentText: {fontSize: 43, marginLeft: 10, marginRight: 10, color: 'rgb(23, 223, 165)', backgroundColor: 'green'},
    percentSuffix: {fontSize: 16, color: 'rgb(23, 223, 165)'},
})