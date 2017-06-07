le.registerModule({
    designID: "036",
    module: {
        
        moduleConfig: function () {
            var self = this;

            /*--------------------------Set Grid  Behavior  -------------------------------------------------------------------- */
            var ownRow = function (row, userID) {
                
                if(row.Status() != "A")
                    return false;
                
                if (row.AdministrationTime() != null) {
                   
                    if (row.ChangeBy() != null)  {
                        if(row.ChangeBy().toLowerCase().trim() === userID)
                        return true;
                    }
                    else if (row.CreateBy().toLowerCase().trim() == userID ) /* If administered by cloning, changeBy is null */
                    {
                        return true;
                    }
                    return false;
                }
                else {
                    return true;
                }
            }       
                
            
            var defaultBehavior = function () {
                var self = this;

                le.grid.DefaultBehavior.call(self);

                // Per-row evaluators
                self.isEditable = function (row) {
                    return ownRow(row, le.session.getUserName());
                }
                                
                self.isDeleteable = function (row) {
                    return ownRow(row, le.session.getUserName()) && row.Status() == 'A';
                }

                self.isStrikeable = function (row) {
                    return !ownRow(row, le.session.getUserName()) && row.Status() == 'A';
                }
                                
            };

            self.gridBehavior = new defaultBehavior();

            var selectedRows = self.gridBehavior.selectedRows;

            /*----------------------------------------Set/ Administer Operations------------------------------------------------------------------------------------------------------*/
            self.LoadSetHeader = function () {
                return "Reload Set";
            },

            self.AdministerSetHeader = function () {
                return "Administer Set";
            },
            self.validateLoadSet = function (setNumber) {
                if (!self.SetExists(setNumber)) {
                    return "Enter a valid Set #";
                }
                else if (self.setNotFullyAdministered(setNumber)) {
                    return "Cannot load Set. All Medications for other instances of this Set must be administered first";
                }
                return "";
            },

            self.validateAdministerSet = function (setNumber) {
                if (!self.SetExists(setNumber))
                    return "Enter a valid Set #";
                if (!self.setNotFullyAdministered(setNumber))
                    return "All Medications in the Set have been administered ";
                if (self.setNotMedChecked(setNumber))
                    return "All Medications in the Set must be checked";
                return "";
            },

             self.LoadSetOKEnabled = ko.pureComputed(function () {
                 var setNumber = self.Tables.t_EHR_MedicationAdministration.Single().LoadSetNumber();

                return setNumber && self.SetExists(setNumber);
            });

            self.AdministerSetOKEnabled = ko.pureComputed(function () {
                var setNumber = self.Tables.t_EHR_MedicationAdministration.Single().AdministerSetNumber();

                return setNumber && self.setNotFullyAdministered(setNumber) && !self.setNotMedChecked(setNumber);                
            });

            self.SetExists = function (setNumber) {
                var matchedRow = ko.utils.arrayFirst(self.Tables.t_EHR_MedicationAdministrationDetail.Rows(), function (row) {
                    return setNumber === row.SetNumber();
                });

                return matchedRow ? true : false;
            },
            
            self.NotFullyAdministered = function () {
                var medications = self.Tables.t_EHR_MedicationAdministrationDetail.Rows();

                for (var i = 0; i < medications.length; i++) {
                    if (medications[i].AdministrationTime() == null && le.util.FieldValueIn(medications[i].MedCheckStatus, [2, 3, 4])) {
                            return true;
                        }                       
                }

                return false;
            }

            self.setNotFullyAdministered = function (setNumber) {
                var medications = self.Tables.t_EHR_MedicationAdministrationDetail.Rows();
                for (var i = 0; i < medications.length; i++) {
                    if (medications[i].SetNumber() == setNumber) {
                        if (medications[i].AdministrationTime() == null && le.util.FieldValueIn(medications[i].MedCheckStatus, [2, 3, 4])) {
                            return true;
                        }
                    }
                }
                return false;
            },

            self.setNotMedChecked = function (setNumber) {
                var medications = self.Tables.t_EHR_MedicationAdministrationDetail.Rows();
                for (var i = 0; i < medications.length; i++) {
                    if (medications[i].SetNumber() == setNumber) {
                        if (medications[i].MedCheckStatus() == 1) {
                            return true;
                        }
                    }
                }
                return false;
            },
          
            self.LoadSetEnabled = ko.pureComputed(function () {
                var medications = self.Tables.t_EHR_MedicationAdministrationDetail.Rows();
                for (var i = 0; i < medications.length; i++) {
                    if (medications[i].SetNumber() && medications[i].SetNumber() != 0)
                        return true;
                }
                return false;
            });

            self.AdministerSetEnabled = ko.pureComputed(function () {
                if (self.IsDayOfAdmit() == false)
                    return false;
                var medications = self.Tables.t_EHR_MedicationAdministrationDetail.Rows();
                for (var i = 0; i < medications.length; i++) {
                    if (medications[i].AdministrationTime() == null && medications[i].SetNumber() && medications[i].SetNumber() != 0) {
                        return true;
                    }
                        
                }
                return false;
                
            });

            self.AdministerAllEnabled = ko.pureComputed(function () {
                var selected = selectedRows();

                // If rows are selected, then there are enough rows to enable the button. If not, check if the detail table
                //  has more than one row.
                var enoughRows = selected.length > 0 ? true : self.Tables.t_EHR_MedicationAdministrationDetail.Rows().length > 0;

               return self.AllMedicationsChecked() && enoughRows && self.NotFullyAdministered() && self.IsDayOfAdmit();               
            });

            self.AdministerSetComment = ko.pureComputed(function () {
                var medAdmin = self.Tables.t_EHR_MedicationAdministration.Single();
                return (medAdmin.AdministerSet() && (medAdmin.AdministerSetUserID() || medAdmin.AdministerSetFullName()) && medAdmin.AdministerSetDateTime())
                    ? "Last Administered by " + (medAdmin.AdministerSetFullName() ? medAdmin.AdministerSetFullName() : medAdmin.AdministerSetUserID()) + " [" + moment(medAdmin.AdministerSetDateTime()).format("MM/DD/YYYY HH:mm") + "]" : "";
            });

            self.AdministerAllComment = ko.pureComputed(function () {
                var medAdmin = self.Tables.t_EHR_MedicationAdministration.Single();
                return ( (medAdmin.AdministerAllUserID() || medAdmin.AdministerAllFullName()) && medAdmin.AdministerAllDateTime())
                    ? "Last Administered by " + (medAdmin.AdministerAllFullName() ? medAdmin.AdministerAllFullName() : medAdmin.AdministerAllUserID()) + " [" + moment(medAdmin.AdministerAllDateTime()).format("MM/DD/YYYY HH:mm") + "]" : "";
            });

            self.AdministerAllCaption = ko.pureComputed(function () {
                var tableCount = self.Tables.t_EHR_MedicationAdministrationDetail.Rows().length;

                var selectedCount = selectedRows().length;

                if (selectedCount == tableCount || selectedCount == 0)
                    return "Administer All";
                else
                    return "Administer Selected";
            });

            /*---------------------------------------------------------------------------------------------------------------------------------------------------------*/
            
            self.IsDayOfAdmit = ko.pureComputed(function () {
               return moment().isSame(le.session.getAdmitDate(), 'day'); //Administration is allowed only on the day of the procedure!                
            });

            self.GetLoggedInUser = function () {
                var staff = ko.utils.arrayFirst(self.Tables.v_EHR_UserStaff.Rows(), function (row) {
                    if (row.UserID())
                        return row.UserID().toLowerCase().trim() == le.session.getUserName();
                });
                return staff;
            }
            
            self.SetLoggedInUser = function (currentRow) {
                var staff = self.GetLoggedInUser();

                if (staff) {
                    currentRow.AdministeredByName(staff.StaffName());
                    currentRow.AdministeredByID(staff.StaffID());
                    currentRow.AdministeredByIDType(staff.StaffIDType());
                }                                
            }

            self.AdministerUpdateCallback = function () {
                var medAdmin = self.Tables.t_EHR_MedicationAdministration.Single();

                var staff=self.GetLoggedInUser();

                var date = moment().hstDate();

                medAdmin.AdministerAllUserID(staff.StaffID());
                medAdmin.AdministerAllFullName(staff.StaffName());
                medAdmin.AdministerAllDateTime(date);

                var meds = selectedRows().length > 0 ? selectedRows() : self.Tables.t_EHR_MedicationAdministrationDetail.Rows();

                for (var i = 0; i < meds.length; i++) {
                    if (!meds[i].AdministrationTime() && le.util.FieldValueIn(meds[i].MedCheckStatus, [2, 3, 4])) {
                        meds[i].AdministeredByName(staff.StaffName());
                        meds[i].AdministeredByIDType(staff.StaffIDType());
                        meds[i].AdministeredByID(staff.StaffID());
                        meds[i].AdministrationTime(date);
                    }
                }

                selectedRows.removeAll();
            },
            
            /*----------------------------------------Medication Check------------------------------------------------------------------------*/            
            self.DoMedCheck = ko.observable(false);

            self.MedCheckRequired = ko.pureComputed(function () {
                var medications = self.Tables.t_EHR_MedicationAdministrationDetail.Rows();
                for (var i = 0; i < medications.length; i++) {
                    if (medications[i].MedCheckStatus() == 1)
                        return true;
                }
                return false;
            });

            self.AllMedicationsChecked = function () {
                var medications = self.Tables.t_EHR_MedicationAdministrationDetail.Rows();

                for (var i = 0; i < medications.length; i++) {
                    if (medications[i].MedCheckStatus()==1)
                        return false;
                }
                return true;
            },
            
            self.MedCheckEnabled = ko.computed(function () {             
                return self.Tables.t_EHR_MedicationAdministrationDetail.Rows().length > 0;
            });
           
             self.performMedCheck = function () {
                 return $.ajax({
                     datatype: "json",
                     url: le.ajax.relative("api/gsdd/" + "36/" + le.session.getChartKey())
                 }).done(function (data) {
                     return data;
                 }).fail(function () {
                     self.displayErrorOnMedCheck();//Show error dialog on Error!
                 });
             },

            self.displayErrorOnMedCheck = function () {
                le.dialogs.notifyError("Error performing Medication Check!", le.util.doNothing);
            },

            self.displayErrorOnAdministerAll = function () {
                le.dialogs.notifyError("Error administering the Medications!", le.util.doNothing);
            },

            self.updateMedCheck = function (data) {
                var result = $.parseJSON(data);
                $.each(result, function (i, medication) {
                    var matchedRow = ko.utils.arrayFirst(self.Tables.t_EHR_MedicationAdministrationDetail.Rows(), function (row) {
                        return medication.Id === row.MedicationAdministrationDetailKey();
                    });
                    if (matchedRow) {
                        matchedRow.MedCheckStatus(medication.MedicationCheckStatus);                    
                        matchedRow.MedCheckWarning(le.util.getTruncatedString(medication.MedicationCheckWarning, 1000));
                    }
                });

            };

             self.Tables.t_EHR_MedicationAdministrationDetail.Rows.subscribe(function () {
                 self.DoMedCheck(moment());
             });

             self.MedCheckAllergiesNotLinkedWarning = ko.pureComputed(function () {
                 var allergyLinkWarning = '';
                 var allergies = self.Tables.t_EHR_AllergyChartDetail.Rows();

                 for (var i = 0; i < allergies.length; i++) {
                     if (!le.util.isNullOrEmpty(allergies[i].AllergyOther()))
                         allergyLinkWarning += allergies[i].AllergyOther() + ', ';
                 }

                 if (le.util.isNullOrEmpty(allergyLinkWarning) == false) {
                     allergyLinkWarning = allergyLinkWarning.substring(0, (allergyLinkWarning.length - 2));
                 }
                 return allergyLinkWarning;

             });

             self.MedCheckAllergiesLinkedWarning = ko.pureComputed(function () {
                 var allergyLinkWarning = '';
                 var allergies = self.Tables.t_EHR_AllergyChartDetail.Rows();

                 for (var i = 0; i < allergies.length; i++) {
                     if (!le.util.isNullOrEmpty(allergies[i].AllergyName()))
                         allergyLinkWarning += allergies[i].AllergyName() + ', ';
                 }
                 if (le.util.isNullOrEmpty(allergyLinkWarning) == false) {
                     allergyLinkWarning = allergyLinkWarning.substring(0, (allergyLinkWarning.length - 2));
                 }
                 return allergyLinkWarning;
             });

              self.MedCheckAllergiesNotLinkedWarningVisible = ko.pureComputed(function () {
                    var medChecked = ko.utils.arrayFirst(self.Tables.t_EHR_MedicationAdministrationDetail.Rows(), function (row) {
                        return row.MedCheckStatus() != 1;
                        });
                            /* If Med check has been made on any one medication and if some allergies listed are not linked to the 
                            gold standard repository, we should display the warning that the Med Check is not complete when the 
                            allergies are not linked **/
                    if (medChecked && le.util.isNullOrEmpty(self.MedCheckAllergiesNotLinkedWarning()) == false)
                         {
                            return true;
                         }
                        return false;
                });
           
            /*---------------------------------------------------------------------------------------------------------------------------------------------------------*/

        }
    },
    tables: {
        "t_EHR_MedicationAdministration": {
            rowModelConfig: function () {
                var self = this;

                self.MedCheckEnabled = ko.observable(false);
            }
        },
        "t_EHR_MedicationAdministrationDetail": {
            defaults: function (row) {
                var self = this;

                  self.SetLoggedInUser(row);

                row.BodySide('N');

                //defaulted to current time              
                row.AdministrationTime(moment().format(le.const.iso8601tz));
            },
            complete: function (incomplete, mandatory) {
                var self = this;

                if ((le.util.isNullOrEmpty(self.MedicationName()) && mandatory("MedicationName"))) {
                    incomplete("MedicationName", "Medication must be filled out");
                }

                if ((le.util.isNullOrEmpty(self.Dose()) && mandatory("Dose"))) {
                    incomplete("Dose", "Dose must be filled out");
                }

                if ((le.util.isNullOrEmpty(self.RouteKey()) && mandatory("RouteKey"))) {
                    incomplete("Route", "Route must be filled out");
                }

                if (!self.MedCheckOverride() && self.MedCheckStatus() == 5) {
                    incomplete("MedCheckOverride", "Must choose to override or not administer");
                }

                if ((le.util.isNullOrEmpty(self.AdministrationTime()) && mandatory("AdministrationTime"))) {
                    if (self.MedCheckStatus() != 5) {
                        incomplete("AdministrationTime", "Time must be filled out");
                    }
                    else if (self.MedCheckOverride() == 2)                  
                        {
                            incomplete("AdministrationTime", "Time must be filled out");
                        }                    
                }

                if ((le.util.isNullOrEmpty(self.AdministeredByName()) && mandatory("AdministeredByName")) ) {
                    if (self.MedCheckStatus() != 5) {
                        incomplete("AdministeredByName", "'Administered by' must be filled out");
                    }
                    else if (self.MedCheckOverride() == 2) {
                            incomplete("AdministeredByName", "'Administered by' must be filled out");
                        }                    
                }

                if (self.MedCheckStatus() == 1)
                {
                    incomplete("MedCheckStatus", "Medication Check must be done");
                }

                if(!self.AdministrationTimeAdmitDate() && !le.util.isNullOrEmpty(self.AdministrationTime()))
                {
                    incomplete("AdministrationTime", "Administration time has to be on the same day as the admit date");
                }
            },
            rowModelConfig: function () {
                var self = this;

                self.AdministrationEnabled = ko.computed(function () {
                      return !(self.MedCheckOverride() == 1 && self.MedCheckStatus() == 5);
                });

                self.AdministrationTimeAdmitDate = ko.computed(function () {
                    var dateOfService = moment(le.session.getAdmitDate(), le.const.iso8601, true);
                    return dateOfService.isSame(moment(self.AdministrationTime()), 'day');
                });

                self.AdministrationTimeText = ko.computed(function () {
                    if (self.AdministrationTime() && self.AdministrationTime()!=null)
                        return moment(self.AdministrationTime()).format("HH:mm");
                    return "";
                });

                self.SetNumberInstanceText = ko.computed(function () {
                    if (self.SetNumber() != null && self.SetInstanceNumber() != null) {
                        return self.SetNumber()+ " - " + self.SetInstanceNumber();
                    }
                    else if (self.SetNumber() != null && self.SetInstanceNumber() == null) {
                        return self.SetNumber() + " - " + 1;
                    }
                    return "";
                });

                self.RowMedCheckEnabled = ko.computed(function () {
                    return self.MedicationID() != null ? true : false;
                });

                self.SiteSideForGrid = ko.computed(function () {
                    var strBodySide = self.BodySide();
                    var strBodySite = !le.util.isNullOrEmpty(self.BodySite())?  self.BodySite() : "N/A";
                    if (strBodySide == "R")
                    {
                        strBodySide = "Right"
                    }
                    else if (strBodySide == "L") {
                        strBodySide = "Left"
                    }
                    else if (strBodySide == "B") {
                        strBodySide = "Bilateral"
                    }
                    else  {
                        strBodySide = "N/A"
                    }
                    return  strBodySite + "/" + strBodySide;
                });

                self.DoseText = ko.computed(function () {                   
                    return self.Dose() ? (self.Dose() + " " + (self.DoseUnitOfMeasure() ? self.DoseUnitOfMeasure() : "")) : '';                  
                });

                self.SetNumberText = ko.computed(function () {
                    self.SetNumber() ? self.SetNumber() : "N/A";
                });

                self.LastAdministeredByName = self.AdministeredByName();

                self.LastAdministeredById = self.AdministeredByID();
             
                /*--------------------------------------------------Medication Check per Med------------------------------------------------------------------------------------------*/

                self.OverrideUpdateCallback = function ()
                {
                    if (self.MedCheckOverride() == 1 && self.MedCheckStatus() == 5) {
                        self.LastAdministeredByName = self.AdministeredByName();
                        self.LastAdministeredById = self.AdministeredByID();
                        self.AdministrationTime(null);
                        self.AdministeredByID(null);
                        self.AdministeredByName(null);
                    }
                    else if (self.MedCheckOverride() == 2 && self.MedCheckStatus() == 5) {
                        if (!self.AdministrationTime()) {
                            self.AdministrationTime(moment().format(le.const.iso8601tz));
                        }
                        if (!self.AdministeredByID() && self.LastAdministeredById) {                  
                            self.AdministeredByID(self.LastAdministeredById);
                        }
                        if (!self.AdministeredByName() && self.LastAdministeredByName){
                            self.AdministeredByName(self.LastAdministeredByName);
                        }
                    }
                }
              
                self.OverrideWarningEnabled = ko.computed(function () {
                   return (self.MedCheckStatus() == 5)//Prompt to cancel or override a medication only when there is a Med Check warning
                  
                });

           
                self.MedicationTypeUpdateCallback = function () {
                    //Automatically update the Med Check status on selecting a Medication                    
                    if (self.MedicationID() != null || self.DrugCheckMedicationID()!=null) {
                        self.CheckMed();
                    }
                    else
                    {
                        self.MedCheckStatus(1);
                        self.MedCheckWarning(' ');
                    }
                };
             
                 self.CheckMed = function () {
                    if (self.MedicationIDType() == "IM" && !self.DrugCheckMedicationIDType() && !self.DrugCheckMedicationID()) {
                        self.MedCheckStatus(4);
                        self.MedCheckWarning(' ');
                    }
                    else {
                        var medicationId = (self.MedicationID() && self.MedicationIDType()!='IM') ? self.MedicationID() : self.DrugCheckMedicationID();
                        var medicationIdType = (self.MedicationIDType() && self.MedicationIDType()!='IM')? self.MedicationIDType() : self.DrugCheckMedicationIDType();
                        $.ajax({
                            datatype: "json",
                            url: le.ajax.relative("api/gsdd/" + "36/" + le.session.getChartKey() + "/" + medicationId + "/" + medicationIdType)
                        }).done(function (data) {
                            self.updateMedCheck(data);                           
                        }).fail(function () {
                            self.displayMedCheckError();
                        });
                    }

                 };
                 self.RowMedCheckEventHandler = function () {
                     var medicationId = (self.MedicationID() && self.MedicationIDType() != 'IM') ? self.MedicationID() : self.DrugCheckMedicationID();
                     var medicationIdType = (self.MedicationIDType() && self.MedicationIDType() != 'IM') ? self.MedicationIDType() : self.DrugCheckMedicationIDType();
                     return $.ajax({
                         datatype: "json",
                         url: le.ajax.relative("api/gsdd/" + "36/" + le.session.getChartKey() + "/" + medicationId + "/" + medicationIdType)
                     }).done(function (data) {
                         return data;
                     }).fail(function () {
                         self.displayMedCheckError();
                     });
                 }

                self.displayMedCheckError = function () {
                    self.MedCheckStatus("Error performing check, try again!");
                };
                
                self.updateMedCheck = function (data) {
                    var result = $.parseJSON(data);
                    self.MedCheckStatus(result.MedicationCheckStatus);                   
                    self.MedCheckWarning(le.util.getTruncatedString(result.MedicationCheckWarning, 1000));
                };

                 self.MedicationCheckStatusHtml = le.util.mapField(self.MedCheckStatus, {
                     1: "Not checked",
                     2: '<span class="glyphicon glyphicon glyphicon-ok m036-fine gi-1x"></span>',
                     3: '<span class= "glyphicon  glyphicon-warning-sign m036-warning-icon"> </span>',
                     4: "Unable to check",
                     5: '<span class= "glyphicon  glyphicon-exclamation-sign m036-issues-icon"> </span>'
                 });

                self.MedCheckStatusText = le.util.mapField(self.MedCheckStatus, {
                    1: "Not Checked",//Dont show anything if allergy check has not been done yet!
                    2: "No issues",
                    3: "Warning",
                    4: "Unable to check",
                    5: "Issues"
                });

                self.MedicationWarningTextStyle = le.util.mapField(self.MedCheckStatus, {
                    1: "",
                    2: "",
                    3: "form-control m036-warning",
                    4: "",
                    5: "form-control m036-issues"
                });

                self.MedCheckStatusTextStyle = le.util.mapField(self.MedCheckStatus, {
                    1: "",
                    2: "m036-fine",
                    3: "m036-warning",
                    4: "",
                    5: "m036-issues"
                });

               
                /*---------------------------------------------------------------------------------------------------------------------------------------------------------*/
            }
        }
    }
});