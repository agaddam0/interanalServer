({
	tagsGridRowActions : [
	    {Label: "Edit", ActionName: "Edit", Type: "Link"}
	],
	
	tagsMarketingMaterialsGridRowActions : [
	    {Label: "Unassign", ActionName: "Remove", Type: "Link", Class: "af-tag-marketing-material-unassign"}
	],
	
	marketingMaterialTagsGridRowActions : [
        {Label: "Unassign", ActionName: "Remove", Type: "Link", Class: "af-tag-marketing-material-unassign"}
	],
	
	selectTagsMarketingMaterialsGridRowActions : [
	    {Label: "Add", ActionName: "Select", Type: "Select"}
	],
	
	selectTagsForMarketingMaterialGridRowActions : [
	    {Label: "Add", ActionName: "Select", Type: "Select"}
	],
	
	AllMarketingMaterialListViews : [
	    {Label: "All Materials", Id: "", WhereClause: ""},
	    {Label: "Active Materials", Id: "Active", WhereClause: "Status__c = 'Active'"},
	    {Label: "Expiring Materials", Id: "Expiring", WhereClause: "Expiration_Date__c != null AND Expiration_Date__c >= TODAY AND Expiration_Date__c <= NEXT_N_DAYS:30"},
	    {Label: "Featured Materials", Id: "Featured", WhereClause: "Feature__c = true"},
	    {Label: "New Materials", Id: "New", WhereClause: "New__c = true"},
	    {Label: "Pre-enrollment Materials", Id: "Preenrollment", WhereClause: "Available_Packages__c includes ('Pre-enrollment Marketing')"}
	],
	
	MarketingMaterialsGridRowActions : [
	    {Label: "Edit", ActionName: "Edit", Type: "Link"}
	],
    
    AnnouncementsGridRowActions : [
        {Label: "Edit", ActionName: "Edit", Type: "Link"}  
    ],
    
    AllAnnouncementListViews : [
        {Label: "All Announcements", Id: "", WhereClause: "RecordType.Name = 'Marketing Material'"},
        {Label: "Active Announcements", Id: "Active", WhereClause: "RecordType.Name = 'Marketing Material' AND Status__c = 'Active'"}
    ],
    
    AllOrdersListViews : [
        {Label: "All Orders", Id: "", WhereClause: ""},
        {Label: "Today's Orders", Id: "Today", WhereClause: "Date_Submitted__c = TODAY"},
        {Label: "Rush Orders", Id: "Rush", WhereClause: "(Status__c = 'In Progress' OR Status__c = 'Submitted' OR Status__c = 'Sent to 3rd Party for Fulfillment') AND Rush_Order__c = true"},
        {Label: "In Progress", Id: "Progress", WhereClause: "Status__c = 'In Progress'"},
        {Label: "Submitted", Id: "Submitted", WhereClause: "Status__c = 'Submitted' OR Status__c = 'Sent to 3rd Party for Fulfillment' OR Status__c = 'Pending Approval'"},
        {Label: "Processing", Id: "Processing", WhereClause: "Status__c = 'Bindery Services' OR Status__c = 'Received' OR Status__c = 'Mail Services' OR Status__c = 'In Production Process'"},
        {Label: "Completed", Id: "Completed", WhereClause: "Status__c = 'Completed'"},
    ],
	
	TagCustomFieldInputs : {Tag_Category__c: {componentDef: 'c:SObjectDropdown', attributes: { 'class': 'slds-m-top_small', sobjectName: 'Tag_Category__c' } }},

	loadOrderAdminDetails : function(component, helper) {
		var getOrderAdminDetailsAction = component.get('c.getOrderAdminDetails');

		getOrderAdminDetailsAction.setCallback(component, function(response){
			var state = response.getState();

			if (component.isValid() && state === "SUCCESS") {
				var orderAdminContext = response.getReturnValue();
				
				component.set('v.AllowManageTagCategories', orderAdminContext.AllowTagCategoryAdmin);
				component.set('v.EditMarketingMaterialAllowed', orderAdminContext.EditMarketingMaterialAllowed);
                component.set('v.AllTagCategoriesListViewId', orderAdminContext.AllTagCategoriesListViewId);
				component.set('v.TagCustomFieldInputs', helper.TagCustomFieldInputs);
				helper.loadManageMarketingMaterials(component, helper);
			}
			else {
				console.log('Problem getting the order admin state. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(getOrderAdminDetailsAction);
	},
	
	// Tag Category functions
	
	loadAllTagCategories : function(component, helper) {
		var getAllTagCategoriesAction = component.get('c.getAllTagCategories');

		getAllTagCategoriesAction.setCallback(component, function(response){
			var state = response.getState();

			if (component.isValid() && state === "SUCCESS") {
                var tagCategories = response.getReturnValue();
				component.set('v.AllTagCategories', tagCategories);
			}
			else {
				console.log('Problem getting all tag categories. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(getAllTagCategoriesAction);
	},
	
	// Tag functions
	
	loadManageTags : function(component, helper) {
		component.set('v.AdminFunction', 'ManageTags');
		
		helper.loadAllTagCategories(component, helper);
		helper.loadTagsGridRowActions(component, helper);
		helper.hideTagRecordDetails(component);
		
		helper.loadTagsUsingCategoryFilter(component, helper);
	},
	
	loadTagsUsingCategoryFilter : function(component, helper) {
		var tagCategoryFilter = component.get('v.TagCategoryFilter');
		var tagsGrid = component.find('tagsGrid');
		
        if (tagCategoryFilter && tagCategoryFilter == 'DisplayInNav') {
            tagsGrid.set('v.whereClause', 'WHERE Display_in_Search_Navigation__c = true');
        }
        else if(tagCategoryFilter) {
		    tagsGrid.set('v.whereClause', 'WHERE Tag_Category__c = \'' + tagCategoryFilter + '\'');
		}
		else {
		    tagsGrid.set('v.whereClause', '');
		}
		
		var allTagsSearchText = component.get('v.AllTagsSearchText');
		
		if (allTagsSearchText) {
			component.set('v.AllTagsSearchText', '');
		}
		
		tagsGrid.reloadRecords();
	},
	
	loadNewTagModal : function(component, helper) {
		var newTagRecord = { "sobjectType": 'Tag__c', Status__c: "Active", Display_in_Search_Navigation__c: false };
		component.set('v.NewTagRecord', newTagRecord);
		
		var newTagFieldSetForm = component.find('newTagFieldSetForm');
		newTagFieldSetForm.showModalUsingRecord();
	},

	hideNewTagModal : function(component) {
		var newTagFieldSetForm = component.find('newTagFieldSetForm');
		newTagFieldSetForm.hideModal();
	},
	
	saveNewTag : function(component, helper) {
		var newTagFieldSetForm = component.find('newTagFieldSetForm');
		newTagFieldSetForm.clearValidationMessages();

		var isValid = newTagFieldSetForm.validate();

		if (!isValid) {
			newTagFieldSetForm.showValidationMessages();

			return;
		}
	
		var newTagRecord = component.get('v.NewTagRecord');
		
		var addNewTagAction = component.get('c.addNewTag');
		addNewTagAction.setParams({
			"newTag": newTagRecord
		});
		
		addNewTagAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var newTagId = response.getReturnValue();
				var saveAndNew = component.get("v.SaveAndNewClick");
                helper.hideNewTagModal(component);
                
                if(saveAndNew) {
                    helper.loadNewTagModal(component, helper);
                    helper.loadManageTags(component, helper);
                    component.set("v.SaveAndNewClick", false);
                }else {
                    helper.loadTagRecordDetails(component, helper, newTagId);
                }
                
				helper.showSuccessToast('The new tag was saved successfully.');
			}
			else {
				var newTagFieldSetForm = component.find('newTagFieldSetForm');
				newTagFieldSetForm.set('v.errorResponse', response);
                component.set("v.SaveAndNewClick", false);
				console.log('Problem saving the new tag. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(addNewTagAction);
	},
	
	loadTagsGridRowActions : function(component, helper) {
		component.set('v.tagsGridRowActions', this.tagsGridRowActions);
	},
	
	loadEditTagModal : function(component, tagRecordToEdit) {
		this.loadEditTagModalUsingId(component, tagRecordToEdit.Id);
	},
	
	loadEditTagModalUsingId : function(component, tagId) {
		var editTagFieldSetForm = component.find("editTagFieldSetForm");
	    editTagFieldSetForm.showModalUsingQuery(tagId);
	},
	
	hideEditTagModal : function(component) {
		var editTagFieldSetForm = component.find("editTagFieldSetForm");
	    editTagFieldSetForm.hideModal();
	},
	
	saveEditTag : function(component, helper) {
		var editTagFieldSetForm = component.find('editTagFieldSetForm');
		editTagFieldSetForm.clearValidationMessages();

		var isValid = editTagFieldSetForm.validate();

		if (!isValid) {
			editTagFieldSetForm.showValidationMessages();
			return;
		}
	
		var editTagRecord = component.get('v.EditTagRecord');
		
		var updateTagAction = component.get('c.updateTag');
		updateTagAction.setParams({
			"tagToUpdate": editTagRecord
		});
		
		updateTagAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var tagsGrid = component.find('tagsGrid');
				if (tagsGrid) {
					tagsGrid.reloadRecords();
				}
				
				var viewTagRecordId = component.get('v.ViewTagRecordId');
				
				if (viewTagRecordId) {
				    helper.loadTagRecordDetails(component, helper, viewTagRecordId);
				}
				
				helper.hideEditTagModal(component);
				
				helper.showSuccessToast('The tag was updated successfully.');
			}
			else {
				var editTagFieldSetForm = component.find('editTagFieldSetForm');
				editTagFieldSetForm.set('v.errorResponse', response);
				console.log('Problem saving the edited tag. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(updateTagAction);
	},

	loadTagRecordDetails : function(component, helper, tagRecordId) {
		component.set('v.ShowTagDetails', true);
		component.set('v.ViewTagRecordId', tagRecordId);
		
		var tagsMarketingMaterialsGrid = component.find('tagsMarketingMaterialsGrid');
		tagsMarketingMaterialsGrid.set('v.rowActions', this.tagsMarketingMaterialsGridRowActions);
		tagsMarketingMaterialsGrid.set('v.whereClause', "WHERE Tag__c = '" + tagRecordId + "'");
		tagsMarketingMaterialsGrid.reloadRecords();
		
		var tagsHistoryGrid = component.find('tagsHistoryGrid');
		tagsHistoryGrid.set('v.whereClause', "WHERE ParentId = '" + tagRecordId + "'");
		tagsHistoryGrid.reloadRecords();
		
		helper.reloadTagRecordView(component, tagRecordId);
	},
	
	reloadTagRecordView : function(component, tagRecordId) {
		var container = component.find("ViewTagRecordContainer");
		
        $A.createComponent("force:recordView",
                           {recordId: tagRecordId},
                           function(cmp) {
                               container.set("v.body", [cmp]);
                           });
	},
	
	hideTagRecordDetails : function(component) {
		component.set('v.ShowTagDetails', false);
	},
	
	loadAssignTagMarketingMaterials : function(component, helper) {
		helper.clearSelectedMarketingMaterialsForTag(component);
		
		var selectTagsMarketingMaterialsGrid = component.find('selectTagsMarketingMaterialsGrid');
		selectTagsMarketingMaterialsGrid.set('v.rowActions', this.selectTagsMarketingMaterialsGridRowActions);
		
		var ViewTagRecordId = component.get('v.ViewTagRecordId');
		
		selectTagsMarketingMaterialsGrid.set('v.whereClause', "WHERE Status__c = 'Active' AND Id not in (Select Marketing_Material__c FROM Marketing_Material_Tag__c WHERE Tag__c = '" + ViewTagRecordId + "')");
		
		selectTagsMarketingMaterialsGrid.reloadRecords();
		
		helper.showAssignTagMarketingMaterials(component);
	},
	
	showAssignTagMarketingMaterials : function(component) {
		component.set('v.ShowAddTagsMarketedMaterials', true);
	},
	
	hideAssignTagMarketingMaterials : function(component) {
		component.set('v.ShowAddTagsMarketedMaterials', false);
        component.set('v.MarketingMaterialsForTagSearchText', '');
	},
	
	toggleTagsMarketingMaterialSelection : function(component, selectedMarketingMaterial) {
		var SelectedMarketingMaterialsForTag = component.get('v.SelectedMarketingMaterialsForTag');
		
		if (!SelectedMarketingMaterialsForTag) {
		    SelectedMarketingMaterialsForTag = [];
		}
		
		var elementIndex = SelectedMarketingMaterialsForTag.findIndex(function(currentValue){
			return currentValue.Id == selectedMarketingMaterial.Id
		});
		
		if (elementIndex > -1) {
			SelectedMarketingMaterialsForTag.splice(elementIndex, 1);
		}
		else {
		    SelectedMarketingMaterialsForTag.push(selectedMarketingMaterial);
		}
		
		component.set('v.SelectedMarketingMaterialsForTag', SelectedMarketingMaterialsForTag);
	},
	
	assignMarketingMaterialsToTag : function(component) {
		var helper = this;
		var tagRecordId = component.get('v.ViewTagRecordId');
		var selectedMarketingMaterials = component.get('v.SelectedMarketingMaterialsForTag');
		
		var assignMarketingMaterialsToTagAction = component.get('c.addMarketingMaterialsToTag');
		
		assignMarketingMaterialsToTagAction.setParams({
			"tagId": tagRecordId,
			"marketingMaterials": selectedMarketingMaterials
		});
		
		assignMarketingMaterialsToTagAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var tagsMarketingMaterialsGrid = component.find('tagsMarketingMaterialsGrid');
				tagsMarketingMaterialsGrid.reloadRecords();
				
				helper.hideAssignTagMarketingMaterials(component);
				helper.clearSelectedMarketingMaterialsForTag(component);
				
				helper.showSuccessToast('The marketing materials were assigned to the tag.');
			}
			else {
				console.log('Problem assigning the marketing materials to the tag. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(assignMarketingMaterialsToTagAction);
	},

	unassignMarketingMaterialFromTag : function(component, marketingMaterialTagRecord) {
	    var helper = this;
	
		helper.deleteMarketingMaterialTag(component, marketingMaterialTagRecord.Id, function(response) {
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var tagsMarketingMaterialsGrid = component.find('tagsMarketingMaterialsGrid');
				tagsMarketingMaterialsGrid.reloadRecords();
				
				helper.showSuccessToast('The marketing material was unassigned from the tag.');
			}
			else {
				console.log('Problem unassigning the marketing materials from the tag. Response state: ' + state);
			}
		
		});
	},
	
	clearSelectedMarketingMaterialsForTag : function(component) {
		component.set('v.SelectedMarketingMaterialsForTag', []);
	},
	
	filterMarketingMaterialsForTag : function(component) {
		var selectTagsMarketingMaterialsGrid = component.find("selectTagsMarketingMaterialsGrid");
		selectTagsMarketingMaterialsGrid.filterRecordsUsingSearchText();
	},
	
	filterAllTagsUsingSearchText : function(component) {
		var helper = this;
		var searchText = component.get('v.AllTagsSearchText');		
		var tagsGrid = component.find('tagsGrid');
        tagsGrid.filterRecordsUsingSearchText(searchText);
	},
	
	// Marketing Material Functions
	
	loadManageMarketingMaterials : function(component, helper) {
		component.set('v.AdminFunction', 'ManageRecords');
		component.set('v.AllMarketingMaterialListViews', this.AllMarketingMaterialListViews);
		
		var editMarketingMaterialsAllowed = component.get('v.EditMarketingMaterialAllowed');
		
		// TO DO: Update this logic if other actions are needed besides Edit.
		if (editMarketingMaterialsAllowed) {
			component.set('v.MarketingMaterialsGridRowActions', this.MarketingMaterialsGridRowActions);
		}
		
		helper.hideMarketingMaterialRecordDetails(component);
		helper.clearAllMarketingMaterialsSearchText(component);
		helper.loadMarketingMaterialsUsingListviewFilter(component, helper);
	},
	
	loadMarketingMaterialsUsingListviewFilter : function(component, helper) {
		var selectedListView = helper.getSelectedMarketingMaterialsListView(component, helper);
		var marketingMaterialsGrid = component.find('marketingMaterialsGrid');
		
		marketingMaterialsGrid.set('v.whereClause', selectedListView.WhereClause);
		
		marketingMaterialsGrid.reloadRecords();
	},
	
	loadNewMarketingMaterialModal : function(component, helper) {
		var newMarketingMaterialRecord = { "sobjectType": 'Marketing_Material__c', Status__c: "Active" };
		component.set('v.NewMarketingMaterialRecord', newMarketingMaterialRecord);
		
		var newMarketingMaterialModal = component.find('newMarketingMaterialModal');
		newMarketingMaterialModal.showModalUsingRecord();
	},
    
    loadClonedMarketingMaterialModal : function(component, helper) {
        var newMarketingMaterialModal = component.find('newMarketingMaterialModal');
        newMarketingMaterialModal.showModalUsingRecord();
    },
    
    loadNewChildMarketingMaterialModal : function(component, helper) {
        var newMarketingMaterialRecord = { "sobjectType": 'Marketing_Material__c', Status__c: "Active", Parent_Material__c : component.get('v.ViewMarketingMaterialRecordId')};
		component.set('v.NewMarketingMaterialRecord', newMarketingMaterialRecord);
		
		var newMarketingMaterialModal = component.find('newMarketingMaterialModal');
		newMarketingMaterialModal.showModalUsingRecord();
	},
	
	hideNewMarketingMaterialModal : function(component) {
		var newMarketingMaterialModal = component.find('newMarketingMaterialModal');
		newMarketingMaterialModal.hideModal();
	},
	
	saveNewMarketingMaterial : function(component, helper) {
		var newMarketingMaterialModal = component.find('newMarketingMaterialModal');
		newMarketingMaterialModal.clearValidationMessages();

		var isValid = newMarketingMaterialModal.validate();

		if (!isValid) {
			newMarketingMaterialModal.showValidationMessages();
			return;
		}
	
		var newMarketingMaterialRecord = component.get('v.NewMarketingMaterialRecord');
		
		var addNewMarketingMaterialAction = component.get('c.addNewMarketingMaterial');
		addNewMarketingMaterialAction.setParams({
			"newMarketingMaterial": newMarketingMaterialRecord
		});
		
		addNewMarketingMaterialAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var newMarketingMaterialId = response.getReturnValue();
				var saveAndNew = component.get("v.SaveAndNewClick");
                helper.hideNewMarketingMaterialModal(component);
                
                if(saveAndNew) {
                    helper.loadNewMarketingMaterialModal(component, helper);
                    helper.loadManageMarketingMaterials(component, helper);
                    component.set("v.SaveAndNewClick", false);
                } 
                else {
                    helper.loadMarketingMaterialRecordDetails(component, helper, newMarketingMaterialId);
                }
                
				helper.showSuccessToast('The new marketing material was saved successfully.');
			}
			else {
				var newMarketingMaterialModal = component.find('newMarketingMaterialModal');
				newMarketingMaterialModal.set('v.errorResponse', response);
                component.set("v.SaveAndNewClick", false);
				console.log('Problem saving the new marketing material. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(addNewMarketingMaterialAction);
	},
	
	loadEditMarketingMaterialModal : function(component, marketingMaterialToEdit) {
		this.loadEditMarketingMaterialModalUsingId(component, marketingMaterialToEdit.Id);
	},
	
	loadEditMarketingMaterialModalUsingId : function(component, marketingMaterialIdToEdit) {
		var editMarketingMaterialModal = component.find('editMarketingMaterialModal');
		editMarketingMaterialModal.showModalUsingQuery(marketingMaterialIdToEdit);
	},
	
	saveEditedMarketingMaterial : function(component, helper) {
		var editMarketingMaterialModal = component.find('editMarketingMaterialModal');
		editMarketingMaterialModal.clearValidationMessages();

		var isValid = editMarketingMaterialModal.validate();

		if (!isValid) {
			editMarketingMaterialModal.showValidationMessages();
			return;
		}

		var editedMarketingMaterialRecord = component.get('v.EditMarketingMaterialRecord');
		
		var updateMarketingMaterialAction = component.get('c.updateMarketingMaterial');
		updateMarketingMaterialAction.setParams({
			"marketingMaterialToUpdate": editedMarketingMaterialRecord
		});
		
		updateMarketingMaterialAction.setCallback(component, function(response){
			var state = response.getState();
			var editMarketingMaterialModal = component.find('editMarketingMaterialModal');
			
			if (component.isValid() && state === "SUCCESS") {
				var marketingMaterialsGrid = component.find('marketingMaterialsGrid');
				
				if (marketingMaterialsGrid) {
					marketingMaterialsGrid.reloadRecords();
				}
				
				var viewMarketingMaterialRecordId = component.get('v.ViewMarketingMaterialRecordId');
				
				if (viewMarketingMaterialRecordId) {
				    helper.loadMarketingMaterialRecordDetails(component, helper, viewMarketingMaterialRecordId);
				}
				
				editMarketingMaterialModal.hideModal();
				
				helper.showSuccessToast('The marketing material was updated successfully.');
			}
			else {
				editMarketingMaterialModal.set('v.errorResponse', response);
				console.log('Problem updating the marketing material. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(updateMarketingMaterialAction);
	},
	
	loadMarketingMaterialRecordDetails : function(component, helper, marketingMaterialRecordId) {
		var getMarketingMaterialsDetailsAction = component.get('c.getMarketingMaterialDetails');
		
		getMarketingMaterialsDetailsAction.setParams({
			"marketingMaterialId": marketingMaterialRecordId
		});
		
		getMarketingMaterialsDetailsAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var marketingMaterialDetails = response.getReturnValue();
				
				component.set('v.DeleteMarketingMaterialAllowed', marketingMaterialDetails.IsRecordDeletable);
				component.set('v.MarketingMaterialThumbnailURL', marketingMaterialDetails.ThumbnailURL);
				component.set('v.MarketingMaterialDownloadAllowed', marketingMaterialDetails.DownloadingAllowed);
				component.set('v.MarketingMaterialDownloadURL', marketingMaterialDetails.DownloadURL);
				component.set('v.DownloadDocumentIds', marketingMaterialDetails.DownloadContentDocumentIds);
			
				component.set('v.ShowMarketingMaterialDetails', true);
				component.set('v.ViewMarketingMaterialRecordId', marketingMaterialRecordId);
				component.set('v.MarketingMaterialThumbnailContentDocumentId', marketingMaterialDetails.ThumbnailContentDocumentId);
				
				var marketingMaterialTagsGrid = component.find('marketingMaterialTagsGrid');

				marketingMaterialTagsGrid.set('v.rowActions', helper.marketingMaterialTagsGridRowActions);
				marketingMaterialTagsGrid.set('v.whereClause', "WHERE Marketing_Material__c = '" + marketingMaterialRecordId + "'");
				marketingMaterialTagsGrid.reloadRecords();
                
                var marketingMaterialChildren = component.find('marketingMaterialChildren');
                marketingMaterialChildren.set('v.rowActions', helper.MarketingMaterialsGridRowActions);
                marketingMaterialChildren.set('v.whereClause', "Parent_Material__c = '" + marketingMaterialRecordId + "'");
                marketingMaterialChildren.reloadRecords();
				
				var marketingMaterialHistoryGrid = component.find('marketingMaterialHistoryGrid');
				marketingMaterialHistoryGrid.set('v.whereClause', "ParentId = '" + marketingMaterialRecordId + "'");
				marketingMaterialHistoryGrid.reloadRecords();
				
				helper.reloadThumbnailFiles(component, true);
				helper.reloadMarketingMaterialRecordView(component, marketingMaterialRecordId);
			}
			else {
				console.log('Problem updating the marketing material. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(getMarketingMaterialsDetailsAction);
	},
	
	reloadMarketingMaterialRecordView : function(component, marketingMaterialRecordId) {
		var container = component.find("ViewMarketingMaterialRecordContainer");
		
        $A.createComponent("force:recordView",
                           {recordId: marketingMaterialRecordId},
                           function(cmp) {
                               container.set("v.body", [cmp]);
                           });
	},
	
	hideMarketingMaterialRecordDetails : function(component) {
		component.set('v.ShowMarketingMaterialDetails', false);
		component.set('v.ViewMarketingMaterialRecordId', null);
	},
	
	unassignTagFromMarketingMaterial : function(component, marketingMaterialTagRecord) {
	    var helper = this;
	
		helper.deleteMarketingMaterialTag(component, marketingMaterialTagRecord.Id, function(response) {
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var marketingMaterialTagsGrid = component.find('marketingMaterialTagsGrid');
				marketingMaterialTagsGrid.reloadRecords();
				
				helper.showSuccessToast('The tag was removed from the marketing material.');
			}
			else {
				console.log('Problem unassigning the tag from the marketing material. Response state: ' + state);
			}
		
		});
	},
	
	loadAssignTagsToMarketingMaterials : function(component, helper) {
		helper.clearSelectedTagsForMarketingMaterial(component);
	
		var selectTagsForMarketingMaterialGrid = component.find('selectTagsForMarketingMaterialGrid');
		selectTagsForMarketingMaterialGrid.set('v.rowActions', this.selectTagsForMarketingMaterialGridRowActions);
		
		var ViewMarketingMaterialRecordId = component.get('v.ViewMarketingMaterialRecordId');
		
		selectTagsForMarketingMaterialGrid.set('v.whereClause', "WHERE Status__c = 'Active' AND Id not in (Select Tag__c FROM Marketing_Material_Tag__c WHERE Marketing_Material__c = '" + ViewMarketingMaterialRecordId + "')");
		
		selectTagsForMarketingMaterialGrid.reloadRecords();
		
		helper.showAssignTagsToMarketingMaterial(component);
	},
	
	showAssignTagsToMarketingMaterial : function(component) {
		component.set('v.ShowAddTagsToMarketedMaterials', true);
	},
	
	hideAssignTagsToMarketingMaterial : function(component) {
		component.set('v.ShowAddTagsToMarketedMaterials', false);
        component.set('v.TagsForMarketingMaterialSearchText', '');
	},
	
	toggleTagForMarketingMaterialSelection : function(component, selectedTag) {
		var SelectedTagsForMarketingMaterial = component.get('v.SelectedTagsForMarketingMaterial');
		
		if (!SelectedTagsForMarketingMaterial) {
		    SelectedTagsForMarketingMaterial = [];
		}
		
		var elementIndex = SelectedTagsForMarketingMaterial.findIndex(function(currentValue){
			return currentValue.Id == selectedTag.Id
		});
		
		if (elementIndex > -1) {
			SelectedTagsForMarketingMaterial.splice(elementIndex, 1);
		}
		else {
		    SelectedTagsForMarketingMaterial.push(selectedTag);
		}
		
		component.set('v.SelectedTagsForMarketingMaterial', SelectedTagsForMarketingMaterial);
	},
	
	filterTagsForMarketingMaterial : function(component) {
		var selectTagsForMarketingMaterialGrid = component.find("selectTagsForMarketingMaterialGrid");
		selectTagsForMarketingMaterialGrid.filterRecordsUsingSearchText();
	},
	
	assignTagsToMarketingMaterial : function(component) {
		var helper = this;
		var marketingMaterialRecordId = component.get('v.ViewMarketingMaterialRecordId');
		var selectedTags = component.get('v.SelectedTagsForMarketingMaterial');
		
		var addTagsToMarketingMaterialAction = component.get('c.addTagsToMarketingMaterial');
		
		addTagsToMarketingMaterialAction.setParams({
			"marketingMaterialId": marketingMaterialRecordId,
			"tags": selectedTags
		});
		
		addTagsToMarketingMaterialAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var marketingMaterialTagsGrid = component.find('marketingMaterialTagsGrid');
				marketingMaterialTagsGrid.reloadRecords();
				
				helper.hideAssignTagsToMarketingMaterial(component);
				helper.clearSelectedTagsForMarketingMaterial(component);
				
				helper.showSuccessToast('The tags were assigned to the marketing material.');
			}
			else {
				console.log('Problem assigning the tags to the marketing material. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(addTagsToMarketingMaterialAction);
	},
	
	clearSelectedTagsForMarketingMaterial : function(component) {
		component.set('v.SelectedTagsForMarketingMaterial', []);
	},
	
	deleteMarketingMaterialRecord : function(component) {
		var helper = this;
		var marketingMaterialToDeleteId = component.get('v.ViewMarketingMaterialRecordId');
		
		var deleteMarketingMaterialAction = component.get('c.deleteMarketingMaterial');
		
		deleteMarketingMaterialAction.setParams({
			"marketingMaterialToDeleteId": marketingMaterialToDeleteId
		});
		
		deleteMarketingMaterialAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				helper.loadManageMarketingMaterials(component, helper);
				helper.hideMarketingMaterialDeleteModal(component);
				
				helper.showSuccessToast('The marketing material was deleted.');
			}
			else {
				console.log('Problem deleting the marketing material. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(deleteMarketingMaterialAction);
	},
	
	showMarketingMaterialDeleteModal : function(component) {
		component.set('v.ShowDeleteMarketingMaterialConfirmationModal', true);
	},
	
	hideMarketingMaterialDeleteModal : function(component) {
		component.set('v.ShowDeleteMarketingMaterialConfirmationModal', false);
	},
	
	filterAllMarketingMaterialsUsingSearchText : function(component) {
		var helper = this;
		var searchText = component.get('v.AllMarketingMaterialsSearchText');
		
		var marketingMaterialsGrid = component.find('marketingMaterialsGrid');
        
        marketingMaterialsGrid.filterRecordsUsingSearchText(searchText);
	},
	
	clearAllMarketingMaterialsSearchText : function(component) {
		component.set('v.AllMarketingMaterialsSearchText', '');
	},
	
	handleUploadedThumbNail : function(component, helper, files) {
		var marketingMaterialId = component.get('v.ViewMarketingMaterialRecordId');
		var thumbnailContentDocumentId = files[0].documentId;
		
		var onMarketingMaterialThumbnailUploadedAction = component.get('c.onMarketingMaterialThumbnailUploaded');
		
		onMarketingMaterialThumbnailUploadedAction.setParams({
			"marketingMaterialId": marketingMaterialId,
			"thumbnailContentDocumentId": thumbnailContentDocumentId
		});
		
		onMarketingMaterialThumbnailUploadedAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var context = response.getReturnValue();
				component.set('v.MarketingMaterialThumbnailURL', context.ThumbnailURL);
				
				helper.showSuccessToast('The thumbnail was uploaded.');
			}
			else {
				console.log('Problem uploading the thumbnail. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(onMarketingMaterialThumbnailUploadedAction);
	},
	
	reloadThumbnailFiles : function(component, isMarketingMaterial) {
        
        if(isMarketingMaterial)
            var thumbnailFileUploader = component.find('thumbnailFileUploader');
        else
            var thumbnailFileUploader = component.find('thumbnailFileUploaderForAnnouncement');
        
		thumbnailFileUploader.reloadFiles();
	},
	
	loadMarketingMaterialThumbnailVersionsModal : function(component) {
		component.set('v.ShowMarketingMaterialThumbnailVersions', true);
		
		var thumbnailContentDocumentId = component.get('v.MarketingMaterialThumbnailContentDocumentId');
		
		var marketingMaterialContentVersionsGrid = component.find('marketingMaterialContentVersionsGrid');
		marketingMaterialContentVersionsGrid.set('v.whereClause', "ContentDocumentId = '" + thumbnailContentDocumentId + "'");
		marketingMaterialContentVersionsGrid.reloadRecords();
	},
	
	hideMarketingMaterialThumbnailVersionsModal : function(component) {
		component.set('v.ShowMarketingMaterialThumbnailVersions', false);
	},
	
	handleUploadedDownload : function(component, helper, files) {
		var marketingMaterialId = component.get('v.ViewMarketingMaterialRecordId');
		var downloadContentDocumentId = files[0].documentId;
		
		var onMarketingMaterialDownloadableUploadedAction = component.get('c.onMarketingMaterialDownloadableUploaded');
		
		onMarketingMaterialDownloadableUploadedAction.setParams({
			"marketingMaterialId": marketingMaterialId,
			"downloadContentDocumentId": downloadContentDocumentId
		});
		
		onMarketingMaterialDownloadableUploadedAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var context = response.getReturnValue();
				component.set('v.MarketingMaterialDownloadURL', context.DownloadURL);
				
				helper.showSuccessToast('The downloadable file was uploaded.');
			}
			else {
				console.log('Problem uploading the downloadable file. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(onMarketingMaterialDownloadableUploadedAction);
	},
	
	loadMarketingMaterialDownloadVersionsModal : function(component) {
		component.set('v.ShowMarketingMaterialDownloadVersions', true);
		
		var ViewMarketingMaterialRecordId = component.get('v.ViewMarketingMaterialRecordId');
		
		var marketingMaterialDownloadDocumentsGrid = component.find('marketingMaterialDownloadDocumentsGrid');
		
		var DownloadDocumentIds = component.get('v.DownloadDocumentIds');
		
		var whereClause = "Id in ('" + DownloadDocumentIds[0] + "'";
		
		for (let i= 1; i < DownloadDocumentIds.length; ++i) {
			whereClause += ", '" + DownloadDocumentIds[i] + "'";
		}
		
		whereClause += ")";
		
		
		marketingMaterialDownloadDocumentsGrid.set('v.whereClause', whereClause);
		marketingMaterialDownloadDocumentsGrid.reloadRecords();
	},
	
	hideMarketingMaterialDownloadVersionsModal : function(component) {
		component.set('v.ShowMarketingMaterialDownloadVersions', false);
	},
    
    cloneMarketingMaterial : function(component, event, helper) {
        var recordId = component.get('v.ViewMarketingMaterialRecordId');
        var cloneRecordAction = component.get('c.cloneMarketingMaterial');
        
        cloneRecordAction.setParams({
            'originalMarketingMaterialId' : recordId
        });
        
        cloneRecordAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var clonedMarketingMaterial = response.getReturnValue();
                component.set('v.NewMarketingMaterialRecord', clonedMarketingMaterial);
                helper.loadClonedMarketingMaterialModal(component, helper);
            }
            else {
                helper.showErrorToast('There was a problem cloning the record.');
            }                
        });
		
		$A.enqueueAction(cloneRecordAction);
    },
    
    // order functions
    
    loadManageOrders : function(component, helper){
        component.set('v.AdminFunction', 'ManageOrders');
        component.set('v.AllOrdersListViews', this.AllOrdersListViews);
        component.set('v.ShowOrderDetails', false);
        helper.loadOrdersUsingListviewFilter(component, helper);
    },
        
    loadOrdersUsingListviewFilter : function(component, helper) {
        var selectedListView = this.getOrdersListView(component, helper);
        var ordersGrid = component.find('ordersGrid');
        
        ordersGrid.set('v.whereClause', selectedListView.WhereClause);
        
        ordersGrid.reloadRecords();
    },
        
    getOrdersListView : function(component, helper) {
        var listViewFilter = component.get('v.OrderListViewFilter');
        
        for (let listView of this.AllOrdersListViews) {
            if (listView.Id == listViewFilter) {
                return listView;
            }
        }
        
        return this.AllOrdersListViews[0];
    },  
            
    loadOrderRecordDetails : function(component, helper, orderRecordId) {
		component.set('v.ShowOrderDetails', true);
		component.set('v.ViewOrderRecordId', orderRecordId);
        
        this.reloadOrderRecordView(component, orderRecordId);
        this.loadOrderLineItemsGrid(component, orderRecordId);
    },
    
    loadOrderLineItemRecordDetails : function(component, helper, orderLineItemRecordId) {
    	component.set('v.ShowOrderLineItemDetails', true);
		component.set('v.ViewOrderLineItemRecordId', orderLineItemRecordId);
    },
    
    hideOrderLineItemDetails : function(component) {
    	component.set('v.ShowOrderLineItemDetails', false);
    },

    reloadOrderRecordView : function(component, orderRecordId) {
		var container = component.find("ViewOrderRecordContainer");
		
        $A.createComponent("force:recordView",
                           {recordId: orderRecordId},
                           function(cmp) {
                               container.set("v.body", [cmp]);
                           });
	},
	
	loadOrderLineItemsGrid : function(component, orderRecordId) {
		var orderLineItemsGrid = component.find('orderLineItemsGrid');
		
		var whereClause = "Order__c = '" + orderRecordId + "'";
		orderLineItemsGrid.set('v.whereClause', whereClause);
		orderLineItemsGrid.reloadRecords();
	},
    
    filterAllOrdersUsingSearchText : function(component) {
		var helper = this;
		var searchText = component.get('v.AllOrdersSearchText');
        var ordersGrid = component.find('ordersGrid');
        ordersGrid.filterRecordsUsingSearchText(searchText);
	},
    
    // Announcement Functions
    loadManageAnnouncements : function(component, helper) {
        component.set('v.AdminFunction', 'ManageAnnouncements');
        component.set('v.ShowAnnouncementDetails', false);
        component.set('v.AllAnnouncementListViews', this.AllAnnouncementListViews);
        component.set('v.AnnouncementGridRowActions', this.AnnouncementsGridRowActions);
        component.set('v.AllAnnouncementsSearchText', '');
        
        helper.loadAnnouncementsUsingListviewFilter(component, helper);
    },
    
    loadAnnouncementsUsingListviewFilter : function(component, helper) {
        component.set('v.AllAnnouncementsSearchText', '');
		var selectedListView = helper.getSelectedAnnouncementsListView(component, helper);
		var announcementsGrid = component.find('announcementsGrid');
		
        announcementsGrid.set('v.rowActions', this.AnnouncementsGridRowActions);
        announcementsGrid.set('v.whereClause', selectedListView.WhereClause);
        
		announcementsGrid.reloadRecords();
	},
    
    getSelectedAnnouncementsListView : function(component, helper) {
		var listViewFilter = component.get('v.AnnouncementListViewFilter');
		
		for (let listView of this.AllAnnouncementListViews) {
		    if (listView.Id == listViewFilter) {
		        return listView;
		    }
		}
		
		return this.AllAnnouncementListViews[0];
	}, 
    
    filterAllAnnouncementsUsingSearchText : function(component, helper) {
		var searchText = component.get('v.AllAnnouncementsSearchText');
        var announcementsGrid = component.find('announcementsGrid');
        announcementsGrid.filterRecordsUsingSearchText(searchText);
    },
    
    loadAnnouncementRecordDetails : function(component, helper, announcementId) {        
        var getAnnouncementDetailsAction = component.get('c.getAnnouncementDetails');
		
		getAnnouncementDetailsAction.setParams({
			"announcementId": announcementId
		});
		
		getAnnouncementDetailsAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var announcementDetails = response.getReturnValue();
				
				component.set('v.DeleteAnnouncementAllowed', announcementDetails.IsRecordDeletable);
				component.set('v.AnnouncementThumbnailURL', announcementDetails.ThumbnailURL);
				component.set('v.AnnouncementThumbnailContentDocumentId', announcementDetails.ThumbnailContentDocumentId);
                
                component.set('v.ShowAnnouncementDetails', true);
                component.set('v.ViewAnnouncementRecordId', announcementId);
                
                helper.reloadThumbnailFiles(component, false);
                helper.reloadAnnouncementRecordView(component, announcementId);
            }
        });
        
        $A.enqueueAction(getAnnouncementDetailsAction);
	},
    
    reloadAnnouncementRecordView : function(component, announcementRecordId) {
		var container = component.find("ViewAnnouncementRecordContainer");
		
        $A.createComponent("force:recordView",
                           {recordId: announcementRecordId},
                           function(cmp) {
                               container.set("v.body", [cmp]);
                           });
	},
    
    loadNewAnnouncementModal : function(component) {
        var newAnnouncementRecord = { "sobjectType": 'Announcement__c' };
		component.set('v.NewAnnouncementRecord', newAnnouncementRecord);
		
		var newAnnouncementModal = component.find('newAnnouncementModal');
		newAnnouncementModal.showModalUsingRecord();
    }, 
    
    saveNewAnnouncement : function(component, helper) {
        var newAnnouncementModal = component.find('newAnnouncementModal');
		newAnnouncementModal.clearValidationMessages();

		var isValid = newAnnouncementModal.validate();

		if (!isValid) {
			newAnnouncementModal.showValidationMessages();

			return;
		}
	
		var newAnnouncementRecord = component.get('v.NewAnnouncementRecord');
		
		var addNewAnnouncementAction = component.get('c.addNewAnnouncement');
		addNewAnnouncementAction.setParams({
			"newAnnouncement": newAnnouncementRecord
		});
		
		addNewAnnouncementAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var newAnnouncementId = response.getReturnValue();
				
				helper.loadAnnouncementRecordDetails(component, helper, newAnnouncementId);
				helper.hideNewAnnouncementModal(component);
				
				helper.showSuccessToast('The new announcement was saved successfully.');
			}
			else {
				var newAnnouncementModal = component.find('newAnnouncementModal');
				newAnnouncementModal.set('v.errorResponse', response);
				console.log('Problem saving the new announcement. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(addNewAnnouncementAction);
    },
    
    hideNewAnnouncementModal : function(component) {
		var newAnnouncementFieldSetForm = component.find('newAnnouncementModal');
		newAnnouncementFieldSetForm.hideModal();
	}, 
    
    loadEditAnnouncementModalUsingId : function(component, announcementId) {
		var editAnnouncementModal = component.find('editAnnouncementModal');
		editAnnouncementModal.showModalUsingQuery(announcementId);
	},
    
    loadEditAnnouncementModal : function(component, announcemnetRecordToEdit) {
		this.loadEditAnnouncementModalUsingId(component, announcemnetRecordToEdit.Id);
	},
	
	hideEditAnnouncementModal : function(component) {
		var editAnnouncementModal = component.find("editAnnouncementModal");
	    editAnnouncementModal.hideModal();
	},
    
    saveEditedAnnouncement : function(component, helper) {
		var editAnnouncementModal = component.find('editAnnouncementModal');
		editAnnouncementModal.clearValidationMessages();

		var isValid = editAnnouncementModal.validate();

		if (!isValid) {
			editAnnouncementModal.showValidationMessages();
			return;
		}

		var editedAnnouncementRecord = component.get('v.EditAnnouncementRecord');
		
		var updateAnnouncementAction = component.get('c.updateAnnouncement');
		updateAnnouncementAction.setParams({
			"announcementToUpdate": editedAnnouncementRecord
		});
		
		updateAnnouncementAction.setCallback(component, function(response){
			var state = response.getState();
			var editAnnouncementModal = component.find('editAnnouncementModal');
			
			if (component.isValid() && state === "SUCCESS") {
				var AnnouncementsGrid = component.find('announcementsGrid');
				
				if (AnnouncementsGrid) {
					AnnouncementsGrid.reloadRecords();
				}
				
				var viewAnnouncementRecordId = component.get('v.ViewAnnouncementRecordId');
				
				if (viewAnnouncementRecordId) {
				    helper.loadAnnouncementRecordDetails(component, helper, viewAnnouncementRecordId);
				}
				
				editAnnouncementModal.hideModal();
				
				helper.showSuccessToast('The announcement was updated successfully.');
			}
			else {
				editAnnouncementModal.set('v.errorResponse', response);
				console.log('Problem updating the announcement. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(updateAnnouncementAction);
    },
    
    handleUploadedAnnouncementThumbnail : function(component, helper, files) {
		var announcementId = component.get('v.ViewAnnouncementRecordId');
		var thumbnailContentDocumentId = files[0].documentId;
		
		var onAnnouncementThumbnailUploadedAction = component.get('c.onAnnouncementThumbnailUploaded');
		
		onAnnouncementThumbnailUploadedAction.setParams({
			"announcementId": announcementId,
			"thumbnailContentDocumentId": thumbnailContentDocumentId
		});
		
		onAnnouncementThumbnailUploadedAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var context = response.getReturnValue();
				component.set('v.AnnouncementThumbnailURL', context.ThumbnailURL);
				
				helper.showSuccessToast('The thumbnail was uploaded.');
			}
			else {
				console.log('Problem uploading the thumbnail. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(onAnnouncementThumbnailUploadedAction);
	},
    
    loadAnnouncementThumbnailVersionsModal : function(component) {
		component.set('v.ShowAnnouncementThumbnailVersions', true);
		
		var thumbnailContentDocumentId = component.get('v.AnnouncementThumbnailContentDocumentId');
		
		var announcementContentVersionsGrid = component.find('announcementContentVersionsGrid');
		announcementContentVersionsGrid.set('v.whereClause', "ContentDocumentId = '" + thumbnailContentDocumentId + "'");
		announcementContentVersionsGrid.reloadRecords();
	},
	
	hideAnnouncementThumbnailVersionsModal : function(component) {
		component.set('v.ShowAnnouncementThumbnailVersions', false);
	},

	// Utility functions
	
	deleteMarketingMaterialTag : function(component, marketingMaterialTagIdToDelete, responseCallback) {
		var helper = this;
		
		var deleteMarketingMaterialTagAction = component.get('c.deleteMarketingMaterialTag');
		
		deleteMarketingMaterialTagAction.setParams({
			"marketingMaterialTagIdToDelete": marketingMaterialTagIdToDelete
		});
		
		deleteMarketingMaterialTagAction.setCallback(component, responseCallback);
		
		$A.enqueueAction(deleteMarketingMaterialTagAction);
	},
	
	getSelectedMarketingMaterialsListView : function(component, helper) {
		var listViewFilter = component.get('v.MarketingMaterialListViewFilter');
		
		for (let listView of this.AllMarketingMaterialListViews) {
		    if (listView.Id == listViewFilter) {
		        return listView;
		    }
		}
		
		return this.AllMarketingMaterialListViews[0];
	},
	
	showSuccessToast : function(successMessage) {
	    var toastEvent = $A.get("e.force:showToast");
	    toastEvent.setParams({
	        "message": successMessage,
	        "type": 'success'
	    });
	    toastEvent.fire();
	},
        
    showErrorToast : function(errorMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": errorMessage,
            "type": 'error'
        });
        toastEvent.fire();
    }
})