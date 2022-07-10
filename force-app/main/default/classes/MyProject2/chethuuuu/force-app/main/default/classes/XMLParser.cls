public class XMLParser{

    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public static Map<String, List<String>> parseXMLResponse(HttpResponse responseObj, Set<String> responseModels, Set<String> parentModels) {
        Map<String, List<String>> responseMap = new Map<String, List<String>>();
        if(responseObj.getStatusCode() == 200) {
            responseMap = parseXML(responseObj.getBody(), responseModels, parentModels);
        } else if(responseObj.getStatusCode() != 200) {
            responseMap = parseXML(responseObj.getBody(), GeneralConstants.GET_FAILED_RESPONSE, null);
        }
        return responseMap;
    }

    public static Map<String, List<String>> parseXML(String toParse, Set<String> responseModels, Set<String> parentModels){

        Map<String, List<String>> xmlDataMap = new Map<String, List<String>>();
        DOM.Document doc = new DOM.Document();
        try {
            doc.load(toParse);
            DOM.XMLNode root = doc.getRootElement();
            xmlDataMap = iterateThroughXML(root, responseModels, parentModels, xmlDataMap);
        } catch(Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Parsing Response Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
       errorLogDBInstance.executeInserts();
       return xmlDataMap;
    }

    private static Map<String, List<String>> iterateThroughXML(DOM.XMLNode node, Set<String> responseModels, Set<String> parentModels, Map<String, List<String>> xmlDataMap){

        List<Dom.XMLNode> parentModelChildElements = new List<Dom.XMLNode>();

        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {

            if(responseModels != null && responseModels.contains(node.getName())) {
                xmlDataMap = prepareXMLDataMap(node.getName(), node.getText(), xmlDataMap);
            }

            if(parentModels != null && parentModels.contains(node.getName())) {
                parentModelChildElements.addAll(node.getChildren());
            }

            if(!parentModelChildElements.isEmpty()) {
                for (Dom.XMLNode child: parentModelChildElements) {
                    String parentChildName = node.getName()+child.getName();
                    xmlDataMap = prepareXMLDataMap(parentChildName, child.getText(), xmlDataMap);

                    if(!child.getChildren().isEmpty()) {
                        for (Dom.XMLNode subChild: child.getChildren()) {
                            String subParentChildName = node.getName()+child.getName()+subChild.getName();
                            xmlDataMap = prepareXMLDataMap(subParentChildName, subChild.getText(), xmlDataMap);
                        }
                    }
                }
            }
            for (Dom.XMLNode child: node.getChildElements()) {
                iterateThroughXML(child, responseModels, parentModels, xmlDataMap);
            }
        }
        return xmlDataMap;
    }

    private static Map<String, List<String>> prepareXMLDataMap(String model, String value, Map<String, List<String>> xmlDataMap){
        if (xmlDataMap.containsKey(model)) {
            xmlDataMap.get(model).add(String.valueOf(value));
        } else {
            xmlDataMap.put(model, new List<String> {String.valueOf(value)});
        }
       return xmlDataMap;
    }

}