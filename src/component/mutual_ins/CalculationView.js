"use strict";

import React, {Component} from 'react';
import {
    View, StyleSheet, Text, TouchableOpacity, Image, ScrollView, TouchableWithoutFeedback, InteractionManager,
    Animated, Easing
} from 'react-native';
import UI from '../../constant/UIConstants';
import BlankView from '../general/BlankView';
import net from '../../helper/Network';

const TitleWidth = 106

export default class CalculationView extends Component {
    constructor(props) {
        super(props)
        this.state = {
            loading: true, error: null, cars: [], baseInfo: null, index: 0
        }
    }

    componentDidMount() {
        this.reloadData()
    }

    reloadData() {
        this.setState({loading: true})
        net.postApi({
            method: '/user/car/get', security: true
        }).then(rsp => {
            this.state.cars = rsp.cars
            for (var index in rsp.cars) {
                var car = rsp.cars[index]
                if (car.isdefault == 1) {
                    this.state.index = index
                }
            }
            return net.postApi({method: '/cooperation/premium/baseinfo/get', security: false})
        }).then(rsp => {
            this.setState({loading: false, error: null, baseInfo: rsp})
            this.scrollToIndex(this.state.index)
        }).catch(e => {
            this.setState({error: e.message, loading: false})
        })
    }

    scrollToIndex(index) {
        if (this.state.index == index) {
            return
        }
        this.setState({index: index})
        var count = this.state.cars ? this.state.cars.length : 0
        var scrollX = Math.max(0, index * TitleWidth + TitleWidth/2 - UI.Win.Width/2)
        scrollX = Math.min(count * TitleWidth - UI.Win.Width, scrollX)
        this.refs.topBar.scrollTo({x: scrollX})
    }

    render() {
        var cars = this.state.cars ? this.state.cars : []
        return (
            <BlankView style={styles.container}
                       visible={Boolean(this.state.loading || this.state.error)}
                       text={this.state.error}
                       loading={this.state.loading}
                       onPress={this.reloadData.bind(this)}>
                <View style={styles.topBarContainer}>
                    <Image style={styles.topLine} source={{uri: 'cm_greenline'}}/>
                    <ScrollView horizontal={true}
                                ref="topBar"
                                decelerationRate="fast"
                                showsHorizontalScrollIndicator={false}
                                contentContainerStyle={styles.topBar}>
                        {cars.map(this.renderTopBarTitle.bind(this))}
                    </ScrollView>
                </View>
                <ScrollView style={styles.pagesContainer}></ScrollView>
            </BlankView>
        )
    }

    renderTopBarTitle(car, index) {
        return (
            <TouchableWithoutFeedback key={index} onPress={() => {this.scrollToIndex(index)}}>
                <View style={styles.topTitleContainer}>
                    <Text style={this.state.index == index ? styles.topTitleHighlight : styles.topTitle}>
                        {car.licencenumber}
                    </Text>
                    {this.state.index == index && !this.state.topBarAnimating && (
                        <Image style={styles.topArrow} source={{uri: 'mec_greencursor'}}/>
                    )}
                </View>
            </TouchableWithoutFeedback>
        )
    }

    renderTop

    renderScrollPage() {

    }
}

const styles = StyleSheet.create({
    container: {flex: 1, backgroundColor: 'white'},

    topBarContainer: {height: 48},
    topBar: {backgroundColor: 'transparent', alignItems: 'center'},
    topLine: {position: 'absolute', left: 0, right: 0, bottom: 0, height: 0.5},
    topArrow: {width: 16, height: 6, position: 'absolute', bottom: 0, left: (TitleWidth-16)/2},
    topTitleContainer: {...UI.Style.Btn, width: TitleWidth, height: 48},
    topTitle: {fontSize: 15, color: UI.Color.GrayText},
    topTitleHighlight: {fontSize: 19, color: UI.Color.DefaultTint},

    pagesContainer: {flex: 1},
})