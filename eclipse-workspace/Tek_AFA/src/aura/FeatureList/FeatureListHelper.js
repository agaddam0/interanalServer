({	
	showFeatureDetailModal: function(component) {
    	var helper = this;
    	component.set('v.ShowFeatureDetailModal', true);
    },
    hideFeatureDetailModal : function(component) {
    	component.set('v.ShowFeatureDetailModal', false);
    },
    showPrintModal: function(component) {
    	var helper = this;
    	component.set('v.ShowPrintModal', true);
    },
    hidePrintModal : function(component) {
    	component.set('v.ShowPrintModal', false);
    },
    filterAndMapFeatures: function(component) {
        	const getClassFromFeature = function(feature, future) {
                const themeName = component.get('v.themeName');
        		const wrapTheme = (c) => {
                	return c.concat((t => (t != '' ? '_'.concat(t) : ''))(themeName));
            	}   
                
                const tierOne = feature.Teir_1_Feature__c ? ' tier-one ' : '';
                let className = ""
                
                switch (feature.Status__c) {
                    case 'On Hold':
                        className = wrapTheme('feature-on-hold');
                        break;
                    case 'Not Started':
                        if (future == true) {
                        	className = wrapTheme('feature-future');    
                        } else {
                         	className = wrapTheme('feature-not-started');    
                        }
                        break;
                    case 'In Progress':
                        className = wrapTheme('feature-in-progress');
                        break;
                    case 'Discovery':
                        className = wrapTheme('feature-discovery');
                        break;
                    case 'Completed':
                        className = wrapTheme('feature-complete');
                        break;
                    default: 
                        className = wrapTheme('feature-future');
                        break;
                	}
                

                return {
                    placeholderClass: 'slds-item slds-m-around',
                    className: "slds-text-title slds-p-around_x-small slds-m-bottom_small ".concat(className).concat(tierOne),
                    statusClass: className,
                    tierClass: tierOne
                };
            }
            
            const filterFuture = (f, year) => {
                return f.Release_Year__c > Number.parseInt(year) || (f.Release_Year__c == year && !f.Release_Quarter__c);
            }
            
            const filterByYear = (f, year) => {
                return f.Release_Year__c == `${year}`;
            }
                                      
            const filterByQuarter = (f, quarter) => {
                return f.Release_Quarter__c == `${quarter}`;
            }
    
    		const addClassForFeature = (feature, future) => {
    			return Object.assign(feature, getClassFromFeature(feature, future));
			}

			const addDateComponents = (feature) => {
                let releaseDisplayText;
                if (feature.Release_Date__c) {
	                const releaseDate = new Date(feature.Release_Date__c);
                	releaseDisplayText = 'Estimated Release Date: ' + (releaseDate.getMonth() + 1) + '/' + (releaseDate.getDate() + 1);
            	} else {
                    releaseDisplayText = '';
                }
              
				return Object.assign(feature, { releaseDisplayText: releaseDisplayText });
			}
            
			const SummaryColumns = [
                { 
                    "property": "v.firstQuarterReleases",
                    "key": "1st Quarter"
                },
 				{ 
                    "property": "v.secondQuarterReleases",
                    "key": "2nd Quarter"
                },
 				{ 
                    "property": "v.thirdQuarterReleases",
                    "key": "3rd Quarter"
                },
 				{ 
                    "property": "v.fourthQuarterReleases",
                    "key": "4th Quarter"
                },
                {
                    "property": "v.futureReleases",
                    "key": "Future"
                }
            ];
        
        	const pad = function(arr, len) {
                return arr.length < len ? arr.concat(new Array(len - arr.length).fill({ 
                    											className: 'slds-text-title slds-p-around_x-small slds-m-bottom_small feature-placeholder',
                    											Name: '',
                    											Id: '', 
                    											Description__c: '',
                    											placeholderClass: 'slds-item slds-m-around opacity-placeholder',
                    											statusTheme: 'feature-placeholder',
                    											isPlaceholder: true
                })).slice() : arr.slice();
        	}
    		
			const filterYear = component.get("v.filterYear");
			const getFeaturesActionResponse = component.get('v.featureReleases');
        
                let topoff = SummaryColumns.reduce(function(acc, e, i) {
                    	const len = getFeaturesActionResponse.slice()
                        .filter(f => filterByYear(f, filterYear))
                        .filter(f => filterByQuarter(f, e.key)).length;
                               
                        	if (len > acc) {
                             acc = len
                        	}
                    		return acc;
	                }, 0)
                
            let data = SummaryColumns.map(
                e => {
                    return {
                    key: e.key,
                    data: pad(getFeaturesActionResponse
                    	.filter(f => e.key === 'Future' ? filterFuture(f, filterYear) : filterByYear(f, filterYear))
                    	.filter(f => e.key === 'Future' ?  true : filterByQuarter(f, e.key))
                        .map(f => addClassForFeature(f, e.key === 'Future'))
                        .map(f => addDateComponents(f)), topoff)
                	}
                }) 
    
		component.set('v.summaryColumns', data)        
	},
	loadFeatures: function(component, event, helper) {
		var getFeaturesAction = component.get('c.getAllFeatures');

        getFeaturesAction.setCallback(component, (response) => {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
            	const features = response.getReturnValue();
            	console.log(features);
            	component.set('v.featureReleases', features);
            	this.filterAndMapFeatures(component);
        	} else {
				console.log('Problem getting feature releases. Response state: ' + state);
			}
             
        });
		
		$A.enqueueAction(getFeaturesAction);
	}
})