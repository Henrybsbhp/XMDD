"use strict";

import React, {Component} from 'react';
import {
    View, StyleSheet, Text, TouchableOpacity, Image, ScrollView, TouchableWithoutFeedback, TextInput, NativeModules
} from 'react-native';
import Toast from 'react-native-root-toast';
import UI from '../../constant/UIConstants';
import BlankView from '../general/BlankView';
import ImageUploadingView from '../general/ImageUploadingView';
import net from '../../helper/Network';
import HudView from '../general/HudView';
import UploadResultView from './UploadResultView';

const NavigationManager = NativeModules.NavigationManager;

export default class UploadInfoView extends Component {
    constructor(props) {
        super(props)
        var car = this.props.route.car
        this.state = {
            insCompany: null, oldInsCompany: null, checked: true, loading: false, error: null, province: '浙',
            plateNumber: car && car.licensenumber && car.licensenumber.substr(1),
            idpic: null, carpic: null,
        }
    }

    componentDidMount() {
        if (this.props.route.memberID && this.props.route.memberID > 0) {
            this.fetchIDLicenseInfo()
        }
    }

    /// Callback
    chooseProvince() {
        NavigationManager.presentPlateNumberProvincePicker(info => {
            this.setState({province: Object.keys(info)[0]})
        })
    }

    chooseInsCompany() {
        NavigationManager.pushInsuanceCompanyPicker(name => {
            this.setState({insCompany: name})
        })
    }

    chooseOldInsCompany() {
        NavigationManager.pushInsuanceCompanyPicker(name => {
            this.setState({oldInsCompany: name})
        })
    }

    onCheckboxPress() {
        this.setState({checked: !this.state.checked})
    }

    onSubmit() {
        var rexp = /^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵黔粤粵青藏川宁琼使][a-z][a-z0-9]{5}[警港澳领学]{0,1}$/i
        if (!rexp.test(this.state.province + this.state.plateNumber)) {
            this.showToast('请输入正确的车牌号码')
        }
        else if (!this.state.idpic) {
            this.showToast('请上传身份证照片')
        }
        else if (this.refs.idpic.state.fail) {
            this.showToast('请重新上传身份证照片')
        }
        else if (!this.state.carpic) {
            this.showToast('请上传行驶证照片')
        }
        else if (this.refs.carpic.state.fail) {
            this.showToast('请上重新传行驶证照片')
        }
        else if (this.refs.idpic.uploading || this.refs.carpic.uploading) {
            this.showToast('请等待图片上传成功')
        }
        else if (!this.state.insCompany) {
            this.showToast('请选择现保险公司')
        }
        else  {
            this.uploadInfo()
        }
    }

    onPlateNumberChanged(text) {
        this.setState({plateNumber: text && text.toUpperCase()})
    }

    showToast(message, config) {
        Toast.show(message, {
            duration: Toast.durations.SHORT,
            position: Toast.positions.CENTER,
            shadow: false,
            ...config
        });
    }

    /// Request
    fetchIDLicenseInfo() {

    }

    uploadInfo() {
        this.refs.hud.showSpinner()
        net.postApi({
            method: '/cooperation/idlicense/info/update/v2',
            security: true,
            params: {
                idurl: this.state.idpic,
                licenseurl: this.state.carpic,
                firstinscomp: this.state.insCompany ? this.state.insCompany : '',
                secinscomp: this.state.oldInsCompany ? this.state.oldInsCompany : '',
                memberid: this.props.route.memberID ? this.props.route.memberID : 0,
                groupid: this.props.route.groupID ? this.props.route.groupID : 0,
                isbuyfroceins: this.state.checked ? 1 : 0,
                licensenumber: this.state.province + this.state.plateNumber,
                usercarid: this.props.route.car && this.props.route.car.usercarid,
            }
        }).then(rsp => {
            this.refs.hud.hide()
            var route = {
                component: UploadResultView, title: '提交成功', couponList: rsp.couponlist, memberID: rsp.memberid,
                groupID: this.props.groupID
            }
            this.props.navigator.push(route);
        }).catch(e => {
            this.refs.hud.hide()
            this.showToast(e.message, {duration: Toast.durations.LONG})
        })
    }

    render() {
        return (
            <HudView ref="hud">
                <BlankView style={styles.container}
                           visible={this.state.loading || this.state.error}
                           text={this.state.error}
                           onPress={this.fetchIDLicenseInfo.bind(this)}>
                    <ScrollView style={{flex: 1}}>
                        {this.renderPlateNumber()}
                        <View style={styles.picturesCell}>
                            <Text style={styles.picturesCellTitle}>请上传车主身份证照片</Text>
                            <ImageUploadingView ref="idpic"
                                                style={styles.picturesCellImage}
                                                exampleSource={{uri: 'ins_pic1'}}
                                                onUpload={(url) => {
                                                    this.state.idpic = url
                                                }}/>
                            <Text style={styles.picturesCellTitle}>请上传车辆行驶证照片</Text>
                            <ImageUploadingView ref="carpic"
                                                style={styles.picturesCellImage}
                                                exampleSource={{uri: 'ins_pic2'}}
                                                onUpload={(url) => {
                                                    this.state.carpic = url
                                                }}/>
                        </View>
                        <View style={{backgroundColor: 'white', marginTop: 8}}>
                            <View style={styles.insSection}>
                                <Text style={styles.insSectionTitle}>请选择保险公司</Text>
                            </View>
                            {this.renderInsCompanyCell(
                                '请选择当前投保的保险公司',
                                ' (必填)',
                                this.state.insCompany,
                                this.chooseInsCompany.bind(this))}
                            {this.renderInsCompanyCell(
                                '请选择3年内投保过的其他保险公司',
                                ' (选填)',
                                this.state.oldInsCompany,
                                this.chooseOldInsCompany.bind(this)
                            )}
                        </View>
                        {this.renderStrongInsCell()}
                    </ScrollView>
                    {this.renderBottomView()}
                </BlankView>
            </HudView>
        )
    }

    renderPlateNumber() {
        var disabled = Boolean(this.props.route.car && this.props.route.car.licensenumber)
        return (
            <View style={styles.licenseCell}>
                <Text style={styles.licenseCellTitle}>车牌号码</Text>
                <View style={{marginRight: 26, flexDirection: 'row'}}>
                    <TouchableOpacity style={styles.licenseCellProvinceBtn}
                                      disabled={disabled}
                                      onPress={this.chooseProvince.bind(this)}>
                        <Image style={UI.Style.BgImg}
                               capInsets={{top: 5, left: 5, bottom: 5, right: 5}}
                               source={{uri: 'ins_bg_border_green'}}/>
                        <Text style={styles.licenseCellProvinceTitle}>{this.state.province}</Text>
                        <Image source={{uri: 'mec_arrow', width: 11, height: 5}}/>
                    </TouchableOpacity>
                    <TextInput style={styles.licenseCellPlateNumber}
                               maxLength={6}
                               placeholder="填写车牌"
                               value={this.state.plateNumber}
                               editable={!disabled}
                               onChangeText={this.onPlateNumberChanged.bind(this)}/>
                </View>
            </View>
        )
    }

    renderInsCompanyCell(placehold, subPlacehold, value, onChanged) {
        return (
            <View>
                <View style={[styles.HLine, {marginLeft: 26}]}/>
                <TouchableOpacity style={styles.insCell} onPress={onChanged}>
                    <Text style={[styles.insCellInput, {color: value ? UI.Color.DarkText : UI.Color.LightGray}]}>
                        {value || placehold}
                        {!value && subPlacehold && (<Text style={{fontSize: 13}}>{subPlacehold}</Text>)}
                    </Text>
                    <Image style={styles.insCellArrow} source={{uri: 'mutualInsjoin_arrow'}}/>
                </TouchableOpacity>
            </View>
        )
    }

    renderStrongInsCell() {
        var checkbox = this.state.checked ? 'checkbox_selected' : 'checkbox_normal_301'
        return (
            <View style={styles.strongInsCell}>
                <TouchableWithoutFeedback onPress={this.onCheckboxPress.bind(this)}>
                    <Image style={styles.checkbox} source={{uri: checkbox, width: 18, height: 18}}/>
                </TouchableWithoutFeedback>
                <Text style={styles.strongInsCellTitle}>需要代买交强险与车船税</Text>
            </View>
        )
    }

    renderBottomView() {
        return (
            <View style={styles.bottomView}>
                <View style={styles.HLine}/>
                <TouchableOpacity style={styles.bottomButton} onPress={this.onSubmit.bind(this)}>
                    <Image style={UI.Style.BgImg}
                           capInsets={{top: 5, left: 5, bottom: 5, right: 5}}
                           source={UI.Img.BtnBgGreen}/>
                    <Text style={styles.bottomButtonTitle}>提交资料</Text>
                </TouchableOpacity>
            </View>
        )
    }
}

const styles = StyleSheet.create({
    container: {backgroundColor: UI.Color.Background},
    licenseCell: {
        flexDirection: 'row', alignItems: 'center', backgroundColor: 'white', height: 45,
        justifyContent: 'space-between'
    },
    licenseCellTitle: {fontSize: 17, color: UI.Color.DarkText, marginLeft: 24},
    licenseCellProvinceBtn: {...UI.Style.Btn, paddingHorizontal: 7, height: 27},
    licenseCellProvinceTitle: {fontSize: 16, color: UI.Color.DefaultTint, marginRight: 5},
    licenseCellPlateNumber: {fontSize: 17, color: UI.Color.DarkText, textAlign: 'right', width: 80,},

    picturesCell: {marginTop: 8, backgroundColor: 'white', paddingBottom: 15},
    picturesCellTitle: {marginLeft: 28, fontSize: 14, color: UI.Color.GrayText, marginVertical: 11},
    picturesCellImage: {
        alignSelf: 'center', width: UI.Win.Width - 56, height: 320/620 * (UI.Win.Width - 56),
    },

    insSection: {flexDirection: 'row', alignItems: 'center', height: 40},
    insSectionTitle: {fontSize: 14, color: UI.Color.GrayText, alignSelf: 'center', marginLeft: 28},

    insCell: {height: 48, alignItems: 'center', justifyContent: 'space-between', flexDirection: 'row'},
    insCellArrow: {width: 10, height: 18, marginRight: 28},
    insCellInput: {fontSize: 16, color: UI.Color.DarkText, marginLeft: 28},
    HLine: {height: 0.5, backgroundColor: UI.Color.Line},

    strongInsCell: {
        flexDirection: 'row', alignItems: 'center', paddingHorizontal: 24, backgroundColor: 'white',
        height: 58, marginVertical: 8,
    },
    strongInsCellTitle: {fontSize: 16, color: UI.Color.DarkText, marginLeft: 3},
    checkbox: {margin: 5},

    bottomView: {height: 70, backgroundColor: 'white'},
    bottomButton: {...UI.Style.Btn, height: 50, marginHorizontal: 17, flex: 1, marginVertical: 10},
    bottomButtonTitle: {fontSize: 17, color: 'white'},
})