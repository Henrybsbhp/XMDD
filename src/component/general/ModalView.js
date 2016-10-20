"use strict";
import React, {Component, PropTypes} from 'react';
import {View, TouchableWithoutFeedback, StyleSheet, Animated, Easing} from 'react-native';
import UI from '../../constant/UIConstants';
import Overlay from '../../../lib/react-native-overlay/Overlay.ios';

var globalID = 1

export default class ModalView extends Component {
    static propTypes = {
        isOpen: PropTypes.bool,
        bgPressToClose: PropTypes.bool,
        willOpen: PropTypes.func,
        willClose: PropTypes.func,
        onClosed: PropTypes.func,
        onOpened: PropTypes.func,
        bgAnimation: PropTypes.oneOf(['none', 'fade']),
        fgOpenAnimation: PropTypes.oneOf(['none', 'fade', 'scale']),
        fgCloseAnimation: PropTypes.oneOf(['none', 'fade', 'scale']),
        aboveStatusBar: PropTypes.bool,
        bgStyle: PropTypes.object,
        fgStyle: PropTypes.object,
    }

    static defaultProps = {
        isOpen: false,
        bgPressToClose: true,
        bgAnimation: 'none',
        fgOpenAnimation: 'fade',
        fgCloseAnimation: 'fade',
        aboveStatusBar: false,
    }

    constructor(props) {
        super(props);
        this.state = {
            isOpen: false, visible: false, bgFade: new Animated.Value(0), fgFade: new Animated.Value(0),
            fgScale: new Animated.Value(0),
        };
    }

    componentWillReceiveProps(props) {
        if (this.state.isOpen == props.isOpen) {
            return;
        }
        if (props.isOpen) {
            this.open();
        }
        else {
            this.close();
        }
    }

    //// Action
    createOpenAnimations() {
        var anims = []

        // 背景透明度动画
        if (this.props.bgAnimation == 'fade') {
            this.state.bgFade.setValue(0)
            anims.push(Animated.timing(
                this.state.bgFade,
                {toValue: 1, duration: 100, easing: Easing.inOut(Easing.quad)}
            ))
        } else {
            this.state.bgFade　= new Animated.Value(1)
        }

        // 前景透明度动画
        if (this.props.fgOpenAnimation == 'fade') {
            this.state.fgFade.setValue(0)
            anims.push(Animated.timing(
                this.state.fgFade,
                {toValue: 1, duration: 150, easing: Easing.out(Easing.quad)}
            ))
        } else {
            this.state.fgFade = new Animated.Value(1)
        }

        // 前景缩放动画
        if (this.props.fgOpenAnimation == 'scale') {
            this.state.fgScale.setValue(0.7)
            anims.push(Animated.spring(
                this.state.fgScale,
                {toValue: 1, tension: 65}
            ))
        } else {
            this.state.fgScale = new Animated.Value(1)
        }
        return anims
    }

    open() {
        this.state.visible = true;
        this.state.isOpen = true;
        var anims = this.createOpenAnimations()
        this.setState(this.state)
        if (anims.length > 0) {
            Animated.parallel(anims).start(() => {
                this.props.onOpened && this.props.onOpened(this)
            })
        }
        else {
            this.props.onOpened && this.props.onOpened(this)
        }
    }

    createCloseAnimations() {
        var anims = []
        // 背景透明度动画
        if (this.props.bgAnimation == 'fade') {
            anims.push(Animated.timing(
                this.state.bgFade,
                {toValue: 0, duration: 100, easing: Easing.inOut(Easing.quad)}
            ))
        }

        // 前景透明度动画
        if (this.props.fgCloseAnimation == 'fade') {
            anims.push(Animated.timing(
                this.state.fgFade,
                {toValue: 0, duration: 100, easing: Easing.inOut(Easing.quad)}
            ))
        }

        // 前景缩放动画
        if (this.props.fgOpenAnimation == 'scale') {
            anims.push(Animated.spring(
                this.state.fgScale,
                {toValue: 0.5, tension: 65}
            ))
            anims.push(Animated.timing(
                this.state.fgFade,
                {toValue: 0, duration: 120, easing: Easing.in(Easing.quad)}
            ))
        }
        return anims
    }

    close() {
        var anims = this.createCloseAnimations()
        this.state.isOpen = false;
        if (anims.length > 0) {
            Animated.parallel(anims).start(() => {
                this.setState({visible: false})
                this.props.onClosed && this.props.onClosed(this)
            })
        }
        else {
            this.setState({visible: false})
            this.props.onClosed && this.props.onClosed(this)
        }
    }

    //// Callback
    onBgPress() {
        if (this.props.bgPressToClose) {
            this.close()
        }
    }

    render() {
        var bgStyle = [this.props.bgStyle, {opacity: this.state.bgFade}]
        var fgStyle = [this.props.fgStyle, {opacity: this.state.fgFade, transform: [{scale: this.state.fgScale}]}]
        return (
            <Overlay isVisible={this.state.visible} aboveStatusBar={this.props.aboveStatusBar}>
                <View style={[styles.container, this.props.style]}>
                    <TouchableWithoutFeedback
                        style={styles.background}
                        onPress={this.onBgPress.bind(this)}>
                        <Animated.View style={[styles.background, bgStyle]} />
                    </TouchableWithoutFeedback>
                    <Animated.View style={fgStyle}>
                        {this.renderChildren()}
                    </Animated.View>
                </View>
            </Overlay>
        );
    }

    renderChildren() {
        return this.props.children
    }
}

const styles = StyleSheet.create({
    container: {flex: 1},
    background: {position: 'absolute', left: 0, right: 0, top: 0, bottom: 0},
});