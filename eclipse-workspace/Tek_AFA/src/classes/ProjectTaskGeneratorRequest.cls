public with sharing class ProjectTaskGeneratorRequest {
    @InvocableVariable(required=true)
    public Id RecordId;

    @InvocableVariable(required=true)
    public String ProjectTemplateName;
}