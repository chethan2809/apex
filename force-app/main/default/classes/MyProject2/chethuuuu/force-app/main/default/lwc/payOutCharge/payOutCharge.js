import { api, wire, track, LightningElement } from "lwc";
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/loan__Charge__c.Id';
import NAME_FIELD from '@salesforce/schema/loan__Charge__c.loan__Fee__r.Name';
import PAYOUT_FIELD from '@salesforce/schema/loan__Charge__c.Paidout__c';
import PAYOUT_DATE from '@salesforce/schema/loan__Charge__c.Paidout_Date__c';

const fields = [ID_FIELD, NAME_FIELD, PAYOUT_FIELD, PAYOUT_DATE];
export default class ExploreUpdateRecord extends LightningElement {

    @api recordId;
    name;
    @track isLoading = false;
    @track pay = false;
    @track msg = '';
    @track record;
    @track error;
    @wire(getRecord, {
        recordId: '$recordId',
        fields
    })
    charge;

    get payout() {
        return getFieldValue(this.charge.data, PAYOUT_FIELD);
    }

    get created() {
        return getFieldValue(this.charge.data, PAYOUT_DATE);
    }
    get accName() {
        return getFieldValue(this.charge.data, NAME_FIELD);
    }
    get accId() {
        return getFieldValue(this.charge.data, ID_FIELD);
    }

    handleClick() {
        this.isLoading = true;

        const fields = {};

        if (this.charge.data.fields.loan__Fee__r.displayValue == 'Florida Fee' && this.charge.data.fields.Paidout__c.value == true) {
            this.isLoading = false;
            this.msg = 'Already Paidout';
            this.showSuccessToast();
            this.closeAction();
        } else if (this.charge.data.fields.loan__Fee__r.displayValue == 'Florida Fee' && this.charge.data.fields.Paidout__c.value != true) {
            this.pay = true;
            this.msg = 'Paidout Successfully';
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[PAYOUT_FIELD.fieldApiName] = this.pay;
            fields[NAME_FIELD.fieldApiName] = this.name;
            fields[PAYOUT_DATE.fieldApiName] = new Date().toISOString();
            const recordInput = {
                fields: fields
            };
            updateRecord(recordInput)
                .then((record) => {
                    this.showSuccessToast();
                    this.closeAction();
                    this.isLoading = false;

                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error in updating',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });

        } else {
            this.isLoading = true;
            this.msg = 'Not Applicable';
            this.showSuccessToast();
            this.closeAction();
        }
    }

    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: this.msg,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}