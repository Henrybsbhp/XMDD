import React from 'react';
import {
    AppRegistry,
    View,
    Navigator,
    StyleSheet,
    NativeModules,
} from 'react-native';

import MyUserStore from './store/MyUserStore';
import NavigatorView from './component/general/NavigatorView';
import MutualInsView from './component/mutual_ins/MutualInsView';
import AboutUsView from './component/mine/AboutUsView';


const components = {MutualInsView: MutualInsView,
    AboutUsView:AboutUsView};

var globalID = 1;

export default class RootView extends React.Component {
    constructor(props) {
        super(props)
        MyUserStore.isLogin = Boolean(props.isLogin)
        this.state = {forceRerend: false}
    }

    componentWillMount() {
        NativeModules.NavigationManager.setNavigationBarHidden(true, true);
    }

    render() {
        return (
            <View style={{flex: 1}}>
                <NavigatorView
                    route={{
                        ...this.props,
                        component: components[this.props.component],
                    }}
                />
            </View>
        );
    }
}

const Styles = StyleSheet.create({
    modal: {position: 'absolute', left: 0, right: 0, top: 0, bottom: 0},
})

AppRegistry.registerComponent('App', () => RootView);