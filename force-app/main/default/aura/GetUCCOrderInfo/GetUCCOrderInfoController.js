({
    handleConfirmDialogYes : function(component, event, helper) {
        var accountId = component.get("v.recordId");
        var action = component.get("c.getOrderInformationOnClick");
        action.setParams({
            "accountId":accountId
        });
        $A.enqueueAction(action);
        helper.showDialog(component);
    },

    handleConfirmDialogNo : function(component, event, helper) {
        helper.showDialog(component);
    },
})