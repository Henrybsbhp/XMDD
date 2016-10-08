import React from 'react';
import {
    AppRegistry,
    Navigator,
    StyleSheet,
    NativeModules,
} from 'react-native';

import NavigatorView from './component/general/NavigatorView';
import MutualInsView from './component/mutual_ins/MutualInsView';
import AboutUsView from './component/mine/AboutUsView';


const components = {MutualInsView: MutualInsView,
    AboutUsView:AboutUsView};

export default class RootView extends React.Component {
    componentWillMount() {
        NativeModules.NavigationManager.setNavigationBarHidden(true, true);
    }
    render() {
        return (
            <NavigatorView
                route={{
                    ...this.props,
                    component:components[this.props.component],
                }}
            />
        );
    }
}

AppRegistry.registerComponent('App', () => RootView);