import { LightningElement, wire, api } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedPartiesByApplicationIds from '@salesforce/apex/CollectionCaseDB.getRelatedPartiesByApplicationIds';
import getCollectionCaseDetails from '@salesforce/apex/CollectionCaseDB.getCollectionCaseDetails';
import consumerCreditPull from '@salesforce/apex/CollectionsCreditPull.consumerCreditPull';
import getConsumerCreditReportByContactId from '@salesforce/apex/CollectionsCreditPull.getConsumerCreditReportByContactId';
import { getCreditReportColumns } from 'c/ccDataTableConfig';

export default class CcConsumerCreditPull extends LightningElement {
    @api recordId;
    disableSaveButton = false;
    contactList;
    collectionList;
    applicationId;
    consumerCreditReport = [];
    selectedGuarantorContact;
    isLoaded = false;
    columns = getCreditReportColumns();
    isChanged = false;

    @wire(getCollectionCaseDetails, {collectionCaseId: '$recordId'})
    wiredContract({
        error,
        data
    }) {
        if (data) {
            this.collectionList = data;
            this.applicationId = this.collectionList[0].Contract_Application_Id__c;
            if(this.applicationId){
                this.getRelatedPartiesRecords();
            }
        } else if (error) {
            this.error = error;
        }
    }

    getRelatedPartiesRecords() {
        let appIds = [];
        appIds.push(this.applicationId);
        console.log('applicationId - ' + JSON.stringify(this.applicationId));
        return getRelatedPartiesByApplicationIds({ applicationIds : appIds })
            .then(result => {
                console.log('result - ' + JSON.stringify(result));
                let options = [];
                for(let key in result) {
                    if(result[key].clcommon__Type__r.Name == 'GUARANTOR') {
                        options.push({label : result[key].clcommon__Contact__r.Name, value : result[key].clcommon__Contact__c});
                    }
                }
                this.contactList = options;
                this.selectedGuarantorContact = this.contactList[0].value;
                this.getConsumerCreditReport();
            })
            .catch(error => {
                this.error = error;
                this.contactList = undefined;
                console.log('error - ' + JSON.stringify(this.error));
            });
    }

    createConsumerCreditPull() {
        this.isLoaded = true;
        let contactComboBox = this.template.querySelector("[data-id='Contact']");
        let selectedContact = contactComboBox ? contactComboBox.value : null;
        if(selectedContact == null) {
            const evt = new ShowToastEvent({
                title: 'Contact', message: 'Please Select Contact', variant: 'Warning'
            });
            this.dispatchEvent(evt);
            return;
        }
        this.disableSaveButton = true;
        consumerCreditPull({contactId : selectedContact, collectionCaseId : this.recordId}).then(result => {
            console.log('result - ' + JSON.stringify(result));
            const evt = new ShowToastEvent({
                title: 'Consumer Credit', message: 'Consumer Credit Pull Successful', variant: 'success'
            });
            this.dispatchEvent(evt);
            setTimeout(() => {
                this.getConsumerCreditReport();
            }, 10000);
            getRecordNotifyChange([{recordId: this.recordId}]);
        }).catch(error => {
            const evt = new ShowToastEvent({
                title: 'Failed', message: JSON.stringify(error), variant: 'error'
            });
            this.dispatchEvent(evt);
            this.disableSaveButton = false;
            this.isLoaded = false;
        });
    }

    handleGuarantorChange(event){
        this.selectedGuarantorContact = event.detail.value;
        this.getConsumerCreditReport();
    }

    getConsumerCreditReport() {
        this.isChanged = !this.isChanged;
        this.consumerCreditReport = [];
        this.disableSaveButton = true;
        getConsumerCreditReportByContactId({contactId : this.selectedGuarantorContact,
            isChanged : this.isChanged}).then(result => {
            this.consumerCreditReport = result;
            let consumerCreditLinkName;
                this.consumerCreditReport = this.consumerCreditReport.map(row => {
                    consumerCreditLinkName = `/${row.Id}`;
                    return {...row, consumerCreditLinkName}
                });
            getRecordNotifyChange([{recordId: this.recordId}]);
            console.log('consumerCreditReport - ' + JSON.stringify(this.consumerCreditReport));
            this.isLoaded = false;
            this.disableSaveButton = false;
        }).catch(error => {
            console.log('error - ' + JSON.stringify(error));
            this.isLoaded = false;
            this.disableSaveButton = false;
        });
    }
}