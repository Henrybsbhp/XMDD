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

export default class Navigator extends Component {
    popInNative() {
        NativeModules.NavigationManager.popViewAnimated(true);
    }

    popToHrefInNative(href, options) {
        NativeNavigator.popToViewByRouteKey(href, options, true, () => {
            this.popToHref(href)
        })
    }

    popToHref(href) {
        var routeStack = this.navigator.state.routeStack
        for (var route of routeStack) {
            if (route.href == href) {
                this.nav.popToRoute(route)
                break
            }
        }
    }

    pop() {
        this.nav.pop()
    }

    push(route) {
        this.nav.push(this._createRoute(route))
    }

    update(oldRoute, newRoute) {
        if (this.nav) {
            this.nav.replace(this._createRoute({...oldRoute, ...newRoute}))
        }
        else  {
            console.log('newRoute', newRoute)
            for (var prop in newRoute) {
                oldRoute[prop] = newRoute[prop]
            }
        }
    }

    replace(route) {
        if (this.nav) {
            this.nav.replace(this._createRoute(route))
        }
        else  {
            this._unReplacedRoute = route
        }
    }

    _createRoute(route) {
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
        var route = this._createRoute({
            title: this.props.title,
            component: RouteMap[this.props.href],
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
