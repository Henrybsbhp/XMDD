"use strict";

import {Actions as MutualInsActions} from '../store/MutualInsStore';

const NotificationHandles = {
    "MutualInsFetchSimpleGroups": MutualInsActions.fetchSimpleGroups,
}

export default class Notify {
    static handle(notification) {
        NotificationHandles[notification]()
    }
}
