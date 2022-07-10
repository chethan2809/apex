Public class FileDownLoadUtility{

    @future(callout = true)
    public static void fetchFileFromExternalUrl(String extFileUrl){
        //extFileUrl='https://drive.google.com/file/d/0ByXILxflqQ2jWGpNVmI1WW9uYTQ/view?usp=sharing';
        Http h = new Http(); 
        HttpRequest req = new HttpRequest(); 
        //Replace any spaces in extFileUrl with %20 
        extFileUrl = extFileUrl.replace(' ', '%20'); 
        //Set the end point URL
        req.setEndpoint(extFileUrl); 
        req.setMethod('GET'); 
        req.setHeader('Content-Type', 'application/pdf'); 
        req.setCompressed(true); 
        req.setTimeout(60000); 
        //Now Send HTTP Request
        HttpResponse res  = h.send(req); 
        system.debug('Response from Server: ' + res.getBody()); 
        //getBodyAsBlob method was will convert the response into Blob 
        blob retFile = res.getBodyAsBlob();
        System.debug('00retFile'+retFile);
        //return retFile;
    }
    
    public static Id createAttachment(blob fileContent, String recordId, String fileType){
        //for pdf files content type should be pdf
        //for jpeg file content type should be image/jpeg
        Attachment attach = new Attachment(); 
        attach.ParentId = recordId; 
        attach.Name = 'FileFromExtenalSource.pdf'; 
        attach.Body = fileContent; 
        attach.contentType = fileType; 
        insert attach; 
        return attach.id;
    }
}