import { LightningElement, wire, api } from 'lwc';
import getAPSRecords from '@salesforce/apex/CollectionCaseDB.getAPSRecords';
import getCollectionCaseDetails from '@salesforce/apex/CollectionCaseDB.getCollectionCaseDetails';
import updateAPSRecord from '@salesforce/apex/PaymentArrangementsManager.updateAPSRecord';
import getTotalCount from '@salesforce/apex/CollectionCaseDB.getTotalCount';
import { getAPSColumns } from 'c/ccDataTableConfig';

const apsMap = {
    sObject: "loan__Automated_Payment_Setup__c",
    Id: undefined,
    loan__Active__c: undefined
};

export default class CcAutomatedPaymentSetups extends LightningElement {
    @api recordId;
    columns = getAPSColumns();
    rowLimit = 10;
    rowOffSet = 0;
    error;
    collectionList;
    apsList = [];
    clContractId;
    totalRows = 0;
    tblName = 'loan__Automated_Payment_Setup__c';
    whereClauseFieldName = 'loan__CL_Contract__c';
    loadMoreStatus;
    enableInfiniteLoading = true;
    sortBy;
    sortDirection;
    recordsDisplayStatus = '';
    confirmationPopupTitle = 'Confirmation';
    showConfirmationPopup = false;
    confirmationMessage = '';
    record;
    isSame = false;
    get apsMaptoUpdate() {
        return apsMap;
    }

    @wire(getCollectionCaseDetails, {collectionCaseId: '$recordId'})
    wiredContract({
        error,
        data
    }) {
        if (data) {
            this.collectionList = data;
            this.clContractId = this.collectionList[0].CL_Contract_Id__c;
            if(this.clContractId){
                this.getAPSRecordsList();
                this.getTotalRecordCount();
            }
        } else if (error) {
            this.error = error;
        }
    }

    getAPSRecordsList() {
        this.isSame = !this.isSame;
        return getAPSRecords({ loanAccountId: this.clContractId, limitSize: this.rowLimit, offset: this.rowOffSet, isSame: this.isSame })
            .then(result => {
                if(this.apsList.length > 0){
                    let updatedRecords = [...this.apsList, ...result];
                    this.apsList = updatedRecords;
                }
                else {
                    this.apsList = result;
                }
                let apsArray = [];
                for (let row of this.apsList) {
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
                    apsArray.push(flattenedRow);
                }
                this.apsList  = apsArray;
                if(this.apsList.length == 0){
                    this.loadMoreStatus = 'No records to display';
                } else {
                    this.loadMoreStatus = '';
                }
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.apsList = undefined;
                console.log('error:',JSON.stringify(this.error));
            });
    }

    _flatten(nodeValue, flattenedRow, nodeName){
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.'+ key;
            flattenedRow[finalKey] = nodeValue[key];
        })
    }

    getTotalRecordCount() {
        return getTotalCount({ genericId: this.clContractId, tblName: this.tblName, whereClauseFieldName: this.whereClauseFieldName })
        .then(result => {
            this.totalRows = result;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.totalRows = 0;
        });
    }

    loadMoreData(event) {
        const { target } = event;
        if(this.rowOffSet < this.totalRows){
            target.isLoading = true;
            this.loadMoreStatus = '';
            this.rowOffSet = this.rowOffSet + this.rowLimit;
            this.enableInfiniteLoading = true;
            this.getAPSRecordsList()
                .then(()=> {
                    target.isLoading = false;
                });
        } else {
            target.isLoading = false;
            if(this.rowOffSet != 0){
                this.loadMoreStatus = 'No more data to load';
            }
            this.enableInfiniteLoading = false;
        }
    }

    handleRowAction(event) {
        const row = event.detail.row;
        this.record = row;
        if(row.loan__Active__c == true){
            this.confirmationMessage = 'Are you sure to Deactivate the selected APS record ?';
        }
        else if(row.loan__Active__c == false){
            this.confirmationMessage = 'Are you sure to Activate the selected APS record ?';
        }
        this.showConfirmationPopup = true;
    }

    handleConfirmationClick(event){
        if(event.target.name == 'confirm'){
            this.apsMaptoUpdate.Id = this.record.Id;
            this.apsMaptoUpdate.loan__Active__c = !this.record.loan__Active__c;
            updateAPSRecord({ apsObject: this.apsMaptoUpdate }).then(result => {
                setTimeout(() => {
                    this.apsList = [];
                    this.rowLimit = 10;
                    this.rowOffSet = 0;
                    this.getAPSRecordsList();
                }, 2000);

            }).catch(error => {
                console.log('error:' + this.error);
            });
        }
        this.showConfirmationPopup = false;
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.apsList));
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
        this.apsList = parseData;
    }
}