var echart = (function (echart, $, ko) {
    var componentModels = echart.componentModels = echart.componentModels || {};
        
    var grid = echart.grid = echart.grid || {};
    
    componentModels.SimpleGridViewModel = function (params,columns,dataRows) {
        var self = this;

        var lastDataChangeRefresh = false;
          
        self.dataSelectColumn = params.dataSelectColumn ? params.dataSelectColumn : "IsSelected";
        self.dataSelectable = (params.dataSelectable !== undefined) ? params.dataSelectable : false;
        self.dataRows = dataRows;
        if (self.dataSelectable) ko.utils.arrayForEach(self.dataRows(), function (row) {
            row[self.dataSelectColumn] = row[self.dataSelectColumn] ? ko.observable(row[self.dataSelectColumn]) : ko.observable(false);
        });



        self.selectAll = ko.computed({
            read: function () {
                if (!self.dataSelectable) return false;
                if (self.dataRows().length == 0) return false;

                var selectableData = (self.showPager) ? self.dataRows.pageItems() : self.dataRows();

                var firstUnchecked = ko.utils.arrayFirst(selectableData, function (item) {
                        return item[self.dataSelectColumn]() == false;
                });
                return firstUnchecked == null;
            },
            write: function (value) {
                if (!self.dataSelectable) return;

                var selectableData = (self.showPager) ? self.dataRows.pageItems() : self.dataRows();

                ko.utils.arrayForEach(selectableData, function (item) {
                    item[self.dataSelectColumn](value);
                });
            }
        });

        self.pageSize = params.pageSize ? params.pageSize : 10;

        if (params.showPager === true) {
            self.dataRows.extend({ paged: { pageSize: self.pageSize, pageGenerator: 'sliding' } });
        }


        self.dataRows.subscribe(function (oldDataRows) {
            // go to the first page (if paging on) unless the last data change was a refresh and we don't want to go the first page on refresh
            if (self.dataRows.toFirstPage && (self.firstPageOnRefresh || !lastDataChangeRefresh)) self.dataRows.toFirstPage();
            lastDataChangeRefresh = false;
        });

        self.columns = columns;
                
        self.noDataMessage = params.noDataMessage ? params.noDataMessage : "No data found";

        self.showPager = params.showPager ? params.showPager : false;

        self.firstPageOnRefresh = (params.firstPageOnRefresh !== undefined) ? params.firstPageOnRefresh : true;
                
        self.addEventHandler = params.addEvent ? params.addEvent : function () { }

        self.removeEventHandler = params.removeEvent ? params.removeEvent : function () { }

        self.editEventHandler = params.editEvent ? params.editEvent : function () { }

        self.moveUpEventHandler = params.moveUpEvent ? params.moveUpEvent : function () { }

        self.moveDownEventHandler = params.moveDownEvent ? params.moveDownEvent : function () { }

        self.linkbuttonEventHandler = params.linkbuttonEvent ? params.linkbuttonEvent : function () { }

        self.addEnabledHandler = params.addEnabled ? params.addEnabled : function (data) { return true; }

        self.removeEnabledHandler = params.removeEnabled ? params.removeEnabled : function (data) {return true; }

        self.editEnabledHandler = params.editEnabled ? params.editEnabled : function (data) { return true; }

        self.moveUpEnabledHandler = params.moveUpEnabled ? params.moveUpEnabled : function (data) { return true; }

        self.moveDownEnabledHandler = params.moveDownEnabled ? params.moveDownEnabled : function (data) { return true; }
                                           
        self.moveUpEnabled = function (data) { return  self.moveUpEnabledHandler(data);  };

        self.moveDownEnabled = function (data) { return self.moveDownEnabledHandler(data);  };

        self.addEnabled = function (data) { return  self.addEnabledHandler(data); };

        self.removeEnabled = function (data) { return  self.removeEnabledHandler(data);  };

        self.editEnabled = function (data) { return self.editEnabledHandler(data); };
                
        self.addEvent = function (data) { if (self.addEnabled(data) == true) return function () { self.addEventHandler(data); }; return function () { } };

        self.removeEvent = function (data) { if (self.removeEnabled(data) == true) return function () { self.removeEventHandler(data); };return function () { } };

        self.editEvent = function (data) {  return function () { self.editEventHandler(data); }; };

        self.upEvent = function (data,e) { if (self.moveUpEnabled(data) == true) return function () { self.moveUpEventHandler(data,e); }; return function () { } };

        self.downEvent = function (data,e) { if (self.moveDownEnabled(data) == true) return function () { self.moveDownEventHandler(data,e); }; return function () { } };

        self.linkbuttonEvent = function (data) { return function () { self.linkbuttonEventHandler(data); } };


        self.loadCallbacks = params.loadCallbacks ? params.loadCallbacks : function (data) { return true; }

        self.findRefreshIndex = params.findRefreshIndex ? params.findRefreshIndex : function (row, data) { return -1; }


        self.columnActionStyles = {
            edit: "glyphicon glyphicon-pencil chart-designer-color", editDisabled: "glyphicon  glyphicon-info-sign chart-designer-color",
            moveUp: "glyphicon glyphicon-arrow-up chart-designer-color", moveUpDisabled: "glyphicon glyphicon-arrow-up chart-designer-table-disabled",
            moveDown: "glyphicon glyphicon-arrow-down chart-designer-color", moveDownDisabled: "glyphicon glyphicon-arrow-down chart-designer-table-disabled",
            remove: "fa fa-trash-o chart-designer-color", removeDisabled: "fa fa-trash-o chart-designer-table-disabled",
            add: "glyphicon glyphicon-plus-sign chart-designer-color", addDisabled: "glyphicon glyphicon-plus-sign chart-designer-table-disabled"
        }

        self.editCSS=function(data)
        {   return (self.editEnabled(data) === true) ? self.columnActionStyles.edit : self.columnActionStyles.editDisabled;           
        }

        self.moveUpCSS =  function (index) {
            return (index() != 0) ? self.columnActionStyles.moveUp : self.columnActionStyles.moveUpDisabled;          
        };

        self.moveDownCSS = function (index) {
            return (index() == (self.dataRows().length - 1)) ? self.columnActionStyles.moveDownDisabled : self.columnActionStyles.moveDown;         
        };

        self.removeCSS = function (data) {
            return (self.removeEnabled(data) === true) ? self.columnActionStyles.remove : self.columnActionStyles.removeDisabled;
        }

        self.addCSS = function (data) {
            return (self.addEnabled(data) === true) ? self.columnActionStyles.add : self.columnActionStyles.addDisabled;
        }
               
        $.each(self.columns, function (i, column) {
            if (column.defaultSortColumn == true) {
                self.defaultSortColumn = column;
                return;
            }
        });

        if (!self.defaultSortColumn) {
            $.each(self.columns, function (i, column) {
                if (column.sortable === true) {
                    self.defaultSortColumn = column;
                    return;
                }
            });            
        }             
        

        self.selectedColumn = ko.observable(self.defaultSortColumn);

        self.sortDirection = ko.observable(0);

        self.columnSortStyles = {
            alphaAsc: 'glyphicon glyphicon glyphicon-sort-by-alphabet', alphaDesc: 'glyphicon glyphicon glyphicon-sort-by-alphabet-alt',            
            numericAsc: 'glyphicon glyphicon glyphicon-sort', numericDesc: 'glyphicon glyphicon glyphicon-sort-alt'
        };

        self.selectionStyle = function (column) {
            return ko.computed(function () {
                var selectedColumn = self.selectedColumn()

                if (column == selectedColumn) {

                    if (column.sortType == "Alpha") {

                        return self.sortDirection() == 0 ? self.columnSortStyles.alphaAsc : self.columnSortStyles.alphaDesc;
                    }                   
                    if (column.sortType == "Numeric") {
                        return self.sortDirection() == 0 ? self.columnSortStyles.numericAsc : self.columnSortStyles.numericDesc;
                    }
                }

                return "";
            });
        },
        self.columnHeaderClicked = function (column) {
            return function () {
                // If they clicked on the current sort column, toggle the sorting in the opposite direction.
                //  Otherwise, set the sort column to the new column and set sort direction to ascending.
                if (column == self.selectedColumn())
                    self.sortDirection(self.sortDirection() == 1 ? 0 : 1);
                else {
                    self.selectedColumn(column);
                    self.sortDirection(column.defaultsortDirection);
                }

                self.rebindData(
                        function (left, right) {
                            var leftVal, rightVal, defaultLeftVal, defaultRightVal;
                            if (column.sortType == "Alpha") {
                                leftVal = left[column.name]?left[column.name].toUpperCase():'';
                                rightVal = right[column.name]?right[column.name].toUpperCase():'';
                            }
                            else {
                                leftVal = left[column.name];
                                rightVal = right[column.name];
                            }
                            if (self.defaultSortColumn.sortType == "Alpha") {
                                defaultLeftVal = left[self.defaultSortColumn.name]?left[self.defaultSortColumn.name].toUpperCase():'';
                                defaultRightVal = right[self.defaultSortColumn.name]?right[self.defaultSortColumn.name].toUpperCase():'';
                            }
                            else {
                                defaultLeftVal = left[self.defaultSortColumn.name];
                                defaultRightVal = right[self.defaultSortColumn.name];
                            }
                            return leftVal == rightVal ? (defaultLeftVal < defaultRightVal ? -1 : 1)
                                : leftVal < rightVal ? -1 : 1;
                        });
            }
        },
         self.rebindData = function (sortfunc) {
             if (self.sortDirection() == 0) {
                 self.dataRows.sort(sortfunc);
             }
             else {
                 self.dataRows.sort(sortfunc).reverse();
             }
         }

        self.topIndex = function () {
            return (!self.showPager || self.firstPageOnRefresh) ? 0 : (dataRows.pageNumber() - 1) * self.pageSize;
        }

        self.getSelectedRows = function ()
        {
            if (!self.dataSelectable) return [];

            //var selectableData = (self.showPager) ? self.dataRows.pageItems() : self.dataRows();  // actions for all checked or all checked on page?
            var selectableData = self.dataRows();

            return ko.utils.arrayFilter(selectableData, function (row) { return row[self.dataSelectColumn](); });
        }

        self.refreshAddToTop = function (newRow) {
            lastDataChangeRefresh = true;

            var insertIdx = self.topIndex();
            if (insertIdx == 0) {
                dataRows.unshift(newRow);
            }
            else {
                dataRows().splice(insertIdx, 0, newRow);
                dataRows.valueHasMutated();
            }

        };

        // not yet implemented, currently can remove old row, then add modified row to top
        self.refreshUpdateRow = function (oldRow, newRow) {
            lastDataChangeRefresh = true;

        };


        self.refreshDeleteRow = function (oldRow) {
            lastDataChangeRefresh = true;

            var oldIdx = self.findRefreshIndex(oldRow, dataRows());
            if (oldIdx > -1)  dataRows.splice(oldIdx, 1);    
        };


        self.callbackFunctions = {
            addToTop: self.refreshAddToTop
            , updateRow: self.refreshUpdateRow
            , deleteRow: self.refreshDeleteRow
            , getSelectedRows: self.getSelectedRows
        }

        // callback (once loaded) to set obtain grid refresh functions
        self.loadCallbacks(self.callbackFunctions);

    };

    ko.components.register("simple-grid", {
        viewModel: {
            createViewModel: function (params, componentInfo) {
                var e = componentInfo.element,
                    $e = $(e);

                var columns = [];

                var ctx = ko.contextFor(e);

                var dataRows = ctx.$root[params.dataSource];
                             
                                      
                $.each(componentInfo.templateNodes, function (i, element) {
                    if (element.localName === 'simple-grid-column') {
                        columns.push({
                            name: $(element).attr('name'),
                            header: $(element).attr('header'),
                            sortable:$(element).attr('sortable')?($(element).attr('sortable')=='true'?true:false):false,
                            sortType: $(element).attr('sortType') ? $(element).attr('sortType') : "Numeric",
                            type: $(element).attr('type'),
                            controlEnabled: $(element).attr('controlEnabled'),
                            hasSubItems: $(element).attr('hasSubItems'),
                            subItemName: $(element).attr('subItemName'),
                            subItemField: $(element).attr('subItemField'),
                            source: ctx.$root[$(element).attr('source')],
                            caption: $(element).attr('caption'),
                            defaultSortColumn: $(element).attr('defaultSortColumn')?($(element).attr('defaultSortColumn')=='true'?true:false):false
                        });
                    }
                   
                });             

                return new componentModels.SimpleGridViewModel(params,columns,dataRows);
            }
        },
        template: { element: 'simple-grid-template' }
    });

    return echart;
})(echart || {}, jQuery, ko)

