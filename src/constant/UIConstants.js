"use strict";
import {Dimensions} from 'react-native';
const WIN = Dimensions.get('window');

const constants = {
    Img: {
        DefaultAD: {uri: 'ad_default_2_5'},
        DefaultADHomeBottom: {uri: 'hp_bottom_ad_default'},
        DefaultADMutIns: {uri: 'ad_default_mutualIns_top'},
        DefaultMutInsCarBrand: {url: 'mins_def'},
        ArrowRight: {uri: 'Common_pointer_imageView', width: 10, height: 12},
    },
    Win: {
        Height: WIN.height,
        Width: WIN.width,
    },
    Color: {
        Background: '#F7F7F8',
        Line: '#E3E3E3',
        DarkText: '#454545',
        GrayText: '#888888',
        DefaultTint: '#18D06A',
        Orange: '#FF7428',
        Clear: 'rgba(0, 0, 0, 0)',
    },
    Style: {
        Center: {alignItems: 'center', justifyContent: 'center'},
        HContainer: {flexDirection: 'row'},
        VContainer: {flexDirection: 'column'},
        BgImg: {position: 'absolute', top: 0, left: 0, bottom: 0, right: 0},
        Btn: {flexDirection: 'row', justifyContent: 'center', alignItems: 'center'},
    },
};

export default constants;