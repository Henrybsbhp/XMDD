"use strict";
import Reflux from 'reflux';
const Domains = {
    Open: 'ModalOpen',
    Close: 'ModalClose',
}

var ModalHelper = Reflux.createStore({
    open(modal) {
        this.trigger(Domains.Open, modal)
    },

    close(modal) {
        this.trigger(Domains.Close, modal)
    },
})

ModalHelper.Domains = Domains

export default ModalHelper;

