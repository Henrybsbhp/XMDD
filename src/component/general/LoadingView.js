import React, {Component, PropTypes} from 'react';
import {requireNativeComponent, StyleSheet} from 'react-native';

const RCTLoadingView = requireNativeComponent('RCTLoadingView', LoadingView);


export default class LoadingView extends Component {
    static Animation = { TYM: 0, MON: 1, UI: 2, GIF: 3 }

    static propTypes = {
        loading: PropTypes.bool,
        animationType: PropTypes.oneOf([0,1,2,3]),
    }

    static defaultProps = {
        loading: true,
        animationType: LoadingView.Animation.GIF,
    }

    constructor(props) {
        super(props);
        this.state = {forceRerend: false}
    }

    componentWillReceiveProps(props) {
        this.setState({forceRerend: !this.state.forceRerend});
    }

    render() {
        return (<RCTLoadingView animationType={this.props.animationType}
                                animate={this.props.loading}
                                style={styles.content} />);
    }
}

const styles = StyleSheet.create({
    content: {flex: 1}
});