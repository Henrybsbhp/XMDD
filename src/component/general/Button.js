"use strict";
import React, {Component, PropsType} from 'react'
import {TouchableOpacity, Text, Image, StyleSheet} from 'react-native'

export default class Button extends Component {
    static propsTypes = {
        title: PropsType.string,
        titleStyle: PropsType.object,
        image: PropsType.object,
        imageStyle: PropsType.object,
        backgroundImage: PropsType.object,
        backgroundStyle: PropsType.object,
        onPress: PropsType.func,
    }

    render() {
        return (
            <TouchableOpactiy onPress={this.props.onPress}>
                <Image capInsets={this.props.backgroundStyle && this.props.backgroundStyle.capInsets}
                       style={[styles.backgroundImage, this.props.backgroundStyle]}/>
                <View style={this.props.style}>
                    {this.props.title && this.props.title.length > 0 && (
                        <Text style={this.props.titleStyle}>{this.props.title}</Text>
                    )}
                    {this.props.image && (
                        <Image capInsets={this.props.imageStyle && this.props.imageStyle.capInsets}
                               style={this.props.backgroundStyle} />
                    )}
                </View>
            </TouchableOpactiy>
        )
    }
}

const styles = StyleSheet.create({
    content: {flexDirection: 'row'},
    backgroundImage: {resizeMode: 'stretch', position: 'absolute', top: 0, left: 0, bottom: 0, right: 0},
})