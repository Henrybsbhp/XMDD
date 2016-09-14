import ReactNative from 'react-native';

export default ReactNative.StyleSheet.create({
    hud: {
        position: 'absolute',
        top:0,
        left:0,
        bottom:0,
        right:0,
        flex:1,
    },
    Container: {flex: 1},
    HorizontalContainer: {flexDirection: 'row', alignItems: 'center'},
    VerticalContainer: {flexDirection: 'column'},
});