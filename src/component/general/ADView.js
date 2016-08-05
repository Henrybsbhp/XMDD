'use strict';

import React, {
    PropTypes,
    Component
} from 'react';
import {View, Image, TouchableOpacity, StyleSheet} from 'react-native';
import ViewPager from 'react-native-viewpager';
import UI from '../../constant/UIConstants';


export default class ADView extends Component {
    static propTypes = {
        dataSource: PropTypes.array,
        defaultImage: PropTypes.object,
    }

    static defaultProps = {
        defaultImage: UI.Img.DefaultAD,
        dataSource: [{onPress: ()=>{}}],
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
        let locked = this.state.dataSource.getPageCount() <= 1;
        return (
            <ViewPager
                dataSource={this.state.dataSource}
                renderPage={this._renderPage.bind(this)}
                locked={locked}
                renderPageIndicator={locked ? false : undefined}
                isLoop={false}
                autoPlay={true}
                style={styles.container}
            />
        );
    }

    _renderPage(data, pageID) {
        return (
            <TouchableOpacity onPress={()=>data.onPress(pageID)}>
                <Image
                    source={{uri: data.image}}
                    defaultSource={this.props.defaultImage}
                    style={[styles.page, this.props.style]}
                />
            </TouchableOpacity>
        );
    }
}


const styles = StyleSheet.create({
    container: {flex: 1},
    page: {
        width: UI.Win.Width,
        height: Math.ceil(UI.Win.Width * 184.0 / 640),
    },

});

