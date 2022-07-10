public class CompumailReturns {

    public static String getDocumentName() {
        DateTime currentSystemDateTime = GeneralHelper.currentSystemDateTime;
        String todaysDate = (DateTime.newInstance(currentSystemDateTime.year(), currentSystemDateTime.month(),currentSystemDateTime.day()).format('YYYYMMDD'));
        String todaysTime = String.valueOf(currentSystemDateTime.getTime());
        String documentName = todaysDate + ' Compumail Return ' + todaysTime + '.csv';
        return documentName;
    }

    public static Attachment buildDocumentBody(String name, List<String> csvRowList, Id parentId) {
        String ncoaColumnList = 'Custno,Ltrno,DNA,NA1,NA2,NCT,NST,Z11,ACC,PH2,DCD,MTP,MDT,NIX\n';
        String csvFile = ncoaColumnList + String.join(csvRowList, '\n');
        Attachment attachmentObj = new Attachment();
        attachmentObj.Body = Blob.valueOf(csvFile);
        attachmentObj.Name = name;
        attachmentObj.parentId = parentId;
        return attachmentObj;
    }
}