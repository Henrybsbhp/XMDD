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
import ModalHelper from './helper/ModalHelper';


const components = {MutualInsView: MutualInsView,
    AboutUsView:AboutUsView};

export default class RootView extends React.Component {
    constructor(props) {
        super(props)
        MyUserStore.isLogin = Boolean(props.isLogin)
        this.modalMap = {}
        this.state = {modals: [], forceRerend: false}
    }

    componentWillMount() {
        NativeModules.NavigationManager.setNavigationBarHidden(true, true);
        this.unsubscribe = ModalHelper.listen(this.onStoreChanged.bind(this))
    }

    componentWillUnmount() {
        this.unsubscribe()
    }

    onStoreChanged(domain, modal) {
        if (ModalHelper.Domains.Open == domain) {
            this.modalMap[modal.id] = {timetag: new Date().valueOf(), modal: modal}
            values = this.modalMap.keys.map(k => this.modalMap[k])
            sortValues = values.sort((a, b) => {
                return a['timetag'] > b['timetag']
            })
            this.setState({modals: sortValues})
        }
        else if (ModalHelper.Domains.Close == domain) {
            delete this.modalMap[modal.id];
            this.setState({forceRerend: !this.state.forceRerend})
        }

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

AppRegistry.registerComponent('App', () => RootView);