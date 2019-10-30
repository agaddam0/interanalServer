({
	doInit : function(component, event, helper) {
		helper.loadOrderAdminDetails(component, helper);
	},
	
	onManageRecordsClick : function(component, event, helper) {
		helper.loadManageMarketingMaterials(component, helper);
	},
	
	onManageTagsClick : function(component, event, helper) {
		helper.loadManageTags(component, helper);
	},
	
	onManageTagCategoriesClick : function(component, event, helper) {
        var allTagCategoriesListViewId = component.get('v.AllTagCategoriesListViewId');

		if (allTagCategoriesListViewId) {
			var navEvent = $A.get("e.force:navigateToList");
	        navEvent.setParams({
	            "listViewId": allTagCategoriesListViewId,
	            "scope": "Tag_Category__c"
	        });
	        navEvent.fire();

	        return;
        }

		// If there's no All "Tag Categories" List View, open the
		// object tab.
		var homeEvent = $A.get("e.force:navigateToObjectHome");
		homeEvent.setParams({
			"scope": "Tag_Category__c"
		});
		homeEvent.fire();
	},   
	
	// Tag Functions
	onNewTagClick : function(component, event, helper) {
		helper.loadNewTagModal(component, helper);
	},
	
	closeNewTagModal : function(component, event, helper) {
		helper.hideNewTagModal(component);
	},
	
	saveNewTag : function(component, event, helper) {
		helper.saveNewTag(component, helper);
	},
    
    saveAndNewTagClick : function(component, event, helper) {
        component.set("v.SaveAndNewClick", true);
		helper.saveNewTag(component, helper);
	},
	
	onTagCategoryFilterChange : function(component, event, helper) {
		helper.loadTagsUsingCategoryFilter(component, helper);
	},
	
	handleGridRowAction : function(component, event, helper) {
		var eventSourceGrid = event.getSource();
		var gridId = eventSourceGrid.getLocalId();
		var actionName = event.getParam("actionName");
		var record = event.getParam("record");
		
		if (gridId == "tagsGrid") {
		    if (actionName == "Edit") {
		        helper.loadEditTagModal(component, record);
		    }
		}
		
		if (gridId == "selectTagsMarketingMaterialsGrid") {
		    if (actionName == "Select") {
		    	helper.toggleTagsMarketingMaterialSelection(component, record);
		    }
		}
		
		if (gridId == "tagsMarketingMaterialsGrid") {
		    if (actionName == "Remove") {
		        helper.unassignMarketingMaterialFromTag(component, record);
		    }
		}
		
		if (gridId == "marketingMaterialsGrid") {
			if (actionName == "Edit") {
				helper.loadEditMarketingMaterialModal(component, record);
			}
		}
        
        if (gridId == "marketingMaterialChildren") {
			if (actionName == "Edit") {
				helper.loadEditMarketingMaterialModal(component, record);
			}
		}
		
		if (gridId == "marketingMaterialTagsGrid") {
			if (actionName == "Remove") {
		 		helper.unassignTagFromMarketingMaterial(component, record);
		    }
		}
		
		if (gridId == "selectTagsForMarketingMaterialGrid") {
		    if (actionName == "Select") {
		    	helper.toggleTagForMarketingMaterialSelection(component, record);
		    }
		}
        
        if (gridId == "announcementsGrid") {
            if(actionName == "Edit") {
                helper.loadEditAnnouncementModal(component, record);
            }
        }
	},
	
	closeEditTagModal : function(component, event, helper) {
		helper.hideEditTagModal(component);
	},
	
	saveEditTag : function(component, event, helper) {
	    helper.saveEditTag(component, helper);
	},
	
	tagsGridViewRecord : function(component, event, helper) {
		var tagRecordId = event.currentTarget.getAttribute("data-recId");
		
		helper.loadTagRecordDetails(component, helper, tagRecordId);
	},

	onAssignTagMarketingMaterialsClick : function(component, event, helper) {
		helper.loadAssignTagMarketingMaterials(component, helper);
	},
	
	closeAddTagsMarketingMaterials : function(component, event, helper) {
	    helper.hideAssignTagMarketingMaterials(component);
	},
	
	assignMarketingMaterialsToTag : function(component, event, helper) {
		helper.assignMarketingMaterialsToTag(component);
	},
	
	filterMarketingMaterialsForTag : function(component, event, helper) {
		helper.filterMarketingMaterialsForTag(component);
	},
	
	onTagDetailEditClick : function(component, event, helper) {
		var tagToEditId = component.get('v.ViewTagRecordId');
	
		helper.loadEditTagModalUsingId(component, tagToEditId);
	},
	
	onBackToTagsClick : function(component, event, helper) {
		helper.loadManageTags(component, helper);
	},
	
	filterAllTagsUsingSearchText : function(component, event, helper) {
		helper.filterAllTagsUsingSearchText(component);
	},    
	
	// Marketing Material Functions
	marketingMaterialsGridViewRecord : function(component, event, helper) {
		var marketingMaterialRecordId = event.currentTarget.getAttribute("data-recId");
		
		helper.loadMarketingMaterialRecordDetails(component, helper, marketingMaterialRecordId);
	},
	
	onNewMarketingMaterialClick : function(component, event, helper) {
		helper.loadNewMarketingMaterialModal(component, helper);
	},
    
    onNewChildMarketingMaterialClick : function(component, event, helper) {
		helper.loadNewChildMarketingMaterialModal(component, helper);
	},
	
	onMarketingMaterialListviewFilterChange : function(component, event, helper) {
		helper.loadMarketingMaterialsUsingListviewFilter(component, helper);
	},
	
	closeNewMarketingMaterialModal : function(component, event, helper) {
	    helper.hideNewMarketingMaterialModal(component);
	},
	
	saveNewMarketingMaterial : function(component, event, helper) {
		helper.saveNewMarketingMaterial(component, helper);
	},
    
    saveAndNewMaterialClick : function(component, event, helper) {
        component.set("v.SaveAndNewClick", true);
        helper.saveNewMarketingMaterial(component, helper);
    },
	
	saveEditedMarketingMaterial : function(component, event, helper) {
		helper.saveEditedMarketingMaterial(component, helper);
	},
	
	onMarketingMaterialDetailEditClick : function(component, event, helper) {
		var marketingMaterialToEditId = component.get('v.ViewMarketingMaterialRecordId');
	
		helper.loadEditMarketingMaterialModalUsingId(component, marketingMaterialToEditId);
	},
    
    onMarketingMaterialCloneClick : function(component, event, helper) {
        helper.cloneMarketingMaterial(component, event, helper);
    },
	
	onBackToMarketingMaterialsClick : function(component, event, helper) {
		helper.loadManageMarketingMaterials(component, helper);
	},
	
	onAssignTagsToMarketingMaterialClick : function(component, event, helper) {
		helper.loadAssignTagsToMarketingMaterials(component, helper);
	},
	
	closeAddTagsToMarketingMaterials : function(component, event, helper) {
		helper.hideAssignTagsToMarketingMaterial(component);
	},
	
	filterTagsForMarketingMaterial : function(component, event, helper) {
		helper.filterTagsForMarketingMaterial(component);
	},
	
	assignTagsToMarketingMaterial : function(component, event, helper) {
		helper.assignTagsToMarketingMaterial(component);
	},
	
	onMarketingMaterialDetailDeleteClick : function(component, event, helper) {
		helper.showMarketingMaterialDeleteModal(component);
	},
	
	closeDeleteMarketingMaterialConfirmationModal : function(component, event, helper) {
		helper.hideMarketingMaterialDeleteModal(component);
	},
	
	onDeleteMarketingMaterial : function(component, event, helper) {
		helper.deleteMarketingMaterialRecord(component);
	},
	
	filterAllMarketingMaterialsUsingSearchText : function(component, event, helper) {
		helper.filterAllMarketingMaterialsUsingSearchText(component);
	},
	
	handleUploadFilesFinished : function(component, event, helper) {
		var componentSrc = event.getSource();
		var uploadFileComponentId = componentSrc.getLocalId();
		var files = event.getParam("Files");
		
		if (uploadFileComponentId == "thumbnailFileUploader") {
			helper.handleUploadedThumbNail(component, helper, files);
		}
		
		if (uploadFileComponentId == "downloadableFileUploader") {
			helper.handleUploadedDownload(component, helper, files);
		}
        
        if (uploadFileComponentId == 'thumbnailFileUploaderForAnnouncement') {
            helper.handleUploadedAnnouncementThumbnail(component, helper, files);
        }
	},
	
	onViewThumbnailVersionsClick : function(component, event, helper) {
		helper.loadMarketingMaterialThumbnailVersionsModal(component);
	},
	
	closeMarketingMaterialThumbnailVersionsModal : function(component, event, helper) {
		helper.hideMarketingMaterialThumbnailVersionsModal(component);
	},
	
	onViewDownloadVersionsClick : function(component, event, helper) {
		helper.loadMarketingMaterialDownloadVersionsModal(component);
	},
	
	closeMarketingMaterialDownloadVersionsModal : function(component, event, helper) {
		helper.hideMarketingMaterialDownloadVersionsModal(component);
	},
    
    // Order Functions
    
    ordersGridViewRecord : function(component, event, helper) {
        var orderRecordId = event.currentTarget.getAttribute("data-recId");
        
        helper.loadOrderRecordDetails(component, helper, orderRecordId);
    },
    
    orderLineItemsGridViewRecord : function(component, event, helper) {
        var orderLineItemRecordId = event.currentTarget.getAttribute("data-recId");
        
        helper.loadOrderLineItemRecordDetails(component, helper, orderLineItemRecordId);
    },
    
    onManageOrdersClick : function(component, event, helper) {
        helper.loadManageOrders(component, helper);
    },
    
    filterAllOrdersUsingSearchText : function(component, event, helper) {
      	helper.filterAllOrdersUsingSearchText(component);  
    },
    
    onBackToOrdersClick : function(component, event, helper) {
        helper.loadManageOrders(component, helper);
    },
    
    onOrderListviewFilterChange : function(component, event, helper) {
        helper.loadOrdersUsingListviewFilter(component, event, helper);
    },
    
    onBackToOrderFromOrderLineItemDetailClick : function(component, event, helper) {
		helper.hideOrderLineItemDetails(component);
	},
    
    // Announcement Functions
    
    filterAllAnnouncementsUsingSearchText : function(component, event, helper) {
        helper.filterAllAnnouncementsUsingSearchText(component, helper);  
    },
    
    onManageAnnouncementsClick : function(component, event, helper) {
        helper.loadManageAnnouncements(component, helper);
    },
    
    onAnnouncementListviewFilterChange : function(component, event, helper) {
		helper.loadAnnouncementsUsingListviewFilter(component, helper);
	},
    
    announcementsGridViewRecord : function(component, event, helper) {
        var announcementRecordId = event.currentTarget.getAttribute("data-recId");
        
        helper.loadAnnouncementRecordDetails(component, helper, announcementRecordId);
    },
    
    onBackToAnnouncemetClick : function(component, event, helper) {
        helper.loadManageAnnouncements(component, helper);
    },
    
    onNewAnnouncementClick : function(component, event, helper) {
        helper.loadNewAnnouncementModal(component);
    },
    
    saveNewAnnouncement : function(component, event, helper) {
      	helper.saveNewAnnouncement(component, helper);  
    },
    
    onAnnouncementDetailEditClick : function(component, event, helper) {
        var announcementToEditId = component.get('v.ViewAnnouncementRecordId');
	
		helper.loadEditAnnouncementModalUsingId(component, announcementToEditId);
    },
    
    saveEditedAnnouncement : function(component, event, helper) {
        helper.saveEditedAnnouncement(component, helper);
    },
    
    onViewAnnouncementThumbnailVersionsClick : function(component, event, helper) {
        helper.loadAnnouncementThumbnailVersionsModal(component);
	},
	
	closeAnnouncementThumbnailVersionsModal : function(component, event, helper) {
		helper.hideAnnouncementThumbnailVersionsModal(component);
	},
    
    scrollToTop : function(component, event, helper){
        var container = document.getElementById("adminContainer");
        container.scrollTop = 0;
    }
})