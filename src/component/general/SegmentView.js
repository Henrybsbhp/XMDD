"use strict";
import React, {Component, PropTypes} from 'react';
import {View, StyleSheet, Text, Animated, TouchableOpacity} from 'react-native';
import UI from '../../constant/UIConstants';

export default class SegmentView extends Component {
    static propTypes = {
        items: PropTypes.array,
        onChanged: PropTypes.func,
        selectedIndex: PropTypes.number,
    }

    static defaultProps = {
        isOpen: false,
        selectedIndex: 0,
    }

    constructor(props) {
        super(props);
        this.state = {selectedIndex: 0, forceRerend: false, translateAnim: new Animated.Value(0)};
    }

    componentWillReceiveProps(props) {
        if ('selectedIndex' in props) {
            this.setSelectedIndex(props.selectedIndex)
        }
        else {
            this.setState({forceRerend: !this.state.forceRerend})
        }
    }

    setSelectedIndex(index) {
        this.setState({selectedIndex: index, forceRerend: !this.state.forceRerend});
        Animated.timing(
            this.state.translateAnim,
            {toValue: index, duration: 180}
        ).start();
    }

    render() {
        var itemViews = [];
        for (var i = 0; i < this.props.items.length; i++) {
            itemViews.push(this.renderItem(this.props.items[i], this.state.selectedIndex == i, i));
        }
        var lineWidth = UI.Win.Width / itemViews.length;
        var translateX = this.state.translateAnim.interpolate({
            inputRange: [0, itemViews.length - 1],
            outputRange: [0, lineWidth * (itemViews.length - 1)],
        })
        return (
            <View>
                <View style={styles.bar}>
                    {itemViews}
                </View>
                <Animated.View style={[styles.line, {width: lineWidth, transform: [{translateX: translateX}]}]}/>
            </View>
        );
    }

    renderItem(item, selected, key) {
        const color = UI;
        return (
            <TouchableOpacity
                key={key}
                style={styles.item}
                onPress={() => {
                    this.setSelectedIndex(key)
                    if (this.props.onChanged) {
                        this.props.onChanged(key)
                    }
                }}>
                <Text style={[styles.title, selected ? {color: UI.Color.DefaultTint} : null]}
                      numberOfLines={0}
                      textAlign="center">
                    {item}
                </Text>
            </TouchableOpacity>
        );
    }
}

const styles = StyleSheet.create({
    container: {flex: 1},
    bar: {height: 45, flexDirection: 'row', backgroundColor: 'white'},
    item: {flex: 1, alignItems: 'center', justifyContent: 'center'},
    title: {color: UI.Color.DarkText, fontSize: 16},
    line: {position: 'absolute', bottom:0, height: 2, backgroundColor: UI.Color.DefaultTint}
});