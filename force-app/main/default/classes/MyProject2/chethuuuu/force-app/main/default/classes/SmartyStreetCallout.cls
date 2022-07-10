public class SmartyStreetCallout {
    public static void verifyAddress(String Address){
        
        Http http = new Http();
        HttpRequest Request = new HttpRequest();
        Request.setEndpoint('https://us-autocomplete-pro.api.smartystreets.com/lookup?auth-id=0a7a4fb6-9fbe-249d-a73e-883217f03bf4&auth-token=r7u9rlxxhSGW9p7AI3ZV&search='+ Address);
        Request.setMethod('GET');
        Request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        //Request.setBody('[{"candidates":10,"match":"invalid","street":"3901 SW 154th Ave","street2":"","city":"Davie","state":"FL","zipcode":"33331"}]');
        HttpResponse Response = http.send(Request);
        System.debug(' Request: '+ Request);
        System.debug(' Response: '+ Response);
        
        if(Response.getStatusCode()!=200){
            system.debug('Error: - ' + Response.getBody());
        }
        
        if(Response.getStatusCode()==200){
            Map<string,object> Results = (Map<string,object>) JSON.deserializeUntyped(Response.getBody());
            system.debug('Success: '+Response.getBody());
           System.debug('Result' + Results);
            
            
		/*List<object> zipcodes= (List<object>) Results.get('zipcode');
		//zipcodes.add(Results.get('zipcode'));
            for(object zipcode : zipcodes){
            	Map<string,object> cities = (Map<string,object>)zipcode;
            	system.debug(cities.get('city'));
            Map<string,object> states= (Map<string,object>)zipcode;
				system.debug(states.get('state'));*/
           }
            
        }
    }