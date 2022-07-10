public class EmailTemplateDB extends DBManager {
    public List<EmailTemplate> getTemplatesByName(Set<String> templateNames) {
        return [
            SELECT Id, Name, Subject, Body, HtmlValue, TemplateType, DeveloperName
            FROM EmailTemplate
            WHERE DeveloperName IN :templateNames
        ];
    }

    public List<EmailTemplate> getAllTemplates() {
        return [
            SELECT Id, Name, Subject, Body, HtmlValue, TemplateType, DeveloperName
            FROM EmailTemplate
        ];
    }
}