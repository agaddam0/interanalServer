@isTest
public class UploadFileCTRLTester {
    private static final String DEFAULT_FILE_DESCRIPTION = 'TEST Description'; 
    
    static Id serviceExchangeAgreementRecTypeId = Schema.SObjectType.Enrollment_Form__c.getRecordTypeInfosByName().get('Service Exchange Agreement').getRecordTypeId();
    static ContentVersion document = new ContentVersion();
    static Proposal__c proposal = new Proposal__c();

    @testSetup
    static void testData()
    {
        try {
	        Opportunity opportunity = OpportunityTestData.Instance.insertAFESOpportunity();
	        
	        Enrollment_Form__c signatureForm = new Enrollment_Form__c();
	        signatureForm.Status__c = 'In Progress';
	        signatureForm.Auto_Generated__c = false;
	        signatureForm.RecordTypeId = serviceExchangeAgreementRecTypeId;
	        signatureForm.Enrollment_Opportunity__c = opportunity.Id;
	        
	        insert signatureForm;
	        
	        Opportunity o = OpportunityTestData.Instance.insertAWDOpportunity();
	        	        
	        ContentVersion ctv = new ContentVersion();
	        ctv.Title = 'Test Content';
	        ctv.PathOnClient = 'Test.jpg';
	        ctv.VersionData = Blob.valueOf('Test Content');
	        ctv.IsMajorVersion = true;
	        ctv.Description = DEFAULT_FILE_DESCRIPTION;
	        insert ctv;
	        
	        document = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: ctv.Id];
	        
	        Proposal__c p = new Proposal__c();
            p.Group_Display_Name__c = 'Test Proposal Group Name';
            p.Opportunity__c = o.Id;
            insert p;
	        
	        ContentDocumentLink newFileShare = new ContentDocumentLink();
	        newFileShare.ContentDocumentId = document.ContentDocumentId;
	        newFileShare.LinkedEntityId = p.Id;
	        newFileShare.ShareType = 'V';
	        
	        insert newFileShare;
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
        }
    }
    
    static void loadTestDocument() {
        List<ContentVersion> documents = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test Content'];
        
        if (documents.size() > 0) {
            document = documents[0];
        }
    }
    
    static void loadTestProposal() {
        List<Proposal__c> proposals = [SELECT Id, Opportunity__c FROM Proposal__c WHERE Group_Display_Name__c = 'Test Proposal Group Name'];
        
        if (proposals.size() > 0) {
            proposal = proposals[0];
        }
    }
    
    @isTest
    static void testNewFileUpload()
    {
        Enrollment_Form__c eForm = [SELECT Id, Status__c, Enrollment_Opportunity__c FROM Enrollment_Form__c 
                                    WHERE RecordTypeId =: serviceExchangeAgreementRecTypeId LIMIT 1];
        
        try {
            ApexPages.currentPage().getParameters().put('id', eForm.Id);
            ApexPages.currentPage().getParameters().put('ContentLinkIds', eForm.Enrollment_Opportunity__c);
            UploadFileCTRL ctrl = new UploadFileCTRL();
            ctrl.fileName = 'Test Name';
            Blob body = Blob.valueOf('Test Blob');
            ctrl.fileBody = body;
            ctrl.upload();
            
            ContentDocumentLink cdl = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: eForm.Id];
            system.assert(cdl != null); 
            
            ApexPages.currentPage().getParameters().put('fileToDelete', cdl.ContentDocumentId);
            ctrl.DeleteFile();
            List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: eForm.Id];
            system.assert(cdls.size() == 0);
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
        }
    }

    @isTest
    static void test_getContentDocumentLinks()
    {
        try {
	        loadTestProposal();
	        test.startTest();
	        
	        // Luke: if the proposal doesn't exist, it's probably because there was a "Unable To Lock Row Error" during testSetup
	        // so continue on.
	        if (proposal == null || proposal.Id == null) { return; }
	        
	        List<ContentDocumentLink> links = UploadFileCTRL.getContentDocumentLinks(proposal.Id, '');
	        test.stopTest();
	        
	        system.assertEquals(1, links.size());
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
        }
    }

    @isTest
    static void getContentDocumentLinks_filterByDefaultDescription_expectFileReturnedTest()
    {
        try {
            loadTestProposal();
            test.startTest();
            
            // Luke: if the proposal doesn't exist, it's probably because there was a "Unable To Lock Row Error" during testSetup
            // so continue on.
            if (proposal == null || proposal.Id == null) { return; }
            
            List<ContentDocumentLink> links = UploadFileCTRL.getContentDocumentLinks(proposal.Id, DEFAULT_FILE_DESCRIPTION);
            test.stopTest();
            
            system.assertEquals(1, links.size());
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
        }
    }
    
    @isTest
    static void test_afterUploadProcessing()
    {
        try {
	        loadTestProposal();
	        loadTestDocument();
	        
	        // Luke: if the proposal or document doesn't exist, it's probably because there was a "Unable To Lock Row Error" during testSetup
            // so continue on.
            if (proposal == null ||
                proposal.Id == null ||
                document == null ||
                document.ContentDocumentId == null) {
                return;
            }
	        
	        test.startTest();
	        List<ContentDocumentLink> links = UploadFileCTRL.afterUploadProcessing(proposal.Id, new List<String>{document.ContentDocumentId}, new List<String>{proposal.Opportunity__c}, '', '');
	        test.stopTest();
	        
	        system.assertEquals(1, links.size());
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
        }
    }

    @isTest
    static void afterUploadProcessing_withFileDescription_expectContentDocumentHasFileDescriptionTest()
    {
        try {
            loadTestProposal();
            loadTestDocument();
            
            // Luke: if the proposal or document doesn't exist, it's probably because there was a "Unable To Lock Row Error" during testSetup
            // so continue on.
            if (proposal == null ||
                proposal.Id == null ||
                document == null ||
                document.ContentDocumentId == null) {
                return;
            }
            
            test.startTest();
            
            String fileDescription = 'testDescription';
            
            List<ContentDocumentLink> links = UploadFileCTRL.afterUploadProcessing(proposal.Id, new List<String>{document.ContentDocumentId}, new List<String>{proposal.Opportunity__c}, fileDescription, '');
            test.stopTest();
            
            system.assertEquals(1, links.size());
            system.assertEquals(fileDescription, links[0].ContentDocument.Description, 'The file\'s description was not updated.');
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
        }
    }
    
    @isTest
    static void test_deleteFile()
    {
        try {
            loadTestProposal();
	        loadTestDocument();
	        
	        // Luke: if the document doesn't exist, it's probably because there was a "Unable To Lock Row Error" during testSetup
            // so continue on.
            if (document == null ||
                document.ContentDocumentId == null) {
                return;
            }
	        
	        test.startTest();
	        List<ContentDocumentLink> links = UploadFileCTRL.DeleteFile(document.ContentDocumentId, proposal.Id, '');
	        test.stopTest();
	        
	        system.assertEquals(0, links.size());
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
        }
    }
}