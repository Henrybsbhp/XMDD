import React, {Component} from 'react';
import {
    View,
    Text,
    TextInput,
    StyleSheet,
} from 'react-native';


export default class EditMyInfoView extends Component {
    constructor(props) {
        super(props);
        this.state = {value: props.route.value}
        props.route.emitter.on('onSave', (callback) => {
            callback(this.state.value);
        });
    }

    render() {
        return (
            <View style={[this.props.style, styles.container]}>
                <TextInput style={styles.input}
                           value={this.state.value}
                           onChangeText={(text) => {this.setState({value: text})}}
                           clearButtonMode="while-editing"
                />
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        backgroundColor: "#f7f7f8",
        flex: 1,
    },
    input: {
        marginTop: 10,
        height: 48,
        backgroundColor: 'white',
        fontSize: 15,
        paddingLeft: 18,
        paddingRight: 14,
    }
});

