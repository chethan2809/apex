public class Notes {
    public static Note createNote(String title, String body, Id parentId) {
        Note noteObj = new Note();
        noteObj.Title = title;
        noteObj.Body = body;
        noteObj.parentId = parentId;
        return noteObj;
    }
}