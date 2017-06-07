le.registerModule({
    designID: "005",
    module: {
        moduleConfig: function () {
            var self = this;

            self.StaffCallback = function () {
                var Communication = self.Tables.t_EHR_CommunicationLog.Single();

                var staff = self.Tables.v_EHR_UserStaff.Single();
                var user = this.Tables.v_EHR_UserFullName.Single();
                if (Communication.UnableToContactPatient()) {
                    if (self.Tables.v_EHR_UserStaff.Single()) {
                        Communication.UnableToContactName(staff.StaffName());
                        Communication.UnableToContactIDType(staff.StaffIDType());
                        Communication.UnableToContactID(staff.StaffID());
                        var myDate = new Date();
                        var format = "MM-DD-YYYY HH:mm";
                        var newDate = moment(myDate).format(format);
                        Communication.UnableToContactDate(newDate);
                    }
                }
                else {
                    Communication.UnableToContactName(null);
                    Communication.UnableToContactIDType(null);
                    Communication.UnableToContactID(null);
                }
            };

            self.StatusCallback = function (field) {
                var row = field.row;
                if (row.CommunicationStatus() == "1" || row.CommunicationStatus() == "2") {
                    row.SpokeInPreferredLanguage(false);  
                }
                else {
                    row.SpokeInPreferredLanguage(true);
                }
            };
        }
    },
    tables: {
        "t_EHR_CommunicationLog":{
            rowModelConfig: function () {
                var self = this;
                //self.Count = ko.observable('');
                var permission = self.module.Tables.t_UserPermission.Single();
                var rows = self.module.Tables.t_EHR_CommunicationLogDetail.Rows();

                self.PrimaryLanguangeEnabled = ko.computed(function () {
                    return permission == undefined ? false : permission.CanUpdate() ? true : false;
                });

                self.IncorrectEnabled = ko.computed(function () {
                    return permission == undefined ? true : permission.CanUpdate() ? false : true;
                });

                self.CorrectLanguangeEnabled = ko.computed(function () {
                    return permission == undefined ? true : permission.CanUpdate() ? false : true;
                });

                self.IncorrectVisible = ko.computed(function () {
                    return permission == undefined ? true : permission.CanUpdate() ? false : true;
                });

                self.StaffText = ko.computed(function () {
                    if (self.UnableToContactPatient()) {
                        var format = "MM-DD-YYYY HH:mm";
                        return "[" + moment(self.UnableToContactDate()).format(format) + " " + self.UnableToContactName() + "]";
                    } else {
                        return '';
                    }
                });

                self.CountText = ko.computed(function () {
                    self.module.Tables.t_EHR_CommunicationLogDetail.Rows();
                    var count = 0;
                    $.each(rows, function (index, row) {
                        if (row.Status() == 'A') {
                            count = count+1;
                        }
                    });
                    return count;
                });

                self.UnableEnabled = ko.computed(function () {
                    self.module.Tables.t_EHR_CommunicationLogDetail.Rows();
                    var notReached = true;
                    $.each(rows, function (index, row) {
                        if (row.CommunicationStatus() == "4" && row.Status() == 'A') {
                            notReached=false;
                        }
                    });
                    return notReached;
                });
            }
        },
        "t_EHR_CommunicationLogDetail": {
            complete: function (incomplete, mandatory) {
                var communication = this.module.Tables.t_EHR_CommunicationLog.Single();
                if (this.CommunicationDate() == null && mandatory("CommunicationDate")) {
                    incomplete("CommunicationDate", "Time must be filled out");
                }

                if (le.util.isNullOrEmpty(this.PerformedByName()) && mandatory("PerformedByName")) {
                    incomplete("PerformedByName", "Performed by must be filled out");
                }

                if (le.util.isNullOrEmpty(this.CommunicationStatus()) && mandatory("StatusText")) {
                    incomplete("CommunicationStatus", "Status must be filled out");
                }
            },
            rowModelConfig: function () {
                var self = this;
                
                self.SpokeWithEnabled = ko.computed(function () {
                    return !(self.CommunicationStatus() == "1");
                });

                self.SpokeInPreferredEnabled = ko.computed(function () {
                    return !(self.CommunicationStatus() == "1" || self.CommunicationStatus() == "2");
                });

                self.Date = ko.computed(function () {
                    var formatDate = "MM-DD-YYYY";
                    return moment(self.CommunicationDate()).format(formatDate);
                });

                self.Time = ko.computed(function () {
                    var formatTime = "HH:mm";
                    return moment(self.CommunicationDate()).format(formatTime);
                });

                self.StatusText = ko.computed(function () {
                    if (self.CommunicationStatus() == "1") {
                        return "No Answer";
                    }
                    else if (self.CommunicationStatus() == "2") {
                        return "Left Message";
                    }
                    else if (self.CommunicationStatus() == "3") {
                        return "Partially Completed";
                    }
                    else if (self.CommunicationStatus() == "4") {
                        return "Call Completed";
                    }
                });
            }
        }
    }
});