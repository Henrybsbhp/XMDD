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
import LoadingView from './LoadingView';

const empty = () => {};
export default class BlankView extends Component {

    static propTypes = {
        visible: PropTypes.bool,
        loading: PropTypes.bool,
        text: PropTypes.string,
        image: PropTypes.object,
        onPress: PropTypes.func,
    }

    static defaultProps = {
        visible: false,
        loading: false,
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
            content = (<LoadingView loading={true} style={styles.loadingView}/>);
        }
        else  if (this.props.visible) {
             content = this._renderBlankContent();
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
    loadingView: {position: 'absolute', top: 0, left: 0, bottom: 0, right: 0}
})