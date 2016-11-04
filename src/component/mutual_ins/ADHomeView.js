"use strict";

import React, {Component} from 'react';
import {View, StyleSheet, Text, TouchableOpacity, Image, TouchableWithoutFeedback, NativeModules} from 'react-native';
import WebView from '../general/WebView';
import Constant from '../../constant/Constants';
import UI from '../../constant/UIConstants';
import MutualInsView from './MutualInsView';

const NavigationManager = NativeModules.NavigationManager;

export default class ADHomeView extends Component {

    onCalculatePress() {
        NavigationManager.pushViewControllerByUrl(Constant.Link.MutualInsCalculate)
    }

    onEnterPress() {
        var route = {component: MutualInsView, title: '小马互助'}
        this.props.navigator.push(route)
    }

    render() {
        return (
            <View style={styles.container}>
                <WebView source={{uri: Constant.Link.MutualInsADHome}}
                         style={styles.webView}
                         ref="webView"
                         navigator={this.props.navigator}
                         automaticallyAdjustContentInsets={false}
                         scalesPageToFit={true}
                />
                <View style={styles.bottomView}>
                    <View style={styles.line}/>
                    <View style={styles.bottomViewContent}>
                        <TouchableOpacity style={styles.calculateButton}
                                          onPress={this.onCalculatePress.bind(this)}>
                            <Image style={UI.Style.BgImg}
                                   capInsets={{top: 5, left: 5, bottom: 5, right: 5}}
                                   source={UI.Img.BtnBgGreen}/>
                            <Text style={styles.buttonTitle}>费用试算</Text>
                        </TouchableOpacity>
                        <TouchableOpacity style={styles.enterButton}
                                          onPress={this.onEnterPress.bind(this)}>
                            <Image style={UI.Style.BgImg}
                                   capInsets={{top: 5, left: 5, bottom: 5, right: 5}}
                                   source={UI.Img.BtnBgOrange}/>
                            <Text style={styles.buttonTitle}>立即进入</Text>
                        </TouchableOpacity>

                    </View>
                </View>
            </View>
        )
    }
}

const styles = StyleSheet.create({
    container: {flex: 1, backgroundColor: 'white'},
    webView: {flex: 1},
    line: {height: 0.5, backgroundColor: UI.Color.Line},
    bottomView: {height: 61},
    bottomViewContent: {flex: 1, alignItems: 'center', flexDirection: 'row'},
    calculateButton: {...UI.Style.Btn, height: 50, marginLeft: 18, marginRight: 18, flex: 1},
    enterButton: {...UI.Style.Btn, height: 50, marginRight: 18, flex: 1},
    buttonTitle: {fontSize: 17, color: 'white'},
})
