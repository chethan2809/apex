import { LightningElement, wire, api } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCollectionCaseDetails from '@salesforce/apex/CollectionCaseDB.getCollectionCaseDetails';
import businessCreditPull from '@salesforce/apex/CollectionsCreditPull.businessCreditPull';
import getBusinessCreditReportByAccountId from '@salesforce/apex/CollectionsCreditPull.getBusinessCreditReportByAccountId';
import { getBusinessReportColumns } from 'c/ccDataTableConfig';

export default class CcBusinessCreditPull extends LightningElement {
    @api recordId;
    disableSaveButton = false;
    businessCreditReport = [];
    columns = getBusinessReportColumns();
    applicationAccountId;
    isLoaded = false;
    isChanged = false;

    @wire(getCollectionCaseDetails, {collectionCaseId: '$recordId'})
    wiredContract({
        error,
        data
    }) {
        if (data) {
            this.collectionList = data;
            this.applicationAccountId = this.collectionList[0].Account__c;
            if(this.applicationAccountId) {
                this.getBusinessCreditReport();
            }
        } else if (error) {
            this.error = error;
        }
    }

    createBusinessCreditPull() {
        this.isLoaded = true;
        this.disableSaveButton = true;
        businessCreditPull({borrowerAccountId : this.applicationAccountId, collectionCaseId : this.recordId}).then(result => {
            console.log('result - ' + JSON.stringify(result));
            const evt = new ShowToastEvent({
                title: 'Business Credit', message: 'successful', variant: 'success'
            });
            this.dispatchEvent(evt);
            setTimeout(() => {
                this.getBusinessCreditReport();
            }, 5000);
            this.isLoaded = false;
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

    getBusinessCreditReport() {
        this.isChanged = !this.isChanged;
        this.businessCreditReport = [];
        getBusinessCreditReportByAccountId({borrowerAccountId : this.applicationAccountId,
            isChanged : this.isChanged}).then(result => {
            this.businessCreditReport = result;
            this.disableSaveButton = false;
            let businessCreditLinkName;
            this.businessCreditReport = this.businessCreditReport.map(row => {
                businessCreditLinkName = `/${row.Id}`;
                return {...row, businessCreditLinkName}
            });
            let businessCreditReportArray = [];
                for (let row of this.businessCreditReport) {
                    const flattenedRow = {}
                    let rowKeys = Object.keys(row);
                    rowKeys.forEach((rowKey) => {
                        const singleNodeValue = row[rowKey];
                        if(singleNodeValue.constructor === Object){
                            this._flatten(singleNodeValue, flattenedRow, rowKey);
                        }else{
                            flattenedRow[rowKey] = singleNodeValue;
                        }
                    });
                    businessCreditReportArray.push(flattenedRow);
                }
            this.businessCreditReport = businessCreditReportArray;
            this.error = undefined;
            getRecordNotifyChange([{recordId: this.recordId}]);
        }).catch(error => {
            console.log('error - ' + JSON.stringify(error));
        });
    }

    _flatten(nodeValue, flattenedRow, nodeName){
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.'+ key;
            flattenedRow[finalKey] = nodeValue[key];
        })
    }
}