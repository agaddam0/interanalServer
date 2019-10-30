public without sharing class setupFormBLogic {

    public static void updateParentEnrollmentForm(List<SObject> newForms) 
    {
        system.debug('### newForms = ' + newForms);
        set<Id> newFormsIds = new set<Id>();
        String objectAPIName = newForms[0].getSObjectType().getDescribe().getName();
        
        for(SObject csf : newForms) 
        {
            newFormsIds.add(csf.Id);    
        }
        
        list<Customer_Setup_Form__c> newFormswithOwnerNames = [SELECT Id, Owner.Name, Enrollment_Form__c FROM Customer_Setup_Form__c WHERE Id IN: newFormsIds];
        
        if (newFormsIds.size() > 0) updateParentRecords(objectAPIName, newFormsIds);
    }

    public static void updateParentEnrollmentForm(list<SObject> newForms, map<Id, SObject> oldFormsMap)   
    {
        system.debug('### newForms = ' + newForms);
        set<Id> newFormsIds = new set<Id>();
        String objectAPIName = newForms[0].getSObjectType().getDescribe().getName();
        
        for(SObject so : newForms) 
        {
            if((String.valueOf(so.get('OwnerId'))!= String.valueOf(oldFormsMap.get(so.Id).get('OwnerId'))) 
               || (String.valueOf(so.get('Status__c'))!= String.valueOf(oldFormsMap.get(so.Id).get('Status__c')) && objectAPIName != 'Platform_Setup__c')
               || (String.valueOf(so.get('Status__c'))!= String.valueOf(oldFormsMap.get(so.Id).get('Status__c')) &&
                   objectAPIName == 'Platform_Setup__c' &&
                   ((id) so.get('RecordTypeId') == Constants.PLATFORM_SETUP_AFES_FORM || (id) so.get('RecordTypeId') == Constants.PLATFORM_SETUP_AWD_FORM))
              || (objectAPIName == 'Platform_Setup__c'
                  && String.valueOf(so.get('Enroll_Info_Enrollment_Type__c')) != String.valueOf(oldFormsMap.get(so.Id).get('Enroll_Info_Enrollment_Type__c'))))
            newFormsIds.add(so.Id);
        }
        
        if (newFormsIds.size() > 0) updateParentRecords(objectAPIName, newFormsIds);
    }
    
    public static void updateParentRecords(String objectAPIName, Set<Id> newFormsIds) 
    {
        system.debug('### objectAPIName = ' + objectAPIName);
        system.debug('### newFormsIds = ' + newFormsIds);
        Set<Enrollment_Form__c> enForms = new Set<Enrollment_Form__c>();
        String queryString = 'SELECT Id, Owner.Name, Status__c, Enrollment_Form__c';
        if(objectAPIName == 'Platform_Setup__c')
            queryString += ', Enroll_Info_Enrollment_Type__c';
        queryString += ' FROM ' + objectAPIName + ' WHERE Id IN:newFormsIds';
        String ownerField;
        String statusField;
        String enrollmentTypeField;
        
        system.debug('### queryString = '+ queryString);
        List<sObject> newFormswithOwnerNames = Database.query(queryString);
        
        if(objectAPIName == 'Customer_Setup_Form__c')
        { 
            ownerField = 'Customer_Setup_Owner__c';
            statusField = 'Customer_Setup_Form_Status__c';
            
        }   
        else if(objectAPIName == 'Platform_Setup__c')
        { 
            ownerField = 'Platform_Setup_Owner__c';
            statusField = 'Platform_Setup_Status__c';
            enrollmentTypeField = 'Enrollment_Type__c';
        }
        else if(objectAPIName == 'Section_125_Setup_Form__c')
        {
             ownerField = 'Section_125_Owner__c';
             statusField = 'Section_125_Status__c';
        }        
        else if(objectAPIName == 'Section_125_Plan_Summary__c')
        {
             ownerField = 'Section_125_Plan_Summary_Owner__c';
             statusField = 'Section_125_Plan_Summary_Status__c';
        }

        system.debug('### ownerField = ' + ownerField);
        for(SObject so : newFormswithOwnerNames)
        {
            system.debug('### Owner: ' + so.getsObject('Owner'));
            sObject owner = so.getsObject('Owner');
            Enrollment_Form__c e = new Enrollment_Form__c(Id = String.valueOf(so.get('Enrollment_Form__c')));
            if(owner != null)
                e.put(ownerField, String.valueOf(owner.get('Name')));
            e.put(statusField, String.valueOf(so.get('Status__c')));
            if(objectAPIName == 'Platform_Setup__c')
                e.put(enrollmentTypeField, String.valueOf(so.get('Enroll_Info_Enrollment_Type__c')));
            enForms.add(e);
        }
        system.debug('### enForms = '+ enForms);
        List<Enrollment_Form__c> enFormUpdates = new List<Enrollment_Form__c>(enForms);
        
        try 
        {
            update enFormUpdates;
            system.debug('### enFormUpdates success = ' + enFormUpdates);
        } catch (Exception e) 
        {
            system.debug('### Exception e = ' + e);
        }
    }
    
    public static void syncSection125(List<Section_125_Setup_Form__c> s125s, Map<Id, Section_125_Setup_Form__c> oldMap)
    {
        Set<Id> efIds = new Set<Id>();
        List<Section_125_Setup_Form__c> update125s = new List<Section_125_Setup_Form__c>();
        
        for (Section_125_Setup_Form__c s125 : s125s)
        {
            if ((s125.Status__c == 'H.O. Processing' || s125.Status__c == 'Completed') && (s125.OwnerId != oldMap.get(s125.Id).OwnerId || s125.Status__c != oldMap.get(s125.Id).Status__c)) 
                efIds.add(s125.Enrollment_Form__c);
        }
        if (efIds.size() > 0)
        {
            //List<Enrollment_Form__c> efs = [SELECT Id, (SELECT Id, Enrollment_Form__c FROM Section_125_Setup_Forms__r) FROM Enrollment_Form__c WHERE Id IN : efIds];
             Map<Id, Enrollment_Form__c> efsMap = new Map<Id, Enrollment_Form__c>([SELECT Id, (SELECT Id, Status__c, OwnerId FROM Section_125_Setup_Forms__r) FROM Enrollment_Form__c WHERE Id IN : efIds]);
            
            for (Section_125_Setup_Form__c s125 : s125s)
            {
                if (efIds.size() > 0) 
                {
                    for (Section_125_Setup_Form__c s125Sub : efsMap.get(s125.Enrollment_Form__c).Section_125_Setup_Forms__r) 
                    {               
                        system.debug('### s125Sub.Id = '+ s125Sub.Id);
                        
                        if (s125Sub.Id != s125.Id && s125Sub.Status__c != s125.Status__c) s125Sub.Status__c = s125.Status__c;
                        if (s125Sub.Id != s125.Id && s125Sub.OwnerId != s125.OwnerId) s125Sub.OwnerId = s125.OwnerId;
                        
                        update125s.add(s125Sub);
                    }
                }
            }
        }
        if (update125s.size() > 0) 
        {
            system.debug('### update125s = ' + update125s);
            try 
            {
                update update125s;
            } catch (exception ex)
            {
                system.debug('### ex = ' + ex);
            }
        }
    }
    
    public static void BeforeUpdateFormReopenChangePlatformOwnerToOppOwner(Map<Id, Platform_Setup__c> PlatformOLDMAP, Map<Id, Platform_Setup__c> PlatformNEWMAP)
    {
        Map<Id, Id> enrollmentFormIdToPlatformId = new Map<Id, Id>();
        List<Id> enrollmentFormIds = new List<Id>();
        
        // Add the affected platform ids to a map for the enrollment form to search with
        for(Platform_Setup__c platform : PlatformNEWMAP.values())
        {
            if(platform.Status__c == 'In Progress' && PlatformOLDMAP.get(platform.Id).Status__c != 'In Progress')
            {
                enrollmentFormIdToPlatformId.put(platform.Enrollment_Form__c, platform.Id);
                enrollmentFormIds.add(platform.Enrollment_Form__c);
            }
        }
        
        // do not process further if there are no affected platform forms
        if(enrollmentFormIdToPlatformId.values().size() <= 0)
            return;
        
        // get enrollment form with the opporutntiy owners of the affected platform setup forms
        List<Enrollment_Form__c> eForms = [SELECT Id, Enrollment_Opportunity__r.OwnerId FROM Enrollment_Form__c WHERE Id IN :enrollmentFormIds];
        
        // update the platform setup form owners in the trigger new (before update) to the opportunity owner Id
        for(Enrollment_Form__c eForm : eForms)
        {
            PlatformNEWMAP.get(enrollmentFormIdToPlatformId.get(eForm.Id)).OwnerId = eForm.Enrollment_Opportunity__r.OwnerId;
        }
    }
    
    public static void BeforeUpdateFormReopenChangeCustomerFormOwnerToOppOwner(Map<Id, Customer_Setup_Form__c> CustomerOLDMAP, Map<Id, Customer_Setup_Form__c> CustomerNEWMAP)
    {
        Map<Id, Id> enrollmentFormIdToCustomerId = new Map<Id, Id>();
        List<Id> enrollmentFormIds = new List<Id>();
        system.debug('Customer Form Owner Update');
        // Add the affected customer ids to a map for the enrollment form to search with
        for(Customer_Setup_Form__c customer : CustomerNEWMAP.values())
        {
            system.debug('Customer Form Owner Update Status: ' + customer.Status__c);
            system.debug('Customer Form Owner Update Old Status: ' + CustomerOLDMAP.get(customer.Id).Status__c);
            if(customer.Status__c == 'In Progress' && CustomerOLDMAP.get(customer.Id).Status__c != 'In Progress')
            {
                enrollmentFormIdToCustomerId.put(customer.Enrollment_Form__c, customer.Id);
                enrollmentFormIds.add(customer.Enrollment_Form__c);
            }
        }
        
        // do not process further if there are no affected customer forms
        if(enrollmentFormIdToCustomerId.values().size() <= 0)
            return;
        
        // get enrollment form with the opporutntiy owners of the affected customer setup forms
        List<Enrollment_Form__c> eForms = [SELECT Id, Enrollment_Opportunity__r.OwnerId FROM Enrollment_Form__c WHERE Id IN :enrollmentFormIds];
        
        // update the customer setup form owners in the trigger new (before update) to the opportunity owner Id
        for(Enrollment_Form__c eForm : eForms)
        {
            CustomerNEWMAP.get(enrollmentFormIdToCustomerId.get(eForm.Id)).OwnerId = eForm.Enrollment_Opportunity__r.OwnerId;
        }
    }
    
    public static void BeforeUpdateFormReopenChangeSection125OwnerToOppOwner(Map<Id, Section_125_Setup_Form__c> Section125OLDMAP, Map<Id, Section_125_Setup_Form__c> Section125NEWMAP)
    {
        Map<Id, Id> enrollmentFormIdToSection125Id = new Map<Id, Id>();
        List<Id> enrollmentFormIds = new List<Id>();
        
        for(Section_125_Setup_Form__c s125 : Section125NEWMAP.values())
        {
            if(s125.Status__c == 'In Progress' && Section125OLDMAP.get(s125.Id).Status__c != 'In Progress')
            {
                enrollmentFormIdToSection125Id.put(s125.Enrollment_Form__c, s125.Id);
                enrollmentFormIds.add(s125.Enrollment_Form__c);
            }
        }
        
        if(enrollmentFormIdToSection125Id.values().size() <= 0)
            return;
        
        List<Enrollment_Form__c> eForms = [SELECT Id, Enrollment_Opportunity__r.OwnerId FROM Enrollment_Form__c WHERE Id IN :enrollmentFormIds];
        
        for(Enrollment_Form__c eForm : eForms)
        {
            Section125NEWMAP.get(enrollmentFormIdToSection125Id.get(eForm.Id)).OwnerId = eForm.Enrollment_Opportunity__r.OwnerId;
        }
    }
    
    public static void BeforeUpdateFormReopenChangePlanSummaryFormOwnerToOppOwner(Map<Id, Section_125_Plan_Summary__c> PlanSummaryOLDMAP, Map<Id, Section_125_Plan_Summary__c> PlanSummaryNEWMAP)
    {
        Map<Id, Id> enrollmentFormIdToPlanSummaryId = new Map<Id, Id>();
        List<Id> enrollmentFormIds = new List<Id>();
        
        for(Section_125_Plan_Summary__c planSummary : PlanSummaryNEWMAP.values())
        {
            if(planSummary.Status__c == 'In Progress' && PlanSummaryOLDMAP.get(planSummary.Id).Status__c != 'In Progress')
            {
                enrollmentFormIdToPlanSummaryId.put(planSummary.Enrollment_Form__c, planSummary.Id);
                enrollmentFormIds.add(planSummary.Enrollment_Form__c);
            }
        }
        
        if(enrollmentFormIdToPlanSummaryId.values().size() <= 0)
            return;
        
        List<Enrollment_Form__c> eForms = [SELECT Id, Enrollment_Opportunity__r.OwnerId FROM Enrollment_Form__c WHERE Id IN :enrollmentFormIds];
        
        for(Enrollment_Form__c eForm : eForms)
        {
            PlanSummaryNEWMAP.get(enrollmentFormIdToPlanSummaryId.get(eForm.Id)).OwnerId = eForm.Enrollment_Opportunity__r.OwnerId;
        }
    }
    
    // refactored 4/7/17 to avoid an uneccesary query
    public static void UpdatePlatformSetupFormStartAndEndDates(List<Opportunity> NEWOpps, Map<Id, Opportunity> OLDOpps)
    {
        List<Id> oppIds = new List<Id>();
        List<Platform_Setup__c> platforms = new List<Platform_Setup__c>();
        Map<Id, Opportunity> affectedOpps = new Map<Id, Opportunity>();
        Map<Id, Platform_Setup__c> platformsToUpdate = new Map<Id, Platform_Setup__c>();
        
        for(Opportunity o : NEWOpps)
        {
            if(o.Enrollment_Start_Date__c != OLDOpps.get(o.Id).Enrollment_Start_Date__c 
               || o.Enrollment_End_Date__c != OLDOpps.get(o.Id).Enrollment_End_Date__c
              || o.Platform__c != OLDOpps.get(o.Id).Platform__c)
            {
                oppIds.add(o.Id);
                affectedOpps.put(o.Id, o);
            }
        }
        
        if(oppIds.size() > 0)
        {
            platforms = [SELECT Id, Opportunity_Enrollment_Start_Date__c, Opportunity_Enrollment_End_Date__c,
                         Enrollment_Form__c, Enrollment_Form__r.Enrollment_Opportunity__c, Opportunity_Platform__c
                         FROM Platform_Setup__c
                         WHERE Enrollment_Form__r.Enrollment_Opportunity__c IN: oppIds];
        }
        
        
        for(Platform_Setup__c p : platforms)
        {
            // Check to see if the start or end date is different than what is on the platform
            if(p.Opportunity_Enrollment_Start_Date__c != affectedOpps.get(p.Enrollment_Form__r.Enrollment_Opportunity__c).Enrollment_Start_Date__c 
               || p.Opportunity_Enrollment_End_Date__c != affectedOpps.get(p.Enrollment_Form__r.Enrollment_Opportunity__c).Enrollment_End_Date__c)
            {
                p.Opportunity_Enrollment_Start_Date__c = affectedOpps.get(p.Enrollment_Form__r.Enrollment_Opportunity__c).Enrollment_Start_Date__c;
                p.Opportunity_Enrollment_End_Date__c = affectedOpps.get(p.Enrollment_Form__r.Enrollment_Opportunity__c).Enrollment_End_Date__c;
                platformsToUpdate.put(p.Id, p);
            }
            
            // check to see if the platform is different than what is on the opportunity
            if(p.Opportunity_Platform__c != affectedOpps.get(p.Enrollment_Form__r.Enrollment_Opportunity__c).Platform__c)
            {
                p.Opportunity_Platform__c = affectedOpps.get(p.Enrollment_Form__r.Enrollment_Opportunity__c).Platform__c;
                platformsToUpdate.put(p.Id, p);
            }
        }
        
        if(platformsToUpdate.size() > 0)
            update platformsToUpdate.values();
    }
    
    public static void setSection125PrimaryField(List<Section_125_Setup_Form__c> newSection125s) {
        Set<Id> enrollmentFormIds = CollectionUtil.getLookupIds(newSection125s, 'Enrollment_Form__c');
        
        List<Section_125_Setup_Form__c> existingEnrollmentSection125s = getExistingEnrollmentSections125s(enrollmentFormIds);
        
        Map<Object, List<Section_125_Setup_Form__c>> existingSection125sByEnrollment = CollectionUtil.groupRecordsByField(existingEnrollmentSection125s, 'Enrollment_Form__c');
        
        for(Section_125_Setup_Form__c newSection125 : newSection125s) {
            if (newSection125.Enrollment_Form__c == null) {
                continue;
            }
            
            List<Section_125_Setup_Form__c> enrollmentSection125s = existingSection125sByEnrollment.get(newSection125.Enrollment_Form__c);
            
            if (enrollmentSection125s == null) {
                newSection125.Primary__c = true;
            }
        }
    }
    
    public static void linkSection125FormCommonOwnersToCustomerSetupForms(List<Section_125_Setup_Form__c> newSection125s) {
        List<Section_125_Setup_Form__c> primarySection125s = CollectionUtil.filterRecordsByFieldValue(newSection125s, 'Primary__c', true);
        
        if (primarySection125s.isEmpty()) {
            return;
        }
        
        Map<Id, List<Section_125_Setup_Form__c>> primarySection125sByEnrollment = CollectionUtil.groupRecordsByLookupField(primarySection125s, 'Enrollment_Form__c');
        Set<Id> enrollmentFormIds = CollectionUtil.getLookupIds(primarySection125s, 'Enrollment_Form__c');
        
        List<Common_Ownership_Form__c> existingEnrollmentCommonOwnershipForms = getExistingEnrollmentCommonOwnershipForms(enrollmentFormIds);
        List<Common_Ownership_Form__c> existingCommonOwnershipFormsToUpdate = new List<Common_Ownership_Form__c>();
        
        for(Common_Ownership_Form__c existingCOF : existingEnrollmentCommonOwnershipForms) {
            List<Section_125_Setup_Form__c> primaryEnrollmentSection125s = primarySection125sByEnrollment.get(existingCOF.MCP_Setup_Form__r.Enrollment_Form__c);
            
            if (primaryEnrollmentSection125s == null ||
                primaryEnrollmentSection125s.isEmpty()) {
                continue;
            }
            
            Section_125_Setup_Form__c primaryEnrollmentS125 = primaryEnrollmentSection125s[0];
            existingCOF.Section_125_Setup_Form__c = primaryEnrollmentS125.Id;
            existingCommonOwnershipFormsToUpdate.add(existingCOF);
        }
        
        if (existingCommonOwnershipFormsToUpdate.size() > 0) {
            update existingCommonOwnershipFormsToUpdate;
        }
    }
    
    public static void linkCustomerSetupFormCommonOwnersToSection125Forms(List<Customer_Setup_Form__c> newCustomerSetupForms) {
        Map<Id, List<Customer_Setup_Form__c>> customerSetupFormsByEnrollment = CollectionUtil.groupRecordsByLookupField(newCustomerSetupForms, 'Enrollment_Form__c');
        Set<Id> enrollmentFormIds = customerSetupFormsByEnrollment.keySet();
        enrollmentFormIds.remove(null);
        
        List<Common_Ownership_Form__c> existingEnrollmentCommonOwnershipForms = getExistingEnrollmentCommonOwnershipFormsWithNullCustomerSetupForms(enrollmentFormIds);
        List<Common_Ownership_Form__c> existingCommonOwnershipFormsToUpdate = new List<Common_Ownership_Form__c>();
        
        for(Common_Ownership_Form__c existingCOF : existingEnrollmentCommonOwnershipForms) {
            List<Customer_Setup_Form__c> newEnrollmentCustomerSetupForms = customerSetupFormsByEnrollment.get(existingCOF.Section_125_Setup_Form__r.Enrollment_Form__c);
            
            if (newEnrollmentCustomerSetupForms == null ||
                newEnrollmentCustomerSetupForms.isEmpty()) {
                continue;
            }
            
            Customer_Setup_Form__c newCustomerSetupForm = newEnrollmentCustomerSetupForms[0];
            existingCOF.MCP_Setup_Form__c = newCustomerSetupForm.Id;
            existingCommonOwnershipFormsToUpdate.add(existingCOF);
        }
        
        if (existingCommonOwnershipFormsToUpdate.size() > 0) {
            update existingCommonOwnershipFormsToUpdate;
        }
    }
    
    public static void linkCommonOwnershipFormToOtherExistingFormAsNeeded(List<Common_Ownership_Form__c> newCommonOwnershipForms) {
        Set<Id> s125Ids = new Set<Id>();
        Set<Id> customerSetupFormIds = new Set<Id>();
        List<Common_Ownership_Form__c> newCommonOwnershipFormsWithoutCustomerSetupForms = new List<Common_Ownership_Form__c>();
        List<Common_Ownership_Form__c> newCommonOwnershipFormsWithoutS125s = new List<Common_Ownership_Form__c>();
        
        for (Common_Ownership_Form__c newCOF : newCommonOwnershipForms) {
            system.debug('    linkCommonOwnershipFormToOtherExistingFormAsNeeded::newCOF ' + newCOF);
            
            if (newCOF.MCP_Setup_Form__c != null &&
                newCOF.Section_125_Setup_Form__c == null) {
                customerSetupFormIds.add(newCOF.MCP_Setup_Form__c);
                newCommonOwnershipFormsWithoutS125s.add(newCOF);
            }
            
            if (newCOF.Section_125_Setup_Form__c != null &&
                newCOF.MCP_Setup_Form__c == null) {
                s125Ids.add(newCOF.Section_125_Setup_Form__c);
                newCommonOwnershipFormsWithoutCustomerSetupForms.add(newCOF);
            }
        }
        
        if (newCommonOwnershipFormsWithoutCustomerSetupForms.size() > 0) {
            linkCommonOwnershipFormsToCustomerSetupForms(newCommonOwnershipFormsWithoutCustomerSetupForms, s125Ids);
        }
        
        if (newCommonOwnershipFormsWithoutS125s.size() > 0) {
            linkCommonOwnershipFormsToS125s(newCommonOwnershipFormsWithoutS125s, customerSetupFormIds);
        }
    }
    
    private static void linkCommonOwnershipFormsToCustomerSetupForms(List<Common_Ownership_Form__c> newCommonOwnershipFormsWithoutCustomerSetupForms, Set<Id> s125Ids) {
        List<Enrollment_Form__c> enrollmentForms = getExistingEnrollmentFormsBySection125Ids(s125Ids);
        
        system.debug('    linkCommonOwnershipFormsToCustomerSetupForms::enrollmentForms ' + enrollmentForms);
        
        Map<Id, Enrollment_Form__c> enrollmentFormsByS125 = new Map<Id, Enrollment_Form__c>();
        
        for (Enrollment_Form__c ef : enrollmentForms) {
            if (ef.Section_125_Setup_Forms__r != null &&
                ef.Section_125_Setup_Forms__r.size() > 0) {
                enrollmentFormsByS125.put(ef.Section_125_Setup_Forms__r[0].Id, ef);
            }
        }
        
        system.debug('    linkCommonOwnershipFormsToCustomerSetupForms::enrollmentFormsByS125 ' + enrollmentFormsByS125);
        
        for (Common_Ownership_Form__c newCOFWithoutCustomerSetupForm : newCommonOwnershipFormsWithoutCustomerSetupForms) {
            Enrollment_Form__c ef = enrollmentFormsByS125.get(newCOFWithoutCustomerSetupForm.Section_125_Setup_Form__c);
            
            system.debug('    linkCommonOwnershipFormsToCustomerSetupForms::ef ' + ef);
            system.debug('    linkCommonOwnershipFormsToCustomerSetupForms::newCOFWithoutCustomerSetupForm ' + newCOFWithoutCustomerSetupForm);
            
            if (ef != null &&
                ef.MCP_Setup_Forms__r != null &&
                ef.MCP_Setup_Forms__r.size() > 0) {
                newCOFWithoutCustomerSetupForm.MCP_Setup_Form__c = ef.MCP_Setup_Forms__r[0].Id;
                
                system.debug('    linkCommonOwnershipFormsToCustomerSetupForms::Set MCP Setup Form ');
            }
        }
    }
    
    private static void linkCommonOwnershipFormsToS125s(List<Common_Ownership_Form__c> newCommonOwnershipFormsWithoutS125s, Set<Id> customerSetupFormIds) {
        List<Enrollment_Form__c> enrollmentForms = getExistingEnrollmentFormsByCustomerSetupFormIds(customerSetupFormIds);
        
        Map<Id, Enrollment_Form__c> enrollmentFormsByCustomerSetupForm = new Map<Id, Enrollment_Form__c>();
        
        for (Enrollment_Form__c ef : enrollmentForms) {
            if (ef.MCP_Setup_Forms__r != null &&
                ef.MCP_Setup_Forms__r.size() > 0) {
                enrollmentFormsByCustomerSetupForm.put(ef.MCP_Setup_Forms__r[0].Id, ef);
            }
        }
        
        for (Common_Ownership_Form__c newCOFWithoutS125 : newCommonOwnershipFormsWithoutS125s) {
            Enrollment_Form__c ef = enrollmentFormsByCustomerSetupForm.get(newCOFWithoutS125.MCP_Setup_Form__c);
            
            if (ef != null &&
                ef.Section_125_Setup_Forms__r != null &&
                ef.Section_125_Setup_Forms__r.size() > 0) {
                newCOFWithoutS125.Section_125_Setup_Form__c = ef.Section_125_Setup_Forms__r[0].Id;
            }
        }
    }
    
    private static List<Enrollment_Form__c> getExistingEnrollmentFormsBySection125Ids(Set<Id> s125Ids) {
        return
        [SELECT Id,
                Name,
                (SELECT Id, Name
                   FROM MCP_Setup_Forms__r),
                (SELECT Id, Name
                   FROM Section_125_Setup_Forms__r
                  WHERE Primary__c = true
                    AND Id in :s125Ids)
           FROM Enrollment_Form__c
          WHERE Id in (SELECT Enrollment_Form__c
                         FROM Section_125_Setup_Form__c
                        WHERE Id in :s125Ids)];
    }
    
    private static List<Enrollment_Form__c> getExistingEnrollmentFormsByCustomerSetupFormIds(Set<Id> customerSetupFormIds) {
        return
        [SELECT Id,
                Name,
                (SELECT Id, Name
                   FROM Section_125_Setup_Forms__r
                  WHERE Primary__c = true),
                (SELECT Id, Name
                   FROM MCP_Setup_Forms__r
                  WHERE Id in :customerSetupFormIds)
           FROM Enrollment_Form__c
          WHERE Id in (SELECT Enrollment_Form__c
                         FROM Customer_Setup_Form__c
                        WHERE Id in :customerSetupFormIds)];
    }

    private static List<Section_125_Setup_Form__c> getExistingEnrollmentSections125s(Set<Id> enrollmentFormIds) {
        return
        [SELECT Id,
                Name,
                Enrollment_Form__c
           FROM Section_125_Setup_Form__c
          WHERE Enrollment_Form__c in :enrollmentFormIds];
    }
    
    private static List<Common_Ownership_Form__c> getExistingEnrollmentCommonOwnershipForms(Set<Id> enrollmentFormIds) {
        return
        [SELECT Id,
                Name,
                Section_125_Setup_Form__c,
                MCP_Setup_Form__r.Enrollment_Form__c
           FROM Common_Ownership_Form__c
          WHERE MCP_Setup_Form__r.Enrollment_Form__c in :enrollmentFormIds
            AND Section_125_Setup_Form__c = null];
    }
    
    private static List<Common_Ownership_Form__c> getExistingEnrollmentCommonOwnershipFormsWithNullCustomerSetupForms(Set<Id> enrollmentFormIds) {
        return
        [SELECT Id,
                Name,
                MCP_Setup_Form__c,
                Section_125_Setup_Form__r.Enrollment_Form__c
           FROM Common_Ownership_Form__c
          WHERE Section_125_Setup_Form__r.Enrollment_Form__c in :enrollmentFormIds
            AND MCP_Setup_Form__c = null];
    }
    
    public static void UpdateFormOwnerToHomeOfficeLoggedInUser(List<sObject> NEWsObjectList, Map<Id, sObject> OLDMAPsObjects)
    {
        system.debug('OLDMAPsObjects: ' + OLDMAPsObjects);
        system.debug('NEWsObjectList: ' + NEWsObjectList); 
        
        Id loggedInUserId = system.UserInfo.getUserId();
        
        for(sObject form : NEWsObjectList)
        {
            String ownerString = (String)form.get('OwnerId');
            
            // if owner is a queue
            if(ownerString.substring(0, 3) == '00G')
            {
                if((form.get('Status__c') == 'H.O. Processing' && OLDMAPsObjects.get((Id)form.get('Id')).get('Status__c') != 'H.O. Processing')
                   || (form.get('Status__c') == 'Completed' && OLDMAPsObjects.get((Id)form.get('Id')).get('Status__c') != 'Completed')
                   || (form.get('Status__c') == 'Waiting on Information' && OLDMAPsObjects.get((Id)form.get('Id')).get('Status__c') != 'Waiting on Information'))
                {
                    form.put('OwnerId', loggedInUserId);
                }
            }            
        }
    }
}