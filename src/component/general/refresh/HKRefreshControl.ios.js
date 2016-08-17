'use strict';

import React, {NativeModules, NativeEventEmitter} from 'react-native';

const HKRefreshControl = NativeModules.HKRefreshControl;
const DROP_VIEW_DID_BEGIN_REFRESHING_EVENT = 'dropViewDidBeginRefreshing';
const eventEmitter = new NativeEventEmitter(HKRefreshControl);

var callbacks = {};
var subscription = eventEmitter.addListener(
    DROP_VIEW_DID_BEGIN_REFRESHING_EVENT,
    (reactTag) => {callbacks[reactTag]()}
);
// subscription.remove();

module.exports = {
    configure: function(configs, callback) {
        var nodeHandle = React.findNodeHandle(configs.node);

        HKRefreshControl.configure(nodeHandle, null, (error) => {
            if (!error) {
                callbacks[nodeHandle] = callback;
            }
        });
    },
    endRefreshing: function(node) {
        var nodeHandle = React.findNodeHandle(node);
        HKRefreshControl.endRefreshing(nodeHandle);
    }
};
