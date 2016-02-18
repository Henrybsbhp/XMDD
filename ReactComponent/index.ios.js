/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';

var React = require('react-native');
var {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Image,
  ListView,
  AlertIOS
} = React;

var MOCKED_MOVIES_DATA = [
  {name: 'Title', address: '2015', pics: ['http://7xipxm.com1.z0.glb.clouddn.com/1437706631836.jpg']},
];

// var REQUEST_URL = 'https://raw.githubusercontent.com/facebook/react-native/master/docs/MoviesExample.json';
var REQUEST_URL = 'https://dev.xiaomadada.com/paa/rest/api/shop/v2/get/by-distance'

var AwesomeProject11 = React.createClass({

  getInitialState: function() {
    return {
      dataSource: new ListView.DataSource({
        rowHasChanged: (row1, row2) => row1 !== row2,
      }),
      loaded: false,
    };
  },

  componentDidMount: function() {
    this.fetchData();
  },

  render: function() {
    if (!this.state.loaded) {
      return this.renderLoadingView();
    }

    return (
      <ListView
        dataSource={this.state.dataSource}
        renderRow={this.renderMovie}
        style={styles.listView}
      />
    );
  },

  renderLoadingView: function() {
    return (
      <View style={styles.container}>
        <Text>
          Loading movies...
        </Text>
      </View>
    );
  },

  renderMovie: function(shop) {
    return (
      <View style={styles.container}>
        <Image
          source={{uri: shop.pics[0]}}
          style={styles.thumbnail}
        />
        <View style={styles.rightContainer}>
          <Text style={styles.title}>{shop.name}</Text>
          <Text style={styles.year}>{shop.address}</Text>
          <Text style={styles.year}>----------------------------</Text>
        </View>
      </View>
    );
  },


  fetchData: function() {
    fetch(REQUEST_URL,{method:"POST",body: JSON.stringify({"id":"9","params":{"servicetype":2,"latitude":30.19155326283644,"pageno":1,"longitude":120.1918689083582,"typemask":0}})})
      .then((response) => response.json())
      .then((responseData) => {
        this.setState({
          dataSource: this.state.dataSource.cloneWithRows(responseData.shops),
          loaded: true,
        });
      AlertIOS.alert(
                "POST Response",
                "Response Body -> " + JSON.stringify(responseData.shops)
            )

var Dimensions = require('Dimensions');
      AlertIOS.alert(
                "POST Response",
                Dimensions.get('window').width + '\n' + Dimensions.get('window').height + '\n'
            )
      })
      .done();
  },


});

var styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  thumbnail:{
    width:53,
    height:81,
  },
  rightContainer:{
    flex:1,
    // backgroundColor: '#000000',
  },
  title:{
    fontSize:20,
    marginBottom:8,
    textAlign:'center',
  },
  year: {
    textAlign: 'center',
  },
  listView: {
    paddingTop: 20,
    backgroundColor: '#F5FCFF',
  },
});

AppRegistry.registerComponent('AwesomeProject', () => AwesomeProject11);
