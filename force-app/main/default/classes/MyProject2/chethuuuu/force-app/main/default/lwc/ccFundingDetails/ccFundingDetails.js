import { LightningElement, wire, api } from 'lwc';
import getFundingDetails from '@salesforce/apex/CollectionCaseDB.getFundingDetails';
import getCollectionCaseDetails from '@salesforce/apex/CollectionCaseDB.getCollectionCaseDetails';
import getLoanDisbursalTransactionDetails from '@salesforce/apex/CollectionCaseDB.getLoanDisbursalTransactionDetails';
import getDisbursalTransactionSummary from '@salesforce/apex/CollectionCaseDB.getDisbursalTransactionSummary';
import { getFundingDetailColumns } from 'c/ccDataTableConfig';

export default class CcFundingDetails extends LightningElement {
    @api recordId;
    columns = getFundingDetailColumns();
    fundingDetailList = [];
    rowLimit = 10;
    rowOffSet = 0;
    totalRows = 0;
    sortBy;
    loadMoreStatus;
    sortDirection;
    paymentTypes;
    distributionGrandTotal;
    enableInfiniteLoading = true;
    error;
    contractName;
    collectionList;
    disbursalTransactionId;
    loanDisbursalTransaction;

    @wire(getCollectionCaseDetails, {collectionCaseId: '$recordId'})
    wiredContract({
        error,
        data
    }) {
        if (data) {
            this.collectionList = data;
            console.log('Check1' + JSON.stringify(this.collectionList));
            this.contractName = this.collectionList[0].Contract_Number__c;
            console.log('Check2' + this.collectionList[0].Contract_Number__c);
            if(this.contractName){
                this.getDisbursalTransactions();
            }
            this.error = undefined;
        } else if (error) {
            console.log('wiredContract' + JSON.stringify(error));
            this.collectionList = undefined;
            this.error = error;
        }
    }

    getDisbursalTransactions() {

        return getLoanDisbursalTransactionDetails({contractName: this.contractName})
            .then(result => {
                this.loanDisbursalTransaction = result;
                console.log('loanDisbursalTransaction:'+this.loanDisbursalTransaction[0].Id);
                this.disbursalTransactionId = this.loanDisbursalTransaction[0].Id;
                console.log('disbursalId:'+this.disbursalTransactionId);
                if(this.disbursalTransactionId) {
                    this.getFundingRecords();
                    this.getTransactionAmountGrandTotalRecords();
                }
                this.error = undefined;
            })
            .catch(error => {
                console.log('getDisbursalTransactions' + JSON.stringify(error));
                this.error = error;
                this.disbursalTransactionId = undefined;
            });
    }

    getFundingRecords() {
        return getFundingDetails({disbursalTransactionId: this.disbursalTransactionId})
            .then(result => {
                console.log('funding:'+JSON.stringify(result.length));
                this.fundingDetailList = result;
               /*  if(result.length > 0){
                    let updatedRecords = [...this.fundingDetailList, result];
                    this.fundingDetailList = updatedRecords;
                    console.log('fundings:'+JSON.stringify(this.fundingDetailList));
                }
                else {
                    this.fundingDetailList = result;
                } */
                if (result.length == 0) {
                    this.loadMoreStatus = 'No records to display';
                } else {
                    this.loadMoreStatus = '';
                }
                this.error = undefined;
            })
            .catch(error => {
                console.log('getFundingRecords' + JSON.stringify(error));
                this.error = error;
                this.fundingDetailList = undefined;
            });
    }

    getTransactionAmountGrandTotalRecords() {
            return getDisbursalTransactionSummary({disbursalTransactionId : this.disbursalTransactionId})
            .then(result => {
                console.log('Grandtotals:'+JSON.stringify(result));
                this.distributionGrandTotal = result.distributionGrandTotal;
                this.error = undefined;
            })
            .catch(error => {
                console.log('getTransactionAmountGrandTotalRecords' + JSON.stringify(error));
                this.error = error;
                this.distributionGrandTotal = undefined;
                console.log('error:'+JSON.stringify(this.error));
            });
    }

    loadMoreData(event) {
        const { target } = event;
        if (this.rowOffSet < this.totalRows) {
            target.isLoading = true;
            this.loadMoreStatus = '';
            this.rowOffSet = this.rowOffSet + this.rowLimit;
            this.enableInfiniteLoading = true;
            this.getFundingRecords()
                .then(() => {
                    target.isLoading = false;
                });
        } else {
            target.isLoading = false;
            this.loadMoreStatus = 'No more data to load';
            this.enableInfiniteLoading = false;
        }
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.fundingDetailList));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.fundingDetailList = parseData;
    }
}