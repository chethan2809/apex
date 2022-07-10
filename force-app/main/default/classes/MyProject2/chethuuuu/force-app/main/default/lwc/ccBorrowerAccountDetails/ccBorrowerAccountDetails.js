import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNT_NAME from '@salesforce/schema/Collection_Case__c.Account__r.Name';
import ACCOUNT_PHONE from '@salesforce/schema/Collection_Case__c.Account__r.Phone';
import BUILDING_NUMBER from '@salesforce/schema/Collection_Case__c.Account__r.BillingBuildingNumber__c';
import BILLING_STREET from '@salesforce/schema/Collection_Case__c.Account__r.BillingStreet';
import BILLING_CITY from '@salesforce/schema/Collection_Case__c.Account__r.BillingCity';
import BILLING_STATE from '@salesforce/schema/Collection_Case__c.Account__r.BillingState';
import BILLING_POSTALCODE from '@salesforce/schema/Collection_Case__c.Account__r.BillingPostalCode';
import BILLING_COUNTRY from '@salesforce/schema/Collection_Case__c.Account__r.BillingCountry';
import ACCOUNT_ID from '@salesforce/schema/Collection_Case__c.Account__c';

export default class CcBorrowerAccountDetails extends LightningElement {
    @api recordId;

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [ACCOUNT_ID, ACCOUNT_NAME, ACCOUNT_PHONE, BUILDING_NUMBER,
                 BILLING_STREET, BILLING_CITY, BILLING_STATE,
                 BILLING_POSTALCODE, BILLING_COUNTRY
                ]
	})
    accountDetails;
    
    get accountId(){
        return '/' + getFieldValue(this.accountDetails.data, ACCOUNT_ID);
    }

    get accountName(){
        return getFieldValue(this.accountDetails.data, ACCOUNT_NAME);
    }

    get accountPhone(){
        return getFieldValue(this.accountDetails.data, ACCOUNT_PHONE);
    }

    get buildingNumber(){
        return getFieldValue(this.accountDetails.data, BUILDING_NUMBER);
    }

    get billingStreet(){
        return getFieldValue(this.accountDetails.data, BILLING_STREET);
    }

    get billingCity(){
        return getFieldValue(this.accountDetails.data, BILLING_CITY);
    }

    get billingState(){
        return getFieldValue(this.accountDetails.data, BILLING_STATE);
    }

    get billingPostalCode(){
        return getFieldValue(this.accountDetails.data, BILLING_POSTALCODE);
    }

    get billingCountry(){
        return getFieldValue(this.accountDetails.data, BILLING_COUNTRY);
    }
}