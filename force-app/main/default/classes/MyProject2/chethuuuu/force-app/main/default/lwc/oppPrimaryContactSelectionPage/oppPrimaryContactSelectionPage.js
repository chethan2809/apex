import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange, updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import PRIMARY_CONTACT from '@salesforce/schema/Opportunity.Primary_Contact__c';
import getContactsByOpportunityIds from '@salesforce/apex/oppPrimaryContactSelectionPageCtrl.getContactsByOpportunityIds';

export default class OppPrimaryContactSelectionPage extends LightningElement {

    @api recordId;
    contactName = '';
    contactId;
    contactsList = [];
    messageResult = false;
    showSearchedValues = false;
    disableSave = true;
    recordFound = false;
    isshow = false;
    disableButton = false;

    @wire(getContactsByOpportunityIds, { opportunityId: '$recordId' })
    retrieveContacts(result) {
        if (result.data) {
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
        this.disableButton = false;
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
        const recordInput = { fields };
        this.disableButton = true;
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