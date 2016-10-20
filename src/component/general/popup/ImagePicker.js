"use strict";
import React, {Component, PropTypes} from 'react';
import {
    Text, View, Image, StyleSheet, TouchableOpacity, Animated, Easing, ImagePickerIOS, InteractionManager
} from 'react-native';
import ModalView from '../ModalView';
import UI from '../../../constant/UIConstants';

const EmptyFunc = () => {}

export default class ImagePicker extends ModalView {
    static propTypes = {
        exampleImage: PropTypes.object,
        exampleTitle: PropTypes.string,
        exampleVisible: PropTypes.bool,
        onPicked: PropTypes.func,
    }
    static defaultProps = {
        exampleTitle: '所有上传资料均会加水印，小马达达保障您的隐私安全！',
        exampleVisible: true,
        bgStyle: {backgroundColor: "rgba(0,0,0,0.5)"},
        fgStyle: {flex: 1},
        bgAnimation: 'fade',
        fgOpenAnimation: 'none',
        fgCloseAnimation: 'none',
    }

    constructor(props) {
        super(props)
        this.state.bottomY = new Animated.Value(0)
    }

    createOpenAnimations() {
        var anims = super.createOpenAnimations()
        anims.push(Animated.timing(
            this.state.bottomY,
            {toValue: 1, duration: 200, easing: Easing.out(Easing.quad)}
        ))
        return anims
    }

    createCloseAnimations() {
        var anims = super.createCloseAnimations()
        anims.push(Animated.timing(
            this.state.bottomY,
            {toValue: 0, duration: 200, easing: Easing.in(Easing.quad)}
        ))
        return anims
    }

    onTakePhoto() {
        this.close()
        ImagePickerIOS.canUseCamera(usable => {
            if (!usable) {
                return;
            }
            InteractionManager.runAfterInteractions(() => {
                ImagePickerIOS.openCameraDialog(null, this.props.onPicked, EmptyFunc)
            })
        })
    }

    onGetPhoto() {
        this.close()
        InteractionManager.runAfterInteractions(() => {
            ImagePickerIOS.openSelectDialog(null, this.props.onPicked, EmptyFunc)
        })
    }

    renderChildren() {
        var bottomTransform = [{translateY: this.state.bottomY.interpolate({
            inputRange: [0, 1],
            outputRange: [230, 0],
        })}]
        return (
            <View style={styles.container}>
                <Animated.View style={[styles.exampleView, {opacity: this.state.bgFade}]}>
                    {this.props.exampleVisible && (
                        <Image style={styles.exampleImage} source={this.props.exampleImage}/>
                    )}
                    {this.props.exampleVisible && (
                        <Text style={styles.exampleTitle}>{this.props.exampleTitle}</Text>
                    )}
                </Animated.View>
                <View style={UI.Style.HContainer}>
                    <Animated.View style={[styles.bottomView, {transform: bottomTransform}]}>
                        <View style={styles.actionsView}>
                            <View style={styles.bottomTitleContainer}>
                                <Text style={styles.bottomTitle}>选取照片</Text>
                            </View>
                            <View style={styles.HLine}/>
                            <TouchableOpacity style={styles.actionButton} onPress={this.onTakePhoto.bind(this)}>
                                <Text style={styles.actionButtonTitle}>拍照</Text>
                            </TouchableOpacity>
                            <View style={styles.HLine}/>
                            <TouchableOpacity style={styles.actionButton} onPress={this.onGetPhoto.bind(this)}>
                                <Text style={styles.actionButtonTitle}>从相册选取</Text>
                            </TouchableOpacity>
                        </View>
                        <View style={styles.cancelView}>
                            <TouchableOpacity style={styles.cancelButton} onPress={this.close.bind(this)}>
                                <Text style={styles.cancelButtonTitle}>取消</Text>
                            </TouchableOpacity>
                        </View>
                    </Animated.View>
                </View>
            </View>
        )
    }
}

const styles = StyleSheet.create({
    container: {flex: 1, alignItems: 'center'},
    HLine: {height: 0.5, backgroundColor: UI.Color.Line},
    exampleView: {flex: 1, alignItems: 'center', justifyContent: 'center'},
    exampleImage: {width: 290, height: 230, resizeMode: 'contain'},
    exampleTitle: {fontSize: 14, color: 'white', width: 300, marginTop: -8},
    bottomView: {marginHorizontal: 8, marginBottom: 8, flex: 1},
    bottomTitleContainer: {...UI.Style.Center, height: 44},
    bottomTitle: {fontSize: 14, color: UI.Color.GrayText},
    actionsView: {backgroundColor: 'white', borderRadius: 8},
    actionButton: {...UI.Style.Btn, height: 56},
    actionButtonTitle: {fontSize: 17, color: UI.Color.Blue},
    cancelView: {height: 56, borderRadius: 8, marginTop: 8, backgroundColor: 'white'},
    cancelButton: {...UI.Style.Btn, flex: 1},
    cancelButtonTitle: {fontSize: 17, color: UI.Color.Blue, fontWeight: 'bold'},
});