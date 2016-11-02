"use strict";

import MutualInsView from '../component/mutual_ins/MutualInsView';
import MutualInsGroupIntroView from '../component/mutual_ins/GroupIntroductionView';
import AboutUsView from '../component/mine/AboutUsView';

const RouteMap = {
    '/MutualIns/Home': MutualInsView,
    '/MutualIns/GroupIntro': MutualInsGroupIntroView,
    '/Mine/AboutUs': AboutUsView,
}

export default RouteMap;