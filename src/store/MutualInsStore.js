"use strict"
import Reflux from 'reflux'
import net from '../helper/Network'
import {extend} from '../helper/Object'

export const Domains = {
    SimpleGroups: "SimpleGroupsInfoChanged",
    GroupDetail: "GroupDetailInfoChanged",
}

const PageAmount = 10

export var Actions = Reflux.createActions([
    "fetchSimpleGroups",
    "fetchGroupBase",
    "fetchGroupFundIfNeeded",
    "fetchGroupMembersIfNeeded",
    "fetchMoreGroupMembers",
    "fetchGroupMessagesIfNeeded",
    "fetchMoreGroupMessages",
    "fetchGroupMyInfoIfNeeded",
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
        var group = this.getOrCreateDetailGroup(groupid)
        group.base.loading = true
        this.trigger(Domains.GroupDetail, group)
        net.postApi({
            method: '/cooperation/group/config/get',
            security: true,
            params: {
                groupid: groupid,
                memberid: memberid,
            }
        }).then(rsp => {
            extend(group.base, {
                ...rsp,
                loading: false,
                error: null,
            })
            group.fund.usable = false
            group.members.usable = false
            group.messages.usable = false
            this.trigger(Domains.GroupDetail, group)
        }).catch( e => {
            group.base.loading = false
            group.base.error = e.message
            this.trigger(Domains.GroupDetail, group)
        })
    },

    onFetchGroupFundIfNeeded(groupid, force=false) {
        var group = this.getOrCreateDetailGroup(groupid)
        if (force || (!group.fund.usable && !group.fund.loading)) {
            group.fund.loading = true
            this.trigger(Domains.GroupDetail, group)
            net.postApi({
                method: '/cooperation/group/sharemoney/detail/get',
                security: false,
                params: {groupid: groupid},
            }).then(rsp => {

                extend(group.fund, {
                    ...rsp,
                    loading: false,
                    error: null,
                    usable: true,
                    progress: parseFloat(rsp.presentpoolpresent/100),
                })
                this.trigger(Domains.GroupDetail, group)
            }).catch(e => {
                extend(group.fund, {loading: false, error: e.message, usable: true})
                this.trigger(Domains.GroupDetail, group, e.message)
            })
        }
    },

    onFetchGroupMembersIfNeeded(groupid, force=false) {
        var group = this.getOrCreateDetailGroup(groupid)
        if (force || (!group.members.usable && !group.members.loading)) {
            group.members.loading = true
            this.trigger(Domains.GroupDetail, group)
            net.postApi({
                method: '/cooperation/groupmember/list/get',
                security: false,
                params: {groupid: groupid, lstupdatetime: 0},
            }).then(rsp => {
                extend(group.members, {...rsp, loading: false, error: null, usable: true,})
                this.trigger(Domains.GroupDetail, group)
            }).catch(e => {
                extend(group.members, {loading: false, error: e.message, usable: true})
                this.trigger(Domains.GroupDetail, group, e.message)
            })
        }
    },

    onFetchMoreGroupMembers(groupid) {
        var group = this.getOrCreateDetailGroup(groupid)
        var len = group.members.memberlist ? group.members.memberlist.length : 0
        if (!group.members.loadingMore && len > 0 && len % PageAmount == 0) {
            group.members.loadingMore = true
            this.trigger(Domains.GroupDetail, group)
            net.postApi({
                method: '/cooperation/groupmember/list/get',
                security: false,
                params: {groupid: groupid, lstupdatetime: group.members.lstupdatetime},
            }).then(rsp => {
                extend(group.members, {
                    lstupdatetime: rsp.lstupdatetime, loadingMore: false, error: null, usable: true,
                })
                for (var m of rsp.memberlist) {
                    group.members.memberlist.push(m)
                }
                this.trigger(Domains.GroupDetail, group)
            }).catch(e => {
                extend(group.members, {loadingMore: false, error: e.message, usable: true})
                this.trigger(Domains.GroupDetail, group, e.message)
            })
        }
    },

    onFetchGroupMessagesIfNeeded(groupid, force=false) {
        var group = this.getOrCreateDetailGroup(groupid)
        if (force || (!group.messages.usable && !group.messages.loading)) {
            group.messages.loading = true
            this.trigger(Domains.GroupDetail, group)
            net.postApi({
                method: '/cooperation/group/messagelist/get',
                security: false,
                params: {groupid: groupid, lstupdatetime: 0},
            }).then(rsp => {
                extend(group.messages, {...rsp, loading: false, error: null, usable: true,})
                this.trigger(Domains.GroupDetail, group)
            }).catch(e => {
                extend(group.messages, {loading: false, error: e.message, usable: true})
                this.trigger(Domains.GroupDetail, group, e.message)
            })
        }
    },

    onFetchMoreGroupMessages(groupid) {
        var group = this.getOrCreateDetailGroup(groupid)
        var len = group.messages.list ? group.messages.list.length : 0
        if (!group.messages.loadingMore && len > 0 && len % PageAmount == 0) {
            group.messages.loadingMore = true
            this.trigger(Domains.GroupDetail, group)
            net.postApi({
                method: '/cooperation/group/messagelist/get',
                security: false,
                params: {groupid: groupid, lstupdatetime: group.messages.lstupdatetime},
            }).then(rsp => {
                extend(group.messages, {
                    lstupdatetime: rsp.lstupdatetime, loadingMore: false, error: null, usable: true,
                })
                for (var msg of rsp.list) {
                    group.messages.list.push(msg)
                }

                this.trigger(Domains.GroupDetail, group)
            }).catch(e => {
                extend(group.messages, {loadingMore: false, error: e.message, usable: true})
                this.trigger(Domains.GroupDetail, group, e.message)
            })
        }
    },

    fetchGroupMyInfoIfNeeded(groupid, memberid, force=false) {
        var group = this.getOrCreateDetailGroup(groupid)
        if (force || (!group.myInfo.usable && !group.myInfo.loading)) {
            group.myInfo.loading = true
            this.trigger(Domains.GroupDetail, group)
            net.postApi({
                method: '/cooperation/my/detail/get',
                security: true,
                params: {groupid: groupid, memberid: memberid},
            }).then(rsp => {

                extend(group.myInfo, {
                    ...rsp,
                    loading: false,
                    error: null,
                    usable: true,
                })
                this.trigger(Domains.GroupDetail, group)
            }).catch(e => {
                extend(group.myInfo, {loading: false, error: e.message, usable: true})
                this.trigger(Domains.GroupDetail, group, e.message)
            })
        }
    },

    getOrCreateDetailGroup(groupid) {
        if (this.detailGroups[groupid]) {
            return this.detailGroups[groupid]
        }
        var group = {
            groupID: groupid,
            base: {},
            myInfo: {usable: false},
            fund: {usable: false},
            members: {usable: false},
            messages: {usable: false},
        }
        this.detailGroups[groupid] = group
        return group
    }
})

