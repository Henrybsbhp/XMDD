"use strict";

import React, {Component} from 'react';
import {View, StyleSheet, Text, TouchableOpacity, Image, ListView} from 'react-native';
import UI from '../../constant/UIConstants';
import UploadInfoView from './UploadInfoView';

export default class ChooseCarView extends Component {
    constructor(props) {
        super(props)
        // 设置数据源
        this.ds = new ListView.DataSource({
            rowHasChanged: (r1, r2) => r1 != r2,
            sectionHeaderHasChanged: (s1, s2) => s1 != s2,
        })
        this.state = {datasource: this.createDatasource(this.props.route.cars), loading: true, error: null}
    }

    createDatasource(cars) {
        var rows = []
        for (var car of cars) {
            rows.push({render: this.renderCarCell.bind(this), car: car})
        }
        rows.push({render: this.renderOtherCell.bind(this)})
        return this.ds.cloneWithRows(rows)
    }

    /// Actions
    onCellPress(car) {
        var route = {component: UploadInfoView, title: '完善入团信息', car: car}
        this.props.navigator.push(route);
    }

    render() {
        return (
            <ListView style={styles.container}
                      dataSource={this.state.datasource}
                      renderRow={(row, sid, rid) => row.render(row, sid, rid)}/>
        )
    }

    renderCarCell(row) {
        var logo = row.car.carlogourl  && row.car.carlogourl.length > 0 ? {uri: row.car.carlogourl} : undefined
        return (
            <View style={styles.carCell}>
                <TouchableOpacity style={styles.carCellContent} onPress={() => {this.onCellPress(row.car)}}>
                    <Image source={logo}
                           defaultSource={UI.Img.DefaultMutInsCarBrand}
                           style={styles.carCellImage}/>
                    <Text style={styles.carCellTitle}>{row.car.licensenumber}</Text>
                </TouchableOpacity>
                <View style={styles.carCellTipContainer}>
                    <Image source={{url: 'mins_tip_bg1'}}
                           capInsets={{top: 0, left: 13, bottom: 0, right: 0}}
                           style={styles.carCellTipBg}/>
                    <Text style={styles.carCellTipTitle}>未参团</Text>
                </View>
                <View style={styles.line}/>
            </View>
        )
    }

    renderOtherCell() {
        return (
            <View style={{backgroundColor: 'white'}}>
                <TouchableOpacity style={styles.otherCell} onPress={() => {this.onCellPress()}}>
                    <Text style={styles.otherCellTitle}>其他车辆</Text>
                </TouchableOpacity>
            </View>
        )
    }
}

const styles = StyleSheet.create({
    container: {flex: 1, backgroundColor: UI.Color.Background},
    line: {height: 0.5, backgroundColor: UI.Color.Line},

    carCell: {height: 80, backgroundColor: 'white'},
    carCellContent: {flexDirection: 'row', flex: 1, alignItems: 'center'},
    carCellImage: {width: 40, height: 40, marginLeft: 17},
    carCellTitle: {marginLeft: 10, flex: 1},
    carCellTipContainer: {height: 23, position: 'absolute', right: 0, top: 7, justifyContent: 'center'},
    carCellTipBg: {position: 'absolute', top: 0, left: 0, bottom: 0, right: 0, resizeMode: 'stretch'},
    carCellTipTitle: { color: UI.Color.Orange, marginLeft: 23, marginRight: 14},

    otherCell: {...UI.Style.Btn, height: 48},
    otherCellTitle: {fontSize: 16, color: UI.Color.DefaultTint},
})