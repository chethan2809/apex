import { LightningElement, wire } from 'lwc';

import getContacts from '@salesforce/apex/LWCContactDB.getContacts';
export default class LWSWireDecorator extends LightningElement {
    contacts;
    error;

    @wire(getContacts) getWiredContactLWC({error, data}){
        if(data) {
            this.contacts = data;
            this.error = undefined;
        } else if(error) {
            this.contacts = undefined;
            this.error = error;
        }
    }

}