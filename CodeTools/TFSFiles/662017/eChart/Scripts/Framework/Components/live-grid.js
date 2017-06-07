var le = (function (le, $, ko, S, ksm) {
    var componentModels = le.componentModels = le.componentModels || {};

    // Namespace for all things Grid
    var grid = le.grid = le.grid || {};

    // if crud proc stuffs hsta in as the CreateBy user, then anyone can edit the row. a foodfight row
    var ownRow = function (row, userID) {
        return row.Status() === "A" && (row.CreateBy().toLowerCase().trim() === "hsta" || row.CreateBy().toLowerCase().trim() === userID);
    }

    /*********************************************************************************/
    /* To override the default grid behavior, you will need to create an object that */
    /*  implements the same interface as grid.DefaultBehavior.  The methods are:     */
    /*                                                                               */
    /*  isEditable: takes a single RowModel as a parameter, and returns whether the  */
    /*              row can be edited. Will show the pencil if true, the info icon   */
    /*              if false.                                                        */
    /*                                                                               */
    /*  isCloneable: takes a single RowModel as a parameter, and returns whether     */
    /*               the row can be cloned.  Shows the clone menu item if true,      */
    /*               hides it if false.                                              */
    /*                                                                               */
    /*  isDeleteable: takes a single RowModel as a parameter, and returns whether    */
    /*                the row can be deleted.  Shows the delete menu if true, hides  */
    /*                it if false.                                                   */
    /*                                                                               */
    /*  isStrikeable:  takes a single RowModel as a parameter, and returns whether   */
    /*                 the row can be struck through. Shows the strikethrough menu   */
    /*                 if true, hides it if false.                                   */
    /*                                                                               */
    /*  isShowMoreEnabled: Returns true if the show more feature is enabled, false   */
    /*                     if not.                                                   */
    /*                                                                               */
    /*  isEllipVisible: Returns true if the grid should show the ellip column, false */
    /*                  if not.                                                      */
    /*                                                                               */
    /*  isAddEnabled: Returns true if the add button is enabled, false if not.       */
    /*                                                                               */
    /*  isAddVisible: Returns true if the add button should be visible, false if not.*/
    /*                                                                               */
    /*********************************************************************************/

    grid.DefaultBehavior = function () {
        var self = this;

        self.itemsShown = 10;

        self.selectedRows = ko.observableArray();

        // Enabling
        self.isAddEnabled = le.util.alwaysTrue;

        self.isStrikethroughEnabled = ko.computed(function () {
            var rows = self.selectedRows();

            for (var i = 0; i < rows.length; i++) {
                if (self.isStrikeable(rows[i]) == true)
                    return true;
            }

            return false;
        });

        self.isDeleteEnabled = ko.computed(function () {
            var rows = self.selectedRows();

            for (var i = 0; i < rows.length; i++) {
                if (self.isDeleteable(rows[i]) == true)
                    return true;
            }

            return false;
        });

        self.isCloneEnabled = ko.computed(function () {
            if (self.selectedRows().length != 1)
                return false;

            return self.isCloneable(self.selectedRows()[0]);
        });

        // Per-row evaluators
        self.isEditable = function (row) {
            return ownRow(row, le.session.getUserName());
        }

        self.isCloneable = function (row) {
            var cloneableFields = le.UIDictionary.getCloneableFields(row.module.designID, row.module.version, row.tableName);

            return cloneableFields != null && cloneableFields.length > 0;
        }

        self.isDeleteable = function (row) {
            return ownRow(row, le.session.getUserName()) && row.Status() == 'A';
        }

        self.isStrikeable = function (row) {
            return !ownRow(row, le.session.getUserName()) && row.Status() == 'A';
        }

        self.isLocked = function () {
         return    le.util.alwaysFalse();
        }

        // Visibility
        self.isShowMoreEnabled = le.util.alwaysTrue;

        self.isToolbarVisible = le.util.alwaysTrue;

        self.isSelectionVisible = le.util.alwaysTrue;

        self.isAddVisible = le.util.alwaysTrue;

        self.isDeleteVisible = le.util.alwaysTrue;

        self.isActionIconColumnVisible = le.util.alwaysTrue;
    }

    /*********************************************************************************/
    /*  Food fight mode is when anyone can edit anyone else's row. This pops up in   */    
    /*   several blocks, so we include it here as a standard feature.                */
    /*********************************************************************************/

    grid.FoodFightBehavior = function () {
        var self = this;

        // Call parent constructor
        grid.DefaultBehavior.call(this);

        self.isEditable = le.util.alwaysTrue;

        self.isStrikeable = le.util.alwaysFalse;

        self.isDeleteable = le.util.alwaysTrue;
    };

    componentModels.GridViewModel = function (params, module, flyoutNodes, columns, e) {
        var self = this;        
        
        self.table = module.Tables[params.table];

        self.dataCSS = params.dataCSS ? params.dataCSS : function (fieldName, row) { return ""; }

        var behavior = params.behavior ? params.behavior : new grid.DefaultBehavior();


        // TODO: Make this consistent through component.
        self.tableName = params.table;

        self.externalClick = params.externalClick;

        var designID = self.table.module.designID;

        var version = self.table.module.version;

        var parentContext = le.util.contextFor(e);        

        var moduleConfig = le.factories.ModuleTemplateFactory.getTemplate(designID, version).config;

        var defaultsCallback = moduleConfig.tables[self.tableName] ?
            (moduleConfig.tables[self.tableName].defaults ? moduleConfig.tables[self.tableName].defaults : null)
            : null;                

        self.emptyMessage = params.emptyMessage || "No results";
        
        var fieldSet = le.session.getFieldSetKey(module.moduleTemplateKey, params.fieldSet);

        if (fieldSet == null)
            throw "Field set " + params.fieldSet + " not found in module " + module.designID + ".  Check your UI Dictionary entry";

        self.fieldSetKey = fieldSet;

        self.title = params.title || params.fieldSet;

        self.flyoutNodes = flyoutNodes;
         
        self.columns = columns;

        var _tableName = params.table;

        self.chartAcneVisible = ko.observable(false);

        var settingMasterCheck = false;

        self.masterCheck = ko.observable(false);

        self.masterCheckEnabled = ko.computed(function () {
            return self.table.Rows().length > 0;
        });

        self.clearCheck = function () {
            settingMasterCheck = true;

            self.masterCheck(false);

            settingMasterCheck = false;
        }

        behavior.selectedRows.subscribe(function (val) {
            settingMasterCheck = true;

            if (val.length == self.table.Rows().length) {
                self.masterCheck(true);
            }
            else {
                self.masterCheck(false);
            }

            settingMasterCheck = false;
        })

        self.masterCheck.subscribe(function (newValue) {
            if (settingMasterCheck == true)
                return;

            if (newValue == false)
                behavior.selectedRows.removeAll();
            else {
                var rows = self.table.Rows();

                for (var i = 0; i < rows.length; i++)
                    behavior.selectedRows.push(rows[i]);
            }
        });

        self.selectedRows = behavior.selectedRows;

        // Indicates to sub components that they are inside a flyout.
        self.flyout = true;

        // External flyoutID is used for the data binding. _flyoutID is used to feed jQuery.
        self.flyoutID = le.util.generateUniqueID();

        var _flyoutID = "#" + self.flyoutID;

        // Same for the scrollable area in the flyout
        self.flyoutScrollID = le.util.generateUniqueID();

        var resetFlyoutScrollPosition = function () {
            $("#" + self.flyoutScrollID).scrollTop(0);
        }

        // Guard functions for state machine
        var isFirstInGrid = function (row) {
            if (self.table.Rows().length == 0)
                return false;

            var first = self.table.Rows()[0];

            return first === row;
        };

        var isLastInGrid = function (row) {
            if (self.table.Rows().length == 0)
                return false;

            var last = self.table.Rows()[self.table.Rows().length - 1];

            return last === row;
        };

        var isEditable = function (row) {
            return behavior.isEditable(row);
        };

        var isReadOnly = function (row) {
            return !isEditable(row);
        };

        var isGridEmpty = function () {
            return self.table.Rows().length == 0;
        };

        var gridHasRows = function () {
            return self.table.Rows().length > 0;
        }

        var sm = new ksm.StateMachine();

        self.selectedRow = ko.observable(null);        

        self.flyoutVisible = sm.inState("viewing", "editing", "viewingReadOnly", "cloning", "adding", "postingAddThenNew");

        self.flyoutVisible.subscribe(function (state) {
            if (state == true)
                setTimeout(resetFlyoutScrollPosition, 1000);
        });

        // The shadow row is used to buffer adds and edits without affecting the underlying row.
        //  This saves us from some hairy undo logic.
        self.shadowRow = le.factories.RowModelFactory.blankRow(_tableName, module);

        var cfg = le.factories.ModuleTemplateFactory.getTemplate(module.designID, module.version).config;

        var $context = le.util.contextFor(e);

        var complete = le.util.byString(cfg, "tables." + _tableName + ".complete");

        if (!complete)
            complete = le.util.alwaysTrue;

        var enableHandler = ko.pureComputed(function () {
            self.flyoutVisible();

            // State may not be initialized yet when this is invoked.
            var state = self.state ? self.state() : null;

            if (state === "editing" || state === "cloning" || state === "adding")
                return true;

            if (self.selectedRow() != null && behavior.isEditable(self.selectedRow()))
                return true;

            return false;
        });

        
        self.context = new le.models.ControlContext(module.designID, module.version, self.shadowRow, complete, new le.models.FlyoutUpdateStrategy(parentContext), enableHandler);        

        var $error = self.context;

        var _navigating = false;

        var isChangeableState = sm.inState("editing", "cloning", "adding", "viewing", "viewingReadOnly");

        $.each(self.shadowRow, function (name, value) {
            if (ko.isObservable(value)) {
                value.subscribe(function () {
                    if (_navigating)
                        return;

                    if (isChangeableState()==true)
                        self.event.dataChanged();
                });
            }
        });

        var _setShadowRow = function (row, copyDirtyFlags) {
            _navigating = true;

            for (var key in self.shadowRow.columns) {
                var shadowCol = self.shadowRow.columns[key];
                var sourceCol = row.columns[key];

                shadowCol(sourceCol());

                if (copyDirtyFlags)
                    shadowCol.isDirty(sourceCol.isDirty());
            }

            if (!copyDirtyFlags) {
                self.shadowRow.clearDirtyFlags()
            }

            _navigating = false;
        };

        // Namespace containers for event & transition
        self.event = {};
        self.transition = {};

        if (self.externalClick)
        self.externalClick.subscribe(function () { self.event.addNewClicked(); });

        // State change handlers
        self.transition.enterPostingDelete = function (rows) {
            le.ajax.postRowDelete(rows, self.fieldSetKey, self.event.deletePosted, self.event.deleteError, $context.isComplete());
        };

        var _strikethroughSuccess = function () {
            sm.raise("strikethroughPosted");
        };

        self.transition.enterConfirmingDelete = function (rows) {
            var _ok = function () {
                self.event.confirmDeleteClicked(rows);
            }

            //self.selectedRow(row);

            var msg = rows.length > 1 ? "Are you sure you want to delete the selected rows?" : "Are you sure you want to delete the selected row?";

            le.dialogs.okCancel(msg, _ok, self.event.cancelDeleteClicked);
        };

        self.transition.enterConfirmingStrikethrough = function (rows) {
            var _ok = function (message) {
                self.event.confirmStrikethroughClicked(rows, message);
            }

            // TODO: Why did I do this??
            //self.selectedRow(row);

            le.dialogs.strikethrough(_ok, self.event.cancelStrikethroughClicked);
        };

        self.transition.enterPostingStrikethrough = function (rows, message) {
            le.ajax.postRowStrikethrough(rows, message, self.fieldSetKey, self.event.strikethroughPosted, self.event.strikethroughError, $context.isComplete());
        };

        self.transition.enterNotifyingError = function (message) {
            var _ok = function () {
                self.event.notifyErrorOkClicked();
            };

            le.dialogs.notifyError(message.responseText, _ok);
        };

        self.transition.enterPostingUpdate = function (row) {
            var success = function () {
                self.event.updatePosted()
                _navigating = false;
            };

            _navigating = true;

            self.context.postRowUpdate(row, self.fieldSetKey, success, self.event.updatePostError);
        };

        self.transition.enterPostingAdd = function (row) {
            var success = function () {
                self.event.addPosted();
                _navigating = false;
            };

            _navigating = true;

            self.context.postRowAdd(row, self.fieldSetKey, success, self.event.addPostError);
        };

        self.transition.enterAdding = function () {
            var newRow = self.table.blankRow();            
           
            _setShadowRow(newRow);

            self.context.clearFieldLog();

            if (defaultsCallback != null) {
                le.dependencyDetection.begin();

                defaultsCallback.call(module, self.shadowRow, module);

                var touchedFields = le.dependencyDetection.end();

                for (var i = 0; i < touchedFields.length; i++) {
                    var defaultField = le.UIDictionary.getDefaultUIDictionaryKey(designID, version, touchedFields[i].dbDictionaryKey);

                    self.context.postFieldUpdate(defaultField, touchedFields[i], le.util.doNothing, le.util.doNothing);
                }
            }
        };

        self.transition.enterCloning = function (row) {
            var newRow = self.table.blankRow();            

            self.context.clearFieldLog();

            var cloneableFields = le.UIDictionary.getCloneableFields(module.designID, module.version, _tableName);

            var cloneableFieldsFromNonPrimaryTable = [];
            
            le.dependencyDetection.begin();

            if (defaultsCallback != null)
                defaultsCallback.call(module, newRow, module);

            for (var i = 0; i < cloneableFields.length; i++) {
                //if the cloneable field is not from primary table, we cannot set it to newRow here(between le.dependencyDetection.begin and end) 
                //because it'll be put in touchedFields and post to server(we can't post field being not from primary table)
                if (row[cloneableFields[i]].isFromPrimaryTable)
                    newRow[cloneableFields[i]](row[cloneableFields[i]]());
                else
                    cloneableFieldsFromNonPrimaryTable.push(cloneableFields[i]);
            }

            var touchedFields = le.dependencyDetection.end();

            for (var i = 0; i < cloneableFieldsFromNonPrimaryTable.length; i++) {
                newRow[cloneableFieldsFromNonPrimaryTable[i]](row[cloneableFieldsFromNonPrimaryTable[i]]());
            }

            _setShadowRow(newRow);

            for (var i = 0; i < touchedFields.length; i++) {
                var defaultField = le.UIDictionary.getDefaultUIDictionaryKey(designID, version, touchedFields[i].dbDictionaryKey);

                self.context.postFieldUpdate(defaultField, touchedFields[i], le.util.doNothing, le.util.doNothing);
            }            
        };

        self.transition.enterFlyout = function (row) {
            self.selectedRow(row);

            _setShadowRow(row);

            self.context.clearFieldLog();
        };

        self.transition.enterNoneSelected = function () {
            self.selectedRow(null);
        };        

        // State transitions
        sm.Initial().on("loaded").to("noneSelected")
                    .on("loadedNone").to("empty");

        sm.State("empty").on("addNewClicked").to("adding")
                         .on("firstRowAdded").to("noneSelected");

        sm.State("adding").on("dataChanged").toSelf()
                          .on("saveAndExitClicked").to("postingAdd")
                          .on("saveAndAddNewClicked").to("postingAddThenNew")
                          .on("cancelClicked").choice({ "noneSelected": gridHasRows, "empty": isGridEmpty })
                          .on("firstRowAdded").toSelf()
                          .enter(self.transition.enterAdding);

        sm.State("noneSelected").on("selected").choice({ "viewing": isEditable, "viewingReadOnly": isReadOnly })
                                .on("addNewClicked").to("adding")
                                .on("deleteClicked").to("confirmingDelete")
                                .on("strikethroughClicked").to("confirmingStrikethrough")
                                .on("cloneClicked").to("cloning")
                                .on("lastRowDeleted").to("empty")
                                .on("firstRowAdded").toSelf()
                                .enter(self.transition.enterNoneSelected);

        // TODO: Modify to include LiveEdit deletes of selected record
        sm.State("confirmingDelete").on("confirmDeleteClicked").to("postingDelete")
                                    .on("liveEditDeleteRow").to("selectedRowDeleted")
                                    .on("cancelDeleteClicked").choice({ "noneSelected": gridHasRows, "empty": isGridEmpty })
                                    .enter(self.transition.enterConfirmingDelete);

        sm.State("confirmingStrikethrough").on("confirmStrikethroughClicked").to("postingStrikethrough")
                                           .on("liveEditDeleteRow").to("selectedRowDeleted")
                                           .on("cancelStrikethroughClicked").choice({ "noneSelected": gridHasRows, "empty": isGridEmpty })
                                           .enter(self.transition.enterConfirmingStrikethrough);

        sm.State("selectedRowDeleted").on("acknowledgeDeleteClicked").choice({ "noneSelected": gridHasRows, "empty": isGridEmpty });

        sm.State("postingStrikethrough").on("strikethroughPosted").choice({ "noneSelected": gridHasRows, "empty": isGridEmpty })
                                        .on("strikethroughError").to("notifyingError")
                                        .enter(self.transition.enterPostingStrikethrough);

        sm.State("notifyingError").on("notifyErrorOkClicked").choice({ "noneSelected": gridHasRows, "empty": isGridEmpty })
                                  .enter(self.transition.enterNotifyingError);

        sm.State("viewing").on("dataChanged").to("editing")
                           .on("nextClicked").choice({ "viewing": isEditable, "viewingReadOnly": isReadOnly })
                           .on("prevClicked").choice({ "viewing": isEditable, "viewingReadOnly": isReadOnly })
                           .on("cancelClicked").choice({ "noneSelected": gridHasRows, "empty": isGridEmpty })
                           .enter(self.transition.enterFlyout);

        sm.State("viewingReadOnly").on("nextClicked").choice({ "viewing": isEditable, "viewingReadOnly": isReadOnly })
                                   .on("prevClicked").choice({ "viewing": isEditable, "viewingReadOnly": isReadOnly })
                                   .on("cancelClicked").choice({ "noneSelected": gridHasRows, "empty": isGridEmpty })
                                   .enter(self.transition.enterFlyout);

        sm.State("cloning").on("dataChanged").toSelf()
                           .on("saveAndExitClicked").to("postingAdd")
                           .on("saveAndAddNewClicked").to("postingAddThenNew")
                           .on("cancelClicked").choice({ "noneSelected": gridHasRows, "empty": isGridEmpty })
                           .enter(self.transition.enterCloning);

        sm.State("editing").on("dataChanged").toSelf()
                           .on("saveAndExitClicked").to("postingUpdate")
                           .on("saveAndAddNewClicked").to("postingUpdateThenNew")
                           .on("cancelClicked").choice({ "noneSelected": gridHasRows, "empty": isGridEmpty });

        sm.State("postingAdd").on("addPosted").via(self.clearCheck).choice({ "noneSelected": gridHasRows, "empty": isGridEmpty })
                              .on("addPostError").via(self.clearCheck).to("notifyingError")
                              .enter(self.transition.enterPostingAdd);

        sm.State("postingAddThenNew").on("addPosted").to("adding")
                                     .on("addPostError").to("notifyingError")
                                     .enter(self.transition.enterPostingAdd);

        sm.State("postingUpdate").on("updatePosted").to("noneSelected")
                                 .on("updatePostError").to("notifyingError")
                                 .enter(self.transition.enterPostingUpdate);

        sm.State("postingDelete").on("deletePosted").choice({ "noneSelected": gridHasRows, "empty": isGridEmpty })
                                 .on("deleteError").to("notifyingError")
                                 .enter(self.transition.enterPostingDelete);

        sm.start();

        self.state = sm.current;

        sm.createEventProxies(self.event);

        var _createSelectionEvent = function (eventName) {
            return function (row) {
                return function () {                    
                    sm.raise(eventName, row);
                }
            }
        };

        var oldLength = self.table.Rows().length;

        self.table.Rows.subscribe(function (rows) {
            if (oldLength == 0 && rows.length > 0)
                sm.raise("firstRowAdded");
            
            if (oldLength > 0 && rows.length == 0)
                sm.raise("lastRowDeleted");

            oldLength = rows.length;
        });

        self.table.Rows.subscribe(function (changes) {
            for (var i = 0; i < changes.length; i++) 
                if (changes[i].status == "deleted")
                    behavior.selectedRows.remove(changes[i].value);
        }, null, "arrayChange");

        self.event.selected = _createSelectionEvent("selected");                

        self.event.saveAndExitClicked = _createSelectionEvent("saveAndExitClicked");

        self.event.saveAndAddNewClicked = _createSelectionEvent("saveAndAddNewClicked");

        self.event.cloneClicked = function () {
            sm.raise("cloneClicked", behavior.selectedRows()[0]);
        };

        self.event.deleteClicked = function () {
            var targetRows = behavior.selectedRows().filter(function(row) {
                return behavior.isDeleteable(row);
            });

            if (targetRows.length > 0)
                sm.raise("deleteClicked", targetRows);
        }

        self.event.strikethroughClicked = function () {
            var targetRows = behavior.selectedRows().filter(function (row) {
                return behavior.isStrikeable(row);
            });
            
            if (targetRows.length > 0)
                sm.raise("strikethroughClicked", targetRows);
        }

        self.event.liveEditDeleteRow = function (row) {
            return function () {
                sm.raise("liveEditDeleteRow", row);
            }
        };

        self.event.deletePosted = function () {            
            self.selectedRow(null);

            self.masterCheck(false);

            behavior.selectedRows([]);

            sm.raise("deletePosted");
        };

        self.event.strikethroughPosted = function () {            
            self.selectedRow(null);

            self.masterCheck(false);

            behavior.selectedRows([]);

            sm.raise("strikethroughPosted");
        };

        self.isDeleteable = function (row) {
            return ko.computed(function () {                
                return behavior.isDeleteable(row);
            });            
        };

        self.isStrikeable = function (row) {
            return ko.computed(function () {
                return behavior.isStrikeable(row);                
            });
        };

        self.isStruckThrough = ko.computed(function () {
            if (!self.shadowRow)
                return false;

            return self.shadowRow.StrikethroughReason() != null;
        });

        self.strikethroughMessage = ko.computed(function () {
            if (!self.shadowRow)
                return "";

            return "Disputed by: " + self.shadowRow.ChangeBy() + ", reason: " + self.shadowRow.StrikethroughReason();
        });

        self.isCloneable = function (row) {
            return ko.computed(function () {
                return behavior.isCloneable(row);
            });
        };        

        self.isToolbarVisible = ko.pureComputed(function () {
            return behavior.isToolbarVisible()
        });

        self.isSelectionVisible = ko.pureComputed(function () {
            return behavior.isSelectionVisible()
        });

        self.isActionIconColumnVisible = ko.pureComputed(function () {
            return behavior.isActionIconColumnVisible();
        });

        self.isAddVisible = ko.pureComputed(behavior.isAddVisible);

        self.isAddEnabled = ko.pureComputed(behavior.isAddEnabled);

        self.isDeleteEnabled = ko.pureComputed(behavior.isDeleteEnabled);

        self.isStrikethroughEnabled = ko.pureComputed(behavior.isStrikethroughEnabled);

        self.isCloneEnabled = ko.pureComputed(behavior.isCloneEnabled);

        self.nextClicked = function () {
            var rows = self.table.Rows();

            for (var i = 0; i < rows.length; i++) {
                if (rows[i] === self.selectedRow()) {
                    var nextRow = rows[i + 1];

                    self.selectedRow(nextRow);

                    _setShadowRow(nextRow);

                    self.context.clearFieldLog();

                    break;
                }
            }
        };

        self.prevClicked = function () {
            var rows = self.table.Rows();

            for (var i = 0; i < rows.length; i++) {
                if (rows[i] === self.selectedRow()) {
                    var prevRow = rows[i - 1];

                    self.selectedRow(prevRow);

                    _setShadowRow(prevRow);

                    self.context.clearFieldLog();

                    break;
                }
            }
        };

        // Flyout button enablers        
        self.errorMessage = $error.errorMessage;

        self.isComplete = $error.isComplete;

        var _inSaveableState = sm.inState("editing", "cloning", "adding");

        self.prevEnabled = ko.computed(function () {
            var rows = self.table.Rows();
            var selected = self.selectedRow();

            if (_inSaveableState())
                return false;

            if (rows.length == 1 || sm.current() == "editing")
                return false;

            return selected !== rows[0];
        });

        self.nextEnabled = ko.computed(function () {
            var rows = self.table.Rows();
            var selected = self.selectedRow();

            if (_inSaveableState())
                return false;

            if (rows.length == 1 || sm.current() == "editing")
                return false;

            return selected !== rows[rows.length - 1];            
        });

        self.saveAndNewEnabled = ko.computed(function () {
            return (sm.current() == "cloning" || sm.current() == "adding") && self.isComplete();
        });

        self.saveEnabled = ko.computed(function () {
            if (!_inSaveableState())
                return false;

            return self.isComplete();            
        });

        self.externalLink = function (url) {
            return function () {
                window.open(url);
            }
        }

        self.popoutText = function (text) {
            return function () {
                if (le.util.isNullOrEmpty(text()))
                    return;

                le.dialogs.showMessage(text(), le.util.doNothing);
            }
        }

        self.popoutTextVisible = function (text) {
            return ko.pureComputed(function () {
                return !le.util.isNullOrEmpty(text());
            });
        }

        // Computed styles
        self.rowCSS = function (row) {
            return ko.computed(function () {
                var styles = [];

                styles.push("nosel");

                if (row.Status() == 'D')
                    styles.push('strikethrough');

                if (row === self.selectedRow())
                    styles.push('selected-row');
                
                return styles.join(' ');
            });
        };

        // Formatting functions
        self.completeCSS = ko.pureComputed(function () {
            for (var name in self.shadowRow.columns)
                self.shadowRow.columns[name]();

            var styleSets = {
                complete: 'glyphicon glyphicon-ok-sign hst-checkbox-complete pull-right',
                incomplete: 'glyphicon glyphicon-minus-sign hst-checkbox-incomplete pull-right',
                unreviewed: 'icon-attention hst-checkbox-unreviewed pull-right'
            };

            var state;

            var complete = $error.isComplete();

            if (complete)
                state = "complete";
            else
                state = "incomplete";

            return styleSets[state];
        });

        self.fieldLabel = function (uiFieldName) {
            return le.UIDictionary.field(module.designID, module.version, uiFieldName).label;
        };

        self.setCustomClass = function (value) {
            //Simply a placeholder if we want to set more custom styles on the column
            return value;
        }

        // TODO: Factor out this code into some kind of common class. Also used into ControlContext.
        var mandatoryFieldCache = {};

        var mandatory = function (uiFieldName) {
            var isMandatory;

            if (!mandatoryFieldCache.hasOwnProperty(uiFieldName)) {
                isMandatory = le.UIDictionary.field(module.designID, module.version, uiFieldName).required;

                mandatoryFieldCache[uiFieldName] = isMandatory;
            }
            else {
                isMandatory = mandatoryFieldCache[uiFieldName];
            }

            return isMandatory;
        };        

        self.asteriskCSS = function (row) {
            return ko.computed(function () {
                var isIncomplete = false;

                var incompleteOrMissing = function () {
                    isIncomplete = true;
                }

                complete.call(row, incompleteOrMissing, mandatory, incompleteOrMissing);

                if (isIncomplete == true)
                    return "glyphicon glyphicon-asterisk chart-acne-indicator";
                else
                    return "";
            }, row);
        }

        self.editIconClass = function (row) {
            return ko.computed(function () {
                return behavior.isEditable(row) == true ? "glyphicon glyphicon-pencil" : behavior.isLocked(row) ==true?"glyphicon glyphicon-lock":"glyphicon glyphicon-info-sign";
            }, row);
        };

        self.chartAcneVisible = $error.showErrors;

        self.toggleChartAcne = function () {
            if ($error.isComplete() == true)
                return;

            var old = $error.showErrors();

            $error.showErrors(!old);
        };

        if (self.table.Rows().length == 0)
            sm.raise("loadedNone");
        else
            sm.raise("loaded");
    };

    ko.components.register("live-grid", {
        viewModel: {
            createViewModel: function (params, componentInfo) {
                var e = componentInfo.element,
                    $e = $(e);

                var columns = [];                

                var flyoutNodes = [];

                var sortFuncs = params.sort || null;

                $.each(componentInfo.templateNodes, function (i, element) {
                    if (element.localName === 'live-grid-column') {
                        columns.push({
                            uiFieldName: $(element).attr('ui-field-name'),
                            dataFieldName: $(element).attr('data-field'),
                            type: $(element).attr('type') ? $(element).attr('type') : "text",
                            width: $(element).attr('width') ? $(element).attr('width') : ""
                        });
                    }

                    if (element.localName === 'flyout') {
                        flyoutNodes = $(element).children().toArray();
                    }
                });

                var $module = le.util.moduleFor(e);                

                return new componentModels.GridViewModel(params, $module, flyoutNodes, columns, e);
            }
        },
        template: { element: 'grid-template' }
    });    

    return le;
})(le || {}, jQuery, ko, S, ksm)

