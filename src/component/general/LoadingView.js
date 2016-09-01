import React, {Component, PropTypes} from 'react';
import {requireNativeComponent, findNodeHandle, View, NativeModules, StyleSheet} from 'react-native';

const RCTLoadingView = requireNativeComponent('RCTLoadingView', LoadingView);
const LoadingViewManager = NativeModules.LoadingViewManager;

export default class LoadingView extends Component {
    static propTypes = {
        loading: PropTypes.bool,
        animationType: PropTypes.oneOf(['gif', 'mon', 'ui', 'tym'])
    }

    static defaultProps = {
        loading: false,
        animationType: 'gif'
    }

    componentDidMount() {
       this.resetAnimating(this.props);
    }

    componentWillReceiveProps(props) {
        this.resetAnimating(props);
    }

    resetAnimating(props) {
        var tag = findNodeHandle(this.refs.loading);
         if (props.loading) {
             switch (props.animationType) {
                 case 'mon': LoadingViewManager.startMONAnimating(tag);break;
                 case 'tym': LoadingViewManager.startTYMAnimating(tag);break;
                 case 'ui': LoadingViewManager.startUIAnimating(tag);break;
                 default: LoadingViewManager.startGifAnimating(tag);break;
             }
         } else {
             loadingViewManager.stopAnimating(tag);
         }
    }


    render() {
        return (<RCTLoadingView {...this.props}
                                ref="loading" style={styles.content} />);
    }
}

const styles = StyleSheet.create({
    content: {flex: 1}
});