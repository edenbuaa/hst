le.registerModule({
    designID: "035",
    module: {
        moduleConfig: function () {
            var self = this;

            self.TestUpdateCallback = function (parameter, arguments) {
                var test = arguments.row;
                var testtext = '';
                if (test.TestName1() != null) {
                    testtext += test.TestName1() + "; ";
                }
                if (test.TestName2() != null) {
                    testtext += test.TestName2() + "; ";
                }
                if (test.TestName3() != null) {
                    testtext += test.TestName3() + "; ";
                }
                if (test.TestName4() != null) {
                    testtext += test.TestName4() + "; ";
                }
                if (testtext.length > 100) {
                    testtext = testtext.substring(0, 96) + "...";
                }
                else {
                    testtext = testtext.substring(0, testtext.length - 2);
                }
                test.TestNames(testtext);
            }


        }
    },
    tables: {
        "t_EHR_SpecimenDetail": {
            complete: function (incomplete, mandatory) {
                var self = this;
                if (le.util.isNullOrEmpty(self.SpecimenID())) {
                    incomplete("SpecimenID", "Specimen ID must be filled out");
                }

                if (self.SpecimenDisposition() == "1") {
                    if (le.util.isNullOrEmpty(self.OrderID())) {
                        incomplete("OrderID", "Order ID must be filled out");
                    }
                }

                if (le.util.isNullOrEmpty(self.SpecimenDescription())) {
                    incomplete("SpecimenDescription", "Specimen must be filled out");
                }

                if (le.util.isNullOrEmpty(self.SpecimenDisposition())) {
                    incomplete("SpecimenDispositionText", "Disposition must be selected");
                }
                
                if (self.SpecimenDisposition() == "1") {
                    if (le.util.isNullOrEmpty(self.LabKey())) {
                        incomplete("LabKey", "Lab must be selected");
                    }

                    if (le.util.isNullOrEmpty(self.TestKey1()) && le.util.isNullOrEmpty(self.TestKey2()) && le.util.isNullOrEmpty(self.TestKey3())
                        && le.util.isNullOrEmpty(self.TestKey4()) && le.util.isNullOrEmpty(self.OtherTest())) {
                        incomplete("TestKey1", "Test(s) or Other Test must be filled out");
                        incomplete("OtherTest", "");
                        if (self.TestEnabled()) {
                            incomplete("TestKey2", "");
                            incomplete("TestKey3", "");
                            incomplete("TestKey4", "");
                        }
                    }
                }
            },
            rowModelConfig: function () {
                var self = this;
                self.TestEnabled = ko.observable(false);
                self.SideText = ko.computed(function () {
                    if (self.BodySide() == 'L')
                        return 'Left';
                    else if (self.BodySide() == 'R')
                        return 'Right';
                    else if (self.BodySide() == 'N')
                        return "N/A";
                });

                self.TestText = ko.computed(function () {
                    return self.TestNames();
                });

                self.SpecimenText = ko.computed(function () {
                    return self.SpecimenDescription() + ' - ' + self.BodySiteName() + " - " + self.SideText();
                });

                self.ShowAllClick = function () {
                    self.TestEnabled(!self.TestEnabled());
                }

                self.OtherEnabled = ko.pureComputed(function () {
                    return self.SpecimenDisposition() == "4";
                });
            }
        }
    }
});