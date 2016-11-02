import React, { Component, PropTypes } from 'react';
import {
    NavigatorIOS, Text, View, TouchableHighlight, NativeModules, StyleSheet, Image
} from 'react-native';
import UI from '../../constant/UIConstants';

export default class TestView extends Component {
    constructor(props) {
        super(props)
        this.state = {forceRerend: false}
    }

    componentWillMount() {
        NativeModules.NavigationManager.setNavigationBarHidden(true, true);
        // NativeModules.NavigationManager.setInteractivePopGestureRecognizerDisable(true);
    }

    componentDidMount() {
        this.setState({forceRerend: true})
    }

    render() {
        var route = {
            component: Scene1, title: '小马互助'
        }

        return (
            <NavigatorIOS initialRoute={route}
                          ref={(nav) => {this.nav = nav}}
                          style={{flex: 1}}
                          itemWrapperStyle={{marginTop: 64}}
                          interactivePopGestureEnabled={true}
            />
        )
    }
}

class Scene1 extends Component {

    onPress() {
        var route = {
            ...this.props.route,
            component: Scene1,
            renderRightItem: this.renderRightItem,
            title: "Scene1",
        }
        // if (this.props.navigator.state.routeStack.length == 0) {
            this.props.navigator.replace(route, 0)
        // }

        // this.props.navigator.replace({...this.props.route, component: Scene1, title: 'dsdsdoij',})
        // var route = {
        //     component: Scene2,
        //     title: 'Scene2',
        //     renderRightItem: this.renderRightItem,
        //     renderLeftItem: this.renderBackItem
        //
        // }
        // this.props.navigator.push(route)
    }

    renderBackItem() {
        return (
            <View>
                <Image source={{uri: 'nav_back_300', scale: UI.Win.Scale, width: 18, height: 18}}/>
            </View>
        )
    }

    renderRightItem() {
        return (
            <View style={styles.rightItem}>
                <Text>Hello</Text>
            </View>
        )
    }

    render() {
        return (
            <View style={{flex: 1, backgroundColor: 'red'}}>
                <Text style={{marginTop: 64}}>Hello</Text>
                <View style={styles.bottomView}>
                    <TouchableHighlight onPress={this.onPress.bind(this)}>
                        <Text style={{height: 200, width: 300}}>dddddd</Text>
                    </TouchableHighlight>
                </View>
            </View>
        )
    }
}

class Scene2 extends Component {
    onPress() {
        var route = {...this.props.route, component: Scene2, renderRightItem: this.renderRightItem}
        this.props.navigator.replace(route)
    }

    constructor(props) {
        super(props)
    }
    componentWillMount() {
        var route = {...this.props.route, component: Scene2, title: 'hello'}
        this.props.navigator.replace(route)
    }

    render() {
        return (
            <View style={{flex: 1, backgroundColor: 'green'}}>
                <TouchableHighlight onPress={this.onPress.bind(this)}>
                    <Text>Scene2</Text>
                </TouchableHighlight>
            </View>
        )
    }

    renderRightItem() {
        return (
            <View style={[styles.rightItem, {backgroundColor: 'red'}]}>
                <Text>Hello</Text>
            </View>
        )
    }
}

const styles = StyleSheet.create({
    nav: {flex: 1},
    rightItem: {...UI.Style.Center, width: 80, height: 36, backgroundColor: 'blue'},
    bottomView: {height: 200, position: 'absolute', bottom: 0, left: 0, right: 0, backgroundColor: 'green'},
})