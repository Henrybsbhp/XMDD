import React, {Component, PropTypes} from 'react';
import {requireNativeComponent, StyleSheet} from 'react-native';

const RCTLoadingView = requireNativeComponent('RCTLoadingView', LoadingView);

export default class LoadingView extends Component {
    static Animation = { TYM: 0, MON: 1, UI: 2, GIF: 3 }

    static propTypes = {
        loading: PropTypes.bool,
        animationType: PropTypes.oneOf([0,1,2,3]),
        offset: PropTypes.number,
    }

    static defaultProps = {
        loading: true,
        offset: 0,
        animationType: LoadingView.Animation.GIF,
    }

    render() {
        return (
            <RCTLoadingView animationType={this.props.animationType}
                            animate={this.props.loading}
                            style={[this.props.style ,{top: this.props.offset}]} />
        );
    }
}

