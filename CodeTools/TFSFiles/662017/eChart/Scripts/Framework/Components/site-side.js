/****************************************************************************/
/* <selectbox>                                                              */
/*                                                                          */
/*  Provides a wrapper around the LiveEdit bindings for Dropdown selects    */
/*                                                                          */
/*  Parameters:                                                             */
/*                dataField:  Field from the RowModel that this checkbox    */
/*                            is bound to.                                  */
/*                                                                          */
/*                 fieldMap:  Map from dropdown fields to row model fields  */
/*                                                                          */
/*                    error:  Name of error condition from module js.       */
/*                            If set, an error ball will show in the        */
/*                            control when the named condition is set.      */
/*                                                                          */
/*                  enabled:  Observable that indicates that this control   */
/*                            should be enabled.                            */
/*                                                                          */
/*              captionText:  The drop-down list default value.             */
/*                            For example:None or Please select             */
/*                                                                          */
/*             displayField:  you can bind a field should be displayed      */
/*                            as the text in the drop-down list.            */
/*                                                                          */
/*              sourceField:  Read the database field columns.              */
/*                                                                          */
/****************************************************************************/
var le = (function (le, $, ko, S) {
    var componentModels = le.componentModels = le.componentModels || {};
    var sidesDataTemp = [];
    var sitesDataTemp = [];
    function updateSideItemsData (data) {
        
        $.each(data.sideItems, function (index, row) {
            sidesDataTemp.push(row);
        })

    }
    function updateSiteItemsData(data) {

        $.each(data.siteItems, function (index, row) {
            sitesDataTemp.push(row);
        })

    }
    function arrIntersection(arr1, arr2,prep1,prep2) {
        var temp=false;

        return arr1.filter(function (v1) {
                    (temp = arr2.find(function (v2) {
                        return v1[prep1] === v2[prep2];
                    }))

                    return temp;
                })

         
    }
    var sideItemsSuccess = function (data) {
        console.log(data);
        updateSideItemsData(data);
        updateSiteItemsData(data);

    };

    var sideItemsFailure = function (data) {
        console.log(data);

    };

    le.ajax.sideRequest(sideItemsSuccess, sideItemsFailure);

    componentModels.SiteSide = function (e, params) {
        /*******************************/
        /* Private variables           */
        /*******************************/
        var self = this;
        var $module = le.util.moduleFor(e),
            $context = le.util.contextFor(e);
        
        self.site_name = 'bodysite';
        self.site_display = params.site_display;
        self.site_search = params.site_search;
        self.site_field = params.site_field;
        self.site_fieldName = params.site_fieldName || le.util.getParamString(e, "site_field");
        self.site_normalized = params.site_normalized;
        self.site_fieldMap = params.site_fieldMap;
        self.site_error = params.site_error;
        self.side_error = params.side_error;
        self.errorMessage = ko.observable(null);
        self.side_field = params.side_field;
        self.side_groupName = params.side_groupName;
        self.side_options = params.side_options;

        var default_sideOptions = [
            { SideCode: 'L', UIFieldName: 'BodySideLeft' },
            { SideCode: 'R', UIFieldName: 'BodySideRight' },
            { SideCode: 'N', UIFieldName: 'BodySideNA' },
            { SideCode: 'B', UIFieldName: 'BodySideBilateral' }];
        var m_sidesData = arrIntersection(default_sideOptions, sidesDataTemp, 'SideCode', 'SideCode');

        if (!le.util.isNullOrEmpty(self.side_options) && self.side_options.length>0) {
            m_sidesData = arrIntersection(self.side_options, m_sidesData, 'SideCode', 'SideCode');
        }
        self.sideItemsData = ko.observableArray(m_sidesData);

        var arr_sidecode = self.sideItemsData().map(function (item) {
            return item.SideCode;
        });

        var m_sitesData = sitesDataTemp;
        if (!le.util.isNullOrEmpty(m_sidesData) && m_sidesData.length>0) {
            m_sitesData = arrIntersection(m_sitesData, m_sidesData, 'BodySide', 'SideCode');
        }
        self.siteItemsData = ko.observableArray(m_sitesData);


        var arr_sitekey = self.siteItemsData().map(function (item) {
            return item.BodySiteKey;
        });

        //self.fieldMap.BodySiteKey.subscribe(function (newValue) {
        //    if ($.inArray(newValue, arr_sitekey) == -1)
        //        self.field.row.BodySide(null);
        //});
        self.BodySideEnabled = ko.pureComputed(function () {
            var siteKey = self.site_fieldMap.BodySiteKey();
            return le.util.isNullOrEmpty(siteKey) || $.inArray(siteKey, arr_sitekey) == -1;
        });

        self.site_updateCallback = params.site_updateCallback || function () {
            var rowModel = self.site_field.row;
            
            if (!le.util.isNullOrEmpty(rowModel[self.site_fieldName]())) {
                var v_sidecode = rowModel[le.util.getParamString(e, "side_field")]();
                if ($.inArray(v_sidecode, arr_sidecode) == -1)
                    rowModel.BodySide(null);
            }
            else {
                rowModel.BodySide(null);
            }
        };

    };

    ko.components.register("site-side", {
        viewModel: {
            createViewModel: function (params, componentInfo) {

                return new componentModels.SiteSide(componentInfo.element, params);
            }
        },
        template: { element: 'siteside-template' }
    });

    return le;
})(le || {}, jQuery, ko, S)