({
	calculateInterest : function(component, event, helper) {
        var compname=component.get("v.compname");
        var amount=component.get("v.amount");
        var rate=component.get("v.rate");
        var year=component.get("v.year");
        var int=amount*rate*year/100;
        var totalAmount=amount+int;
        component.set("v.interest",int);
        component.set("v.finalamount",totalAmount);
        
	}
})