'use strict';

import React, {Component, PropTypes} from 'react';
import {ScrollView, ListView} from 'react-native';

import HKRefreshControl from './HKRefreshControl.ios';

let randId = () => (Math.random() + 1).toString(36).substring(7);

const ELEMENT_ID = randId();

class RefreshControlTargetView extends Component {
    static propTypes = {
        refreshing: PropTypes.bool,
        onRefresh: PropTypes.func,
    }

    static defaultProps = {
        refreshing: false,
    }

    componentWillReceiveProps(props) {
        this.updateRefreshingIfNeeded(props);
    }

    componentDidMount() {
        HKRefreshControl.configure({
            node: this.refs[ELEMENT_ID],
            tintColor: this.props.tintColor,
            activityIndicatorViewColor: this.props.activityIndicatorViewColor
        }, () => {
            if (this.props.onRefresh) {
                this.props.onRefresh();
            }
        });
    }

    updateRefreshingIfNeeded(props) {
        if (props.refreshing != this.props.refreshing && this.refs[ELEMENT_ID]) {
            if (props.refreshing) {
                HKRefreshControl.beginRefreshing(this.refs[ELEMENT_ID]);
            }
            else {
                HKRefreshControl.endRefreshing(this.refs[ELEMENT_ID]);
            }
        }
    }
}


class RCTRefreshControlScrollView extends RefreshControlTargetView {
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

class RCTRefreshControlViewListView extends RefreshControlTargetView {
    render() {
        return (
            <ListView {...this.props} ref={ELEMENT_ID}/>
        );
    }
}
HKRefreshControl.ScrollView = RCTRefreshControlScrollView;
 HKRefreshControl.ListView = RCTRefreshControlViewListView;

module.exports = HKRefreshControl;