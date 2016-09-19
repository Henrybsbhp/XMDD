"use strict";
import React, {Component, PropTypes} from 'react';
import {View, StyleSheet} from 'react-native';
import UI from '../../../constant/UIConstants';
import Svg, {
    Circle,
    LinearGradient,
    Stop,
    Path,
} from 'react-native-svg';


export default class CircleGradientProgress extends Component {
    static propTypes = {
        radius: PropTypes.number.isRequired,
        value: PropTypes.number,
    }

    static defaultProps = {
        value: 0,
    }

    render() {
        const {value, radius} = this.props;
        var reverseFlag = value > 0.5 ? 1 : 0;
        var endRadian = 2 * value * Math.PI;
        var progressPath = `M${radius} ${radius} L${radius} 0 A${radius} ${radius} 0 ${reverseFlag} 1 
                            ${radius * (1 + Math.sin(endRadian))} 
                            ${radius * (1 - Math.cos(endRadian))} Z`;
        return (
            <Svg width={2 * radius} height={2 * radius}>
                <LinearGradient id="grad" x1="0" y1={2 * radius} x2={2 * radius} y2="0">
                    <Stop offset="0" stopColor="#17EEE1" stopOpacity="1"/>
                    <Stop offset="1" stopColor="#18D06A" stopOpacity="1"/>
                </LinearGradient>
                <Circle cx={radius}
                        cy={radius}
                        r={radius - 2}
                        fill="white"
                        stroke={UI.Color.Background}
                        strokeWidth={2.5}
                />
                <Path d={progressPath} fill="url(#grad)" stroke='red' strokeWidth={0}/>
                <Circle cx={radius} cy={radius} r={radius - 4} fill="white"/>
                {this.props.children}
            </Svg>
        )
    }
}