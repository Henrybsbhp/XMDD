import React, {
    Component,
    PropTypes,
} from 'react';
import {
    View,
    DatePickerIOS,
    Modal,
    TouchableOpacity,
    StyleSheet,
    Text,
    Animated,
    Dimensions
} from 'react-native';

const empty = () => {};
const WIN = Dimensions.get('window');

export default class HKDatePicker extends Component {
    static propTypes = {
        visible: PropTypes.bool,
        date: PropTypes.object,
        maxDate: PropTypes.object,
        minDate: PropTypes.object,
        cancelText: PropTypes.string,
        confirmText: PropTypes.string,
        onConfirm: PropTypes.func,
        onCancel: PropTypes.func,
    }

    static defaultProps = {
        visible: false,
        cancelText: '取消',
        confirmText: '确定',
        onConfirm: empty,
        onCancel: empty,
    }

    constructor(props) {
        super(props);
        this.state = {
            modalVisible: props.visible,
            date: this.props.date ? this.props.date : new Date(),
            opacityAnim: new Animated.Value(0),
            shouldUpdate: false,
            didMount: false,
        }
    }

    componentWillReceiveProps(props) {
        if (this.state.didMount) {
            this.setModalVisible(props.visible, props.date)
        }
        else {
            this.state.shouldUpdate = true;
        }
    }

    componentDidMount() {
        this.state.didMount = true;
        if (this.state.shouldUpdate) {
            this.setModalVisible(this.props.visible, this.props.date)
        }
    }

    setModalVisible(visible, date) {
        if (visible) {
            this.setState({modalVisible: visible, date: date ? date : this.state.date});
            Animated.timing(
                this.state.opacityAnim,
                {
                    toValue: 1,
                    duration: 310,
                }
            ).start();
        }
        else {
            Animated.timing(
                this.state.opacityAnim,
                {
                    toValue: 0,
                    duration: 200,
                }
            ).start(() => {this.setState({modalVisible: visible})});
        }
    }

    actionCancel() {
        this.props.onCancel();
        this.setModalVisible(false);
    }

    actionConfirm() {
        this.props.onConfirm(this.state.date);
        this.setModalVisible(false);
    }

    render() {
        return (
            <Modal visible={this.state.modalVisible} transparent={true}>
                <Animated.View style={[styles.container, {opacity: this.state.opacityAnim}]}>
                    <View style={styles.pickerContainer}>
                        <DatePickerIOS
                            style={styles.picker}
                            date={this.state.date}
                            mode={this.props.mode}
                            minimumDate={this.props.minDate}
                            maximumDate={this.props.maxDate}
                            onDateChange={(date) => {this.setState({date: date})}}
                        />
                        <View style={styles.barContainer}>
                            <TouchableOpacity style={styles.barButton} onPress={this.actionCancel.bind(this)}>
                                <Text style={styles.barButtonTitle}>{this.props.cancelText}</Text>
                            </TouchableOpacity>
                            <TouchableOpacity style={styles.barButton} onPress={this.actionConfirm.bind(this)}>
                                <Text style={styles.barButtonTitle}>{this.props.confirmText}</Text>
                            </TouchableOpacity>
                        </View>
                    </View>
                </Animated.View>
            </Modal>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flexDirection: 'column',
        flex: 1,
        backgroundColor: 'rgba(0, 0, 0, 0.4)',
        justifyContent: 'center',
        alignItems: 'center'
    },
    pickerContainer: {
        width: Math.min(310, WIN.width - 20),
        flexDirection: 'column',
        backgroundColor: 'white',
        borderRadius: 5,
        overflow: 'hidden'
    },
    barContainer: {
        flexDirection: 'row',
        borderTopColor: '#ebebeb',
        borderTopWidth: 0.5,
        height: 44,
        justifyContent: 'space-between',
    },
    barButton: {
        paddingHorizontal: 20,
        paddingVertical: 10,
        alignSelf: 'center',
    },
    barButtonTitle: {
        fontSize: 17,
        fontWeight: 'bold',
        color: '#18d06a',
    }
});