var angular, R, r = R, AccountAssessmentDetailsExt;
var currentRoleId, starTemplate, accountData, userRoleId, skipAmt, userIds;
var offId='';
var qLimit = 2000;

(function() {
	'use strict';

	angular
			.module(
					'assessDetailApp',
					[ 'ngTouch', 'ui.grid', 'ui.grid.resizeColumns',
							'ui.grid.moveColumns', 
							//'ui.grid.pagination',
							'ui.grid.pinning', 'ui.grid.exporter',
							'ui.grid.selection', 'userService',
							'jsRemoteService', 'ui.grid.grouping',
							'ui.grid.saveState'])

			.service('setGridInfo', ['$q', 'data', 'accountAssessmentDetailsExt', 'userIds', 'offId','$scope', setGridInfo])
			.service('accountAssessmentDetailsExt', AccountAssessmentDetailsExtension)

			.controller(
					'ctrl',
					[ '$scope', 'uiGridConstants', 'roles',
							'uiGridGroupingConstants',
							'accountAssessmentDetailsExt', '$q',
							'users', controller ]);

	function AccountAssessmentDetailsExtension()
	{
		return AccountAssessmentDetailsExt;
	}

	function controller($scope, uiGridConstants, roles,
			uiGridGroupingConstants, accountAssessmentDetailsExt, $q, users) {


		//	Used to toggle the loading screen
		$scope.loading = true;

		// userRoleId needs to be assigned in the VisualForce page using this
		// service! (Ex: var userRoleId = '{!$User.UserRoleId}';)
		currentRoleId = userRoleId;

		var finalizeAgg = function(aggregation) {
			aggregation.rendered = aggregation.value;
		}

		// Filter grid options
		var selOptions = [ {
			value : '1',
			label : '1'
		}, {
			value : '2',
			label : '2'
		}, {
			value : '3',
			label : '3'
		}, {
			value : '4',
			label : '4'
		}, {
			value : '5',
			label : '5'
		} ];

		// Highlight header when a filter is selected (change to include
		// overall?)
		$scope.highlightFilteredHeader = function(row, rowRenderIndex, col) {
			if (col.filters[0].term == undefined) {
				return 'header-default';
			} else if (col.filters[0].term < 3) {
				return 'header-filtered-bad';
			} else if (col.filters[0].term == 3) {
				return 'header-filtered-ok';
			} else if (col.filters[0].term > 3) {
				return 'header-filtered-awesome';
			}
		};

		// Highlight head for Overall header so it stands out
		$scope.highlightOverallFilteredHeader = function(row, rowRenderIndex, col) {
			if (col.filters[0].term == undefined) {
				return '';
			} else if (col.filters[0].term < 3) {
				return 'header-filtered-bad';
			} else if (col.filters[0].term == 3) {
				return 'header-filtered-ok';
			} else if (col.filters[0].term > 3) {
				return 'header-filtered-awesome';
			}
		};

		// Highlight head for Account header so it stands out
		$scope.highlightAccountFilteredHeader = function(row, rowRenderIndex, col) {
			if (col.filters[0].term) {
				return 'header-blue';
			} else {
				return '';
			}
		};

		// Convert number of stars to array of stars
		$scope.getStars = function(grid, row, col) {
			var stars, status, x = 5;
			var numberStars = (Math.round(grid.getCellValue(row, col)) === 0) ? 1
					: Math.round(grid.getCellValue(row, col));

			status = (numberStars > 3) ? 'awesome' : 'bad';
			status = (numberStars === 3) ? 'ok' : status;
			stars = [];

			while (x-- > 0) {
				stars.push(x >= numberStars ? 'empty' : status);
			}
			return stars.reverse();
		}

		// Template for cells that will display stars
		starTemplate = '<div style="float: left;" ng-repeat="star in grid.appScope.getStars(grid, row, col, rowRenderIndex, colRenderIndex) track by $index">'
				+ '<svg ng-class="star" xmlns="http://www.w3.org/2000/svg" height="16" width="16" id="star">'
				+ '<polygon transform="translate(9, 9) scale(9)"'
				+ 'points="0,-1   0.224513988289792686220972575898763393789606,-0.309016994374947424102293417182819058860155  '
				+ '0.951056516295153572116439333379382143405699,-0.309016994374947424102293417182819058860155'
				+ '0.363271264002680442947733378740309374808046,0.118033988749894848204586834365638117720309'
				+ '0.587785252292473129168705954639072768597652,0.809016994374947424102293417182819058860155  '
				+ '0,0.381966011250105151795413165634361882279691  -0.587785252292473129168705954639072768597652,'
				+ '0.809016994374947424102293417182819058860155  -0.363271264002680442947733378740309374808046,'
				+ '0.118033988749894848204586834365638117720309  -0.951056516295153572116439333379382143405699,'
				+ '-0.309016994374947424102293417182819058860155  -0.224513988289792686220972575898763393789606,'
				+ '-0.309016994374947424102293417182819058860155"></polygon></svg></div>';

		// Used for custom drop down *not used right now*
		var headerFilterTemplate = '<div class="ui-grid-filter-containter" '
				+ 'ng-repeat="colFilter in col.filters"><div my-custom-dropdown></div></div>';

		// Use with cell Template on grouped header cells:
		var hideGroupCellInformation = '<div ng-if="!col.grouping || col.grouping.groupPriority === '
				+ 'undefined || col.grouping.groupPriority === null || ( row.groupHeader && '
				+ 'col.grouping.groupPriority === row.treeLevel )" class="ui-grid-cell-contents" '
				+ 'title="TOOLTIP">{{COL_FIELD CUSTOM_FILTERS}}</div>';

		// Options for grid
		$scope.gridOptions = {

			saveWidths: true,
			saveOrder: true,
			saveVisible: true,
			saveSort: true,
			saveFilter: true,
			savePinning: true,
			saveGrouping: true,
			saveGroupingExpandedStates: true,
			saveTreeView: true,
			saveSelection: true,
			flatEntityAccess : true,
			enableGridMenu : true,
			enableFiltering : true,
			exporterMenuPdf : false,
			//paginationPageSizes : [ 25, 50, 75, 100 ],
		//	paginationPageSize : 25,

			columnDefs : [ 
				{
					field : 'division_name',
					displayName : 'Division',
					width : '10%',
					pinnedLeft : true,
					visible : true,
					state : 'collapsed',
					numExpanded : 0,
					headerCellClass : $scope.highlightAccountFilteredHeader,
					cellTemplate : hideGroupCellInformation,
					grouping : {
						groupPriority : 0
					},
					sort : {
						priority : 0,
						direction : 'asc'
					},
					groupingShowAggregationMenu: false
				}, {
				field : 'region_name',
				displayName : 'Region',
				width : '10%',
				pinnedLeft : true,
				visible : true,
				numExpanded : 0,
				headerCellClass : $scope.highlightAccountFilteredHeader,
				cellTemplate : hideGroupCellInformation,
				grouping : {
					groupPriority : 1
				},
				sort : {
					priority : 1,
					direction : 'asc'
				},
				groupingShowAggregationMenu: false
			}, {
				field : 'district_name',
				displayName : 'District',
				width : '10%',
				pinnedLeft : true,
				visible : true,
				state : 'collapsed',
				numExpanded : 0,
				headerCellClass : $scope.highlightAccountFilteredHeader,
				cellTemplate : hideGroupCellInformation,
				grouping : {
					groupPriority : 2
				},
				sort : {
					priority : 2,
					direction : 'asc'
				},
				groupingShowAggregationMenu: false
			}, {
				field : 'account_owner',
				displayName : 'Owner Name',
				width : '10%',
				pinnedLeft : true,
				visible : true,
				state : 'collapsed',
				numExpanded : 0,
				headerCellClass : $scope.highlightAccountFilteredHeader,
				cellTemplate : hideGroupCellInformation,
				grouping : {
					groupPriority : 3
				},
				sort : {
					priority : 3,
					direction : 'asc'
				},
				groupingShowAggregationMenu: false
			}, {
				field : 'account_name',
				displayName : 'Account Name',
				width : '10%',
				pinnedLeft : true,
				visible : true,
				headerCellClass : $scope.highlightAccountFilteredHeader,
				groupingShowAggregationMenu: false
			}, {
				field : 'overall_rating',
				displayName : 'Overall Rating',
				width : '10%',
				pinnedLeft : true,
				visible : true,
				filter : {
					type : uiGridConstants.filter.SELECT,
					selectOptions : selOptions
				},
				headerCellClass : $scope.highlightOverallFilteredHeader,
				treeAggregationType : uiGridGroupingConstants.aggregation.AVG,
				customTreeAggregationFinalizerFn : finalizeAgg,
				cellTemplate : starTemplate,
				groupingShowAggregationMenu: false
			}, {
				field : 'product_rating',
				displayName : 'Product Rating',
				width : '10%',
				visible : true,
				filter : {
					type : uiGridConstants.filter.SELECT,
					selectOptions : selOptions
				},
				headerCellClass : $scope.highlightFilteredHeader,
				treeAggregationType : uiGridGroupingConstants.aggregation.AVG,
				customTreeAggregationFinalizerFn : finalizeAgg,
				cellTemplate : starTemplate,
				groupingShowAggregationMenu: false
			}, {
				field : 'services_rating',
				displayName : 'Services Rating',
				width : '10%',
				visible : true,
				filter : {
					type : uiGridConstants.filter.SELECT,
					selectOptions : selOptions
				},
				headerCellClass : $scope.highlightFilteredHeader,
				treeAggregationType : uiGridGroupingConstants.aggregation.AVG,
				customTreeAggregationFinalizerFn : finalizeAgg,
				cellTemplate : starTemplate,
				groupingShowAggregationMenu: false
			}, {
				field : 'premium_rating',
				displayName : 'Premium Rating',
				width : '10%',
				visible : true,
				filter : {
					type : uiGridConstants.filter.SELECT,
					selectOptions : selOptions
				},
				headerCellClass : $scope.highlightFilteredHeader,
				treeAggregationType : uiGridGroupingConstants.aggregation.AVG,
				customTreeAggregationFinalizerFn : finalizeAgg,
				cellTemplate : starTemplate,
				groupingShowAggregationMenu: false
			},{
				field : 'policies_rating',
				displayName : 'Policies Rating',
				width : '10%',
				visible : true,
				filter : {
					type : uiGridConstants.filter.SELECT,
					selectOptions : selOptions
				},
				headerCellClass : $scope.highlightFilteredHeader,
				treeAggregationType : uiGridGroupingConstants.aggregation.AVG,
				customTreeAggregationFinalizerFn : finalizeAgg,
				cellTemplate : starTemplate,
				groupingShowAggregationMenu: false
			}, {
				field : 'activity_rating',
				displayName : 'Activity Rating',
				width : '10%',
				visible : true,
				filter : {
					type : uiGridConstants.filter.SELECT,
					selectOptions : selOptions
				},
				headerCellClass : $scope.highlightFilteredHeader,
				treeAggregationType : uiGridGroupingConstants.aggregation.AVG,
				customTreeAggregationFinalizerFn : finalizeAgg,
				cellTemplate : starTemplate,
				groupingShowAggregationMenu: false
			}, {
				field : 'contacts_rating',
				displayName : 'Contacts Rating',
				width : '10%',
				visible : true,
				filter : {
					type : uiGridConstants.filter.SELECT,
					selectOptions : selOptions
				},
				headerCellClass : $scope.highlightFilteredHeader,
				treeAggregationType : uiGridGroupingConstants.aggregation.AVG,
				customTreeAggregationFinalizerFn : finalizeAgg,
				cellTemplate : starTemplate,
				groupingShowAggregationMenu: false
			}, {
				field : 'risk_potential_rating',
				displayName : 'Risk potential',
				width : '10%',
				visible : true,
				filter : {
					type : uiGridConstants.filter.SELECT,
					selectOptions : selOptions
				},
				headerCellClass : $scope.highlightFilteredHeader,
				treeAggregationType : uiGridGroupingConstants.aggregation.AVG,
				customTreeAggregationFinalizerFn : finalizeAgg,
				cellTemplate : starTemplate,
				groupingShowAggregationMenu: false
			}, {
				field : 'working_conditions_rating',
				displayName : 'Working Conditions',
				width : '12%',
				visible : true,
				filter : {
					type : uiGridConstants.filter.SELECT,
					selectOptions : selOptions
				},
				headerCellClass : $scope.highlightFilteredHeader,
				treeAggregationType : uiGridGroupingConstants.aggregation.AVG,
				customTreeAggregationFinalizerFn : finalizeAgg,
				cellTemplate : starTemplate,
				groupingShowAggregationMenu: false
			} ],
			onRegisterApi: function(gridApi) {
				$scope.gridApi = gridApi;
			}
		};

		$scope.saveState = function() {
			localStorage.setItem("gridSettings", JSON.stringify($scope.gridApi.saveState.save()));
		}

		$scope.restoreState = function() {
			var state = localStorage.getItem("gridSettings");
			$scope.gridApi.saveState.restore($scope, JSON.parse(state));
		}	

		accountData = [];
		skipAmt = 0;		
		$scope.totalAccts = 0;

		//		Take the usersRoleId, pull all childrenRoleIds, pass the ids to the Ext to get the user Ids,
		//			pass the user Ids to Ext again to get the star values, parse the star string and create an array of data,
		//			set the grid to the newly made star data from the array that was just created
		roles(currentRoleId).then(function(roleList) {
			var childRoles = r.filter(function (role) {
				return role.name.includes('District Manager') ||
					role.name.includes('Account Manager');
			}, roleList.children).map(r.prop('id'));

			users(childRoles).then(function (data){
				userIds = r.map(r.prop('id'), data.all);
				accountAssessmentDetailsExt.getStarsFromUsers(userIds, skipAmt, null, function(dat) {
					setGridInfo($q, dat, accountAssessmentDetailsExt, userIds, offId,$scope)
						.then(function(da){
						//	console.log(da);
							
							da.forEach(function(element, idx, array){
								//console.log(element);
								if(idx !== array.length){
									var infoSplit = element.split('ϟ');
									
									accountData.push(
										{
											'division_name':				infoSplit[2],
											'region_name' :					infoSplit[0],
											'district_name' :				infoSplit[1],											
											'account_owner' :				infoSplit[3],
											'account_name' :				infoSplit[4],
											'overall_rating' :				infoSplit[5],
											'product_rating' :				infoSplit[6],
											'services_rating' :				infoSplit[7],
											'premium_rating' :				infoSplit[8],
											'policies_rating':				infoSplit[9],
											'activity_rating' :				infoSplit[10],
											'contacts_rating' :				infoSplit[11],
											'risk_potential_rating' :		infoSplit[12],
											'working_conditions_rating' :	infoSplit[13],
										})
								}
							});
							$scope.gridOptions.data = accountData;
						})
						.finally(function() { $scope.loading = false; $scope.totalAccts = skipAmt;})
					})
				});
		});
		
		
	}

	//	Used to keep the data getting pulled from Ext semi-synchronous
	/*function setGridInfo($q, data){

		return $q(function(resolve, reject) {
			var parse = function(data) {
				resolve(data);
			}
			parse(data);
		});
	}*/
	function setGridInfo($q, data, accountAssessmentDetailsExt, userIds, offId,$scope){
		var rtnData = [];
		var oldIds = [];
		var endIndex = -1;
		return $q(function(resolve, reject) {			
			var parse = function(data) {	
				
					var accountSplit = data.split('\n');
					
					if(accountSplit.length < qLimit*2){
						accountSplit.forEach(function(element, idx, array){
							if(element.indexOf('ϟ') > -1){
								endIndex++;
							}
						});
						oldIds = oldIds.concat(accountSplit.splice(endIndex+1, accountSplit.length));
					}else{					
						oldIds = oldIds.concat(accountSplit.splice(qLimit, accountSplit.length));
					}
					
					oldIds.splice(oldIds.length-1, 1);
					
					//console.log(oldIds);
					//console.log(accountSplit);					
					
					rtnData = rtnData.concat(accountSplit);
					skipAmt = rtnData.length;
					
					$scope.totalAccts = skipAmt;
					document.getElementById("loaded_text").innerHTML = "Loaded: " + skipAmt;
					
					//console.log(accountSplit.length + " " + qLimit + " " + skipAmt);
					
					if(accountSplit.length === qLimit) {						
						return accountAssessmentDetailsExt.getStarsFromUsers(userIds, skipAmt, oldIds, function(dat){parse(dat)});
					}
					resolve(rtnData);				 
			}
			parse(data);
		});
	}

})();