"use strict";

import React, {Component} from 'react';
import {View, StyleSheet, Text, TouchableOpacity, Image, TouchableWithoutFeedback} from 'react-native';
import Toast from 'react-native-root-toast';
import WebView from '../general/WebView';
import UI from '../../constant/UIConstants';
import net from '../../helper/Network';
import HudView from '../general/HudView';
import ChooseCarView from './ChooseCarView';
import UploadInfoView from './UploadInfoView';


export default class GroupIntroductionView extends Component {
    constructor(props) {
        super(props)
        this.state = {checked: true}
    }

    /// callback
    onAgreementPress() {

    }

    onCheckboxPress() {
        this.setState({checked: !this.state.checked})
    }

    /// actions
    fetchMyMutualInsCars() {
        this.refs.hud.showSpinner()
        net.postApi({
            method: '/cooperation/usercar/list/get',
            security: true,
        }).then(rsp => {
            this.refs.hud.hide()
            var cars = rsp.usercarlist
            var route = null
            if (cars && cars.length > 0) {
                route = {component: ChooseCarView, title: '选择车辆', cars: cars}
            }
            else {
                route = {component: UploadInfoView, title: '完善入团信息'}
            }
            this.props.navigator.push(route);
        }).catch(e => {
            this.refs.hud.hide()
            Toast.show(e.message, {
                duration: Toast.durations.LONG,
                position: Toast.positions.CENTER,
                shadow: false,
            });
        })
    }

    render () {
        var checkbox = this.state.checked ? 'checkbox_selected' : 'checkbox_normal_301'
        return (
            <HudView ref="hud" style={styles.container}>
                <WebView source={{uri: 'http://www.xiaomadada.com/apphtml/requirement.html'}}
                         ref="webView"
                         automaticallyAdjustContentInsets={false}
                         scalesPageToFit={true}
                         navigator={this.props.navigator}
                         style={styles.webView}
                />
                <View style={styles.bottomView}>
                    <View style={styles.line}/>
                    <View style={styles.agreementView}>
                        <TouchableWithoutFeedback onPress={this.onCheckboxPress.bind(this)}>
                            <Image style={styles.checkbox} source={{uri: checkbox, width: 18, height: 18}}/>
                        </TouchableWithoutFeedback>
                        <Text style={styles.agreementText}>我已同意并阅读</Text>
                        <TouchableOpacity onPress={this.onAgreementPress.bind(this)}>
                            <Text style={styles.agreementLink}>《小马互助公约》</Text>
                        </TouchableOpacity>
                    </View>
                    <TouchableOpacity style={styles.nextButton}
                                      disabled={!this.state.checked}
                                      onPress={this.fetchMyMutualInsCars.bind(this)}>
                        <Image style={UI.Style.BgImg}
                               capInsets={{top: 5, left: 5, bottom: 5, right: 5}}
                               source={this.state.checked ? UI.Img.BtnBgGreen : UI.Img.BtnBgGreenDisable}/>
                        <Text style={styles.nextButtonTitle}>下一步</Text>
                    </TouchableOpacity>
                </View>
            </HudView>
        )
    }
}

const styles = StyleSheet.create({
    container: {flex: 1, backgroundColor: 'white', marginTop: 0},
    webView: {flex: 1},
    line: {height: 0.5, backgroundColor: UI.Color.Line},
    bottomView: {height: 90},
    checkbox: {margin: 5},
    nextButton: {...UI.Style.Btn, height: 50, marginHorizontal: 25},
    nextButtonTitle: {fontSize: 17, color: 'white'},
    agreementView: {flexDirection: 'row', justifyContent: 'center', alignItems: 'center', height: 30},
    agreementText: {fontSize: 12, color: UI.Color.GrayText},
    agreementLink: {fontSize: 12, color: UI.Color.Blue},
})

