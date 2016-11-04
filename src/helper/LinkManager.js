"use strict";
import {NativeModules} from 'react-native';
import RouteMap from './RouteMap';

const NavigationManager = NativeModules.NavigationManager;
const linkMap = {
    cosys: () => RouteMap['/MutualIns/GroupList'],
}

export function handleLink(link, navigator) {
    var info = parseURL(link)
    if (!info) {
        return false;
    }
    var handler = linkMap[info.t];
    if (handler) {
        navigator.push(handler(info))
    }
    else  {
        NavigationManager.pushViewControllerByUrl(link)
    }
    return true;
}

function parseURL(url) {
    var result = /^xmdd:\/\/j\?/.exec(url)
    if (result) {
        var pairs = url.slice(result[0].length).match(/\w+=[\w\.]+/g)
        if (pairs) {
            var params = {}
            for (var p of pairs.slice(1)) {
                var kv = p.split('=')
                params[kv[0]] = kv[1]
            }
            return params
        }
    }
    return null
}

