public class PartnerPricingSecureLinks {
    public static String generatePartnerPricingSecureLink(Id applicationId) {
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('applicationId', applicationId);

        //encodingutil.converttohex(crypto.generateaeskey(128)); rWCV4l71cN6wvog3Hrthsw==
        String aesKey = CustomSettingsHelper.generalSettings.Partner_Pricing_Secure_Link_Key__c;
        Blob data = Blob.valueOf(JSON.serialize(requestMap));
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', EncodingUtil.base64Decode(aesKey), data);
        String encryptedString = EncodingUtil.convertToHex(encrypted);
        String secureLink = GeneralHelper.siteFullURLByName('PartnerPricingSecureLink') + '/s/?source=' + encryptedString;
        return secureLink;
    }
}