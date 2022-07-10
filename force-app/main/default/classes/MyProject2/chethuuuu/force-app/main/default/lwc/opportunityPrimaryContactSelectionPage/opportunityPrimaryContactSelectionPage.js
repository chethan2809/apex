import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange, updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import PRIMARY_CONTACT from '@salesforce/schema/Opportunity.Primary_Contact__c';
import getAccountContactRelationByAccountId from '@salesforce/apex/oppPrimaryContactSelectionPageCtrl.getAccountContactRelationByAccountId';

export default class OpportunityPrimaryContactSelectionPage extends LightningElement {

    @api recordId;
    contactName = '';
    contactId;
    contactsList = [];
    messageResult = false;
    showSearchedValues = false;
    disableSave = true;
    recordFound = false;
    isshow = false;
    @wire(getAccountContactRelationByAccountId, { opportunityId: '$recordId' })
    retrieveContacts(result) {
        console.log('=====' + JSON.stringify(result));
        if (result.data) {
            console.log('=====' + JSON.stringify(result.data));
            this.contactsList = result.data;
            this.messageResult = false;
        }
    }

    handleOnClick(event) {
        if(this.contactsList.length == 0) {

            this.messageResult = true;
        }
        else {
            this.showSearchedValues = true;
        }
    }

    handleKeyChange(event) {
        this.messageResult = false;
        this.contactName = event.target.value;
    }

    handleParentSelection(event) {
        let recordId = event.currentTarget.dataset.recordId;
        console.log('==RecordId====' + recordId);
        let selectRecord = this.contactsList.find((item) => {
            return item.Id === recordId;
        });
        if (selectRecord != null) {
            this.contactName = selectRecord.Name;
            this.contactId = recordId;
            this.showSearchedValues = false;
            this.disableSave = false;
            this.messageResult = false;
            this.recordFound = true;
        }
        else {
            this.contactName = '';
            this.contactId = '';
            this.showSearchedValues = false;
            this.disableSave = true;
            this.messageResult = false;
            this.recordFound = false;
        }
    }

    handleSave(event) {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[PRIMARY_CONTACT.fieldApiName] = this.contactId;
        console.log('PrimaryContact' + this.contactId);
        console.log('PrimaryContactField' + JSON.stringify(fields));

        const recordInput = { fields };
        console.log('RecordInput' + JSON.stringify(recordInput));
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Primary Contact on this Opportunity Record was updated',
                        variant: 'success'
                    })
                );
                setTimeout(() => {
                    getRecordNotifyChange([{ recordId: this.recordId }]);
                }, 5000);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
    handleReset(event) {
        let recordAction = '[role="textbox"]';
        const inputFields = this.template.querySelectorAll(
            recordAction
        )
        inputFields.forEach(field => {
            field.value = "";
        });
        this.isshow = false;
        this.recordFound = false;
    }
}