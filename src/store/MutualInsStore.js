"use strict"
import Reflux from 'reflux'
import net from '../helper/Network'
import {extend} from '../helper/Object'

export const Domains = {
    SimpleGroups: "SimpleGroupsInfoChanged",
    GroupDetail: "GroupDetailInfoChanged",
}

export var Actions = Reflux.createActions([
    "fetchSimpleGroups",
    "fetchGroupBase",
    "fetchGroupFundIfNeeded",
])

export default Reflux.createStore({
    listenables: [Actions],
    simpleGroups: {},
    detailGroups: {},

    onFetchSimpleGroups() {
        var groups = this.simpleGroups
        groups.loading = true
        this.trigger(Domains.SimpleGroups, groups)
        net.postApi({method: '/cooperation/mygroup/v2/get', security: true})
            .then(rsp => {
                this.simpleGroups = {...rsp, loading: false}
                this.trigger(Domains.SimpleGroups, this.simpleGroups)
            })
            .catch(e=> {
                groups.loading = false
                this.trigger(Domains.SimpleGroups, groups, e.message)
            })
    },

    onFetchGroupBase(groupid, memberid) {
        var group = this._getDetailGroup(groupid)
        group.baseLoading = true;
        this.trigger(Domains.GroupDetail, group)
        net.postApi({
            method: '/cooperation/group/config/get',
            security: true,
            params: {
                groupid: groupid,
                memberid: memberid,
            }
        }).then(rsp => {
            extend(group, {base: rsp, baseLoading: false, baseError: null, fundUsable: false})
            this.trigger(Domains.GroupDetail, group)
        }).catch( e => {
            extend(group, {baseLoading: false, baseError: e.message})
            this.trigger(Domains.GroupDetail, group)
        })
    },

    onFetchGroupFundIfNeeded(groupid) {
        var group = this._getDetailGroup(groupid)
        if (!group.fundUsable && !group.fundLoading) {
            group.fundLoading = true
            this.trigger(Domains.GroupDetail, group)
            net.postApi({
                method: '/cooperation/group/sharemoney/detail/get',
                security: false,
                params: {groupid: groupid},
            }).then(rsp => {
                rsp.presentpoolpresent = '60'
                extend(group, {
                    fund: rsp,
                    fundLoading: false,
                    fundError: null,
                    fundUsable: true,
                    fundProgress: parseFloat(rsp.presentpoolpresent/100),
                })
                this.trigger(Domains.GroupDetail, group)
            }).catch(e => {
                extend(group, {fundLoading: false, fundError: e.message, fundUsable: true})
                this.trigger(Domains.GroupDetail, group)
            })
        }
    },

    _getDetailGroup(groupid) {
        if (this.detailGroups[groupid]) {
            return this.detailGroups[groupid]
        }
        var group = {groupID: groupid, fundUsable: false}
        this.detailGroups[groupid] = group
        return group
    }

})

