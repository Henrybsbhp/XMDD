"use strict";

import {Actions as MutualInsActions} from '../store/MutualInsStore';
import RouteMap from './RouteMap';

const NotificationHandles = {
    "GotoMutualInsHomeView": onGotoMutualInsHomeView,
}

export default class Notify {
    static RootNavigator = undefined;
    static handle(notification) {
        NotificationHandles[notification.name](notification)
    }
}

function onGotoMutualInsHomeView() {
    MutualInsActions.fetchSimpleGroups()
    var href = '/MutualIns/Home'
    Notify.RootNavigator.popToHref(href, true)
}