/**
 * @description A fluent interface for creating and inserting SObject records.
 * Solely used for testing, NOT a data factory.
 */
public abstract class SObjectTestData {
    private Map<Schema.SObjectField, Object> customValueMap;
    private Map<Schema.SObjectField, Object> defaultValueMap;

    /**
     * @description Subclasses of SObjectTestData should call super()
     * from within constructors to invoke the setup() method.
     */
    public SObjectTestData() {
        customValueMap = new Map<Schema.SObjectField, Object>();
        defaultValueMap = getDefaultValueMap();
    }

    /**
     * @description Retrieves the value set for the specified field.
     * @param field The Schema.SObjectField whos value we are retrieving.
     * @return An Object used when constructing SObjects for the specified field.
     */
    protected Object currentValueFor(Schema.SObjectField field) {
        Object val = customValueMap.get(field);

        if (val == null) {
            return defaultValueMap.get(field);
        }

        return val;
    }

    /**
     * @description Generates a map of default values for this SObjectType.
     * @return The Map of SObjectFields to their corresponding default values.
     */
    protected abstract Map<Schema.SObjectField, Object> getDefaultValueMap();

    /**
     * @description Dynamically sets the Schema.SObjectField noted by field to value for
     * SObjects being built.
     * @param field The Schema.SObjectField to map the value to and cannot be null.
     * @param value The value for the field and can be set to null.
     * @return The instance of SObjectTestData.
     */
    protected SObjectTestData withDynamicData(Schema.SObjectField field, Object value) {
        customValueMap.put(field, value);
        return this;
    }

    /**
     * @description Builds an instance of SObject dynamically and sets the instance's
     * fields from the values in the customValueMap and defaultValueMap.
     * @return an instance of SObject
     */
    private SObject build() {
        beforeBuild();
        
        SObject instance = getSObjectType().newSObject(null, true);
        Set<Schema.SObjectField> defaultFields = defaultValueMap.keySet().clone();
        defaultFields.removeAll(customValueMap.keySet());
        
        for (Schema.SObjectField field : defaultFields) {
            instance.put(field, defaultValueMap.get(field));
        }
        
        for (Schema.SObjectField field : customValueMap.keySet()) {
        instance.put(field, customValueMap.get(field));
        }

        afterBuild(instance);
        return instance;
    }

    /**
     * @description Builds an instance of SObject dynamically and sets the instance's
     * fields from the values in the defaultValueMap.
     * @return an instance of SObject
     */
    protected SObject buildDefault() {
        beforeBuild();

        SObject instance = getSObjectType().newSObject(null, true);

        for (Schema.SObjectField field : defaultValueMap.keySet()) {
            instance.put(field, defaultValueMap.get(field));
        }

        afterBuild(instance);
        return instance;
    }

    /**
     * @description Builds an instance of SObject dynamically and sets the instance's
     * fields from the values in the customValueMap. Also clears
     * the customValueMap.
     * @return an instance of SObject
     */
    protected SObject buildWithReset() {
        SObject instance = build();

        customValueMap = new Map<Schema.SObjectField, Object>();
        return instance;
    }

    /**
     * @description Builds an instance of SObject dynamically and sets the instance's
     * fields from the values in the customValueMap map. This method does not
     * clear the customValueMap.
     * @return an instance of SObject
     */
    protected SObject buildWithoutReset() {
        return build();
    }

    /**
     * @description Inserts the built SObject.
     * @return The inserted SObject.
     */
    protected SObject insertRecord() {
        SObject instance = buildWithReset();
        beforeInsert(instance);
        insert instance;
        afterInsert(instance);
        return instance;
    }

    /**
     * @description Inserts the SObject built from only the defaults.
     * @return The inserted SObject.
     */
    protected SObject insertDefaultRecord() {
        SObject instance = buildDefault();
        beforeInsert(instance);
        insert instance;
        afterInsert(instance);
        return instance;
    }

    /**
     * @description Inserts a list of SObjects and ties into the before and after hooks.
     * @param numToInsert the number of SObjects to insert.
     * @return The inserted SObjects.
     */
    protected List<SObject> insertRecords(Integer numToInsert) {
        List<SObject> sobjectsToInsert = new List<SObject>();

        for (Integer i = 0; i < numToInsert; i++) {
            SObject sObj = buildWithoutReset();
            sobjectsToInsert.add(sObj);
            beforeInsert(sObj);
        
        }

        insert sobjectsToInsert;

        for (SObject sObj : sobjectsToInsert) {
            afterInsert(sObj);
        }

        return sobjectsToInsert;
    }

    /**
     * @description This method allows subclasses to invoke any action before
     * the SObject is built.
     */
    protected virtual void beforeBuild() {}

    /**
     * @description This method allows subclasses to handle the SObject after
     * it is built.
     * @param sObj The SObject that has been built.
     */
    protected virtual void afterBuild(SObject sObj) {}

    /**
     * @description This method allows subclasses to handle the SObject before
     * it is inserted.
     * @param sObj The SObject that is going to be inserted.
     */
    protected virtual void beforeInsert(SObject sObj) {}

    /**
     * @description This method allows subclasses to handle the SObject after
     * it is inserted.
     * @param sObj The SObject that has been inserted.
     */
    protected virtual void afterInsert(SObject sObj) {}

    /**
     * @description Returns the SObject type for this TestData builder.
     * @return A Schema.SObjectType.
     */
    protected abstract Schema.SObjectType getSObjectType();
}