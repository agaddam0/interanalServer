/**
 * @description Builder class for dealing with Marketing Material records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class MarketingMaterialTestData extends SObjectTestData {

    /**
     * @description Overridden method to set up the default
     * Marketing Material state for MarketingMaterialTestData.
     * @return A map of Marketing Material default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Marketing_Material__c.Title__c => 'Some Marketing Material',
            Marketing_Material__c.Status__c => 'Active',
            Marketing_Material__c.Material_Number__c => 'ABC123',
            Marketing_Material__c.Display_In_Search_Results__c => true,
            Marketing_Material__c.Price__c => 50
        };
    }

    /**
     * @description Returns the SObject type for MarketingMaterialTestData builder.
     * @return Marketing_Material__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Marketing_Material__c.SObjectType;
    }

    /**
     * @description Sets the name on the marketing material.
     * @param withAdditionalInformationNeeded The with additional information needed that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withAdditionalInformationNeeded(String withAdditionalInformationNeeded) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Additional_Information_Needed__c, withAdditionalInformationNeeded);
    }
    
    /**
     * @description Sets the audit date on the marketing material.
     * @param auditDate The audit date that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withAuditDate(Date auditDate) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Audit_Date__c, auditDate);
    }
    
    /**
     * @description Sets the customization type on the marketing material.
     * @param customizationType The customization type that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withCustomizationType(String customizationType) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Customization_Type__c, customizationType);
    }

    /**
     * @description Sets the description on the marketing material.
     * @param description The description that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withDescription(String description) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Description__c, description);
    }

    /**
     * @description Sets the display in search results on the marketing material.
     * @param displayInSearchResults The display in search results that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withDisplayInSearchResults(Boolean displayInSearchResults) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Display_In_Search_Results__c, displayInSearchResults);
    }

    /**
     * @description Sets the division on the marketing material.
     * @param division The division that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withDivision(String division) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Division__c, division);
    }

    /**
     * @description Sets the download URL on the marketing material.
     * @param downloadURL The download URL that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withDownloadURL(String downloadURL) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Download_URL__c, downloadURL);
    }

    /**
     * @description Sets the expiration date on the marketing material.
     * @param expirationDate The expiration date that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withExpirationDate(Date expirationDate) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Expiration_Date__c, expirationDate);
    }

    /**
     * @description Sets the feature on the marketing material.
     * @param feature The feature that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withFeature(Boolean feature) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Feature__c, feature);
    }

    /**
     * @description Sets the feature header on the marketing material.
     * @param featureHeader The feature header that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withFeatureHeader(String featureHeader) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Feature_Header__c, featureHeader);
    }
    
    /**
     * @description Sets the feature visibility on the marketing material.
     * @param featureVisibility The feature visibility that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withFeatureVisibility(String featureVisibility) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Feature_Visibility__c, featureVisibility);
    }

    /**
     * @description Sets the file type on the marketing material.
     * @param fileType The file type that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withFileType(String fileType) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.File_Type__c, fileType);
    }
    
    /**
     * @description Sets the industry on the marketing material.
     * @param industry The industry that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withIndustry(String industry) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Industry__c, industry);
    }
    
    /**
     * @description Sets the material number on the marketing material.
     * @param materialNumber The material number that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withMaterialNumber(String materialNumber) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Material_Number__c, materialNumber);
    }
    
    /**
     * @description Sets the material type on the marketing material.
     * @param materialType The material type that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withMaterialType(String materialType) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Material_Type__c, materialType);
    }
    
    /**
     * @description Sets the price on the marketing material.
     * @param price The price that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withPrice(Decimal price) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Price__c, price);
    }
    
    /**
     * @description Sets the processing type on the marketing material.
     * @param processingType The processing type that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withProcessingType(String processingType) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Processing_Type__c, processingType);
    }
    
    /**
     * @description Sets the quantity minimum on the marketing material.
     * @param quantityMinimum The quantity minimum that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withQuantityMinimum(Integer quantityMinimum) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Quantity_Minimum__c, quantityMinimum);
    }
    
    /**
     * @description Sets the quantity maximum on the marketing material.
     * @param quantityMaximum The quantity maximum that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withQuantityMaximum(Integer quantityMaximum) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Quantity_Maximum__c, quantityMaximum);
    }
    
    /**
     * @description Sets the states on the marketing material.
     * @param states The states that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withStates(String states) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.State__c, states);
    }
    
    /**
     * @description Sets the status on the marketing material.
     * @param status The status that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withStatus(String status) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Status__c, status);
    }
    
    /**
     * @description Sets the thumbnail url on the marketing material.
     * @param thumbnailURL The thumbnail url that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withThumbnailURL(String thumbnailURL) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Thumbnail_URL__c, thumbnailURL);
    }
    
    /**
     * @description Sets the title on the marketing material.
     * @param title The title that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withTitle(String title) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Title__c, title);
    }

    /**
     * @description Sets the website type on the marketing material.
     * @param websiteType The website type that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withWebsiteType(String websiteType) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Website_Type__c, websiteType);
    }
    
    /**
     * @description Sets the available packages on the marketing material.
     * @param availablePackage The available packages that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withAvailablePackages(String availablePackage) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Available_Packages__c, availablePackage);
    }

    /**
     * @description Sets the group type on the marketing material.
     * @param groupType The group type that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withGroupType(String groupType) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Group_Type__c, groupType);
    }

    /**
     * @description Sets the enrollment path on the marketing material.
     * @param enrollmentPath The enrollment path that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withEnrollmentPath(String enrollmentPath) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Enrollment_Path__c, enrollmentPath);
    }

    /**
     * @description Sets the minimum eligibles on the marketing material.
     * @param minimumEligibles The minimum eligibles that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withMinimumEligibles(Integer minimumEligibles) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Minimum_Eligibles__c, minimumEligibles);
    }

    /**
     * @description Sets the pre-enrollment segment on the marketing material.
     * @param preenrollmentSegment The pre-enrollment that the marketing material will have.
     * @return The instance of MarketingMaterialTestData.
     */
    public MarketingMaterialTestData withPreenrollmentSegment(String preenrollmentSegment) {
        return (MarketingMaterialTestData) withDynamicData(Marketing_Material__c.Pre_enrollment_Segment__c, preenrollmentSegment);
    }
    
    /* Create a "with" method for each property that can be set */

    public MarketingMaterialTestData usePreenrollmentMarketingDefaults() {
        return (MarketingMaterialTestData) withGroupType('New;Existing')
                                          .withEnrollmentPath('Limited;Standard;Deluxe;Full Benefit')
                                          .withMinimumEligibles(1)
                                          .withPreenrollmentSegment('Digital')
                                          .withAvailablePackages('Pre-enrollment Marketing');
    }

    /**
     * @description Builds the Marketing Material object.
     * @return The created Marketing Material object.
     */
    public Marketing_Material__c create() {
        return (Marketing_Material__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Marketing Material object.
     * @return The inserted Marketing Material object.
     */
    public Marketing_Material__c insertMarketingMaterial() {
        return (Marketing_Material__c)super.insertRecord();
    }
    
    /**
     * @description Inserts a Marketing Material using only the default values.
     * @return The inserted Marketing Material.
     */
    public Marketing_Material__c insertDefaultMarketingMaterial() {
        return (Marketing_Material__c) insertDefaultRecord();
    }
    
    /**
     * @description Insert the specified number of marketing materials.
     * @param numberOfMarketingMaterialsToInsert The number of marketing materials to insert.
     * @return The marketing materials that were inserted.
     */
    public List<Marketing_Material__c> insertMarketingMaterials(Integer numberOfMarketingMaterialsToInsert) {
        return (List<Marketing_Material__c>) insertRecords(numberOfMarketingMaterialsToInsert);
    }

    /**
     * @description Gets an instance of MarketingMaterialTestData.
     * @return MarketingMaterialTestData instance.
     */
    public static MarketingMaterialTestData Instance {
        get {
            if (Instance == null) {
                Instance = new MarketingMaterialTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private MarketingMaterialTestData() {
        super();
    }
}