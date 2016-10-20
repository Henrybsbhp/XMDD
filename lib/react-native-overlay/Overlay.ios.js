/**
 * @providesModule Overlay
 * @flow-weak
 */

'use strict';

import React, {Component, PropTypes} from 'react';
import {View, StyleSheet, requireNativeComponent, Dimensions} from 'react-native';

export default class Overlay extends Component {
    static propTypes = {
        /**
         * When this property is set to `true`, the Overlay will appear on
         * `UIWindowLevelStatusBar`, otherwise it will appear below that.
         */
        aboveStatusBar: PropTypes.bool,

        /**
         * Determines the visibility of the Overlay. When it is not visible,
         * an empty View is rendered.
         */
        isVisible: PropTypes.bool,
    }

    static defaultProps = {
        aboveStatusBar: false,
        isVisible: false,
    }

    render() {
        if (this.props.isVisible) {
            return (
                <RNOverlay
                    isVisible={true}
                    style={styles.container}
                    pointerEvents="none"
                    aboveStatusBar={this.props.aboveStatusBar}>
                    {React.Children.map(this.props.children, (element) => React.cloneElement(element))}
                </RNOverlay>
            )
        }
        return (<View/>)
    }
}

var RNOverlay = requireNativeComponent('RNOverlay', Overlay);
const WIN = Dimensions.get('window');

var styles = StyleSheet.create({
    container: {
        flex: 1,
        position: 'absolute',
        width: WIN.width,
        height: WIN.height,
        backgroundColor: 'transparent',
    },
});

