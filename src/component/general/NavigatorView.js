/**
 * The examples provided by Facebook are for non-commercial testing and
 * evaluation purposes only.
 *
 * Facebook reserves all rights not expressly granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL
 * FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
'use strict';

import MyInfoView from './../mine/MyInfoView';
import React, {Component} from 'react';
import {
    Navigator,
    StyleSheet,
    View,
    Text,
    TouchableHighlight,
    TouchableOpacity,
    NativeModules,
    Image,
} from 'react-native';

const NavigationBarRouteMapper = {

    LeftButton: function(route, navigator, index, navState) {
        if (route.leftItem) {
            return React.createElement(route.leftItem.component, {...route.leftItem, route, navigator})
        }
        else if (route.shouldBack) {
            return <NavBarBackItem
                navigator={navigator}
                onPress={() => {
                    NativeModules.NavigationManager.popViewAnimated(true);
                }}
            />
        }
        else if (index === 0) {
            return null;
        }

        var previousRoute = navState.routeStack[index - 1];
        return (
            <NavBarBackItem
                route={route}
                navigator={navigator}
            />
        );
    },

    RightButton: function(route, navigator, index, navState) {
        if (route.rightItem) {
            return React.createElement(route.rightItem.component, {...route.rightItem, route, navigator})
        }
    },

    Title: function(route, navigator, index, navState) {
        return (
            <Text style={[styles.navBarText, styles.navBarTitleText]}>
                {route.title}
            </Text>
        );
    },

};

export class NavBarBackItem extends Component {
    render() {
        return (
            <TouchableOpacity
                onPress={() => {
                    if (this.props.onPress) {
                        this.props.onPress(this.props.route, this.props.navigator);
                    }
                    else {
                        this.props.navigator.pop();
                    }
                }}
                style={styles.navBarBackButton}>
                <Image style={styles.arrow} source={{uri: 'nav_back_300'}}/>

            </TouchableOpacity>
        );
    }
}

export class NavBarRightItem extends Component {
    render() {
        return (
            <NavBarButtonItem
                {...this.props}
                style={[styles.navBarRightButton, this.props.style]}
            />
        );
    }
}

export class NavBarLeftItem extends Component {
    render() {
        return (
            <NavBarButtonItem
                {...this.props}
                style={[styles.navBarLeftButton, this.props.style]}
            />
        );
    }
}

export class NavBarButtonItem extends Component {
    render() {
        return (
            <TouchableOpacity
                onPress={() => {this.props.onPress(this.props.route, this.props.navigator)}}
                style={this.props.style}>
                {this.props.image ?
                    <Image source={this.props.image}/> :
                    <Text style={[styles.navBarText, styles.navBarButtonText]}>
                        {this.props.text}
                    </Text>
                }

            </TouchableOpacity>
        );
    }
}

export default class NavigatorView extends Component {

    render() {
        return (
            <Navigator
                debugOverlay={false}
                style={styles.appContainer}
                initialRoute={this.props.route}
                renderScene={(route, navigator) => (
                    <View style={styles.scene}>
                        {React.createElement(
                            route.component,
                            {route, navigator, ...route.passProps},
                        )}
                    </View>
                )}
                navigationBar={
                    <Navigator.NavigationBar
                        routeMapper={NavigationBarRouteMapper}
                        style={styles.navBar}
                    />
                }
            />
        );
    }
};

const styles = StyleSheet.create({
    messageText: {
        fontSize: 17,
        fontWeight: '500',
        padding: 15,
        marginTop: 50,
        marginLeft: 15,
    },
    button: {
        backgroundColor: 'white',
        padding: 15,
        borderBottomWidth: StyleSheet.hairlineWidth,
        borderBottomColor: '#CDCDCD',
    },
    buttonText: {
        fontSize: 17,
        fontWeight: '500',
    },
    navBar: {
        backgroundColor: 'white',
        shadowColor: 'black',
        shadowOpacity: 1,
        shadowRadius: 2.5,
    },
    navBarText: {
        fontSize: 16,
        marginVertical: 10,
    },
    navBarTitleText: {
        color: '#373E4D',
        fontWeight: '500',
        marginVertical: 9,
    },
    navBarBackButton: {
        paddingVertical: 10,
        paddingHorizontal: 12,
        marginLeft: 5,
    },
    navBarButton: {
        padding: 10,
    },
    navBarButtonText: {
        color: '#18D06A',
    },
    navBarLeftButton: {
        marginLeft: 14,
    },
    navBarRightButton: {
        marginRight: 14,
    },
    arrow: {
        width: 18,
        height: 18,
    },
    scene: {
        flex: 1,
        marginTop: Navigator.NavigationBar.Styles.General.TotalNavHeight,
    },
});

