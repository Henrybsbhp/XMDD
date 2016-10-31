import React from 'react';
import {
    AppRegistry,
    View,
    NativeModules,
} from 'react-native';

import MyUserStore from './store/MyUserStore';
import Navigator from './component/general/Navigator.ios';
import Notify from './helper/Notify';
import BatchedBridge from 'react-native/Libraries/BatchedBridge/BatchedBridge'

export default class RootView extends React.Component {
    constructor(props) {
        super(props)
        MyUserStore.isLogin = Boolean(props.isLogin)
        this.notify = new Notify()
        this.state = {forceRerend: false}

    }

    componentWillMount() {
        NativeModules.NavigationManager.setNavigationBarHidden(true, true);
    }

    render() {
        return (
            <View style={{flex: 1}}>
                <Navigator {...this.props}/>
            </View>
        );
    }
}

AppRegistry.registerComponent('App', () => RootView);
BatchedBridge.registerCallableModule('Notify', Notify);

import TestView from './component/test/TestView';
AppRegistry.registerComponent('Test', () => TestView)