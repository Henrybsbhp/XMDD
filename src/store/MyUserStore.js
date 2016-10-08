"use strict"
import React, {NativeModules, NativeEventEmitter} from 'react-native';
import Reflux from 'reflux'
import net from '../helper/Network'
import {extend} from '../helper/Object'

const LoginManager = NativeModules.LoginManager;
const EventEmitter = new NativeEventEmitter(LoginManager);
const Domains = {
    Login: "MyUserLoginChanged",
}

const MyUserStore = Reflux.createStore({
    isLogin: false,
})

var subscription = EventEmitter.addListener("login", (isLogin) => {
    if (MyUserStore.isLogin != isLogin) {
        MyUserStore.isLogin = isLogin
        MyUserStore.trigger(Domains.Login, isLogin)
    }
});

MyUserStore.Domains = Domains
export default MyUserStore
