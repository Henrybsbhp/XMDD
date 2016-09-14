"use strict";
import React, {Component, PropTypes} from 'react';
import {
    Text, View, Image, StyleSheet, TouchableOpacity
} from 'react-native';
import Modal from '../general/Modal';
import UI from '../../constant/UIConstants';

export default class PopoverMenu extends Modal {

    open() {
        this.refs.m.open();
    }

    close() {
        this.refs.m.close();
    }

    render() {
        var props = this.props ? this.props : undefined;
        return (
            <Modal ref="m" {...props}>
                <View style={styles.menuContainer}>
                    <Image
                        source={{uri: 'mins_pop_bg'}}
                        resizeMode="stretch"
                        capInsets={{top: 8, left: 5, bottom: 5, right: 24}}
                        style={styles.menuBgImg}
                    />
                    <View style={styles.menuContent}>
                        {this.props.children}
                    </View>
                </View>
            </Modal>
        );
    }
}

class PopoverMenuCell extends Component {

    static propTypes = {
        text: PropTypes.string,
        image: PropTypes.object,
        onPress: PropTypes.func,
    }

    constructor(props) {
        super(props);
        this.state = {forceRerend: false};
    }

    componentWillReceiveProps(props) {
        this.setState({forceRerend: !this.state.forceRerend});
    }

    render() {
        return (
            <View>
                <TouchableOpacity onPress={this.props.onPress} style={styles.menuCellContainer}>
                    <View style={styles.menuCellImageContainer}>
                        <Image source={this.props.image}/>
                    </View>
                    <Text style={styles.menuCellText} numberOfLines={0}>
                        {this.props.text}
                    </Text>
                </TouchableOpacity>
                <View style={styles.menuSeparator}/>
            </View>
        );
    }
}

PopoverMenu.MenuCell = PopoverMenuCell;

const styles = StyleSheet.create({
    container: {flex: 1},
    menuContainer: {position: 'absolute', width: 148, right: 10, top: 60},
    menuBgImg: {position: 'absolute', left: 0, right: 0, top: 0, bottom: 0},
    menuContent: {marginTop: 7},
    menuSeparator: {height: 0.5, marginLeft: 10, marginRight: 10, backgroundColor: UI.Color.Line},
    menuCellContainer: {height: 45, flexDirection: 'row', alignItems: 'center'},
    menuCellImageContainer: {marginLeft: 14, marginRight: 10, width: 30, height: 30,
        alignItems:'center', justifyContent: 'center'},
    menuCellText: {fontSize: 14, color: UI.Color.DarkText},
});