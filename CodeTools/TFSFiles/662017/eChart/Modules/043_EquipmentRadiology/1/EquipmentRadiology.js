le.registerModule({
    designID: "043",
    module: {
        moduleConfig: function () {
            var self = this;
            var _imRow = self.Tables.t_ItemEquipment.Rows();

            self.foodFightBehavior = new le.grid.FoodFightBehavior();

            self.setIdOption = function (type) {
                return function () {
                    var xray = type.row;
                    var _type = xray.EquipmentType();
                    var _group;
                    var _code = xray.ItemCode();

                    $.each(_imRow, function (i, r) {
                        if (r.ItemCode() == _code) {
                            _group = r.InvGroup();
                            xray.InvGroup(_group);
                            return false;
                        }
                    });
                    if (!le.util.isNullOrEmpty(_type) && !le.util.isNullOrEmpty(_group) && !le.util.isNullOrEmpty(_code)) {
                        var ier = self.Tables.t_ItemEquipment.Rows();
                        var arrMulties = [];
                        $.each(ier, function (i, item) {
                            if (item.InvGroup() == _group && item.ItemCode() == _code) {
                                arrMulties.push({ id: item.IdentificationNumber(), serial: item.SerialNumber(), key: item.ItemEquipKey });
                            }
                        });
                        if (arrMulties.length == 1) {
                            xray.ItemEquipKey(arrMulties[0].key());
                            xray.SerialNumber(arrMulties[0].serial);
                            xray.IdentificationNumber(arrMulties[0].id);
                            xray.IsOnlyOneID(true);
                        } else {
                            //xray.SerialEnabled(true);
                            xray.IsOnlyOneID(false);
                            xray.ItemEquipKey(null);
                            xray.SerialNumber('');
                            xray.IdentificationNumber(null);
                        }
                    }
                    else {
                        xray.ItemEquipKey(null);
                        xray.SerialNumber('');
                        xray.IdentificationNumber(null);
                    }
                }
            }
        }
    },
    tables: {
        "t_EHR_XRayDetail": {
            complete: function (incomplete, mandatory) {
                if (this.EquipmentType() == null) {
                    incomplete("EquipmentType", "Type must be filled out");
                }
                
                if (this.UnitEnabled()) {
                    if (le.util.isNullOrEmpty(this.IdentificationNumber()) || this.IdentificationNumber() == "None") {
                        incomplete("ItemEquipKey", "Unit ID must be filled out");
                    }
                    else {
                        if (le.util.isNullOrEmpty(this.SerialNumber())) {
                            incomplete("SerialNumber", "Serial # must be filled out");
                        }
                    }
                }
               
                if (le.util.isNullOrEmpty(this.BodySiteName())) {
                    incomplete("BodySiteName", "Site must be filled out");
                }

                if (this.BodySide() == null) {
                    incomplete("BodySide", "Side must be filled out");
                }
            },
            rowModelConfig: function () {
                var self = this;
                self.BodySideText = ko.computed(function () {
                    if (self.BodySide() == "L") {
                        return "Left";
                    }
                    else if (self.BodySide() == "R") {
                        return "Right";
                    }
                    else if (self.BodySide() == "N") {
                        return "N/A";
                    }
                    else if (self.BodySide() == "B") {
                        return "Bilateral";
                    }
                });
                
                self.IsOnlyOneID = ko.observable(false);
                self.ExposureTimeText = ko.observable('');

                self.UnitEnabled = ko.pureComputed(function () {
                    return !le.util.isNullOrEmpty(self.EquipmentType());
                });

                self.SerialEnabled = ko.pureComputed(function () {
                    return self.UnitEnabled() && !le.util.isNullOrEmpty(self.IdentificationNumber());
                });
            }
        }
    }
});