({
    doInit : function(component, event, helper) {
        var pageRef = component.get("v.pageReference");
        var myValue = pageRef.state.c__recordId;
        component.set("v.recordId",myValue);
    },
    handleCloseClick: function(component, event) {
          var recId = component.get("v.recordId");
          console.log('recordId:' + recId);
        component.find("navigation")
        .navigate({
            "type" : "standard__recordPage",
            "attributes": {
                "recordId": recId,
                "actionName": "view"
            }
        }, true);
    },
})