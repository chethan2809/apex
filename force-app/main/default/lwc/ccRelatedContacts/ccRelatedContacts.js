import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRelatedContacts from '@salesforce/apex/CollectionCaseDB.getRelatedContactsFromBorrowerAccountIds';
import getCollectionCaseDetails from '@salesforce/apex/CollectionCaseDB.getCollectionCaseDetails';
import { getRelatedContactColumns } from 'c/ccDataTableConfig';

export default class CcRelatedContacts extends NavigationMixin(LightningElement) {
    @api recordId;
    columns = getRelatedContactColumns();
    error;
    collectionList;
    relatedContactsList = [];
    accountId;
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
            this.accountId = this.collectionList[0].Account__c;
            if(this.accountId){
                this.getRelatedContactRecords();
            }
        } else if (error) {
            this.error = JSON.stringify(error);
        }
    }

    getRelatedContactRecords() {
        let accIds = [];
        accIds.push(this.accountId);
        return getRelatedContacts({ borrowerAccountIds: accIds })
            .then(result => {
                let updatedRecords = [...this.relatedContactsList, ...result];
                this.relatedContactsList = updatedRecords;
                let contactLinkName;
                let mailingAddressLink;
                let customMailingAddress;
                this.relatedContactsList = this.relatedContactsList.map(row => {
                    contactLinkName = `/${row.ContactId}`;
                    return {...row, contactLinkName}
                });

                this.relatedContactsList = this.relatedContactsList.map(row => {
                    mailingAddressLink = this.googleMapLink + row.Contact.MailingStreet + ' ' + row.Contact.MailingCity + ' ' + row.Contact.MailingState + ' ' + row.Contact.MailingPostalCode + ' ' + row.Contact.MailingCountry;
                    return {...row, mailingAddressLink}
                });
                this.relatedContactsList = this.relatedContactsList.map(row => {
                    customMailingAddress = row.Contact.MailingStreet + "\n" + row.Contact.MailingCity + "\n" + row.Contact.MailingState + ' ' + row.Contact.MailingPostalCode + ' ' + row.Contact.MailingCountry;
                    return {...row, customMailingAddress}
                });
                let relatedPartiesArray = [];
                for (let row of this.relatedContactsList) {
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

                this.relatedContactsList  = relatedPartiesArray;
                this.error = undefined;
            })
            .catch(error => {
                this.error = JSON.stringify(error);
                this.relatedContactsList = undefined;
            });
    }

    navigateToNewContactPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new'
            },
        });
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.relatedContactsList));
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
        this.relatedContactsList = parseData;
    }

    _flatten(nodeValue, flattenedRow, nodeName){
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.'+ key;
            flattenedRow[finalKey] = nodeValue[key];
        })
    }
}