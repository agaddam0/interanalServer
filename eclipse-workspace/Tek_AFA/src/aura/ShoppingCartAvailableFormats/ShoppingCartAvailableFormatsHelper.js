({    
    showPrintIcon : function(component, materialType){
        var printOptions = ['Brochure', 'Flyer', 'Envelope', 'Folder', 'Letter', 'Packet', 'Postcard', 'Poster', 'Slick', 'Stickers', 'Thank You Card'];
        component.set('v.showPrintIcon', printOptions.includes(materialType));
    },
    
    showDigitalIcon : function(component, materialType){
        var digitalOptions = ['Logo', 'Website', 'Presentation'];
        component.set('v.showDigitalIcon', digitalOptions.includes(materialType) || materialType.toLowerCase().includes('email'));
    },
    
    showDownloadIcon : function(component, processingType){
        component.set('v.showDownloadIcon', processingType.toLowerCase().includes('download'));
    }
})