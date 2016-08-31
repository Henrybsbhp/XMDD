"use strict";

import BaseStore from '../BaseStore';
import network from '../Network';

export class MutualInsStore extends BaseStore {
    fetchMyGroups() {
        return network.postApi({method: '/cooperation/mygroup/v2/get', security: true})
                .then(rsp => {this.myGroups = rsp})
    }
}