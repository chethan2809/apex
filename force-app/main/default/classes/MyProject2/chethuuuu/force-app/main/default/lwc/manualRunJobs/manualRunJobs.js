import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getManualJobsToRun from '@salesforce/apex/ManualRunJobsController.getManualJobsToRun';
import runManualJob from '@salesforce/apex/ManualRunJobsController.runManualJob';

export default class ManualRunJobs extends LightningElement {
    @track selectedJob = '';
    @track loading = false;
    @track runJobError;
    @track disableSubmit = true;
    @track batchSize;

    @wire(getManualJobsToRun) jobMetadataSettings;

    get jobOptions() {
        if (this.jobMetadataSettings.data) {
            let options = [];
            options.push({ "label": "Select Jobs", "value": '' });
            for (let key in this.jobMetadataSettings.data) {
                options.push({
                    "label": this.jobMetadataSettings.data[key].MasterLabel,
                    "value": this.jobMetadataSettings.data[key].DeveloperName
                });
            }
            return options;
        }
    }

    get isError() {
        return this.errors.length > 0;
    }

    get isLoading() {
        if (this.isError) {
            this.disableSubmit = true;
            return false;
        }
        return this.loading;
    }

    get errors() {
        let errors = [];
        if (this.jobMetadataSettings.error) {
            errors = errors.concat(this.jobMetadataSettings.error);
        }
        if (this.runJobError) {
            errors = errors.concat(this.runJobError);
        }

        if (errors.length > 0) {
            console.error(JSON.stringify(errors, null, 2));
        }
        return errors;
    }

    selectJobsChangeHandler(event) {
        this.selectedJob = event.detail.value;
        if(this.selectedJob && this.selectedJob.length > 0) {
            this.batchSize = this.jobMetadataSettings.data[this.selectedJob].Sample_Size__c;
            this.disableSubmit = false;
        } else {
            this.disableSubmit = true;
            this.batchSize = undefined;
        }
    }

    onBatchSizeChange(event) {
        this.batchSize = event.detail.value;
        if(this.batchSize && this.batchSize.length > 0 && this.batchSize > 0 && this.batchSize <= 2000
            && this.selectedJob && this.selectedJob.length > 0
        ) {
            this.disableSubmit = false;
        } else {
            this.disableSubmit = true;
        }
    }

    submitHandleClickHandler(event) {
        this.loading = true;
        this.disableSubmit = true;
        this.template.querySelectorAll('lightning-combobox').forEach(each => {
            each.value = undefined;
        });

        runManualJob({jobName : this.selectedJob, batchSize : this.batchSize})
        .then(result => {
            this.batchSize = undefined;
            this.showToastMessage(
                this.selectedJob + ' Executed Successfully!', 'Please Monitor Jobs under Setup -> Apex Jobs', 'success'
            );
            this.loading = false;
        })
        .catch(error =>{
            this.batchSize = undefined;
            this.runJobError = error;
        })
    }

    showToastMessage(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}