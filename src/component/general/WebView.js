import React, {Component, PropTypes} from 'react';
import {requireNativeComponent} from 'react-native';
import {handleLink} from '../../helper/LinkManager';

const RNWebView = requireNativeComponent('RNWebView', WebView);

export default class WebView extends Component {
    static propTypes = {
        navigator: PropTypes.object.isRequired,
    }

    render() {
        return (
            <RNWebView {...this.props} onHandleLink={this.onHandleLink.bind(this)}/>
        )
    }

    onHandleLink({nativeEvent: event}) {
        handleLink(event.link, this.props.navigator)
    }
}




