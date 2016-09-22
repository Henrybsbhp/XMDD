"use strict";
import React, {Component, PropTypes} from 'react';
import {Animated, View, Image, StyleSheet, Easing} from 'react-native';

export default class GifLoadingView extends Component {

    static propTypes = {
        loading: PropTypes.bool.isRequired,
        offset: PropTypes.number,
    }

    static defaultProps = {
        loading: false,
        offset: 0,
    }

    constructor(props) {
        super(props)
        this.state = {bgx: new Animated.Value(0), animating: false,}
    }

    componentWillReceiveProps(props) {
        this.resetAnimationIfNeeded(props.loading)
    }

    componentDidMount() {
        this.resetAnimationIfNeeded(this.props.loading)
    }

    componentWillUnmount() {
        this.stopAnimating()
    }

    resetAnimationIfNeeded(loading) {
        if (this.state.animating != loading) {
            if (loading) {
                this.startAnimating()
            }
            else  {
                this.stopAnimating()
            }
        }
    }

    startAnimating() {
        this.state.animating = true
        this.animation = Animated.timing(
            this.state.bgx,
            {toValue: -625, duration: 2600, easing: Easing.linear}
        )
        this.animation.start((finish) => {
            this.state.bgx.setValue(0)
            if (finish && this.state.animating) {
                this.startAnimating()
            }
        })
    }

    stopAnimating() {
        this.state.animating = false
        if (this.animation) {
            this.animation.stop()
        }
    }

    render() {
        var bgTransform = [{translateX: this.state.bgx}, {translateY: this.props.offset}]
        return (
            <View style={[this.props.style, styles.container]}>
                <Animated.View style={[styles.bgContainer, {transform: bgTransform}]}>
                    <Image style={styles.bgImg} source={{uri: 'backgroundImgView'}}/>
                    <Image style={styles.bgImg} source={{uri: 'backgroundImgView'}}/>
                </Animated.View>
            </View>
        )
    }
}

const styles = StyleSheet.create({
    container: {flexDirection:'column', justifyContent: 'center'},
    bgContainer: {flexDirection: 'row'},
    bgImg: {width: 625, height: 97},
    fgImg: {width: 131, height: 59},
})
