({

    handleConfirmDialogYes : function(component, event, helper) {
        var accountId = component.get("v.recordId");
        var action = component.get("c.terminateUCCFiling");

        action.setParams({
            "accountId":accountId
        });

        action.setCallback(this, function(response) {
        });

        $A.enqueueAction(action);
        helper.showDialog(component);
    },
    handleConfirmDialogNo : function(component, event, helper) {
        helper.showDialog(component);
    },
})