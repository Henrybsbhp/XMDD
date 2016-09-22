"use strict";
import event from 'events';

export var Emitter = new event.EventEmitter();
export const Events = {
    FetchMutualInsGroupList: 'FetchMutualInsGroupList',
    FetchMutualInsGroupBaseInfo: 'FetchMutualInsGroupBaseInfo',
}
