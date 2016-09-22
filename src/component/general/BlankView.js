import React, {
    PropTypes,
    Component,
} from 'react';
import {
    View,
    Image,
    Text,
    StyleSheet,
    TouchableOpacity,
} from 'react-native';
import LoadingView from './loading/LoadingView';

const empty = () => {};
export default class BlankView extends Component {

    static propTypes = {
        visible: PropTypes.bool,
        loading: PropTypes.bool,
        loadingOffset: PropTypes.number,
        text: PropTypes.string,
        image: PropTypes.object,
        onPress: PropTypes.func,
    }

    static defaultProps = {
        visible: false,
        loading: false,
        loadingOffset: -50,
        onPress: empty,
        image: {name: 'def_failConnect', width: 152, height: 152},
    }

    constructor(props) {
        super(props);
        this.state = {forceRerend: false}
    }

    componentWillReceiveProps(props) {
        this.setState({forceRerend: !this.state.forceRerend})
    }

    render() {
        var content = null;
        if (this.props.visible && this.props.loading) {
            content = this._renderLoadingView()
        }
        else  if (this.props.visible) {
             content = this._renderBlankContent()
        }
        else {
            content = this.props.children;
        }

        return (
            <View {...this.props} style={[this.props.style, styles.container]}>
                {content}
            </View>
        )
    }

    _renderLoadingView() {
        return (
            <View style={{flex:1, flexDirection: 'column', justifyContent: 'center'}}>
                <View style={styles.loadingContainer}>
                    <LoadingView loading={true}
                                 animationType={LoadingView.Animation.GIF}
                                 offset={this.props.loadingOffset}
                                 style={styles.container}/>
                </View>
            </View>
        )
    }

    _renderBlankContent() {
        return (
            <View style={styles.content} >
                <TouchableOpacity onPress={this.props.onPress}>
                    <Image source={{uri: this.props.image.name}}
                           style={[styles.image, {width:this.props.image.width, height:this.props.image.height}]}/>
                </TouchableOpacity>
                <TouchableOpacity onPress={this.props.onPress}>
                    <Text style={styles.text}>{this.props.text}</Text>
                </TouchableOpacity>
            </View>
        )
    }
}

const styles = StyleSheet.create({
    container: {flex: 1},
    content: {flex: 1, flexDirection: 'column', alignItems: 'center', justifyContent:'center', top: -64},
    image: {margin: 20},
    text: {fontSize: 17, fontWeight: 'bold', color: '#aaaaaa'},
    loadingContainer: {flexDirection: 'row', height: 120},
    loadingView: {flex: 1},
})