'use strict';
import React, {Component} from 'react';
import {
    NavigatorIOS,
    StyleSheet,
    View,
    Text,
    TouchableOpacity,
    NativeModules,
    Image,
} from 'react-native';
import RouteMap from '../../helper/RouteMap';
import UI from '../../constant/UIConstants';

const NavigationManager = NativeModules.NavigationManager;

export default class Navigator extends Component {
    getRouteStack() {
        return this.nav.state.routeStack
    }

    popInNative() {
        NavigationManager.popViewAnimated(true);
    }

    popToHrefInNative(href, options, reset) {
        NavigationManager.popToViewByRouteKey(href, options, true, () => {
            this.popToHref(href, reset)
        })
    }

    popToHref(href, reset) {
        var routeStack = this.nav.state.routeStack
        for (var route of routeStack) {
            if (route.href == href) {
                this.nav.popToRoute(route)
                return true;
            }
        }
        if (reset && RouteMap[href]) {
            this.resetTo(RouteMap[href])
        }
        return false;
    }

    resetTo(route) {
        route = this.createRoute(route)
        if (this.props.shouldBack) {
            route.renderLeftItem = this.renderBackItem.bind(this)
            route.onBack = this.popInNative
        }
        this.nav.resetTo(route)
    }

    pop() {
        this.nav.pop()
    }

    push(route) {
        this.nav.push(this.createRoute(route))
    }

    update(oldRoute, newRoute) {
        if (this.nav) {
            this.nav.replace(this.createRoute({...oldRoute, ...newRoute}))
        }
        else  {
            console.log('newRoute', newRoute)
            for (var prop in newRoute) {
                oldRoute[prop] = newRoute[prop]
            }
        }
    }

    replacePreviousAndPop(route) {
        route = this.createRoute(route)
        this.nav.replacePreviousAndPop(route)
    }

    replace(route) {
        if (this.nav) {
            this.nav.replace(this.createRoute(route))
        }
        else  {
            this._unReplacedRoute = route
        }
    }

    createRoute(route) {
        return {
            onBack: this.pop.bind(this),
            ...route,
            passProps: {...route.passProps, navigator: this},
            renderLeftItem: this.renderBackItem,
        }
    }

    _bindNavigator(nav) {
        this.nav = nav
        if (this._unReplacedRoute) {
            this.replace(this._unReplacedRoute)
            this._unReplacedRoute = undefined
        }
    }

    render() {
        var route = this.createRoute({
            ...RouteMap[this.props.href],
            title: this.props.title,
            renderLeftItem: this.props.shouldBack ? this.renderBackItem.bind(this) : undefined,
            onBack: this.popInNative,
        })

        return (
            <NavigatorIOS initialRoute={route}
                          ref={this._bindNavigator.bind(this)}
                          style={{flex: 1}}
                          itemWrapperStyle={styles.scene}
                          interactivePopGestureEnabled={true}
                          translucent={true}
                          tintColor={UI.Color.DefaultTint}
            />
        )
    }

    renderBackItem(route) {
        return (
            <View>
            <TouchableOpacity style = {{paddingVertical: 10, paddingRight: 15}}
                              onPress={() => {route.onBack ? route.onBack(route) : this.onBack(route)}}>
                <Image source={{uri: 'nav_back_300', scale: UI.Win.Scale, width: 18, height: 18}}/>
            </TouchableOpacity>
            </View>
        )
    }
}

const styles = StyleSheet.create({
    scene: {marginTop: 64}
})
