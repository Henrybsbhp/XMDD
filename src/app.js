import React from 'react';
import {
    AppRegistry,
    Navigator,
    StyleSheet,
    NativeModules,
} from 'react-native';

import NavigatorView from './component/general/NavigatorView';
import MyInfoView from './component/mine/MyInfoView';
import EditMyInfoView from './component/mine/EditMyInfoView';
import MutualInsView from './component/mutual_ins/base/MutualInsView';


const components = {MyInfoView: MyInfoView, EditMyInfoView: EditMyInfoView, MutualInsView: MutualInsView};

export default class RootView extends React.Component {
    componentWillMount() {
        NativeModules.NavigationManager.setNavigationBarHidden(true, true);
    }
    componentDidMount() {
        console.log(this.refs)
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