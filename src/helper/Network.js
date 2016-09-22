"use strict";
import {NativeModules} from 'react-native';

const NetMgr = NativeModules.NetworkManager;

export default {
    postApi: (args) => {
        return NetMgr.postApi(args);
    },
    uploadImage: (localurl) => {
        return NetMgr.uploadImage(localurl);
    }
};