({
	doAdd : function(component, event, helper) {
        
        var number1 = component.get("v.input1");
        var number2 = component.get("v.input2");
        component.set("v.output",parseInt(number1)+parseInt(number2));
        
		
	},
    doSub : function(component, event, helper) {
		var number1 = component.get("v.input1");
        var number2 = component.get("v.input2");
        component.set("v.output",parseInt(number1)-parseInt(number2));
	},
    doMul : function(component, event, helper) {
		var number1 = component.get("v.input1");
        var number2 = component.get("v.input2");
        component.set("v.output",parseInt(number1)*parseInt(number2));
	},
    doDiv : function(component, event, helper) {
		var number1 = component.get("v.input1");
        var number2 = component.get("v.input2");
        component.set("v.output",parseInt(number1)/parseInt(number2));
	}
})