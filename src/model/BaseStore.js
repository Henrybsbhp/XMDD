"use strict";
let StoreMap = new WeakMap();

export default class BaseStore {
    constructor(storeid) {
        this.id = storeid;
        StoreMap.set(storeid, this);
    }

    static fetch(storeid) {
        var key = storeid ? storeid : this.name;
        return StoreMap.get(key);
    }

    static fetchOrCreate(storeid) {
        var key = storeid ? storeid : this.name;
        var store = StoreMap.get(key);
        if (!store) {
            return new this(key);
        }
        return store;
    }
}
