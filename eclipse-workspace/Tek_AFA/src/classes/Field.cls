public with sharing class Field {
    @AuraEnabled
    public Boolean DBRequired { get;set; }

    @AuraEnabled
    public String APIName { get;set; }

    @AuraEnabled
    public String Label { get;set; }

    @AuraEnabled
    public Boolean Required { get;set; }

    @AuraEnabled
    public String Type { get; set; }

    @AuraEnabled
    public Object FieldValue {get; set;}

    @AuraEnabled
    public Integer FieldPosition {get; set;}

    @AuraEnabled
    public String FieldHelpText {get; set;}
    
    @AuraEnabled
    public String ReferenceObjectName { get; set; }

    public Field(Schema.FieldSetMember f) {
        this.DBRequired = f.DBRequired;
        this.APIName = f.fieldPath;
        this.Label = f.label;
        this.Required = f.required;
        this.Type = '' + f.getType();
    }

    public Field(Boolean DBRequired) {
        this.DBRequired = DBRequired;
    }
    
    public void setFieldsUsingFieldDescribe(Schema.DescribeFieldResult fieldDesc) {
        FieldHelpText = fieldDesc.getInlineHelpText();
        
        List<Schema.sObjectType> referenceTos = fieldDesc.getReferenceTo();
        
        if (fieldDesc.isCustom() &&
            referenceTos != null &&
            referenceTos.size() > 0) {
            Schema.SObjectType parentSObjectType = referenceTos[0];
            ReferenceObjectName = parentSObjectType.getDescribe().getName();
        }
        
        if (this.Type == 'TextArea' && fieldDesc.isHtmlFormatted()) {
            this.Type = 'RichTextArea';
        }
    }
}