import { LightningElement, wire, api } from 'lwc';
import getRelatedParties from '@salesforce/apex/CollectionCaseDB.getRelatedPartiesByApplicationIds';
import getCollectionCaseDetails from '@salesforce/apex/CollectionCaseDB.getCollectionCaseDetails';
import { getRelatedPartiesColumns } from 'c/ccDataTableConfig';

export default class CcRelatedParties extends LightningElement {
    @api recordId;
    columns = getRelatedPartiesColumns();
    error;
    collectionList;
    relatedPartiesList = [];
    applicationId;
    sortBy;
    sortDirection;
    googleMapLink = 'https://www.google.com/maps?q=';

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
        return getRelatedParties({ applicationIds: appIds })
            .then(result => {
                let updatedRecords = [...this.relatedPartiesList, ...result];
                this.relatedPartiesList = updatedRecords;
                let contactLinkName;
                let mailingAddressLink;
                let customMailingAddress;
                this.relatedPartiesList = this.relatedPartiesList.map(row => {
                    contactLinkName = `/${row.clcommon__Contact__c}`;
                    return {...row, contactLinkName}
                });
                this.relatedPartiesList = this.relatedPartiesList.map(row => {
                    mailingAddressLink = this.googleMapLink + row.clcommon__Contact__r.MailingStreet + ' ' + row.clcommon__Contact__r.MailingCity + ' ' + row.clcommon__Contact__r.MailingState + ' ' + row.clcommon__Contact__r.MailingPostalCode + ' ' + row.clcommon__Contact__r.MailingCountry;
                    return {...row, mailingAddressLink}
                });
                this.relatedPartiesList = this.relatedPartiesList.map(row => {
                    customMailingAddress = row.clcommon__Contact__r.MailingStreet + "\n" + row.clcommon__Contact__r.MailingCity + "\n" + row.clcommon__Contact__r.MailingState + ' ' + row.clcommon__Contact__r.MailingPostalCode + ' ' + row.clcommon__Contact__r.MailingCountry;
                    return {...row, customMailingAddress}
                });
                let relatedPartiesArray = [];
                for (let row of this.relatedPartiesList) {
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
                    relatedPartiesArray.push(flattenedRow);
                }
                this.relatedPartiesList  = relatedPartiesArray;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.relatedPartiesList = undefined;
            });
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.relatedPartiesList));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.relatedPartiesList = parseData;
    }

    _flatten(nodeValue, flattenedRow, nodeName){
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.'+ key;
            flattenedRow[finalKey] = nodeValue[key];
        });
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.'+ key;
            flattenedRow[finalKey] = nodeValue[key];
        });
    }
}