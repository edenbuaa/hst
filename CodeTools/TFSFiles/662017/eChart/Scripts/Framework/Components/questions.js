var le = (function (le, ko) {
    le.questions = le.questions || {};
      

    // Question templates are now kept in QuestionsTemplatePartial.cshtml. Fish them out once and cache them.
    var questionTemplates = {
        "questions-template-two-radio": "",
        "questions-template-three-radio": "",
        "questions-template-checkbox": "",
        "questions-template-text": "",
        "questions-template-date": "",
        "questions-template-time": "",
        "questions-template-masked": "",
        "questions-template-integer": "",
        "questions-template-decimal": "",
        "questions-template-placeholder": "",
        "questions-template-rhetorical": ""
    };

    /*Hard coding the custom templates here. As of now only these 2 are in use*/
    var customTemplates={
        "questions-template-rhetorical-4column": "",
        "questions-template-rhetorical-2column": ""       
    };

    
    for (id in questionTemplates) {
        if (document.getElementById(id)) {
            questionTemplates[id] = document.getElementById(id).innerHTML;
            Mustache.parse(questionTemplates[id]);
        }
    }   

    for (id in customTemplates) {
        if (document.getElementById(id)) {
            customTemplates[id] = document.getElementById(id).innerHTML;
            Mustache.parse(customTemplates[id]);
        }
    }  

    var QuestionViewModel = function (component) {
        var self = this;

        self.expression = null;

        self.response = null;

        self.text = null;

        self.parent = null;

        self.component = component;        

        self.groupName = le.util.generateUniqueID();
              

        self.enabled = ko.pureComputed(function () {
           
            return le.util.alwaysTrue;
        });

        self.isChild = ko.pureComputed(function () {
            return self.parent != null;
        });

        self.visible = ko.pureComputed(function() {
            // Questions without parents are always visible
            if (self.parent == null)
                return true;
            return self.parent.response() == "Y";            
        });
    }

    var QuestionsViewModel = function (params, componentInfo) {
        var self = this;

        // Used to walk back from ResponseKey to the model
        var questionMap = {};

        self.questions = [];  

        self.specialFormattedQuestions = {}

        var htmlFragments = [];

        self.questionsEditable = params.questionsEditable ? params.questionsEditable : le.util.alwaysTrue;
            
        //self.enabled = params.signed ? params.signed() == false : le.util.alwaysTrue;

        if (!params.table)
            throw "You must provide the source table that contain the questions and responses."

        var rows = params.table.Rows();
              

        // We make one pass over the question/responses to create their objects
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i];

            var templateData;

            var question = new QuestionViewModel(self);

            question.enabled = ko.pureComputed(function () {
                if (self.questionsEditable)
                    return self.questionsEditable();
                return true;
                
            });

            question.text = row.QuestionText();

            question.errorName = row.ResponseKey().toString();

            switch (row.QuestionTypeID()) {

                case 1: // 1 => Yes/No
                    templateData = {
                        template: "questions-template-two-radio",
                        index: i,
                        labelOne: "Yes",
                        labelTwo: "No",
                        checkedValueOne: 'Y',
                        checkedValueTwo: 'N'
                    }

                    question.response = row.CodeResponse;
                    break;

                case 2: // 2 => Yes/NA
                    templateData = {
                        template: "questions-template-two-radio",
                        index: i,
                        labelOne: "Yes",
                        labelTwo: "NA",
                        checkedValueOne: 'Y',
                        checkedValueTwo: 'NA'                     
                    }

                    question.response = row.CodeResponse;
                    break;

                case 3: // 3 => Yes/No/NA                    
                    templateData = {
                        template: "questions-template-three-radio",
                        index: i,
                        labelOne: "Yes",
                        labelTwo: "No",
                        labelThree: "NA",
                        checkedValueOne: 'Y',
                        checkedValueTwo: 'N',
                        checkedValueThree: 'NA'
                    }
                    question.response = row.CodeResponse;
                    break;

                case 4: // 4 => Checkbox
                    templateData = {
                        template: "questions-template-checkbox",
                        index: i,
                        checkedValue: 'Y',
                        uncheckedValue: 'N'
                    }     

                    question.response = row.CodeResponse;
                    break;

                case 5: // 5 => Positive/Negative
                    templateData = {
                        template: "questions-template-two-radio",
                        index: i,
                        labelOne: "Positive",
                        labelTwo: "Negative",
                        checkedValueOne: 'P',
                        checkedValueTwo: 'N'
                    }

                    question.response = row.CodeResponse;
                    break;

                case 6: // 6 => Right/Left/Bilateral                    
                    templateData = {
                        template: "questions-template-three-radio",
                        index: i,
                        labelOne: "Right",
                        labelTwo: "Left",
                        labelThree: "Bilateral",
                        checkedValueOne: 'R',
                        checkedValueTwo: 'L',
                        checkedValueThree: 'B'
                    }
                    question.response = row.CodeResponse;                    
                    break;
                case 7: // 7 => Date
                    templateData = {
                        template: "questions-template-date",
                        index: i
                    }

                    question.response = row.DateTimeResponse;
                    break;

                case 8: // 8 => Time
                    templateData = {
                        template: "questions-template-time",
                        index: i
                    }
                    question.response = row.DateTimeResponse;
                    break;

                case 9: // 9 => Date and Time
                    templateData = {
                        template: "questions-template-masked",
                        index: i
                    }

                    question.response = row.DateTimeResponse;
                    question.mask = "NN/NN/NNNN NN:NN";
                    break;

                case 10: // 10 => Text
                    templateData = {
                        template: "questions-template-text",
                        index: i
                    }
                    question.response = row.TextResponse;                    
                    break;

                case 11: // 11 => Integer
                    templateData = {
                        template: "questions-template-integer",
                        index: i
                    }
                    question.response = row.IntegerResponse;                    
                    break;

                case 12: // 12 => Decimal
                    templateData = {
                        template: "questions-template-decimal",
                        index: i
                    }
                    question.response = row.DecimalResponse;                    
                    break;

                case 13: 
                    templateData = {
                        template: "questions-template-placeholder",
                        index: i
                    }
                    question.response = row.TextResponse;  
                    break;

                case 14: 
                    templateData = {
                        template: "questions-template-rhetorical",
                        index: i
                    }
                    question.text = row.QuestionText().replace("@r", row.TextResponse() ? row.TextResponse():'N/A');
                    break;

                case 15:
                    templateData = {
                        template: "questions-template-date",
                        index: i
                    }
                    question.response = row.DateTimeResponse;
                    break;
            }

            self.questions.push(question);

            if (row.ResponseKey() != null)
                questionMap[row.ResponseKey()] = question;

            if (row.CustomTemplate() == null) {
                var fragment = questionTemplates[templateData.template];

                htmlFragments.push(Mustache.render(fragment, templateData));
            }
            else {
                for (customTemplate in customTemplates) {                    
                    if (row.CustomTemplate() == customTemplate) {
                        if (self.specialFormattedQuestions[customTemplate] == null) {
                            self.specialFormattedQuestions[customTemplate] = customTemplate;
                            var fragment = customTemplates[customTemplate];
                            htmlFragments.push(Mustache.render(fragment, templateData));
                        }
                    }
                }
            }
            
           
            
        }

        // Then another pass to map child questions to their parents
        for (var j = 0; j < rows.length; j++) {
            var row = rows[j];

            var question = self.questions[j];

            if (row.ParentResponseKey() != null)
                question.parent = questionMap[row.ParentResponseKey()];
        }

        var html = htmlFragments.join("");

        self.nodes = $.parseHTML(html);
    }


    ko.components.register("questions", {
        viewModel: {
            createViewModel: function (params, componentInfo) {
                return new QuestionsViewModel(params, componentInfo);
            }
        },
        template: { element: 'questions-template' }
    });

    return le;
})(le || {}, ko);