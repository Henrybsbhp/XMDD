"use strict";
import React, {Component, PropTypes} from 'react';
import {View, TouchableWithoutFeedback, Image, StyleSheet, NativeModules, ActivityIndicator} from 'react-native';
import UI from '../../constant/UIConstants';
import ImagePicker from '../general/popup/ImagePicker';
import net from '../../helper/Network';

export default class ImageUploadingView extends Component {
    static propTypes = {
        defaultSource: PropTypes.object,
        exampleSource: PropTypes.object,
        onUpload: PropTypes.func,
    }

    constructor(props) {
        super(props)
        this.state = {
            fail: false,
            source: props.defaultSource,
            sourceWidth: 0,
            sourceHeight: 0,
            uploading: false,
            imagePickerOpened: false,
        }
    }

    componentWillReceiveProps(props) {
        if (props.defaultSource && !this.state.uploading && !this.state.source) {
            this.setState({source: props.defaultSource})
        }
    }

    onOpenImagePicker() {
        this.setState({imagePickerOpened: true})
    }

    onPickedImage(img, height, width) {
        this.setState({source: {uri: img}, sourceWidth: width, sourceHeight: height, uploading: true, fail: false})
        net.uploadImage(img).then(rsp => {
            console.log('upload image success:', rsp)
            this.setState({uploading: false})
            this.props.onUpload && this.props.onUpload(rsp.url)
        }).catch(e => {
            this.setState({fail: true, uploading: false, source: null})
        })
    }

    render() {
        return (
            <View>
                <TouchableWithoutFeedback onPress={this.onOpenImagePicker.bind(this)}>
                    {this.state.fail || this.state.source ? this.renderSource() : this.renderDefault()}
                </TouchableWithoutFeedback>
                <ImagePicker exampleImage={this.props.exampleSource}
                             isOpen={this.state.imagePickerOpened}
                             onPicked={this.onPickedImage.bind(this)}
                             onClosed={() => {this.state.imagePickerOpened = false}}/>
            </View>
        )
    }

    renderSource() {
        var defpic = this.state.fail ? 'cm_defpic_fail2' : 'cm_defpic2'
        return (
            <View style={[styles.container, this.props.style]}>
                <Image style={styles.image} source={this.state.source} defaultSource={{uri: defpic}}/>
                {!this.state.fail && (<Image style={styles.waterMask} source={{uri: 'cm_watermark'}}/>)}
                {this.state.uploading && (
                    <View style={styles.activityContainer}>
                        <ActivityIndicator animating={this.state.uploading}
                                           color="white"
                                           hidesWhenStopped={true}
                                           size="large"/>
                    </View>
                )}
            </View>
        )
    }

    renderDefault() {
        return (
            <View style={[styles.container, this.props.style]}>
                <Image style={styles.foreground} source={{uri: 'mutualIns_camera'}}/>
            </View>
        )
    }
}

const styles = StyleSheet.create({
    container: {alignItems: 'center', justifyContent: 'center', borderWidth: 1, borderColor: 'rgb(238,238,238)'},
    foreground: {width: 58, height: 53},
    image: {
        position: 'absolute', top: 0, left: 0, bottom: 0, right: 0, backgroundColor: UI.Color.Background,
        resizeMode: 'contain'
    },
    waterMask: {position: 'absolute', top: 0, left: 0, bottom: 0, right: 0, resizeMode: 'contain'},
    activityContainer: {
        ...UI.Style.Center, position: 'absolute', top: 0, left: 0, bottom: 0, right: 0,
        backgroundColor: 'rgba(0,0,0,0.4)'
    }
})