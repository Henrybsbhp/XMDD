"use strict";

import network from '../Network';

export default class MutualInsStore {
    fetchMyGroups() {
        return network.postApi({method: '/cooperation/mygroup/v2/get', security: true})
                .then(rsp => {this.myGroups = rsp; return rsp;})
    }
}


