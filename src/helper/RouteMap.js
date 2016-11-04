"use strict";

import MutualInsView from '../component/mutual_ins/MutualInsView';
import MutualInsGroupIntroView from '../component/mutual_ins/GroupIntroductionView';
import AboutUsView from '../component/mine/AboutUsView';
import MutualInsADHomeView from '../component/mutual_ins/ADHomeView';
import MutualInsGroupListView from '../component/mutual_ins/GroupListView';

const RouteMap = {
    '/MutualIns/Home': {component: MutualInsView, title: '小马互助'},
    '/MutualIns/GroupIntro': {component: MutualInsGroupIntroView, title: '小马互助'},
    '/Mine/AboutUs': {component: AboutUsView, title: '关于'},
    '/MutualIns/ADHome': {component: MutualInsADHomeView, title: '小马互助'},
    '/MutualIns/GroupList': {component: MutualInsGroupListView, title: '互助团'},
}

for (var key in RouteMap) {
     RouteMap[key]['href'] = key;
}

export default RouteMap;


