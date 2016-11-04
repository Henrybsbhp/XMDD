"use strict";
import React, {Component} from 'react';
import {View, Text, Image, StyleSheet, ListView, TouchableOpacity,} from 'react-native';
import BlankView from '../general/BlankView';
import UI from '../../constant/UIConstants';
import GroupDetailView from './GroupDetailView';
import net from '../../helper/Network';

export default class GroupListView extends Component {
    constructor(props) {
        super(props)
        // 设置数据源
        this.ds = new ListView.DataSource({
            rowHasChanged: (r1, r2) => r1 != r2,
            sectionHeaderHasChanged: (s1, s2) => s1 != s2,
        })

        this.state = {loading: true, error: null, datasource: this.ds}
    }

    componentDidMount() {
        this.fetchAllGroups()
    }

    onGroupPress(group) {
        var route = {
            component: GroupDetailView,
            groupName: group.groupname,
            groupID: group.groupid,
            shouldLogin: false,
            title: group.groupname
        };
        this.props.navigator.push(route);
    }

    /// network
    fetchAllGroups() {
        this.setState({loading: true})
        net.postApi({
            method: '/cooperation/group/get',
            security: false,
            params: {status: 1},
        }).then(rsp => {
            this.setState({
                loading: false, error: null, groupTouchable: rsp.showdetailflag == 1,
                datasource: this.ds.cloneWithRows(rsp.grouplist)
            })
        }).catch(e => {
            this.setState({loading: false, error: e.message})
        })
    }

    render() {
        return (
            <BlankView style={styles.container}
                       visible={Boolean(this.state.loading || this.state.error)}
                       text={this.state.error}
                       loading={this.state.loading}
                       onPress={this.fetchAllGroups.bind(this)}>
                <ListView style={styles.listView}
                          dataSource={this.state.datasource}
                          automaticallyAdjustContentInsets={false}
                          renderRow={this.renderGroup.bind(this)}
                />
            </BlankView>
        )
    }

    renderGroup(group) {
        return (
            <View style={styles.groupCell} key={group.groupid}>
                <TouchableOpacity style={styles.groupCellContent}
                                  disabled={!this.state.groupTouchable}
                                  onPress={() => {this.onGroupPress(group)}}>
                    <View style={[styles.HContainer, {marginTop: 17}]}>
                        <Text style={styles.groupName}>{group.groupname}</Text>
                        <Text style={styles.peopleNumber}>
                            {group.totalcnt}
                            <Text style={styles.peopleNumberSuffix}>人</Text>
                        </Text>
                    </View>
                    <View style={styles.tagListView}>{group.grouptags.map(this.renderTag)}</View>
                    {group.extendinfo && group.extendinfo.map(x => this.renderExtendInfo(x))}
                </TouchableOpacity>
            </View>
        )
    }

    renderTag(tag) {
        return (
            <View style={styles.tagView} key={tag}>
                <Text style={styles.tagText}>{tag}</Text>
            </View>
        )
    }

    renderExtendInfo(info) {
        var key = Object.keys(info)[0]
        var value = info[key]
        return (
            <View style={styles.HContainer} key={key}>
                <Text style={styles.extendTitle}>{key}</Text>
                <Text style={styles.extendDetail}>{value}</Text>
            </View>
        )
    }
}


const styles = StyleSheet.create({
    container: {flex: 1, backgroundColor: 'white'},
    listView: {flex: 1, backgroundColor: UI.Color.Background, paddingBottom: 10},

    groupCell: {marginTop: 10 , backgroundColor: 'white'},
    groupCellContent: {paddingBottom: 19},
    HContainer: {flexDirection: 'row', marginHorizontal: 16, justifyContent: 'space-between', marginTop: 10},

    groupName: {fontSize: 16, color: UI.Color.DarkText},
    peopleNumber: {color: UI.Color.Orange, fontSize: 25, textAlign: 'right'},
    peopleNumberSuffix: {fontSize: 15},

    tagListView: {flexDirection: 'row', paddingLeft: 16, marginTop: 10},
    tagView: {
        ...UI.Style.Btn, borderWidth: 1, borderColor: UI.Color.Orange, borderRadius:11 , height: 22, marginRight: 11
    },
    tagText: {fontSize: 14, color: UI.Color.Orange, marginHorizontal: 11},

    extendTitle: {fontSize: 13, color: UI.Color.GrayText},
    extendDetail:{fontSize: 13, color: UI.Color.GrayText, textAlign: 'right'},
})

