'use strict';

import React, {Component} from 'react';
import {ScrollView, ListView} from 'react-native';

import HKRefreshControl from './HKRefreshControl.ios';

let randId = () => (Math.random() + 1).toString(36).substring(7);

const ELEMENT_ID = randId();


class RCTRefreshControlScrollView extends Component {
    componentDidMount() {
        HKRefreshControl.configure({
            node: this.refs[ELEMENT_ID],
            tintColor: this.props.tintColor,
            activityIndicatorViewColor: this.props.activityIndicatorViewColor
        }, () => {
            if (this.props.onRefresh) {
                this.props.onRefresh(() => {
                    HKRefreshControl.endRefreshing(this.refs[ELEMENT_ID]);
                });
            }
        });
    }
    render() {
        return (
            <ScrollView {...this.props} ref={ELEMENT_ID}>
                {this.props.children}
            </ScrollView>
        );
    }

    scrollTo(...args) {
        this.refs[ELEMENT_ID].scrollTo(...args);
    }
}

class RCTRefreshControlViewListView extends Component {
    componentDidMount() {
        HKRefreshControl.configure({
            node: this.refs[ELEMENT_ID],
            tintColor: this.props.tintColor,
            activityIndicatorViewColor: this.props.activityIndicatorViewColor
        }, () => {
            if (this.props.onRefresh) {
                this.props.onRefresh(() => {
                    HKRefreshControl.endRefreshing(this.refs[ELEMENT_ID]);
                });
            }
        });
    }
    render() {
        return (
            <ListView {...this.props} ref={ELEMENT_ID}/>
        );
    }
}
HKRefreshControl.ScrollView = RCTRefreshControlScrollView;
 HKRefreshControl.ListView = RCTRefreshControlViewListView;

module.exports = HKRefreshControl;