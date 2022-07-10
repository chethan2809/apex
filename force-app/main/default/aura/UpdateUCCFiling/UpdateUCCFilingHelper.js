({
	helperMethod : function() {
	},

	showDialog : function(component) {
		component.set('v.showConfirmDialog', false);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
    	dismissActionPanel.fire();
	}
})