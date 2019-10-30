({
    loadDynamicComponents : function(component) {
        var helper = this;
        var sectionMetadata = component.get('v.sectionMetadata');
        
        if (!sectionMetadata || !sectionMetadata.Inputs) {
            return;
        }
        
        var inputDesc = [];
        var configTemplate = { componentDef: 'c:EmailBuilderSectionInput', attributes: { } };
        var config = null;
        
        for (let sectionInput of sectionMetadata.Inputs) {
            config = JSON.parse(JSON.stringify(configTemplate));

            config.attributes.dataContainer = component.getReference('v.dataContainer');
            config.attributes.sectionInput = sectionInput;
            config.attributes["aura:id"] = sectionInput.TargetField;
            
            inputDesc.push([
                config.componentDef,
                config.attributes
            ]);            
        }
        
        $A.createComponents(inputDesc, function(cmps) {
            console.log('Email Builder Input Section createComponents');
            component.set("v.sectionInputComponents", cmps);
        });

    }
})