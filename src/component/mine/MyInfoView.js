import React, {
    Component,
} from 'react';
import {
    AppRegistry,
    Image,
    Text,
    View,
    StyleSheet,
    ScrollView,
    ListView,
    TouchableHighlight,
    NativeModules,
    ActionSheetIOS,
    DatePickerIOS
} from 'react-native';
import moment from 'moment';
import DatePicker from '../general/HKDatePicker';
import HudView from '../general/HudView';
import network from '../../model/Network';
import EditMyinfoView from './EditMyInfoView';
import GeneralStyle from '../../model/Style';
import NavigatorView, {NavBarRightItem} from '../general/NavigatorView';
import BlankView from '../general/BlankView';

const EventEmitter = require('events').EventEmitter;

const styles = StyleSheet.create({
    contaienr: {
        flex:1,
    },
    bg: {
        backgroundColor: '#F7F7F8',
        flex: 1,
    },
    content: {
        flex: 1,
        flexDirection: 'row',
        justifyContent: 'space-between'
    },
    avatar: {
        width: 65,
        height: 65,
        marginRight: 17,
        alignSelf: 'center',
        borderRadius: 32.5,
    },
    cell: {
        backgroundColor: 'white',
        height: 49,
    },
    title: {
        marginLeft: 15,
        fontSize: 16,
        color: '#454545',
        alignSelf: 'center'
    },
    arrow: {
        marginRight: 11,
        width: 9,
        height: 15,
        alignSelf: 'center'
    },
    subTitle: {
        fontSize: 16,
        color: '#888888',
        alignSelf: 'center',
        paddingHorizontal: 8,
        textAlign: 'right',
        flex: 1
    },
    logout: {
        textAlign: 'center',
        fontSize: 18,
        color: '#E32D3B',
        alignSelf: 'center',
        flex: 1
    },
    separator: {
        backgroundColor: '#EBEBEB',
        height: 0.5,
        marginLeft: 12,
        justifyContent: 'flex-end'
    },

});

export default class MyInfoView extends Component {
    constructor(props) {
        super(props);
        var ds = new ListView.DataSource({
            rowHasChanged: (r1, r2) => r1 != r2,
            sectionHeaderHasChanged: (s1, s2) => s1 != s2,
        });
        this.ds = ds;
        var dataBlob = {
                header: [{render: this.renderHeaderCell.bind(this), title:'头像', key:'avatar',
                            onClick:this.actionPickAvatar.bind(this)}],
                normal: [
                    {render: this.renderNormalCell.bind(this), title:'昵称', key:'nickname', onClick:this.actionEdit},
                    {render: this.renderNormalCell.bind(this), title:'性别', key:'sex',
                        onClick:this.actionPickSex.bind(this), getValue: this.descForSexType},
                    {render: this.renderNormalCell.bind(this),title:'出生日期', key:'birthday',
                        onClick:this.actionPickDate.bind(this), getValue: this.descForBirthday},
                    {render: this.renderNormalCell.bind(this), title:'手机号', key:'phone', onClick:this.actionEdit,
                        disable:true}],
                bottom: [{render: this.renderBottomCell.bind(this), title:'退出当前账号', onClick:this.actionLogout}]
        };
        this.state = {
            datePickerVisible: false,
            defAvatar: 'Common_Avatar_imageView',
            dataBlob:dataBlob,
            dataSource: ds.cloneWithRowsAndSections(dataBlob),
            loading: true,
        };
    }

    componentDidMount() {
        this.requestMyInfo();
    }

    componentDidUpdate() {
        this.state.datePickerVisible = false;
    }

    ////Request
    //请求获取个人信息
    requestMyInfo() {
        this.refs.hudView.showSpinner();
        network.postApi({method: "/user/basicinfo/get", security: true})
            .then(rsp => {
                this.refs.hudView.hide();
                var birthday = rsp['birthday'];
                birthday = rsp['birthday'] ? moment(rsp['birthday'], 'YYYYMMDD').toDate() : null;
                this.reloadState({
                    loading: false,
                    avatar: rsp['avatar'],
                    nickname: rsp['nickname'],
                    birthday: birthday,
                    sex: rsp['sex'],
                    phone: rsp['phone']
                });
            })
            .catch(error => {
                this.refs.hudView.showError(error);
            })
    }

    requestUpdateMyInfo(info) {
        var newState = Object.assign({}, this.state, info);
        this.refs.hudView.showSpinner();
        return network.postApi({
            method: "/user/basicinfo/update", security: true,
            params: {
                nickname: newState.nickname,
                avatar: newState.avatar,
                sex: newState.sex,
                birthday: newState.birthday ? moment(newState.birthday).format('YYYYMMDD') : null
            }})
            .then(rsp => {
                this.refs.hudView.hide();
                return newState;
            })
            .catch(error => {
                this.refs.hudView.showError(error);
            })
    }

    //// Cell
    renderHeaderCell(row) {
        return (
            <TouchableHighlight onPress={row.onClick}>
                <View style={[styles.cell, {height: 90}]}>
                    <View style={styles.content}>
                        <Text style={styles.title}>{row.title}</Text>
                        <Image
                            source={{uri: this.state.avatar}}
                            style={styles.avatar}
                            defaultSource={{uri: this.state.defAvatar}}
                            onLoad={() => this.state.defAvatar = null}
                        />
                    </View>
                </View>
            </TouchableHighlight>
        )
    }

    renderNormalCell(row, sectionID, rowID) {
        var isLastRow = this.state.dataBlob[sectionID].length == Number(rowID) + 1;
        var isFirstRow = rowID == '0';
        return (
            <TouchableHighlight disabled={row.disable} onPress={()=>{row.onClick.bind(this)(row)}}
                                style={isFirstRow ? {marginTop: 8}: null}>
                <View style={styles.cell}>
                    <View style={styles.content}>
                        <Text style={styles.title}>{row.title}</Text>
                        <Text style={[styles.subTitle, row.disable ? {marginRight: 23} : null]}>
                            {row.getValue ? row.getValue(this.state[row.key]) : this.state[row.key]}
                        </Text>
                        {row.disable ? null : <Image style={styles.arrow} source={{uri: 'cm_arrow_r'}}/>}
                    </View>
                    { isLastRow ? null : <View style = {styles.separator}/> }
                </View>
            </TouchableHighlight>
        )
    }

    renderBottomCell(row) {
        return (
            <TouchableHighlight onPress={row.onClick} style={{marginTop: 8}}>
                <View style={[styles.cell, {height: 50}]}>
                    <View style = {styles.content}>
                        <Text style = {styles.logout}>{row.title}</Text>
                    </View>
                </View>
            </TouchableHighlight>
        )
    }

    //// Action
    actionEdit(row) {
        var emitter = new EventEmitter();
        var rightItem = {
            component: NavBarRightItem,
            text: '保存',
            onPress: (route, navigator) => {
                emitter.emit('onSave', (newValue) => {
                    var info = {};
                    info[row.key] = newValue;
                    console.log(info);
                    this.requestUpdateMyInfo(info)
                        .then((newState)=> {
                            navigator.pop();
                            this.reloadState(newState);
                            NativeModules.AppManager.setAppManagerKeyPath('myUser.userName', newValue);
                        });
                })
            }
        };

        var route = {
            component: EditMyinfoView,
            title: '修改' + row.title,
            key: row.key,
            value: row.getValue ? row.getValue(this.state[row.key]) : this.state[row.key],
            rightItem: rightItem,
            emitter: emitter,
        };
        this.props.navigator.push(route);
    }

    actionPickAvatar() {
        var ImagePicker = NativeModules.ImagePickerManager;
        var options = {
            title: '选取照片',
            cancelButtonTitle: '取消',
            takePhotoButtonTitle: '拍照',
            chooseFromLibraryButtonTitle: '从相册选择',
            cameraType: 'back', // 'front' or 'back'
            mediaType: 'photo', // 'photo' or 'video'
            maxWidth: 1024, // photos only
            maxHeight: 1024, // photos only
            quality: 0.3, // 0 to 1, photos only
            allowsEditing: true, // Built in functionality to resize/reposition the image after selection
            noData: false, // photos only - disables the base64 `data` field from being generated (greatly improves performance on large photos)
            storageOptions: { // if this key is provided, the image will get saved in the documents directory on ios, and the pictures directory on android (rather than a temporary directory)
                skipBackup: true, // ios only - image will NOT be backed up to icloud
                path: 'images' // ios only - will save image at /Documents/images rather than the root
            }
        };

        ImagePicker.showImagePicker(options, (response) => {
            console.log(this.requestUpdateMyInfo)
            if (response.didCancel || response.error) {
                console.log('User cancelled image picker');
            }
            else if (response.error) {
                console.log('ImagePickerManager Error: ', response.error);
            }
            else {
                var url = response.uri;
                var rspUrl;
                network.uploadImage(url)
                    .then(rsp => {
                        console.log(rsp)
                        rspUrl = rsp.url;
                        return this.requestUpdateMyInfo({avatar: rsp.url})
                    })
                    .then(newState => {
                        newState.avatar = rspUrl;
                        this.reloadState(newState);
                        NativeModules.AppManager.setAppManagerKeyPath('myUser.avatarUrl', rspUrl)
                    })
            }
        });
    }

    actionPickSex() {
        function callback(index) {
            if (index != 3) {
                this.requestUpdateMyInfo({sex: index + 1})
                    .then(this.reloadState.bind(this))
            }
        }

        ActionSheetIOS.showActionSheetWithOptions({
            options:['男', '女', '取消'],
            cancelButtonIndex:2,
            title:'请选择性别'
        }, callback.bind(this));
    }

    actionPickDate() {
        this.setState({datePickerVisible: true});
    }

    actionChangeBirthday(date) {
        this.requestUpdateMyInfo({birthday: date})
            .then(this.reloadState.bind(this))
    }

    actionLogout() {
        NativeModules.LoginManager.logout();
        NativeModules.NavigationManager.popViewAnimated(true);
    }

    //// Util
    descForSexType(sex) {
        return sex == 2 ? '女' : '男';
    }

    descForBirthday(birthday) {
        console.log(birthday);
        return birthday ? moment(birthday).format('YYYY年MM月DD日') : null;
    }

    reloadState(states) {
        this.setState({
            ...states,
            dataSource: this.ds.cloneWithRowsAndSections(this.state.dataBlob),
        })
    }

    //// Render
    render() {
        return (
            <HudView ref="hudView" style={[this.props.style, styles.contaienr]}>
                <BlankView visible={false}>
                    <ListView
                        style={styles.bg}
                        dataSource={this.state.dataSource}
                        renderRow={(row, sid, rid) => row.render(row, sid, rid)}
                    />
                    <DatePicker
                        visible={this.state.datePickerVisible}
                        mode="date"
                        date={this.state.birthday ? this.state.birthday : moment('19900101', 'YYYYMMDD').toDate()}
                        maxDate={new Date()}
                        onConfirm={this.actionChangeBirthday.bind(this)}
                    />
                </BlankView>
            </HudView>
        );
    }
}



