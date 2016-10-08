    "use strict";
import React, {Component, PropTypes} from 'react';
import {View, StyleSheet, Text, TouchableOpacity, Image, ListView} from 'react-native';
import UI from '../../constant/UIConstants';
import BlankView from '../general/BlankView';
import Store, {Actions} from '../../store/MutualInsStore';
import LoadingView from '../general/loading/LoadingView';

export default class GroupDetailMessagesView extends Component {

    constructor(props) {
        super(props)
        this.ds = new ListView.DataSource({
            rowHasChanged: (r1, r2) => r1 != r2,
            sectionHeaderHasChanged: (s1, s2) => s1 != s2,
        })
        this.state = this.reloadState(props)
    }

    componentDidMount() {
        Actions.fetchGroupMessagesIfNeeded(this.props.route.groupID)
    }

    componentWillReceiveProps(props) {
        this.setState(this.reloadState(props))
    }

    reloadState(props) {
        var msgs = props.messages
        var state = {
            dataSource: this.ds,
            messages: msgs,
            loading: !msgs.usable || msgs.loading,
            error: msgs.error,
        }
        state.blankImage = state.error ? {name: 'def_failConnect', width: 152, height: 152} :
            {name: 'def_noGroupMessages', width: 153, height: 154};
        if (!state.loading && !state.error && (!state.messages.list || state.messages.list.length == 0)) {
            state.error = '暂无任何成员动态'
        }
        state.blankVisible = Boolean(state.loading || state.error)

        if (!state.blankVisible) {
            var datas = []
            for (var msg of state.messages.list) {
                datas.push(msg)
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
                       onPress={()=>{Actions.fetchGroupMessagesIfNeeded(this.props.route.groupID, true)}}
            >
                <ListView style={styles.container}
                          dataSource={this.state.dataSource}
                          onEndReached={() => {Actions.fetchMoreGroupMessages(this.props.route.groupID)}}
                          renderRow={this.renderRow.bind(this)}
                />
            </BlankView>
        )
    }

    renderRow(row, sid, rid) {
        if (row && row.render) {
            return row.render(row, sid, rid)
        }
        return this.renderMessage(row)
    }

    renderMessage(message) {
        var isRight = message.memberid === this.props.route.memberID
        return (
            <View>
                <View style={styles.timeContainer}>
                    <Image style={styles.timeBackground}
                           resizeMode="stretch"
                           capInsets={{top: 5, left: 5, bottom: 5, right: 5}}
                           source={{uri: 'mins_bg_gary'}} />
                    <Text style={styles.time}>{message && message.time}</Text>
                </View>
                {isRight ? this.renderRightContent(message) : this.renderLeftContent(message)}
            </View>
        )
    }

    renderLeftContent(message) {
        return (
            <View style={styles.contentContainer}>
                <Image style={styles.logo}
                       source={{uri: message.carlogourl}}
                       defaultSource={UI.Img.DefaultMutInsCarBrand}
                />
                <View>
                    <Text style={[styles.title, {marginLeft: 8}]}>
                        {message.licensenumber}
                    </Text>
                    <View style={styles.messageContainer}>
                        <Image style={[styles.messageBackground, {left: 5}]}
                               resizeMode="stretch"
                               capInsets={{top: 22, left: 8, bottom: 5, right: 8}}
                               source={{uri: 'mins_bubble_left'}}
                        />
                        <Text style={[styles.message, {marginLeft: 19}]}>
                            {message.content}
                        </Text>
                    </View>
                </View>
            </View>
        )
    }

    renderRightContent(message) {
        return (
            <View style={[styles.contentContainer, {justifyContent: 'flex-end'}]}>
                <View>
                    <Text style={[styles.title, {marginRight: 8, textAlign: 'right'}]}>
                        {message.licensenumber}
                    </Text>
                    <View style={styles.messageContainer}>
                        <Image style={[styles.messageBackground, {right: 5}]}
                               resizeMode="stretch"
                               capInsets={{top: 22, left: 8, bottom: 5, right: 8}}
                               source={{uri: 'mins_bubble_right'}}
                        />
                        <Text style={[styles.message, {marginRight: 19, color: 'white'}]}>
                            {message.content}
                        </Text>
                    </View>
                </View>
                <Image style={styles.logo}
                       source={{uri: message.carlogourl}}
                       defaultSource={UI.Img.DefaultMutInsCarBrand}
                />
            </View>
        )
    }


    renderLoadMore() {
        return (
            <View style={styles.loadingContainer}>
                <LoadingView loading={Boolean(this.state.messages.loadingMore)}
                             animationType={LoadingView.Animation.MON}
                             style={styles.loading}/>
            </View>
        )
    }
}

const styles = StyleSheet.create({
    container: {backgroundColor: UI.Color.Background},
    loadingContainer: {height: 30, backgroundColor: UI.Color.Background},
    loading: {flex: 1},

    timeContainer: {alignSelf: 'center', height: 16, justifyContent: 'center', marginTop: 16},
    timeBackground: {position: 'absolute', left: 0, right: 0, top: 0, bottom: 0},
    time: {fontSize: 12, color: 'white', backgroundColor: UI.Color.Clear, paddingHorizontal: 8},

    contentContainer: {flexDirection: 'row', marginHorizontal: 15, marginTop: 18},
    logo: {width: 45, height: 45},
    title: {height: 16, fontSize: 12, color: UI.Color.GrayText},
    messageContainer: {maxWidth: UI.Win.Width - 45 - 15 - 5 - 70, marginTop: 3},
    messageBackground: {position: 'absolute', top: 0, left: 0, bottom: 0, right: 0},
    message: {
        marginHorizontal: 12, marginVertical: 12, fontSize: 14, color: UI.Color.DarkText,
        backgroundColor: UI.Color.Clear
    },
})