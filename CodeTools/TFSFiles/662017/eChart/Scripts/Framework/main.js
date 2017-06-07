var le = (function (le, ko, $) {
    var _initHooks = [];

    var _userName,
        _workflowKey,
        _chartKey,
        _virtualPath,
        _centerId,
        _bundleKey = null,
        _admitDate,
        _areaKey,
        _personas,
        _systemFunctions,
        _hstInfo,
        _principal;

    var _fieldSets = {};

    var _typeaheadColumns = null;

    le.principal = function (personas, systemFunctions, hstInfo) {
        var self = this;

        var principalPersonas = personas;
        var principalSystemFunctions = systemFunctions;
        var principalHstInfo = hstInfo;

        self.isPhysician = function () {
            return self.hasPersona("Physician");
        }

        self.isCRNA = function () {
            return self.hasPersona("CRNA");
        }

        self.isAnesthesiologist = function () {
            return self.hasPersona("Anesthesiologist");
        }

        self.isEmployee = function () {
            return self.hasPersona("Employee");
        }

        self.hasPersona = function (persona) { return principalPersonas.hasOwnProperty(persona) && principalPersonas[persona]; }

        self.hasSystemFunction = function (sysFunc) { return principalSystemFunctions.hasOwnProperty(sysFunc) && principalSystemFunctions[sysFunc]; }

        self.getUserFullName = function () {
            var modifier = (principalHstInfo["JobTitle"] != null && principalHstInfo["JobTitle"] != "") ?
                                principalHstInfo["JobTitle"] : principalHstInfo["Salutation"];


            modifier = (modifier == null || modifier == "") ? "" : " " + modifier;

            return principalHstInfo["LastName"] + ", " + principalHstInfo["FirstName"] + modifier;
        }

        self.getEmployeeID = function () {
            return principalHstInfo["EmployeeID"];
        }
        self.getPhysicianID = function () {
            return principalHstInfo["PhysicianID"];
        }

        self.getStaffType = function () {
            if (self.isEmployee()) return "E";
            if (self.isPhysician()) return "P";
            
            return "";
        }

        self.getStaffTypePhysicianFirst = function () {
            if (self.isPhysician()) return "P";
            if (self.isEmployee()) return "E";

            return "";
        }

        self.getStaffID = function () {
            if (self.isEmployee()) return self.getEmployeeID();
            if (self.isPhysician()) return self.getPhysicianID();

            return null;
        }

        self.getStaffIDPhysicianFirst = function () {
            if (self.isPhysician()) return self.getPhysicianID();
            if (self.isEmployee()) return self.getEmployeeID();

            return null;
        }
    }

    le.session = {};

    le.session.getUserName = function () {
        if (_userName) {
            return _userName.toLowerCase().trim();
        }
        return '';
    }

    le.session.getUserFullName = function () { return le.session.principal().getUserFullName(); }

    le.session.isUserPhysician = function () { return le.session.principal().isPhysician(); }

    le.session.isUserCRNA = function () { return le.session.principal().isCRNA(); }

    le.session.isUserAnesthesiologist = function () { return le.session.principal().isAnesthesiologist(); }

    le.session.getWorkflowKey = function () { return _workflowKey; }

    le.session.getChartKey = function () { return _chartKey; }

    le.session.getBundleKey = function () { return _bundleKey; }

    le.session.getAreaKey = function () { return _areaKey; }

    le.session.getPhysicianId = function () { return _physicianId; }

    le.session.getAdmitDate = function () { return _admitDate; }

    le.session.principal = function () {
        if (!_principal) _principal = new le.principal(_personas, _systemFunctions, _hstInfo);
        return _principal;
    }

    le.session.isPhysician = function () { return le.session.principal().isPhysician(); }

    le.session.isNotPhysician = function () { return le.session.principal().isPhysician() == false && le.session.principal().isAnesthesiologist()==false; }

    le.session.hasPersona = function (persona) { return le.session.principal().hasPersona(persona); }

    le.session.hasSystemFunction = function (sysFunc) { return le.session.principal().hasSystemFunction(sysFunc); }

    le.session.canOpenClose = function () { return le.session.hasSystemFunction("60100-U"); }

    le.session.canLockUnlock = function () { return le.session.hasSystemFunction("60101-U"); }

    le.session.getFieldSetKey = function (moduleTemplateKey, name) {
        if (!_fieldSets.hasOwnProperty(moduleTemplateKey))
            return null;

        if (!_fieldSets[moduleTemplateKey].hasOwnProperty(name))
            return null;

        return _fieldSets[moduleTemplateKey][name].FieldSetKey;
    }

    // new for using
    le.session.getVirtualPath = function () {        
        if (_virtualPath.slice(-1) !== '/') {
            return _virtualPath + '/';
        } else {
            return _virtualPath;
        }
    }

    le.session.getTypeaheadColumns = function (name) {
        return _typeaheadColumns[name];
    }

    //Initialize - call from _CharHomeLayout
    le.initChartHome = function (virtualPath, chartKey, dialogId) {
        _virtualPath = virtualPath;
        le.ajax.init(0, 0, virtualPath);
        le.dialogs.init();      // needed by the chart header flyout for close operation

        var data = Q.allSettled([le.ajax.getChartHomeData(chartKey)]);
        var homeModel;
        var homeData;

        Q.when(data)
            .then(function (hm) {
                homeData = hm[0].value;

                _chartKey = homeData.header.v_EHR_Header[0].ChartKey;
                _centerId = homeData.header.v_EHR_Header[0].CenterID;                

                homeModel = le.factories.ChartHomeModelFactory.create(homeData);

                headerModel = le.factories.HeaderModelFactory.createNonChart(homeData);

                // Apply bindings to navbar and home content
                ko.applyBindings(headerModel, document.getElementById("demographic-navbar-home"));
                ko.applyBindings(headerModel, document.getElementById("chart-header-flyout"));
                ko.applyBindings(homeModel.summary, document.getElementById("summary-page-wrapper"));

                //Apply bindings for workflow Statuses
                ko.applyBindings(le.models.WorkflowStatusModel, document.getElementById("workflow-statuses-flyout"));


                // Create hamburger menu
                var options = {};
                options.enabledWorkflowManager = true;
                options.dialogId = dialogId;

                var root = le.factories.HamburgerFactory.create(homeData.header, options, homeData.security);

                ko.applyBindings({ rootMenu: root, button: 'echart-menu-btn' }, document.getElementById("hamburger-menu"));
            })                       
            .fail(function(error) {
                console.log("Stuff went sideways");
                console.log(error.stack);
            }).done();
    }

    le.writeTimeToLog = function (start) {
        var ta0 = new Date().getTime();
        console.log((ta0 - start) +'ms');
    }

    le.init = function (virtualPath, chartKey, workflowKey) {   

        var ta1 = new Date().getTime();
        le.writeTimeToLog(ta1);

        _virtualPath = virtualPath;
        var workflowData,
            chartMetadata,
            workflowModel;

        var moduleHTML = {};

        le.ajax.init(chartKey, workflowKey, virtualPath);

        le.dialogs.init();

        window.onerror = function (message, source, lineno, colno, error) {
            console.log(message);

            le.ajax.logError(message, source, lineno, colno, error);
        }

        var bootstrap = Q.allSettled([le.ajax.getChartMetadata(), le.ajax.getWorkflowData()]);        

        le.writeTimeToLog(ta1);

        Q.when(bootstrap)
        .spread(function (cm, wd) {
            console.profile("DOM Fun");
            le.writeTimeToLog(ta1);

            workflowData = wd.value;
            chartMetadata = cm.value;            

            workflowModel = le.factories.WorkflowModelFactory.create(workflowData);

            _userName = workflowData.userName;

            _chartKey = chartKey;

            _workflowKey = workflowKey;

            _bundleKey = workflowData.modules[0].Tables.t_EHR_Workflow[0].BundleKey;

            _physicianId = workflowData.modules[0].Tables.v_EHR_Header[0].PhysicianId;

            _admitDate = workflowData.modules[0].Tables.v_EHR_Header[0].AdmitDate;

            _typeaheadColumns = chartMetadata.typeaheadColumns;

            _fieldSets = chartMetadata.fieldSets;

            _areaKey = workflowData.modules[0].Tables.t_EHR_Workflow[0].AreaKey;

            _personas = workflowData.security.personas;

            _systemFunctions = workflowData.security.systemFunctions;

            _hstInfo = workflowData.security.hstInfo;


            var styles = [];

            $.each(workflowData.modules, function (index, module) {
                if (module.HasCSS === true && module.DesignID!="000") {
                    styles.push(le.ajax.getStyle(module.DesignID, module.ModuleVersion));
                }
            });

            return Q.allSettled(styles);
        })
        .then(function (styleResults) {

            le.writeTimeToLog(ta1);

            var htmlBlocks = [];

            for (var i = 1; i < workflowData.modules.length; i++) {
                var m = workflowData.modules[i];

                htmlBlocks.push(le.ajax.getHTMLBlock(m.DesignID, m.ModuleVersion));
            };

            return Q.allSettled(htmlBlocks);
        })
        .then(function (htmlBlocks) {

            le.writeTimeToLog(ta1);

            for (var i = 0; i < htmlBlocks.length; i++) {
                var b = htmlBlocks[i];

                le.factories.ModuleTemplateFactory.registerHTML(b.value.designID, b.value.version, b.value.html);
            }

            var scripts = [];

            for (var i = 0; i < workflowData.modules.length; i++) {
                var m = workflowData.modules[i];

                if (m.HasJavaScript === true) {
                    scripts.push(le.ajax.getScript(m.DesignID, m.ModuleVersion));
                }
            };

            return Q.allSettled(scripts);
        })
        .then(function (scriptResults) {

            le.writeTimeToLog(ta1);

            var container = $("#module-area");

           // Ensure any previous loads are wiped
           container.empty();

           var pairs = [];

           for (var i = 0; i < _initHooks.length; i++) {
               _initHooks[i](workflowData, chartMetadata);
           };

           workflowModel.modules = [];

           // Apply bindings to navbar           
           var headerData = workflowData.modules[0];

           var headerModel = le.factories.ModuleModelFactory.createModule(workflowModel, headerData, false);

           // TODO: strip this out when we get to the promised land of back-end completion handlers.
           le.UpdateRouter.moduleZero = headerModel;

           workflowModel.header = headerModel;

           var updateStrategy = new le.models.ModuleUpdateStrategy();

           le.writeTimeToLog(ta1);
            
                console.time("DOM append");

           for (var i = 1; i < workflowData.modules.length; i++) {
               try {
                   var node = $('<div id="m' + workflowData.modules[i].ModuleKey + '" style="position: relative;" data-bind="workflow: workflow, module: module, context: context"><module params="model: module, context: context, template: $root.template"></module></div>').appendTo(container)[0];

                   var moduleData = workflowData.modules[i];

                   var isLastModuleInWorkflow = i === workflowData.modules.length - 1;

                   var moduleModel = le.factories.ModuleModelFactory.createModule(workflowModel, moduleData, isLastModuleInWorkflow);

                   // No BLOC should ever have more than 200 controls. If that ever happens, up the constant below.
                   moduleModel.tabIndexStart(i * 200);

                   var template = le.factories.ModuleTemplateFactory.getTemplate(moduleData.DesignID, moduleData.ModuleVersion);

                   var cfg = template.config;

                        // TODO: This will be removed once all the BLOCs are converted to back-end completion. In blocks that are converted,
                        //        there is no module.complete in the config, 
                   var complete = le.util.byString(cfg, "module.complete");
                   
                   var enableHandler = ko.pureComputed(function () {
                       return moduleModel.uAction;
                   });

                   if (!complete)
                            complete = null;

                   var context = new le.models.ControlContext(moduleData.DesignID, moduleData.ModuleVersion, moduleModel, complete, updateStrategy, enableHandler);

                        le.UpdateRouter.registerModuleContext(moduleData.ModuleKey, context);


                   workflowModel.modules.push(moduleModel);
               }
               catch (e) {
                   console.log("Error processing data from module " + moduleData.DesignID);

                   console.log(e);

                   continue;
               }
                            

               pairs.push({
                   node:        node,
                   module:      moduleModel,
                   workflow:    workflowModel,
                   context:     context,
                   template:    template
               });
           }

           le.writeTimeToLog(ta1);

                console.timeEnd("DOM append");

           var headerPair = {
               node:        document.getElementById("demographic-navbar"),
               module:      headerModel,                   
               workflow:    workflowModel,
               context:     new le.models.ControlContext("000", "1", headerModel, le.util.alwaysTrue, updateStrategy),
               template:    le.factories.ModuleTemplateFactory.getTemplate("000", "1")
           };

           for (var i = 0; i < pairs.length; i++) {
               headerModel.addModule(pairs[i].module);
           }

           ko.applyBindings(headerPair, headerPair.node);

           var statusPair = {
               node: document.getElementById("module-statuses-flyout"),
               module: headerModel,
               workflow: workflowModel,
               context: new le.models.ControlContext("000", "1", headerModel, le.util.alwaysTrue, updateStrategy),
               template: le.factories.ModuleTemplateFactory.getTemplate("000", "1")
           };

           ko.applyBindings(statusPair, statusPair.node);

           console.time("Knockout binding");

           var cutoff = 3;

           if (pairs.length > cutoff) {
               for (var i = 0; i < cutoff; i++) {
                   ko.applyBindings(pairs[i], pairs[i].node);
               }


               setTimeout(function () {
                   for (var j = cutoff; j < pairs.length; j++) {
                       ko.applyBindings(pairs[j], pairs[j].node);
                   }
               }, 100);
           }
           else {
               for (var i = 0; i < pairs.length; i++) {
                   ko.applyBindings(pairs[i], pairs[i].node);
               }
           }

           // Apply bindings to navbar
           ko.applyBindings(headerModel, document.getElementById("chart-header-flyout"));
        
           // Create hamburger menu
           var root = le.factories.HamburgerFactory.create(workflowData.modules[0].Tables, null, workflowData.security);

           ko.applyBindings({ rootMenu: root, button: 'echart-menu-btn' }, document.getElementById("hamburger-menu"));

           // Apply bindings for module Audit History
           ko.applyBindings(le.models.AuditHistoryModel, document.getElementById("audit-history-flyout"));

           // Apply bindings for Generic Spinner -- needs no data, but needs to be bound to something, so choose headerModel     
           ko.applyBindings(headerModel, document.getElementById("generic-spinner-flyout"));


           // Apply bindings for QuickChart Models
           ko.applyBindings(le.models.QuickChartTemplatesModel, document.getElementById("quickChart-templates-flyout"));
           ko.applyBindings(le.models.QuickChartRecordModel, document.getElementById("quickChart-record-flyout"));
           ko.applyBindings(le.models.QuickChartInfoModel, document.getElementById("quickChart-info-flyout"));
           ko.applyBindings(le.models.QuickChartHandoffModel, document.getElementById("quickChart-handoff-flyout"));
           ko.applyBindings(le.models.QuickChartDeleteModel, document.getElementById("quickChart-delete-flyout"));

           // Apply bindings for Pins Chart Models
           ko.applyBindings(le.models.PinnedItemsModel, document.getElementById("pinChart-info-flyout"));
           //its can not work when chart Home , so do this when home action triggered
           //ko.applyBindings(le.models.PinnedItemsModel, document.getElementById("pinChartHome-info-flyout"));


           // Wire up SignalR and start listening for LiveEdit messages
           var liveEditHubProxy = $.connection.liveEditHub;

           le.UpdateRouter.start(_chartKey, workflowData.lastMessageID);

           ko.applyBindings(le.UpdateRouter, document.getElementById("live-edit-error-dialog"));                                

           // HACK: postErrors is being invoked before the components are registered. Wait a few ms, then try,
           setTimeout(function () {
               le.UpdateRouter.postErrors(workflowData);
           }, 50);           

           console.timeEnd("Knockout binding");

           console.profileEnd("DOM Fun");

           le.writeTimeToLog(ta1);
        })
        .fail(function (error) {
            console.log("Stuff went sideways");
            console.log(error.stack);
        }).done();
    };

    le.init.addHook = function (hook) {
        _initHooks.push(hook);
    }

    return le;
})(le || {}, ko, $);