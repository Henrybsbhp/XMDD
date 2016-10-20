"use strict";
import React, {Component, PropTypes} from 'react';
import {
    Text, View, Image, StyleSheet, TouchableOpacity
} from 'react-native';
import ModalView from '../ModalView';
import UI from '../../../constant/UIConstants';

export default class ImageAlert extends ModalView {
    static propTypes = {
        image: PropTypes.object,
        title: PropTypes.string,
        message: PropTypes.string,
    }

    static defaultProps = {
        image: {uri: 'mins_bulb'},
    }

    render() {
        return (
            <ModalView {...this.props}
                       bgAnimation="fade"
                       bgStyle={{backgroundColor: "rgba(0,0,0,0.5)"}}
                       bgPressToClose={false}
                       fgOpenAnimation="scale"
                       fgCloseAnimation="scale"
                       aboveStatusBar={true}
                       style={styles.modal}>
                <View style={styles.content}>
                    <Image source={this.props.image} style={styles.image} />
                    <View style={styles.middleContainer}>
                    {this.props.title && (<Text style={styles.title}>{this.props.title}</Text>)}
                    {this.props.message && (<Text style={styles.message}>{this.props.message}</Text>)}
                    </View>
                    <View style={styles.HLine}/>
                    {this.renderBottom()}
                </View>
            </ModalView>
        );
    }

    renderBottom() {
        var buttons = []
        for (var i in this.props.children) {
            var b = this.props.children[i]
            buttons.push(
                <View style={styles.buttonContainer} key={'button'+i}>
                    {i > 0 && <View style={styles.VLine}/>}
                    {b}
                </View>
            )
         }
        return (
            <View style={styles.bottomContainer}>
                {buttons}
            </View>
        )
    }
}

export class AlertButton extends Component {

    static propTypes = {
        title: PropTypes.string,
        color: PropTypes.string,
        onPress: PropTypes.func,
    }

    static defaultProps = {
        color: UI.Color.GrayText,
    }

    render() {
        return (
            <TouchableOpacity onPress={this.props.onPress} style={styles.button}>
                <Text style={[styles.buttonTitle, {color: this.props.color}]}>{this.props.title}</Text>
            </TouchableOpacity>
        );
    }
}

const styles = StyleSheet.create({
    modal: {flex: 1, alignItems: 'center', justifyContent: 'center'},

    content: {width: 280, backgroundColor: 'white', borderRadius: 3},
    image: {height: 100, width: 280},

    middleContainer: {paddingHorizontal: 25, paddingVertical: 35},
    title: {fontSize: 16, color: UI.Color.DarkText, marginBottom: 14, textAlign: 'center'},
    message: {fontSize: 14, color: UI.Color.GrayText, textAlign: 'center'},

    bottomContainer: {height: 49, flexDirection: 'row'},
    buttonContainer: {flex: 1, flexDirection: 'row'},
    button: {flex: 1, justifyContent: 'center', alignItems: 'center'},
    buttonTitle: {fontSize: 16},

    VLine: {width: 0.5, backgroundColor: UI.Color.Line, left: -1},
    HLine: {height: 0.5, backgroundColor: UI.Color.Line},
});