import { LightningElement, wire, api } from 'lwc';
import getChargesSummaryByType from '@salesforce/apex/CollectionCaseDB.getChargesSummaryByFeeType';
import getChargesSummary from '@salesforce/apex/CollectionCaseDB.getChargesSummary';
import getCollectionCaseDetails from '@salesforce/apex/CollectionCaseDB.getCollectionCaseDetails';
import { getChargesSummaryColumns } from 'c/ccDataTableConfig';

export default class CcLoanChargesSummary extends LightningElement {
    @api recordId;
    columns = getChargesSummaryColumns();
    error;
    collectionList;
    chargesSummaryList = [];
    clContractId;
    sortBy;
    sortDirection;
    grandTotalDue;
    grandTotalPaid;

    @wire(getCollectionCaseDetails, {collectionCaseId: '$recordId'})
    wiredContract({
        error,
        data
    }) {
        if (data) {
            this.collectionList = data;
            this.clContractId = this.collectionList[0].CL_Contract_Id__c;
            if(this.clContractId){
                this.getChargesSummaryRecords();
                this.getChargesGrandTotalRecords();
            }
        } else if (error) {
            this.error = error;
        }
    }

    getChargesSummaryRecords() {
        return getChargesSummaryByType({ loanAccountId: this.clContractId })
            .then(result => {
                this.chargesSummaryList = result;
                let chargesSummaryArray = [];
                for (let row of this.chargesSummaryList) {
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
                    chargesSummaryArray.push(flattenedRow);
                }

                this.chargesSummaryList  = chargesSummaryArray;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.chargesSummaryList = undefined;
            });
    }

    getChargesGrandTotalRecords() {
        return getChargesSummary({ loanAccountId: this.clContractId })
            .then(result => {
                console.log('Grandtotals:'+JSON.stringify(result));
                this.grandTotalDue = result.grandTotalDue;
                this.grandTotalPaid = result.grandTotalPaid;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                console.log('error:'+JSON.stringify(this.error));
            });
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.chargesSummaryList));
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
        this.chargesSummaryList = parseData;
    }

    _flatten(nodeValue, flattenedRow, nodeName){
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.'+ key;
            flattenedRow[finalKey] = nodeValue[key];
        })
    }
}