var eChart = eChart || {};
eChart.ChartDesigner = eChart.ChartDesigner || {};


eChart.ChartDesigner.showChooseQuestionTemplateDialog = function () {
    $("#add-question-template-flyout").modal({
        backdrop: 'static',
        keyboard: false
    });
}


eChart.ChartDesigner.closeAddQuestionTemplateDialog = function () {
    $("#add-question-template-flyout").modal("hide");
}

eChart.ChartDesigner.QuestionnaireTemplates = (function () {
    function QuestionnaireTemplates() {
        var self = this;
        self.searchText = ko.observable('');
        self.QuestionnaireTemplates = ko.observableArray();
        self.ApplicationPath = "";
        var ajax;

        self.init = function (path,questionnaireTemplates) {      
            self.ApplicationPath = path;
            self.QuestionnaireTemplates = ko.observableArray(questionnaireTemplates);

            ajax = new eChart.ChartDesigner.ajax();

            $("#hst-ok-cancel-cancel").click(function () {
                $("#hst-ok-cancel-flyout").modal("hide");
            });

            $("#hst-ok-cancel-cancel").click(function () {
                $("#hst-ok-cancel-flyout").modal("hide");
            });
                        
            $("#hst-ok").click(function () {
                $("#hst-ok-flyout").modal("hide");
            });
        },

        self.showDeleteSuccessMsg = function (data)
         {
            $("#hst-ok-flyout").modal("show");
            self.QuestionnaireTemplates(data);
         }

        self.showDeleteFailureMsg= function ()
        {
            $("#hst-error-flyout").modal("show");
        }

        self.removeQuestionnaireTemplate = function (questionnaireTemplate) {
          
            Q.when(ajax.getData(ajax.relative(self.ApplicationPath, "api/chartdesigner/questionnairetemplate/" + questionnaireTemplate.QuestionnaireTemplateKey))).then(function (data) {
                questionnaireTemplate.InUse = data.InUse;              

                $("#hst-ok-cancel-message").html((questionnaireTemplate.InUse == true) ? "This Questionnaire Template is being used in a chart, are you sure, you want to delete?" : "Are you sure, you want to delete?");
                $("#hst-ok-cancel-flyout").modal("show");
                $("#hst-ok-cancel").click(function () {
                    $("#hst-ok-cancel-flyout").modal("hide");
                    ajax.deleteQuestionnaireTemplate(ajax.relative(self.ApplicationPath, "api/chartdesigner/questionnairetemplate/deactivate"), questionnaireTemplate, self.showDeleteSuccessMsg, self.showDeleteFailureMsg);

                });
            });
           
        }
         
         self.editQuestionnaireTemplate = function (questionnaireTemplate) {          
            window.location.href = questionnaireTemplate.Protected == false ? ajax.relative(self.ApplicationPath, "ChartDesigner/UpdateQuestionnaireTemplate/" + questionnaireTemplate.QuestionnaireTemplateKey) :
            ajax.relative(self.ApplicationPath, "ChartDesigner/ViewQuestionnaireTemplate/" + questionnaireTemplate.QuestionnaireTemplateKey);
          }
       
         self.isEditQuestionnaireTemplateEnabled = function (questionnaireTemplate) {
              return !questionnaireTemplate.Protected;
          }

         self.isRemoveQuestionnaireTemplateEnabled = function (questionnaireTemplate) {
             return questionnaireTemplate.Protected == false;
          }

         self.routeToAddQuestionnaireTemplate = function () {
                window.location.href = ajax.relative(self.ApplicationPath, "ChartDesigner/AddQuestionnaireTemplate");
         }
         self.searchQuestionnaireTemplates = function () {
             var searchText = self.searchText() == '' ? 'hst-all-templates' : self.searchText();
             
             var qtsc = { SearchText: searchText };
             Q.when(ajax.searchTemplates(ajax.relative(self.ApplicationPath, "api/chartdesigner/questionnairetemplate/search"), qtsc)).then(function (data) {
                 self.QuestionnaireTemplates(data);
             });
         }
    };
    return QuestionnaireTemplates;
})();



eChart.ChartDesigner.QuestionnaireTemplateBuilder = (function () {

    function QuestionnaireTemplateBuilder() {
        var self = this;       
        self.QuestionTemplates = ko.observableArray(); //The Questions Templates present in the QuestionnaireTemplate
        self.AllQuestionTemplates = ko.observableArray(); //List of all Question Templates from whih Question Templates are added to build the QuestionnaireTemplate
        self.QuestionTemplateCategories = ko.observableArray(); //List of all Categories for Question Templates. This populates the search drop-down so we can filter by Categories
        self.AllQuestionnaireTemplates = ko.observableArray(); //List of existing QuestionnaireTemplates from which we clone a template if we want to 

        //Hard coding the custom templates here. As of now only these 2 are in use
        var customTemplates = [
            { DisplayName: "None", Value: null },
            { DisplayName: "4column", Value: "questions-template-rhetorical-4column" },
            { DisplayName: "2column", Value: "questions-template-rhetorical-2column"}
        ];

        self.CustomTemplates = ko.observableArray(customTemplates);

        self.SelectedBaseTemplate=ko.observable(null);
        self.QuestionnaireTemplateName = '';
        self.QuestionnaireTemplateCategory = ko.observable(1);
                
        var ajax;
               
        self.templateAction = ko.observable("New"); /*By default, action is set to "Create New", If users selects to clone the existing template, the action is updated to "clone"*/
        
        self.init = function (path, qt, qtypes, ctypes, allQT) {
            self.ApplicationPath = path;
            $.each(qt.QuestionTemplates, function (i, qt) {
                qt.Ordinal = i + 1;//Assign ordinals just in case the database has the ordinals messed up!
                var customTemplate= ko.utils.arrayFirst(self.CustomTemplates(), function (template) {
                    return template.Value == qt.CustomTemplate;
                });
                qt.SelectedCustomTemplate = ko.observable(customTemplate);
            });

            self.QuestionTemplates(qt.QuestionTemplates);
            self.QuestionnaireTemplateName = qt.QuestionnaireName;
            self.QuestionnaireTemplate = qt;
          
            self.AllQuestionTemplates(allQT);
            self.AllQuestionnaireTemplates(qtypes);
            self.QuestionTemplateCategories(ctypes);
           

            ajax = new eChart.ChartDesigner.ajax();

            self.QuestionnaireTemplateCategory = ko.computed({
                read: function () {
                    if (self.QuestionnaireTemplate && self.QuestionnaireTemplate.Category == 2) {
                        return true;
                    }
                    return false;
                },
                write: function (newValue) {
                    if (self.QuestionnaireTemplate)
                        self.QuestionnaireTemplate.Category = (newValue === true) ? 2 : 1;
                },
                owner: this
            });
                       
            $("#hst-ok").click(function () {
                $("#hst-ok-flyout").modal("hide");
                window.location.href = ajax.relative(self.ApplicationPath, "ChartDesigner/ViewQuestionnaireTemplates");
            });
            $("#hst-error-ok").click(function () {
                $("#hst-error-flyout").modal("hide");
            });
        }

        self.moveUpEnabledWhen = function (questionTemplate) { if (questionTemplate) return (questionTemplate.Ordinal !== 1); return true; };
        self.moveDownEnabledWhen = function (questionTemplate) { if (questionTemplate) return (questionTemplate.Ordinal !== self.QuestionTemplates().length); return true; };

        self.searchText = ko.observable('');
        self.searchCategory = ko.observable(0);
        self.searchArea = ko.observable(0);
        self.searchClicked = function () { }
        

        self.templateAction.subscribe(function (newVal) {
            if (newVal == "New") {
                self.QuestionTemplates([]);
                self.SelectedBaseTemplate(null);
            }
            
        });

        self.SelectedBaseTemplate.subscribe(function(selectedBaseTemplate){
            if (selectedBaseTemplate != null) {
                var key = selectedBaseTemplate.QuestionnaireTemplateKey;
                Q.when(ajax.getData(ajax.relative(self.ApplicationPath, "api/chartdesigner/questionnairetemplate/") + key)).
                then(function (data) {
                    self.QuestionTemplates(data.QuestionTemplates);

                })
            }
            else {
                self.QuestionTemplates([]);
            }
        });

        self.moveQuestionTemplateUp = function (questionTemplate)
        {
            var currentIndex = questionTemplate.Ordinal - 1;
            var currentTemplate = self.QuestionTemplates()[currentIndex];
            var prevTemplate = self.QuestionTemplates()[currentIndex - 1];
            currentTemplate.Ordinal = currentTemplate.Ordinal - 1;
            prevTemplate.Ordinal = prevTemplate.Ordinal + 1;
            self.QuestionTemplates()[currentIndex] = prevTemplate;
            self.QuestionTemplates()[currentIndex - 1] = currentTemplate;
            self.QuestionTemplates.valueHasMutated();

        }

        self.moveQuestionTemplateDown = function (questionTemplate) {
            var currentIndex = questionTemplate.Ordinal - 1;
            var currentTemplate = self.QuestionTemplates()[currentIndex];
            var nextTemplate = self.QuestionTemplates()[currentIndex + 1];
            currentTemplate.Ordinal = currentTemplate.Ordinal+ 1;
            nextTemplate.Ordinal = nextTemplate.Ordinal - 1;

            self.QuestionTemplates()[currentIndex] = nextTemplate;
            self.QuestionTemplates()[currentIndex + 1] = currentTemplate;
            self.QuestionTemplates.valueHasMutated();
        }
        
        self.removeQuestionTemplate = function (questionTemplate) {           
            var index = questionTemplate.Ordinal - 1;
            for (var i = index + 1; i < self.QuestionTemplates().length; i++) {
                self.QuestionTemplates()[i].Ordinal = self.QuestionTemplates()[i].Ordinal - 1;
            }                        
            self.QuestionTemplates.remove(questionTemplate);
            
        }

        self.addSelectedQuestionTemplate = function (questionTemplate) {         
            var lastOrdinal;
            lastOrdinal = self.QuestionTemplates().length > 0 ? self.QuestionTemplates()[self.QuestionTemplates().length - 1].Ordinal : 0;
            questionTemplate.Ordinal = lastOrdinal + 1;
            questionTemplate.SelectedCustomTemplate = ko.observable(self.CustomTemplates[0]);
            eChart.ChartDesigner.closeAddQuestionTemplateDialog();
            self.QuestionTemplates.push(questionTemplate);
           
        }

           
        self.saveQuestionnaireTemplate = function () {
            if (self.isValid()==true) {               
                var ajax = new eChart.ChartDesigner.ajax();
                var questionnaireTemplate = self.QuestionnaireTemplate;
                $.each(self.QuestionTemplates(), function (i, q) {
                    q.CustomTemplate = q.SelectedCustomTemplate().Value;
                });
                questionnaireTemplate.QuestionTemplates = ko.toJS(self.QuestionTemplates);

                ajax.saveQuestionnaireTemplate(ajax.relative(self.ApplicationPath, "api/chartdesigner/questionnairetemplate/add"), questionnaireTemplate, self.showSuccessMsg, self.showFailureMsg);

            }
         
        }
        self.isValid = function () {
            
            $("#valQuestionnaireName").html("Questionnaire Template Name required");
            if (self.QuestionnaireTemplate.QuestionnaireName == null)
            {
                $("#valQuestionnaireName").show();
                return false;
            }
            var trimmedName = self.QuestionnaireTemplate.QuestionnaireName.trim();

            if (trimmedName == '' ) {
                $("#valQuestionnaireName").show();
                return false;
            }           

            if (eChart.ChartDesigner.util.isUnique(self.AllQuestionnaireTemplates(), "QuestionnaireTemplateName", trimmedName) == false)
            {
                $("#valQuestionnaireName").html("A Questionnaire Template with this name already exists");
                $("#valQuestionnaireName").show();
                return false;
            }

            $("#valQuestionnaireName").hide();
            if( self.QuestionTemplates().length == 0)
            {
                $("#requiredQuestionTemplate").show();
                return false;
            }
            
            $("#valQuestionnaireName").hide();
            $("#valQuestionnaireName").hide();
            $(".hst-loading").show();
            return true;
        }
              

        self.searchQuestionTemplates = function () {
            var ajax = new eChart.ChartDesigner.ajax();
            var searchText = self.searchText() == '' ? 'hst-all-templates' : self.searchText();
            var searchCategory = self.searchCategory() == null ? 0 : self.searchCategory().QuestionCategoryKey;           
            var qtsc = { SearchText: searchText, CategoryKey: searchCategory};
            Q.when(ajax.searchTemplates(ajax.relative(self.ApplicationPath, "api/chartdesigner/questiontemplate/search"), qtsc)).then(function (data) {
                self.AllQuestionTemplates(data);
              });
        }

        self.navigateToQuestionnaireTemplates = function () {
            return function () {
                var ajax = new eChart.ChartDesigner.ajax();
                window.location.href = ajax.relative(self.ApplicationPath, "ChartDesigner/ViewQuestionnaireTemplates");
            }
        }

        self.showSuccessMsg = function () {
            $(".hst-loading").hide();
            $("#hst-ok-flyout").modal({
                backdrop: 'static',
                keyboard: false
            });
        }

        self.showFailureMsg = function () {
            $(".hst-loading").hide();
            $("#hst-error-flyout").modal({
                backdrop: 'static',
                keyboard: false
            });
        }
    
    }
    return QuestionnaireTemplateBuilder;

})();

