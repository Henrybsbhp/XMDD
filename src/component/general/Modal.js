"use strict";
import React, {Component, PropTypes} from 'react';
import {View, TouchableWithoutFeedback, StyleSheet, Animated} from 'react-native';

var globalID = 1

export default class Modal extends Component {
    static propTypes = {
        isOpen: PropTypes.bool,
        backgroundPressToClose: PropTypes.bool,
        onClosed: PropTypes.func,
        onOpened: PropTypes.func,
    }

    static defaultProps = {
        isOpen: false,
        backgroundPressToClose: true,
    }

    constructor(props) {
        super(props);
        this.id = globalID++;
        this.state = {isOpen: false, visible: false, fadeAnim: new Animated.Value(0)};
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
    open() {
        this.setState({visible: true, isOpen: true});
        Animated.timing(
            this.state.fadeAnim,
            {toValue: 1, duration: 150},
        ).start(() => {
            this.props.onOpened && this.props.onOpened()
        });
    }

    close() {
        this.state.isOpen = false;
        Animated.timing(
            this.state.fadeAnim,
            {toValue: 0, duration: 150},
        ).start(() => {
            this.setState({visible: false})
            this.props.onClosed && this.props.onClosed()
        });

    }

    //// Callback
    onBackgroundPress() {
        if (this.props.backgroundPressToClose) {
            this.close()
        }
    }

    render() {
        if (!this.state.visible) {
            return null;
        }
        return (
            <View style={styles.modal}>
                <TouchableWithoutFeedback
                    onPress={this.onBackgroundPress.bind(this)}>
                    <View style={styles.background}></View>
                </TouchableWithoutFeedback>
                <Animated.View style={{opacity: this.state.fadeAnim}}>
                    {this.props.children}
                </Animated.View>
            </View>
        );
    }
}

const styles = StyleSheet.create({
    modal: {position: 'absolute', left: 0, right: 0, top: 0, bottom: 0},
    background: {position: 'absolute', left: 0, right: 0, top: 0, bottom: 0},
});