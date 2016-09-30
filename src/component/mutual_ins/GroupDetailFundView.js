"use strict";
import React, {Component, PropTypes} from 'react';
import {View, StyleSheet, Animated, Easing, Text} from 'react-native';
import UI from '../../constant/UIConstants';
import progress from '../general/progress/CircleGradientProgress';
import BlankView from '../general/BlankView';
import Store, {Actions} from '../../store/MutualInsStore';

const AnimatedProgress = Animated.createAnimatedComponent(progress);
const CircleRadius = 110;

export default class GroupDetailFundView extends Component {
    constructor(props) {
        super(props)
        this.state = {
            fund: props.fund,
            progressValue: new Animated.Value(this.getProgressValue(props.fund)),
        }
    }

    componentDidMount() {
        Actions.fetchGroupFundIfNeeded(this.props.route.groupID)
    }

    componentWillReceiveProps(props) {
        var fund = props.fund
        if (fund && !fund.loading && !fund.error) {
            this.setProgressValue(this.getProgressValue(fund))
        }
    }

    getProgressValue(fund) {
        var progress = 0
        if (fund.usable && fund.progress && fund.progress != NaN) {
            progress = fund.progress
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
        var fund = this.state.fund
        return (
            <BlankView loading={!fund.usable || fund.loading}
                       loadingOffset={-72}
                       visible={Boolean(!fund.usable || fund.loading || fund.error)}
                       text={fund.error}
                       onPress={() => {Actions.fetchGroupFundIfNeeded(this.props.route.groupID, true)}}
            >
                <View style={styles.container}>
                    {this.renderProgress(fund)}
                    {this.renderLabelTuples(fund)}
                    {this.renderTipLabel(fund)}
                </View>
            </BlankView>
        )
    }

    renderProgress(fund) {
        var percent = fund.presentpoolpresent ? fund.presentpoolpresent : '0';
        return (
            <View style={styles.progressContainer}>
                <AnimatedProgress value={this.state.progressValue} radius={CircleRadius}>
                    <Text style={styles.percentText}>
                        {percent}
                        <Text style={styles.percentSuffix}>%</Text>
                    </Text>
                    <Text style={styles.noteLabel}>互助金剩余</Text>
                    <Text numberOfLines={1} style={styles.remainFundText}>
                        {fund.presentpoolamt}
                    </Text>
                    <Text style={styles.totalFundText}>
                        互助金总额:
                        <Text style={styles.totalFundSubText} numberOfLines={0}>
                            {fund.totalpoolamt}
                            </Text>
                    </Text>
                </AnimatedProgress>
            </View>
        )
    }

    renderLabelTuples(fund) {
        var tuples = []
        if (fund.insstarttime && fund.insstarttime.length > 0) {
            tuples.push(['互助开始时间', fund.insstarttime])
        }
        if (fund.insendtime && fund.insendtime.length > 0) {
            tuples.push(['互助结束时间', fund.insendtime])
        }
        if (tuples.length > 0) {
            return tuples.map(tuple => (
                <View key={tuple} style={styles.tupleContainer}>
                    <Text style={styles.tupleLeft}>{tuple[0]}</Text>
                    <Text style={styles.tupleRight}>{tuple[1]}</Text>
                </View>
            ))
        }
        return null
    }

    renderTipLabel(fund) {
        if (fund && fund.tip && fund.tip.length > 0) {
            return <Text style={styles.tipText}>{fund.tip}</Text>
        }
        return null
    }
}

const styles = StyleSheet.create({
    container: {backgroundColor: 'white', marginTop: 8, paddingBottom: 30},
    progressContainer: {
        width: 2 * CircleRadius, height: 2 * CircleRadius, alignSelf: 'center', marginTop: 20, marginBottom: 15
    },
    HContainer: {flexDirection: 'row'},
    VContainer: {flexDirection: 'column'},
    percentText: {fontSize: 24, color: 'rgb(23, 223, 165)', marginTop: 12, left: 6, textAlign:'center'},
    percentSuffix: {fontSize: 16, color: 'rgb(23, 223, 165)'},
    noteLabel: {fontSize: 13, textAlign: 'center', color: UI.Color.GrayText, marginTop: 24},
    remainFundText: {
        fontSize: 33, textAlign: 'center', color: UI.Color.DarkText, marginTop: 8, height: 35,
    },
    totalFundText: {fontSize: 13, color: UI.Color.DarkText, marginTop: 35, textAlign: 'center'},
    totalFundSubText: {color: UI.Color.Orange, fontSize: 14},
    tupleContainer: {
        flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-end', height: 25,
        paddingHorizontal: 16, backgroundColor: 'white',
    },
    tupleLeft: {fontSize: 14, color: UI.Color.GrayText, textAlign:'left'},
    tupleRight: {fontSize: 14, color: UI.Color.DarkText, textAlign:'right'},
    tipText: {textAlign: 'center', marginHorizontal: 16, marginTop: 31, fontSize: 15, color: UI.Color.DarkText},
})