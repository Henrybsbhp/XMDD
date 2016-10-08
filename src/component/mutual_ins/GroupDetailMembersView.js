"use strict";
import React, {Component, PropTypes} from 'react';
import {View, StyleSheet, Text, TouchableOpacity, Image, ListView} from 'react-native';
import HtmlView from 'react-native-htmlview';
import UI from '../../constant/UIConstants';
import BlankView from '../general/BlankView';
import Store, {Actions} from '../../store/MutualInsStore';
import LoadingView from '../general/loading/LoadingView';

export default class GroupDetailMemberView extends Component {

    constructor(props) {
        super(props)
        this.ds = new ListView.DataSource({
            rowHasChanged: (r1, r2) => r1 != r2,
            sectionHeaderHasChanged: (s1, s2) => s1 != s2,
        })
        this.state = this.reloadState(props)
    }

    componentDidMount() {
        Actions.fetchGroupMembersIfNeeded(this.props.route.groupID)
    }

    componentWillReceiveProps(props) {
        this.setState(this.reloadState(props))
    }

    reloadState(props) {
        var members = props.members
        var state = {
            members: members,
            loading: !members.usable || members.loading,
            error: members.error,
            dataSource: this.ds,
        }
        state.blankImage = state.error ? {name: 'def_failConnect', width: 152, height: 152} :
            {name: 'def_noGroupMembers', width: 153, height: 153};
        if (!state.loading && !state.error && (!state.members.memberlist || state.members.memberlist.length == 0)) {
            state.error = '暂无任何成员加入'
        }
        state.blankVisible = Boolean(state.loading || state.error)

        if (!state.blankVisible) {
            var datas = [{render: this.renderSection.bind(this), members: state.members}]
            for (var member of state.members.memberlist) {
                datas.push(member)
            }
            datas.push({render: this.renderLoadMore.bind(this)})
            state.dataSource = this.ds.cloneWithRows(datas)
        }
        return state
    }

    render() {
        return (
            <BlankView loading={this.state.loading}
                       loadingOffset={-72}
                       visible={this.state.blankVisible}
                       image={this.state.blankImage}
                       text={this.state.error}
                       onPress={()=>{Actions.fetchGroupMembersIfNeeded(this.props.route.groupID, true)}}
            >
                <ListView style={styles.container}
                          dataSource={this.state.dataSource}
                          onEndReached={() => {Actions.fetchMoreGroupMembers(this.props.route.groupID)}}
                          renderRow={this.renderRow.bind(this)}
                />
            </BlankView>
        )
    }

    renderRow(row, sid, cid) {
        if (row.render) {
            return row.render(row, sid, cid)
        }
        return this.renderMember(row)
    }

    renderSection({members}) {
        var memberCount = members.membercnt ? members.membercnt : 0
        var title = `当前团员共${memberCount}人`
        var tipView = null
        if (members.toptip && members.toptip.length > 0) {
            tipView = this.renderTip(false, members.toptip)
        }
        return (
            <View>
                <View style={styles.sectionContainer}>
                    <Text style={styles.section}>{title}</Text>
                    {tipView}
                </View>
            </View>
        )
    }

    renderTip(hollow, text) {
        return (
            <View style={[styles.tipContainer, hollow ? null : {top: 10}]}>
                <Image source={{url: hollow ? 'mins_tip_bg1' : 'mins_tip_bg2'}}
                       capInsets={{top: 0, left: 13, bottom: 0, right: 0}}
                       style={styles.tipBg}/>
                <Text style={[styles.tipTitle, hollow ? null : {color: 'white'}]}>
                    {text}
                </Text>
            </View>
        )
    }

    renderMember(m) {
        var tipView = null
        if (m.statusdesc && m.statusdesc.length > 0) {
            tipView = this.renderTip(true, m.statusdesc)
        }
        return (
            <View style={styles.memberContainer}>
                <View style={styles.line}/>
                <View style={styles.brandContainer}>
                    <Image source={m.carlogourl ? {uri: m.carlogourl} : undefined}
                           defaultSource={UI.Img.DefaultMutInsCarBrand}
                           style={styles.logo}/>
                    <Text style={styles.title}>{m.licensenumber}</Text>
                </View>
                {tipView}
                {m.extendinfo && m.extendinfo.map(this.renderMemberExtendInfo.bind(this))}
            </View>
        )
    }

    renderMemberExtendInfo(dict) {
        var key = Object.keys(dict)[0]
        var value = dict[key]
        return (
            <View style={styles.extendsContainer} key={key}>
                <Text style={styles.extendsLeft}>{key}</Text>
                <Text style={styles.extendsRight}>
                    <HtmlView value={value}/>
                </Text>
            </View>
        )
    }

    renderLoadMore() {
        return (
            <View style={styles.loadingContainer}>
                <LoadingView loading={Boolean(this.state.members.loadingMore)}
                             animationType={LoadingView.Animation.MON}
                             style={styles.loading}/>
            </View>
        )
    }
}

const styles = StyleSheet.create({
    container: {backgroundColor: UI.Color.Background},

    sectionContainer: {flexDirection: 'row', height: 42, marginTop: 8, alignItems: 'center', backgroundColor: 'white'},
    section: {color: UI.Color.DarkText, fontSize: 14, marginLeft: 16},
    line: {backgroundColor: UI.Color.Line, marginLeft: 14, height: 0.5},

    tipContainer: {height: 23, position: 'absolute', right: 0, top: 7, justifyContent: 'center'},
    tipBg: {position: 'absolute', top: 0, left: 0, bottom: 0, right: 0, resizeMode: 'stretch'},
    tipTitle: {color: UI.Color.Orange, marginLeft: 23, marginRight: 14, backgroundColor: UI.Color.Clear},

    memberContainer: {backgroundColor: 'white', paddingBottom: 10},
    brandContainer: {flexDirection:'row', alignItems: 'center', marginTop: 21},
    logo: {width: 40, height: 40, marginLeft: 16},
    title: {fontSize: 17, color: UI.Color.DarkText, marginLeft: 10},

    extendsContainer: {
        flexDirection: 'row', alignItems: 'center', height: 20, justifyContent: 'space-between', marginTop: 6
    },
    extendsLeft: {fontSize: 13, color: UI.Color.GrayText, marginLeft: 16},
    extendsRight: {marginLeft: 5, marginRight: 16, color: UI.Color.DarkText, fontSize: 13},

    loadingContainer: {height: 30, backgroundColor: UI.Color.Background},
    loading: {flex: 1},
})

