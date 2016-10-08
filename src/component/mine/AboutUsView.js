import React, {
    Component,
} from 'react';
import {
    TabBarIOS,
    NavigatorIOS
} from 'react-native';


export default class AboutUsView extends Component {
    render()
    {
        return(
            <TabBarIOS>
                <TabBarIOS.Item title="React Native" selected={true}>
                    <NavigatorIOS initialRoute={{ title: 'React Native' }} />
                </TabBarIOS.Item>
            </TabBarIOS>
        );
    }
};