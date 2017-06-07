le.registerModule({
    designID: "041",
    module: {
   
        moduleConfig: function () {
            var self = this;
            
            self.foodFightBehavior = new le.grid.FoodFightBehavior();
            
        }
    },
    tables: {
        "v_EHR_TourniquetDetail": {
            
            complete: function (incomplete, mandatory, missing) {
                if (le.util.isNullOrEmpty(this.EquipmentType()) && mandatory('EquipmentType')) {
                    missing('EquipmentType', 'EquipmentType');
                }
                if (le.util.isNullOrEmpty(this.IdentificationNumber()) && mandatory('IdentificationNumber')) {
                    missing('IdentificationNumber', 'IdentificationNumber');
                }
                if (le.util.isNullOrEmpty(this.SerialNumber()) && mandatory('SerialNumber')) {
                    missing('SerialNumber', 'SerialNumber');
                } 
                if (le.util.isNullOrEmpty(this.BodySiteKey()) && mandatory('BodySiteKey')) {
                    missing('BodySiteKey', 'BodySiteKey');
                }
                if (le.util.isNullOrEmpty(this.BodySide()) && mandatory('BodySide')) {
                    missing('BodySide', 'BodySide');
                }
                if (le.util.isNullOrEmpty(this.Pressure()) && mandatory('Pressure')) {
                    missing('Pressure', 'Pressure');
                }
                if (!le.util.isNullOrEmpty(this.Pressure()) && this.module.field('Pressure').maxValue && this.module.field('Pressure').minValue
                    && (this.Pressure() > this.module.field('Pressure').maxValue || this.Pressure() < this.module.field('Pressure').minValue)) {
                    incomplete('Pressure', 'Pressure must be between ' + this.module.field('Pressure').minValue + ' and ' + this.module.field('Pressure').maxValue);
                }
                if (le.util.isNullOrEmpty(this.TimeUp()) && mandatory('TimeUp')) {
                    missing('TimeUp', 'TimeUp');
                }
                // allow missing timedown in the flyout ??why?
                //if (le.util.isNullOrEmpty(this.TimeDown()) && mandatory('TimeDown')) {
                //    missing('TimeDown', 'TimeDown');
                //}

                    var wftime = this.module.Tables.v_EHR_WorkflowRoomTime.Single();
                    var wfRoomOutTime = moment(wftime.RoomTimeOut());
                    var wfRoomInTime = moment(wftime.RoomTimeIn());

                    var timeUpMoment = moment(this.TimeUp());
                    var timeDownMoment = moment(this.TimeDown());
                    if (!le.util.isNullOrEmpty(this.TimeUp()) && !le.util.isNullOrEmpty(wftime.RoomTimeIn()) && !timeUpMoment.isAfter(wfRoomInTime)) {
                        //incomplete('TimeUp', null);
                        incomplete('TimeUp', "Time Up must be later than Room In Time");
                    }

                    if (!le.util.isNullOrEmpty(this.TimeUp()) && !le.util.isNullOrEmpty(this.TimeDown()) && !timeDownMoment.isAfter(timeUpMoment)) {
                        //incomplete('TimeUp', null);
                        incomplete('TimeDown', "Time Up must be earlier than Time Down");
                    }
                    if (!le.util.isNullOrEmpty(this.TimeDown()) && !le.util.isNullOrEmpty(wftime.RoomTimeOut()) && !wfRoomOutTime.isAfter(timeDownMoment)) {
                        //incomplete('TimeDown', null);
                        incomplete('TimeDown', "Time Down must be earlier than Room Out Time");
                    }

               
            },
            rowModelConfig: function () {
                var self = this;
                var _imRow = self.module.Tables.v_EHR_ItemMasterForTourniquet.Rows();
                self.EnableSerialNumber = ko.computed(function () {
                    return le.util.isNullOrEmpty(self.ItemEquipKey());
                });
                self.EnableIdentificationNumber = ko.computed(function () {
                    return !le.util.isNullOrEmpty(self.EquipmentType());
                });
                self.FormattedTimeUp = ko.computed(function () {
                    return self.TimeUp()? moment(self.TimeUp()).format('HH:mm') : '';
                });
                self.FormattedTimeDown = ko.computed(function () {
                    return self.TimeDown()? moment(self.TimeDown()).format('HH:mm'): '';
                });
                self.setIdOption = function () {
                    var _type = self.EquipmentType();
                    if (_type == null) {//clear the id# or serial# when type was cleared
                        self.ItemEquipKey(null);
                        self.SerialNumber('');
                        self.IdentificationNumber(null);

                    }


                    if (!le.util.isNullOrEmpty(_type)) {
                        var ier = self.module.Tables.v_EHR_ItemEquipmentForTourniquet.Rows();
                        var arrMulties = [];
                        $.each(ier, function (i, item) {
                            if (item.EquipmentType() == _type) {
                                arrMulties.push({ id: item.IdentificationNumber(), serial: item.SerialNumber(), key: item.ItemEquipKey });
                            }
                        });
                        if (arrMulties.length == 1) {
                            self.ItemEquipKey(arrMulties[0].key());
                            self.SerialNumber(arrMulties[0].serial);
                            self.IdentificationNumber(arrMulties[0].id);
                            
                        } else{

                            self.ItemEquipKey(null);
                            self.SerialNumber('');
                            self.IdentificationNumber(null);
                        }
                    }

                }
            }
        }
    }
});