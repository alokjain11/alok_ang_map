/// <reference path="../Scripts/toastr.js" />
/// <reference path="../content/toastr.css" />


(function (ng) {
    var app = angular.module('myApp', ['ngMap'])
        .directive('loading', function () {
            return {
                restrict: 'E',
                replace: true,
                template: '<div class="loading"></div>',
                link: function (scope, element, attr) {
                    scope.$watch('loading', function (val) {
                        if (val)
                            $(element).show();
                        else
                            $(element).hide();
                    });
                }
            }
        })


    app.controller("myCntrl", function ($scope, $http, NgMap, $interval, $filter, $timeout) {

        debugger


        $scope.triangleCoords = [];

        //$scope.triangleCoords = [
        //    { lat: 28.6029202, lng: 77.0492504},
        //    { lat: 28.5127828, lng: 77.0368925}
        //];

        //$scope.triangleCoords = [
        //    { "lat": 28.4993959, "lng": 77.2918391 },
        //    { "lat": 28.4993959, "lng": 77.2918391 },
        //    { "lat": 28.5538528, "lng": 77.295553 },
        //    { "lat": 28.5538528, "lng": 77.295553 }
        //];                         


        //[{ "lat": 28.4993959, "lng": 77.2918391 }, { "lat": 28.4993959, "lng": 77.2918391 }, { "lat": 28.5538528, "lng": 77.295553 }, { "lat": 28.5538528, "lng": 77.295553 }]


        $scope.RMds = [];
        $scope.dashboard = [];
        $scope.phlebotomisticds = [];
        $scope.selectAll = false;
        $scope.Livestatusds = [];
        $scope.Livestatus_cancelds = [];
        $scope.options = [];
        $scope.points = [];
        $scope.phlebotomisticid = 0;




        $scope.orderid = '0';

        $scope.office1_lat = 28.452132;
        $scope.office1_long = 77.072283;

        $scope.office2_lat = 28.6415980;
        $scope.office2_long = 77.2959270;

        $scope.office3_lat = 28.970114;
        $scope.office3_long = 77.721390;

        $scope.Detail = 'All';
        $scope.RMID = 0
        $scope.remainingTime = 10;

        var flag = 0;

        $scope.P1_Late = 'NO';
        $scope.P2_Late = 'NO';
        $scope.P3_Late = 'NO';
        $scope.P4_Late = 'NO';

        var p_TimeDiff = '0';

        $scope.center_mainmap_lat = 28.7369716;
        $scope.center_mainmap_long = 77.4366544;

        $scope.GetAddress_lat_long = '';

        $scope.Cus_Details = [];

        $scope.orgGrid_details = true;

        $scope.RMID = u_id.value;
        $scope.userid = 0;


        $scope.geofences = [
            { "name": "circle", "lat": 28.549170, "long": 77.256341 }
        ];


        $scope.p_Total_count = ''
        $scope.p_complted_count = ''
        $scope.p_Cancelled_count = ''
        $scope.p_Reschedule_count = ''
        $scope.p_ongoing_count = ''
        $scope.p_NotComplted_count = ''

        $scope.current_statusChk = '';


        BindRM(1);

        if ($scope.RMID == 728) {
            BindLivestatus_Cancel(6, 0, 'All');
            BindLivestatus(4, 0, 'All');
            Bindphlebotomistic(2, 0);
            $scope.userid = 0;
        }
        else {
            BindLivestatus_Cancel(6, $scope.RMID, 'All');
            BindLivestatus(4, $scope.RMID, 'All');
            Bindphlebotomistic(2, $scope.RMID);
            $scope.userid = $scope.RMID;
        }


        //BindMapDetails(3, $scope.phlebotomisticid);

        // Binduser_address(3, $scope.phlebotomisticid);

        function BindRM(Action) {
            debugger
            var httpreq = {
                method: 'POST',
                url: 'Tracker_Phlebotomist.aspx/BindRM',
                headers: {
                    'Content-Type': 'application/json; charset=utf-8',
                    'dataType': 'json'
                },
                data: { Action }
            }
            $http(httpreq).success(function (response) {
                debugger
                $scope.RMds = response.d;

                if ($scope.RMID != 728) {
                    $scope.RMds = $filter('filter')($scope.RMds, { userid: $scope.RMID });
                }



            })
        };

        $scope.toggleAll = function () {
            debugger
            var checked = $scope.selectAll;
            for (var i = 0; i < $scope.phlebotomisticds.length; i++) {
                $scope.options[i] = checked;
                $scope.phlebotomisticds[i].checked = checked;
            }
        };
        var selectedPhlebo = [];
        $scope.SelectedPLenth = '';

        $scope.counter = 0;
        $scope.togglephlebotomistic = function (index, userid) {
            debugger
            //$scope.phlebotomisticds[index].checked = !$scope.phlebotomisticds[index].checked;
            //if (!$scope.currencies[index].checked) {
            //    $scope.selectAll = false;
            //}

            $scope.Grid_DetailsDS = [];
            $scope.orgGrid_details = true;

            debugger
            for (var i = 0; i < $scope.phlebotomisticds.length; i++) {

                if ($scope.phlebotomisticds[i].selected == true) {
                    debugger
                    if ($scope.phlebotomisticds[i].userid == userid) {

                        if (selectedPhlebo.length < 4) {
                            var useridSelected = $scope.phlebotomisticds[i].userid;
                            selectedPhlebo.push(useridSelected);
                        }
                        else {
                            alert("Max 4 is allowed");
                            $scope.phlebotomisticds[i].selected = false;
                        }
                    }
                }
                else {



                    if ($scope.phlebotomisticds[i].userid == userid) {
                        var indexvalue = selectedPhlebo.indexOf(userid)
                        selectedPhlebo.splice(indexvalue, 1);


                    }
                }

            }



            if (selectedPhlebo.length == 0) {
                $scope.SelectedPLenth = '';
            }
            else {
                $scope.SelectedPLenth = selectedPhlebo.length;
            }


            var finalPhleobo = selectedPhlebo.join();

            $scope.finalvalue = finalPhleobo;

            var totailphilipboid = $scope.finalvalue;

            debugger

            var numberphlebo = new Array();
            numberphlebo = totailphilipboid.split(",");

            $scope.number = numberphlebo.length;

            $scope.getNumber = function (num) {
                return new Array(num);
            }

            $scope.phlebotomisticid = userid;
            $scope.selectAll = false;
            BindMapDetails(3, finalPhleobo)




        };





        function Bindphlebotomistic(Action, Phlebos_ManagerId) {
            debugger
            var httpreq = {
                method: 'POST',
                url: 'Tracker_Phlebotomist.aspx/Bindphlebotomistic',
                headers: {
                    'Content-Type': 'application/json; charset=utf-8',
                    'dataType': 'json'
                },
                data: { Action, Phlebos_ManagerId }
            }
            $http(httpreq).success(function (response) {
                debugger
                $scope.phlebotomisticds = response.d.Item1;
                $scope.dashboard = response.d.Item2[0];

            })
        };

        Grid_DetailsDS = [];
        function Bind_Grid_Details(Action, Detail, Phlebos_ManagerId) {
            debugger
            var httpreq = {
                method: 'POST',
                url: 'Tracker_Phlebotomist.aspx/Bind_Grid_Details',
                headers: {
                    'Content-Type': 'application/json; charset=utf-8',
                    'dataType': 'json'
                },
                data: { Action, Detail, Phlebos_ManagerId }
            }
            $http(httpreq).success(function (response) {
                debugger
                $scope.Grid_DetailsDS = response.d;


            })
        };

        function BindLivestatus(Action, Phlebos_ManagerId, Detail) {
            debugger
            var httpreq = {
                method: 'POST',
                url: 'Tracker_Phlebotomist.aspx/BindLivestatus',
                headers: {
                    'Content-Type': 'application/json; charset=utf-8',
                    'dataType': 'json'
                },
                data: { Action, Phlebos_ManagerId, Detail }
            }
            $http(httpreq).success(function (response) {
                debugger

                $scope.phlebotomisticds = response.d.Item1;
                $scope.Livestatusds = response.d.Item2[0];

            })
        };

        function BindLivestatus_Cancel(Action, Phlebos_ManagerId, Detail) {
            debugger
            var httpreq = {
                method: 'POST',
                url: 'Tracker_Phlebotomist.aspx/BindLivestatus_Cancel',
                headers: {
                    'Content-Type': 'application/json; charset=utf-8',
                    'dataType': 'json'
                },
                data: { Action, Phlebos_ManagerId, Detail }
            }
            $http(httpreq).success(function (response) {
                debugger
                if (Detail != 'All') {
                    $scope.phlebotomisticds = response.d.Item1;
                }


                $scope.Livestatus_cancelds = response.d.Item2[0];

            })
        };


        function BindMapDetails_liveclick(Action, phleboId, orderid) {
            debugger
            var httpreq = {
                method: 'POST',
                url: 'Tracker_Phlebotomist.aspx/BindMapDetails_liveclick',
                headers: {
                    'Content-Type': 'application/json; charset=utf-8',
                    'dataType': 'json'
                },
                data: { Action, phleboId, orderid }
            }
            $http(httpreq).success(function (response) {
                debugger

                $scope.selected_point = response.d[0];


                // $scope.model_click($scope.selected_point);
            })
        };

        function BindCustomer_Details(Action, cm_id) {
            debugger
            var httpreq = {
                method: 'POST',
                url: 'Tracker_Phlebotomist.aspx/BindCustomer_Details',
                headers: {
                    'Content-Type': 'application/json; charset=utf-8',
                    'dataType': 'json'
                },
                data: { Action, cm_id }
            }
            $http(httpreq).success(function (response) {
                debugger


                $scope.Cus_Details = response.d;

                // $scope.model_click($scope.selected_point);
            })
        };

        $scope.history_DetailsDS = [];
        $scope.Running_detail = [];
        function Bind_history_Details(Action, PhleboId) {
            debugger
            $scope.history_DetailsDS = [];
            $scope.Running_detail = [];

            var httpreq = {
                method: 'POST',
                url: 'Tracker_Phlebotomist.aspx/Bind_history_Details',
                headers: {
                    'Content-Type': 'application/json; charset=utf-8',
                    'dataType': 'json'
                },
                data: { Action, PhleboId }
            }
            $http(httpreq).success(function (response) {
                debugger


                $scope.history_DetailsDS = response.d;

               

                for (var i = 0; i < $scope.history_DetailsDS.length; i++) {
                    $scope.Running_detail.push([$scope.history_DetailsDS[i].lat, $scope.history_DetailsDS[i].lng])
                }

             
               

                debugger

                // $scope.model_click($scope.selected_point);
            })
        };

        $scope.ETI = [];
        $scope.P_Late = [];
        $scope.P_Late_Time = [];
        $scope.p_TimeDiff = 0

        function ETI_Estimate() {

            // var url = https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=28.4524544,77.0506752&destinations=28.3707715,77.0121372&key=AIzaSyCT5Y80JAPan_xGH6b3reefEyjOZY7c-N8
            debugger

            var startLatitude = 0;
            var endLatitude = 0;
            var startLongitude = 0;
            var endLongitude = 0;



            if ($scope.ETI.length > 0) {

                var k = 0;
                for (var i = 0; i < $scope.ETI.length; i++) {
                    k++;

                    if ($scope.ETI[i].length > 0) {


                        $scope.p_TimeDiff = $scope.ETI[i][0].TimeDiff;
                        startLatitude = $scope.ETI[i][0].a_geo_latitude;
                        startLongitude = $scope.ETI[i][0].a_geo_longitude;
                        endLatitude = $scope.ETI[i][0].lat;
                        endLongitude = $scope.ETI[i][0].logi;


                        var Cklate = p_TimeDiff.includes("-");
                        if (Cklate) {
                            debugger
                            $scope.P_Late[k] = 'YES';
                        }
                        else {

                            var httpreq = {
                                method: 'POST',
                                url: 'Tracker_Phlebotomist.aspx/GetDistance',
                                headers: {
                                    'Content-Type': 'application/json; charset=utf-8',
                                    'dataType': 'json'
                                },
                                data: { startLatitude, endLatitude, startLongitude, endLongitude }
                            }
                            $http(httpreq).success(function (response) {
                                debugger


                                $scope.Estimate_details = JSON.parse(response.d);

                                if ($scope.Estimate_details.status = 'OK') {

                                    $scope.destination_addresses = $scope.Estimate_details.destination_addresses;
                                    $scope.origin_addresses = $scope.Estimate_details.origin_addresses;
                                    $scope.distance = $scope.Estimate_details.rows[0].elements[0].distance.text;
                                    $scope.duration = $scope.Estimate_details.rows[0].elements[0].duration.text;
                                    debugger
                                    $scope.ETI_duration = $scope.Estimate_details.rows[0].elements[0].duration.value;

                                    var ETI_duration = Math.round((parseInt($scope.ETI_duration) / 60), 2);
                                    debugger
                                    if ($scope.p_TimeDiff > ETI_duration) {
                                        debugger
                                        $scope.P_Late[k] = 'NO';
                                    }
                                    else {
                                        debugger
                                        $scope.P_Late[k] = 'YES';
                                        $scope.P_Late_Time[k] = ETI_duration - $scope.p_TimeDiff;
                                    }


                                    debugger

                                }



                                // $scope.model_click($scope.selected_point);
                            })

                        }
                    }

                    else {
                        $scope.P_Late[k] = 'NO';
                    }
                }

            }
            debugger
        };


        function APIEstimate(startLatitude, endLatitude, startLongitude, endLongitude) {

            // var url = https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=28.4524544,77.0506752&destinations=28.3707715,77.0121372&key=AIzaSyCT5Y80JAPan_xGH6b3reefEyjOZY7c-N8
            debugger

            var httpreq = {
                method: 'POST',
                url: 'Tracker_Phlebotomist.aspx/GetDistance',
                headers: {
                    'Content-Type': 'application/json; charset=utf-8',
                    'dataType': 'json'
                },
                data: { startLatitude, endLatitude, startLongitude, endLongitude }
            }
            $http(httpreq).success(function (response) {
                debugger



                $scope.Estimate_details = JSON.parse(response.d);

                if ($scope.Estimate_details.status = 'OK') {

                    $scope.destination_addresses = $scope.Estimate_details.destination_addresses;
                    $scope.origin_addresses = $scope.Estimate_details.origin_addresses;
                    $scope.distance = $scope.Estimate_details.rows[0].elements[0].distance.text;
                    $scope.duration = $scope.Estimate_details.rows[0].elements[0].duration.text;
                    debugger
                    $scope.ETI_duration = $scope.Estimate_details.rows[0].elements[0].duration.value;



                }



                // $scope.model_click($scope.selected_point);
            })
            debugger
        };




        function BindMapDetails(Action, phleboId) {

            var tempphlebo = new Array();
            tempphlebo = phleboId.split(",");


            // alert(phleboId);
            debugger
            var httpreq = {
                method: 'POST',
                url: 'Tracker_Phlebotomist.aspx/BindMapDetails',
                headers: {
                    'Content-Type': 'application/json; charset=utf-8',
                    'dataType': 'json'
                },
                data: { Action, phleboId }
            }
            $http(httpreq).success(function (response) {
                debugger
                $scope.points = response.d.Item1;

                $scope.p_Total_count = $scope.points.length;
                $scope.p_complted_count = $filter('filter')($scope.points, { PickUpStatus: 'Completed' }).length;
                $scope.p_Cancelled_count = $filter('filter')($scope.points, { PickUpStatus: 'Cancelled' }).length;
                $scope.p_Reschedule_count = $filter('filter')($scope.points, { PickUpStatus: 'Reschedule' }).length;
                $scope.p_ongoing_count = $filter('filter')($scope.points, { PickUpStatus: 'OnGoing' }).length;
                $scope.p_NotComplted_count = $filter('filter')($scope.points, { PickUpStatus: 'NotCmpleted' }).length;

                //  $scope.selected_point = $scope.points;
                debugger
                $scope.triangleCoords = response.d.Item2;

                tempPhleboSelected = tempphlebo.length;


                $scope.count = [];
                $scope.path = [];
                $scope.ETI = [];

                var bikefirstLine_lat = 0;
                var bikefirstLine_long = 0;
                var OfficeLat = 0
                var OfficeLong = 0

                var j = 0
                $scope.path_filter = [];
                $scope.home = [];

                for (var i = 0; i < tempphlebo.length; i++) {
                    j++;
                    $scope.count[i] = $filter('filter')($scope.points, { PhleboId: tempphlebo[i] });


                    if ($scope.count[i].length > 0) {

                        $scope.center_mainmap_lat = parseFloat($scope.count[i][0].a_geo_latitude);
                        $scope.center_mainmap_long = parseFloat($scope.count[i][0].a_geo_longitude);

                        PhleboHomeLat = parseFloat($scope.count[i][0].PhleboHomeLat);
                        PhleboHomeLong = parseFloat($scope.count[i][0].PhleboHomeLong);
                    }
                    debugger;
                    $scope.path[i] = ([{ PhleboId: tempphlebo[i], lat: PhleboHomeLat, lng: PhleboHomeLong, PhleboOrder: 1, bikelat: bikefirstLine_lat, bikelng: bikefirstLine_long }]);
                    $scope.path_filter = $filter('filter')($scope.triangleCoords, { PhleboId: tempphlebo[i] });
                    debugger



                    for (var j = 0; j < $scope.path_filter.length; j++) {
                        $scope.path[i].push($scope.path_filter[j]);
                    }



                    //$scope.path[i] = $filter('filter')($scope.triangleCoords, { PhleboId: tempphlebo[i] });

                    if ($scope.path_filter.length > 0) {

                        bikefirstLine_lat = ($scope.path_filter[0].bikelat);
                        bikefirstLine_long = ($scope.path_filter[0].bikelng);

                        OfficeLat = ($scope.path_filter[0].OfficeLat);
                        OfficeLong = ($scope.path_filter[0].OfficeLong);


                    }

                    debugger


                    $scope.path[i].push({ PhleboId: tempphlebo[i], lat: OfficeLat, lng: OfficeLong, PhleboOrder: 1, bikelat: bikefirstLine_lat, bikelng: bikefirstLine_long });



                    $scope.ETI[i] = $filter('filter')($scope.count[i], { PickUpStatus: 'OnGoing' });

                    debugger

                }

                if (tempphlebo.length > 0) {

                    ETI_Estimate($scope.ETI[i])


                }



                debugger




            })
        };

        $scope.send_parameters = function (agent_id, phn) {
            debugger
            //var regId1 = '8980060879'// phn;
            var regId1 = phn;
            // document.cookie = "Number=" + document.getElementById(regId1).value + ";expires=Fri, 27 Dec 2020 23:59:59 GMT;";
            var Agent_id = $("#hdnAgentID").val();// hdnAgentID.Value  document.getElementById('DialerID').value;         
            var HostIP = "192.168.1.20";// document.getElementById('HostIP').value;  
            // 192.168.1.20
            $.ajax({
                type: 'POST',
                url: 'http://192.168.1.212/apps/appsHandler.php?transaction_id=CTI_DIAL&agent_id=' + Agent_id + '&ip=' + HostIP + '&phone_num=' + regId1 + '&resFormat=1',
                //url: 'http://192.168.1.212/apps/appsHandler.php?transaction_id=CTI_DIAL&agent_id=' + agent_id + '&ip=192.168.1.20&phone_num=8510910308&resFormat=1',
                data: {},
                dataType: 'json',
                success: function (data) {
                },
                error: function () {
                }
            });
        }

        $scope.model_click = function (point) {
            debugger

            $scope.phleboId_model = point.PhleboId;
            $scope.orderId_model = point.o_number;

            $scope.a_geo_latitude = point.a_geo_latitude;
            $scope.a_geo_longitude = point.a_geo_longitude;
            $scope.lat = point.lat;
            $scope.logi = point.logi;

            APIEstimate($scope.lat, $scope.a_geo_latitude, $scope.logi, $scope.a_geo_longitude)


            $scope.selected_point = point;
            $('#myModal').modal('show');

            debugger

            var increaseliveStatus = function () {
                BindMapDetails_liveclick(5, $scope.phleboId_model, $scope.orderId_model);
            }
            debugger

            $interval(increaseliveStatus, 10000); // 10 sec



        }





        $scope.RM_change = function (userid) {
            debugger
            $scope.phlebotomisticds = [];
            selectedPhlebo = [];
            $scope.points = [];
            $scope.count = [];
            $scope.path = [];
            $scope.ETI = [];
            $scope.selected_point = [];
            $scope.SelectedPLenth = '';



            BindLivestatus_Cancel(6, userid, $scope.Detail);
            BindLivestatus(4, userid, $scope.Detail);
            Bindphlebotomistic(2, userid)
        };

        $scope.livestatus_click = function (Detail, flag, callchk, userid) {
            debugger
            $scope.phlebotomisticds = [];
            selectedPhlebo = [];
            $scope.points = [];
            $scope.count = [];
            $scope.path = [];
            $scope.ETI = [];
            $scope.selected_point = [];
            $scope.SelectedPLenth = '';
            $scope.Grid_DetailsDS = [];

            if (Detail == 'Online') {
                $scope.current_statusChk = 'Online';
            }
            else if (Detail == 'offline') {
                $scope.current_statusChk = 'offline'
            }
            else {
                $scope.current_statusChk = '';
            }



            if (flag == 1) {
                BindLivestatus(4, userid, Detail);
            }
            else if (flag == 2) {
                BindLivestatus_Cancel(6, userid, Detail);
            }
            else if (flag == 3) {
                Bindphlebotomistic(7, userid)

            }

            if (callchk == 1) {

                $scope.orgGrid_details = false;
                Bind_Grid_Details(10, Detail, userid)
                BindLivestatus_Cancel(6, userid, Detail);
            }
            else {

                $scope.orgGrid_details = true;
            }

        }

        $scope.Cus_Details_click = function (cm_id) {
            debugger
            BindCustomer_Details(8, cm_id);


            $('#modalorderdetails').modal('show');
        }

        $scope.Phlibo_timing_click = function (PhleboId) {
            debugger

            //$scope.Running_detail = [];
            //$scope.Running_detail.push([0, 0])
            //$scope.btnhistoryStarttxt = 'Start';

            Bind_history_Details(9, PhleboId);

            $scope.Allocated_path = $filter('filter')($scope.path, { PhleboId: PhleboId });

            debugger
            //$scope.Allocated_path = $scope.path[i];
            $('#Modal_philbo_timing').modal('show');
        }

        $scope.officeDetails1 = function (event) {
            debugger

            $scope.map.showInfoWindow('officeDetails1', this);
        };

        $scope.officeDetails2 = function (event) {
            debugger

            $scope.map.showInfoWindow('officeDetails2', this);
        };


        $scope.officeDetails3 = function (event) {
            debugger

            $scope.map.showInfoWindow('officeDetails3', this);
        };


        $scope.oneorderDetails = function (event, city) {
            debugger
            $scope.selectedCity = city;

            $scope.map.showInfoWindow('oneorderDetails', this);
        };

        $scope.bykeDetails = function (event, PhDetails) {
            debugger
            var bk_lat = PhDetails.lat;
            var bk_long = PhDetails.logi;


            var lat = parseFloat(bk_lat);
            var lng = parseFloat(bk_long);
            var latlng = new google.maps.LatLng(lat, lng);
            var geocoder = geocoder = new google.maps.Geocoder();
            geocoder.geocode({ 'latLng': latlng }, function (results, status) {
                if (status == google.maps.GeocoderStatus.OK) {
                    if (results[1]) {
                        // alert("Location: " + results[1].formatted_address);
                        $scope.GetAddress_lat_long = results[1].formatted_address;

                        //alert("aa" + $scope.GetAddress_lat_long)
                    }
                }
            });

            $scope.selectedPhlibo = PhDetails;


            $scope.map.showInfoWindow('onebykeDetails', this);
        };

        $scope.livebykeDetails = function (event) {
            debugger

            $scope.map.showInfoWindow('livebykeDetails', this);
        };

        $scope.liveorderDetails = function (event) {
            debugger

            $scope.map.showInfoWindow('liveorderDetails', this);
        };



        $scope.wayPoints = [
            { location: { lat: 29.0588, lng: 76.0856 } },
            { location: { lat: 28.5355, lng: 77.3910 } }
        ];





        $scope.officeicon1 = {
            "url": "imgMap/ofc/1.png"
        };

        $scope.officeicon2 = {
            "url": "imgMap/ofc/1.png"
        };

        $scope.byke_history = {
            "url": "imgMap/car/time/3.png"
        };

        $scope.Direction_Byke = {
            "url": "imgMap/car/time/1.png"
        };


        $scope.Homeicon1 = {
            "scaledSize": [32, 32],
            "url": "imgMap/home/1.png"
        };

        $scope.Homeicon2 = {
            "scaledSize": [32, 32],
            "url": "imgMap/home/2.png"
        };

        $scope.historyicon = {
            "scaledSize": [32, 32],
            "url": "imgMap/Icon/history.png"
        };

        $scope.pinImage = new google.maps.MarkerImage("imgMap/car/time/3.png");   

        $scope.status_green = {
            "scaledSize": [32, 32],
            "url": "imgMap/status/green.png"
        };

        $scope.status_yellow = {
            "scaledSize": [32, 32],
            "url": "imgMap/status/yellow.png"
        };

        $scope.status_rad = {
            "scaledSize": [32, 32],
            "url": "imgMap/status/rad.png"
        };


        ///

        $scope.vichles = {
            0: "imgMap/car/time/0.png",
            1: "imgMap/car/time/1.png",
            2: "imgMap/car/time/2.png",
            3: "imgMap/car/time/3.png",
            4: "imgMap/car/time/4.png"

        }

        $scope.vichles_late = {
            0: "imgMap/car/late/0.png",
            1: "imgMap/car/late/1.png",
            2: "imgMap/car/late/2.png",
            3: "imgMap/car/late/3.png",
            4: "imgMap/car/late/4.png"

        }

        $scope.colors = {
            0: "#000099",
            1: "#000099",
            2: "#009933",
            3: "#cc0000",
            4: "#F9B200"

        }

        ////

        $scope.Completed = {
            0: "imgMap/Icon/com/0.png",
            1: "imgMap/Icon/com/1.png",
            2: "imgMap/Icon/com/2.png",
            3: "imgMap/Icon/com/3.png",
            4: "imgMap/Icon/com/4.png"

        }

        $scope.NotCmpleted = {
            0: "imgMap/Icon/noc/0.png",
            1: "imgMap/Icon/noc/1.png",
            2: "imgMap/Icon/noc/2.png",
            3: "imgMap/Icon/noc/3.png",
            4: "imgMap/Icon/noc/4.png"

        }

        $scope.OnGoing = {
            0: "imgMap/Icon/ong/0.png",
            1: "imgMap/Icon/ong/1.png",
            2: "imgMap/Icon/ong/2.png",
            3: "imgMap/Icon/ong/3.png",
            4: "imgMap/Icon/ong/4.png"

        }
        $scope.Cancelled = {
            0: "imgMap/Icon/can/0.png",
            1: "imgMap/Icon/can/1.png",
            2: "imgMap/Icon/can/2.png",
            3: "imgMap/Icon/can/3.png",
            4: "imgMap/Icon/can/4.png"

        }

        $scope.Reschdule = {
            0: "imgMap/Icon/Res/0.png",
            1: "imgMap/Icon/Res/1.png",
            2: "imgMap/Icon/Res/2.png",
            3: "imgMap/Icon/Res/3.png",
            4: "imgMap/Icon/Res/4.png"

        }

        $scope.Get_address_latlong = function (event, lat_set, long_set, TrackDateTime) {
            debugger;
            $scope.TrackDateTime_h = TrackDateTime;
            GetAddress(lat_set, long_set);

            $scope.map.showInfoWindow('AddressLatLongDetails', this);

        }



        function GetAddress(lat_set, long_set) {
            var lat = parseFloat(lat_set);
            var lng = parseFloat(long_set);
            var latlng = new google.maps.LatLng(lat, lng);
            var geocoder = geocoder = new google.maps.Geocoder();
            geocoder.geocode({ 'latLng': latlng }, function (results, status) {
                if (status == google.maps.GeocoderStatus.OK) {
                    if (results[1]) {
                        // alert("Location: " + results[1].formatted_address);
                        $scope.GetAddress_lat_long = results[1].formatted_address;

                        //alert("aa" + $scope.GetAddress_lat_long)
                    }
                }
            });
        }

        //  $timeout(callAtTimeout, 3000);



        $scope.btntxt = 'StopTimer';

        var increaseCounter = function () {

            BindMapDetails(3, $scope.finalvalue)


        }

        ////  $interval(increaseCounter, 10000); // 10 sec


        //var promise = $interval(increaseCounter, 10000);
        //$scope.timeron_off = function () {
        //    debugger
        //    if ($scope.btntxt == 'StopTimer') {
        //        $scope.btntxt = 'StartTimer';
        //        $interval.cancel(promise);
        //    }
        //    else {
        //        $scope.btntxt = 'StopTimer';
        //        promise = $interval(increaseCounter, 10000);
        //    }

        //};


        $scope.Clear_click = function () {
            window.location.reload();
        }

        ////
        var vm = this;

        $scope.historyStart = 0;
        $scope.btnhistoryStarttxt = 'Start';
        $scope.Running_detail = [];

        $scope.historyStart_click = function () {
            debugger
            $scope.Running_detail = [];
            var count = 0;

            if ($scope.btnhistoryStarttxt == 'Start') {
               
                for (var i = 0; i < $scope.history_DetailsDS.length; i++) {
                    $scope.Running_detail.push([$scope.history_DetailsDS[i].lat, $scope.history_DetailsDS[i].lng])
                }

                $scope.btnhistoryStarttxt = 'Stop';

                

            }
            else {
                count = 0;
                $scope.Running_detail = [];
                $scope.Running_detail.push([0,0])
                $scope.btnhistoryStarttxt = 'Start';

               
            }


            debugger;
        }


        NgMap.getMap({ id: 'maptiming' }).then(function (map) {
            count = 0;
            var line = map.shapes.foo;
            $interval(function () {
                count = (count + 1) % 200;
                var icons = line.get('icons');
                icons[0].offset = (count / 2) + '%';
                line.set('icons', icons);
            }, 200);
           

        });





       


    });
})(angular);
