'use strict';

import React, {
    PropTypes,
    Component
} from 'react';
import {View, Image, TouchableOpacity, StyleSheet} from 'react-native';
import ViewPager from 'react-native-viewpager';


export default class ADView extends Component {
    static propTypes = {
        onPress: PropTypes.func,
        dataSource: PropTypes.array,
    }

    constructor(props) {
        super(props);

        var dataSource = new ViewPager.DataSource({
            pageHasChanged: (p1, p2) => p1 != p2,
        })

        this.state = {
            dataSource: dataSource.cloneWithPages(this.props.dataSource)
        }
    }

    render() {
        return (
            <ViewPager
                dataSource={this.state.dataSource}
                renderPage={this._renderPage}
                isLoop={false}
                autoPlay={true}
            />
        );
    }

    _renderPage(data, pageID) {
        <TouchableOpacity onPress={()=>data.onClick(pageID)}>
            <Image
                source={{uri: data.url}}
                defaultSource={{}}
            />
        </TouchableOpacity>
    }
}


const styles = StyleSheet.create({
    container: {flex: 1}
});

