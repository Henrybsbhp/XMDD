"use strict";
import {Dimensions} from 'react-native';
const WIN = Dimensions.get('window');

const constants = {
    Img: {
        DefaultAD: {uri: 'ad_default_2_5'},
        DefaultADHomeBottom: {uri: 'hp_bottom_ad_default'},
        DefaultADMutIns: {uri: 'ad_default_mutualIns_top'},
        ArrowRight: {uri: 'Common_pointer_imageView', width: 10, height: 12},
    },
    Win: {
        Height: WIN.height,
        Width: WIN.width,
    },
    Color: {
        Background: '#F7F7F8',
        Line: '#EBEBEB',
        DarkText: '#454545',
        GrayText: '#888888',
        Orange: '#FF7428',
        DefaultTint: '#18D06A',
    }
};

export default constants;