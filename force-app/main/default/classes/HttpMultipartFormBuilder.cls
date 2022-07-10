public class HttpMultipartFormBuilder {
    private final static string BOUNDARY = '1ff13444ed8140c7a32fc4e6451aa76d';
    public enum EndingType {
        CR, CRLF, NONE
    }

    public static string getContentType() {
        return 'multipart/form-data;charset="UTF-8";boundary="' + BOUNDARY + '"';
    }

    private static string safelyPad(string value, string valueCrLf64, string lineBreaks) {
        string valueCrLf = '';
        blob valueCrLfBlob = null;

        while (valueCrLf64.endsWith('=')) {
            value += ' ';
            valueCrLf = value + lineBreaks;
            valueCrLfBlob = blob.valueOf(valueCrLf);
            valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
        }

        return valueCrLf64;
    }

    public static string writeBoundary() {
        string value = '--' + BOUNDARY + '\r\n';
        blob valueBlob = blob.valueOf(value);

        return EncodingUtil.base64Encode(valueBlob);
    }

    public static string writeBoundary(EndingType ending) {
        string value = '';

        if (ending == EndingType.CR) {
            value += '\n';
        } else if (ending == EndingType.NONE) {
            value += '\r\n';
        }

        value += '--' + BOUNDARY + '--';

        blob valueBlob = blob.valueOf(value);

        return EncodingUtil.base64Encode(valueBlob);
    }

    public static string writeBodyParameter(string key, string value) {
        string contentDisposition = 'Content-Disposition: form-data; name="' + key + '"';
        string contentDispositionCrLf = contentDisposition + '\r\n\r\n';
        blob contentDispositionCrLfBlob = blob.valueOf(contentDispositionCrLf);
        string contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrLfBlob);
        string content = safelyPad(contentDisposition, contentDispositionCrLf64, '\r\n\r\n');
        string valueCrLf = value + '\r\n';
        blob valueCrLfBlob = blob.valueOf(valueCrLf);
        string valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);

        content += safelyPad(value, valueCrLf64, '\r\n');

        return content;
    }

    public static string writeBlobBodyParameter(string key, string file64, string filename, string mimeType) {
        string contentDisposition = 'Content-Disposition: form-data; name="' + key + '"; filename="' + filename + '"';
        string contentDispositionCrLf = contentDisposition + '\r\n';
        blob contentDispositionCrLfBlob = blob.valueOf(contentDispositionCrLf);
        string contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrLfBlob);
        string content = safelyPad(contentDisposition, contentDispositionCrLf64, '\r\n');

        string contentTypeHeader = 'Content-Type: ' + mimeType;
        string contentTypeCrLf = contentTypeHeader + '\r\n\r\n';
        blob contentTypeCrLfBlob = blob.valueOf(contentTypeCrLf);
        string contentTypeCrLf64 = EncodingUtil.base64Encode(contentTypeCrLfBlob);
        content += safelyPad(contentTypeHeader, contentTypeCrLf64, '\r\n\r\n');

        integer file64Length = file64.length();
        String last4Bytes = file64.Right(4);

        EndingType ending = EndingType.NONE;
        if (last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.left(2) + '0K';
            file64 = file64.left(file64Length - 4) + last4Bytes;
            last4Bytes = null;
            ending = EndingType.CRLF;
        } else if (last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.left(3) + 'N';
            file64 = file64.left(file64Length - 4) + last4Bytes;
            last4Bytes = null;
            ending = EndingType.CR;
        }

        content += file64;
        file64 = null;
        content += writeBoundary(ending);
        return content;
    }
}