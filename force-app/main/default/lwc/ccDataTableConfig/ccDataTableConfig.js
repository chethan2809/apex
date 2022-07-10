const getPaymentColumns = () => {
    return [
        {
            label: 'Transaction Id',
            fieldName: 'Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Transaction Date',
            fieldName: 'loan__Transaction_Date__c',
            type: 'date',
            sortable: true,
            initialWidth: 180,
            typeAttributes: {
                year: "numeric",
                month: "2-digit",
                day: "2-digit",
                timeZone: "UTC"
            }
        },
        {
            label: 'Transaction Amount',
            fieldName: 'loan__Transaction_Amount__c',
            type: 'currency',
            sortable: true,
            initialWidth: 180
        },
        {
            label: 'Principal',
            fieldName: 'loan__Principal__c',
            type: 'currency',
            sortable: true
        },
        {
            label: 'Interest',
            fieldName: 'loan__Interest__c',
            type: 'currency',
            sortable: true
        },
        {
            label: 'Fees',
            fieldName: 'loan__Fees__c',
            type: 'currency',
            sortable: true
        },
        {
            label: 'Payment Type',
            fieldName: 'loan__Payment_Type__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Cleared',
            fieldName: 'loan__Cleared__c',
            type: 'boolean',
            sortable: true,
            initialWidth: 100
        },
        {
            label: 'Reversed',
            fieldName: 'loan__Reversed__c',
            type: 'boolean',
            sortable: true,
            initialWidth: 100
        },
        {
            label: 'Return Reason Code',
            fieldName: 'loan__Reversal_Reason__c',
            type: 'text',
            sortable: true,
            initialWidth: 100
        },
        {
            label: 'Reference',
            fieldName: 'Reversed_LPT_Reference__c',
            type: 'text',
            sortable: true,
            initialWidth: 100
        }
    ];
};
const getBillColumns = () => {
    return [
        {
            label: 'Due Id',
            fieldName: 'Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Due Date',
            fieldName: 'loan__Due_Date__c',
            type: 'date',
            sortable: true,
            typeAttributes: {
                year: "numeric",
                month: "2-digit",
                day: "2-digit",
                timeZone: "UTC"
            }
        },
        {
            label: 'Due Amount',
            fieldName: 'loan__Due_Amt__c',
            type: 'currency',
            sortable: true
        },
        {
            label: 'Payment Amount',
            fieldName: 'loan__Payment_Amt__c',
            type: 'currency',
            sortable: true
        },
        {
            label: 'Payment Satisfied',
            fieldName: 'loan__Payment_Satisfied__c',
            type: 'boolean',
            sortable: true
        }];
};

const getChargesColumns = () => {
    return [
        {
            label: 'Charge Id',
            fieldName: 'Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Date',
            fieldName: 'loan__Date__c',
            type: 'date',
            sortable: true,
            typeAttributes: {
                year: "numeric",
                month: "2-digit",
                day: "2-digit",
                timeZone: "UTC"
            }
        },
        {
            label: 'Total Amount Due',
            fieldName: 'loan__Total_Amount_Due__c',
            type: 'currency',
            sortable: true
        },
        {
            label: 'Paid Amount',
            fieldName: 'loan__Paid_Amount__c',
            type: 'currency',
            sortable: true
        },
        {
            label: 'Fee Name',
            fieldName: 'loan__Fee__r.Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Paid',
            fieldName: 'loan__Paid__c',
            type: 'boolean',
            sortable: true
        },
        {
            label: 'Waived',
            fieldName: 'loan__Waive__c',
            type: 'boolean',
            sortable: true
        }];
};

const getChargesSummaryColumns = () => {
    return [
        {
            label: 'Fee Name',
            fieldName: 'Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Total Due',
            fieldName: 'totalDue',
            type: 'currency',
            sortable: true,
        },
        {
            label: 'Total Paid',
            fieldName: 'totalPaid',
            type: 'currency',
            sortable: true
        }];
};

const getRelatedPartiesColumns = () => {
    return [
        {
            label: "Name",
            fieldName: "contactLinkName",
            type: "url",
            sortable: true,
            initialWidth: 120,
            typeAttributes: {
                label: {
                    fieldName: "clcommon__Contact__r.Name"
                },
                target: "_blank"
            }
        },
        {
            label: 'Party Type',
            fieldName: 'clcommon__Type__r.Name',
            type: 'text',
            sortable: true,
            initialWidth: 120
        },
        {
            label: 'Title',
            fieldName: 'clcommon__Contact__r.Title__c',
            type: 'text',
            sortable: true,
            initialWidth: 120
        },
        {
            label: 'Birthdate',
            fieldName: 'clcommon__Contact__r.Birthdate',
            type: 'date',
            sortable: true,
            initialWidth: 180,
            typeAttributes: {
                year: "numeric",
                month: "2-digit",
                day: "2-digit",
                timeZone: "UTC"
            }
        },
        {
            label: 'Social Security Number',
            fieldName: 'clcommon__Contact__r.ints__Social_Security_Number__c',
            type: 'text',
            sortable: true,
            initialWidth: 180
        },
        {
            label: "Mailing Address",
            fieldName: "mailingAddressLink",
            type: "url",
            sortable: true,
            wrapText: true,
            initialWidth: 300,
            typeAttributes: {
                label: {
                    fieldName: "customMailingAddress"
                },
                target: "_blank",
            }
        },
        {
            label: 'Mobile',
            fieldName: 'clcommon__Contact__r.MobilePhone',
            type: 'phone',
            initialWidth: 120,
            sortable: true
        },
        {
            label: 'Phone',
            fieldName: 'clcommon__Contact__r.Phone',
            type: 'phone',
            sortable: true,
            initialWidth: 120
        },
        {
            label: 'Alternate Phone',
            fieldName: 'clcommon__Contact__r.Alternate_Phone__c',
            type: 'phone',
            sortable: true,
            initialWidth: 120
        },
        {
            label: 'Email',
            fieldName: 'clcommon__Contact__r.Email',
            type: 'email',
            sortable: true,
            initialWidth: 250
        },
        {
            label: 'Alternate Email',
            fieldName: 'clcommon__Contact__r.Alternate_Email__c',
            type: "email",
            sortable: true,
            initialWidth: 250
        },
        {
            label: 'Do Not Contact',
            fieldName: 'clcommon__Contact__r.Do_Not_Contact__c',
            type: "text",
            sortable: true,
            initialWidth: 180
        }
    ];
};

const getRelatedContactColumns = () => {
    return [
        {
            label: "Name",
            fieldName: "contactLinkName",
            type: "url",
            sortable: true,
            initialWidth: 180,
            typeAttributes: {
                label: {
                    fieldName: "Contact.Name"
                },
                target: "_blank"
            }
        },
        {
            label: 'Contact Type',
            fieldName: 'Contact.loan__Contact_Type__c',
            type: 'text',
            sortable: true,
            initialWidth: 120
        },
        {
            label: 'Title',
            fieldName: 'Contact.Title__c',
            type: 'text',
            sortable: true,
            initialWidth: 120
        },
        {
            label: 'Birthdate',
            fieldName: 'Contact.Birthdate',
            type: 'date',
            sortable: true,
            initialWidth: 120,
            typeAttributes: {
                year: "numeric",
                month: "2-digit",
                day: "2-digit",
                timeZone: "UTC"
            }
        },
        {
            label: 'Social Security Number',
            fieldName: 'Contact.ints__Social_Security_Number__c',
            type: 'text',
            sortable: true,
            initialWidth: 200
        },
        {
            label: "Mailing Address",
            fieldName: "mailingAddressLink",
            type: "url",
            sortable: true,
            wrapText: true,
            initialWidth: 250,
            typeAttributes: {
                label: {
                    fieldName: "customMailingAddress"
                },
                target: "_blank",
            }
        },
        {
            label: 'Mobile',
            fieldName: 'Contact.MobilePhone',
            type: 'phone',
            sortable: true,
            initialWidth: 120
        },
        {
            label: 'Phone',
            fieldName: 'Contact.Phone',
            type: 'phone',
            sortable: true,
            initialWidth: 120
        },
        {
            label: 'Alternate Phone',
            fieldName: 'Contact.Alternate_Phone__c',
            type: 'phone',
            sortable: true,
            initialWidth: 120
        },
        {
            label: 'Email',
            fieldName: 'Contact.Email',
            type: 'email',
            sortable: true,
            initialWidth: 250
        },
        {
            label: 'Alternate Email',
            fieldName: 'Contact.Alternate_Email__c',
            type: "email",
            sortable: true,
            initialWidth: 250
        },
        {
            label: 'Do Not Contact',
            fieldName: 'Contact.Do_Not_Contact__c',
            type: "text",
            sortable: true,
            initialWidth: 180
        }
        ];
};

const getFileColumns = () => {
    return [
        {
            label: 'Name',
            fieldName: 'Name',
            type: 'text',
            sortable: true,
            initialWidth: 300
        },
        {
            label: 'Document Category Name',
            fieldName: 'Document_Category_Name__c',
            type: 'text',
            sortable: true,
            initialWidth: 200
        },
        {
            label: 'Wasabi Link',
            fieldName: 'Wasabi_Link__c',
            type: 'url',
            sortable: true
        },
        {
            label: 'Created Date',
            fieldName: 'CreatedDate',
            type: 'text',
            sortable: true,
            initialWidth: 200,
            typeAttributes: {
                year: "numeric",
                month: "2-digit",
                day: "2-digit",
                timeZone: "UTC"
            }
        }
    ];
};
const getAPSColumns = () => {
    return [
        {
            label: 'Automated Payment Setup Name',
            fieldName: 'Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Type',
            fieldName: 'loan__Type__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Transaction Amount',
            fieldName: 'loan__Transaction_Amount__c',
            type: 'currency',
            sortable: true
        },
        {
            label: 'Debit Date',
            fieldName: 'loan__Debit_Date__c',
            type: 'date',
            sortable: true,
            initialWidth: 180,
            typeAttributes: {
                year: "numeric",
                month: "2-digit",
                day: "2-digit",
                timeZone: "UTC"
            }
        },
        {
            label: 'Frequency',
            fieldName: 'loan__Frequency__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Payment Mode',
            fieldName: 'loan__Payment_Mode__r.Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Active',
            fieldName: 'loan__Active__c',
            type: 'boolean',
            sortable: true
        }
    ];
}
const getCreditReportColumns = () => {
    return [
        {
            label: "Credit Report Detail Name",
            fieldName: "consumerCreditLinkName",
            type: "url",
            sortable: true,
            typeAttributes: {
                label: {
                    fieldName: "Name"
                },
                target: "_blank"
            }
        },
        {
            label: 'Credit Statement',
            fieldName: 'Credit_Statement__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Personal FICO Score',
            fieldName: 'Personal_FICO_Score__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'BK Risk Score',
            fieldName: 'Bankruptcy_Risk_Score__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Source Type',
            fieldName: 'Source_Type__c',
            type: 'text',
            sortable: true
        }
    ];
};
const getBusinessReportColumns = () => {
    return [
        {
            label: "Credit Report Detail Name",
            fieldName: "businessCreditLinkName",
            type: "url",
            sortable: true,
            typeAttributes: {
                label: {
                    fieldName: "Name"
                },
                target: "_blank"
            }
        },
        {
            label: 'Account',
            fieldName: 'Account__r.Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Legal Name',
            fieldName: 'Legal_Name__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Source Type',
            fieldName: 'Source_Type__c',
            type: 'text',
            sortable: true
        }
    ];
};

const getFundingDetailColumns = () => {
    return [
        {
            label: 'Disbursal Distribution ID',
            fieldName: 'Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Transaction Date',
            fieldName: 'loan__Transaction_Date__c',
            type: 'date',
            sortable: true,
            initialWidth: 180,
            typeAttributes: {
                year: "numeric",
                month: "2-digit",
                day: "2-digit",
                timeZone: "UTC"
            }
        },
        {
            label: 'Funded Source',
            fieldName: 'Funded_Source__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Account Name',
            fieldName: 'Account_Name__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Payment Mode',
            fieldName: 'loan__Payment_Mode__c',
            type: 'number',
            sortable: true
        },
        {
            label: 'Distribution Amount',
            fieldName: 'loan__Distribution_Amount__c',
            type: 'currency',
            sortable: true
        }
    ];
};
export {
    getPaymentColumns,
    getBillColumns,
    getChargesColumns,
    getChargesSummaryColumns,
    getRelatedPartiesColumns,
    getFileColumns,
    getAPSColumns,
    getCreditReportColumns,
    getBusinessReportColumns,
    getRelatedContactColumns,
    getFundingDetailColumns
};