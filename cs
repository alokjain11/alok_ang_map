  protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["u_id"] != null)
        {
            // Functions
            ifrm.Attributes.Add("src", "http://192.168.1.212/czhandler/cti_handler.php?e=" + Session["DialerID"].ToString());
            Iframe1.Attributes.Add("src", "http://192.168.1.212/czhandler/cti_handler.php?e=" + Session["DialerID"].ToString());
            DialerID.Value = Session["DialerID"].ToString();
            HostIP.Value = GetHostIP();
        }
        else
        {
            Response.Redirect("login.aspx", false);
        }
    }

    protected string GetHostIP()
    {
        string HostIPAddress = "";
        var host = Dns.GetHostEntry(Dns.GetHostName());
        foreach (var ip in host.AddressList)
        {
            if (ip.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)
            {
                HostIPAddress = ip.ToString();
            }
        }
        return HostIPAddress;
    }

    [System.Web.Services.WebMethod()]
    public static string Get_Order_for_Routing_user_interface(string Pickup_Time_Type)
    {
        DateTime pickup_Date;
        string Order_View = "";
        int Breck = 0;
        int phlebo_free_time_mnt_1 = 0;
        int Breck1 = 0;
        int loop_breck = 0;
        int loop_final = 0;
        int Route_Id = 1;
        string random;
        string random_number;
        string from_latitude = "";
        string from_longitude = "";
        int From_New_Pickup_Time = 0;
        double distance_km = 0;
        double duration_mnt = 0;

        DataSet ds1 = new DataSet();
        if (Convert.ToInt32(Pickup_Time_Type.ToString()) == 1)
        {
            pickup_Date = Convert.ToDateTime(System.DateTime.Now.AddDays(1).ToString("yyyy-MM-dd"));
        }
        else
        {
            pickup_Date = Convert.ToDateTime(System.DateTime.Now.ToString("yyyy-MM-dd"));
        }

        DataTable dt = new DataTable();
        string json = "";
        DBController dbc = new DBController();

        if (object.Equals(dbc, null))
        {
            dbc = new DBController();
        }
        SqlParameter[] sqlPar = new SqlParameter[1];
        sqlPar[0] = dbc.MakeInParameter("@o_date", SqlDbType.DateTime, 50, pickup_Date);
        dbc.RunProcedure("sp_get_details_for_user_interface", sqlPar, out ds1);

        if (ds1.Tables[0].Rows.Count > 0)
        {
            dt = new DataTable();
            dt = ds1.Tables[0];

            string css = "";
            int p_check = 0;
            Breck = 1;
            Breck1 = 0;
            loop_final = 1;
            int d_width = 40;
            if (loop_breck == 0)
            {
                loop_breck = 1;
                DataTable drag_route = new DataTable();
                drag_route = dt.Copy();

                drag_route.DefaultView.Sort = "New_Pickup_Time ASC";
                drag_route = drag_route.DefaultView.ToTable();
                drag_route.AcceptChanges();

                int pickup_start = Convert.ToInt32(drag_route.Rows[0]["New_Pickup_Time"].ToString()) - 15;

                drag_route.DefaultView.Sort = "New_Pickup_Time DESC";
                drag_route = drag_route.DefaultView.ToTable();
                drag_route.AcceptChanges();

                int pickup_end = Convert.ToInt32(drag_route.Rows[0]["New_Pickup_Time"].ToString()) + 30;

                drag_route.DefaultView.Sort = "Route_Id DESC";
                drag_route = drag_route.DefaultView.ToTable();
                drag_route.AcceptChanges();

                Route_Id = Convert.ToInt32(drag_route.Rows[0]["Route_Id"].ToString());

                Order_View = " <table width='" + d_width + "px'><tr> <td align='left' width='" + d_width + "px'><table width='" + d_width + "px' id='fix_table' style='position: fixed;margin-left:30px;'><tr>";

                DataTable ddd = new DataTable();
                ddd = ds1.Tables[1].Clone();

                for (int i = 0; i < Route_Id + 1; i++)
                {
                    DataRow[] wwwe = ds1.Tables[1].Select("Route_id='" + (i + 1) + "'");

                    foreach (DataRow row in wwwe)
                    {

                        ddd.Rows.Add(row[0], row[1], row[2], row[3]);
                    }

                    int number_of_pickup = 0;

                    for (int ee = 0; ee < ds1.Tables[0].Rows.Count; ee++)
                    {
                        if (Convert.ToInt32(ds1.Tables[0].Rows[ee]["route_id"].ToString()) == (i + 1))
                        {
                            number_of_pickup = number_of_pickup + 1;
                        }
                    }

                    try
                    {
                        Order_View += "<td align='center' class='sortable-list12'><div class='sortable-item12'>Route: " + (i + 1) + "-" + number_of_pickup + "<br />" + ddd.Rows[i]["Zone"].ToString() + "</div></td></div>";
                    }
                    catch (Exception)
                    {

                        Order_View += "<td align='center' class='sortable-list12'><div class='sortable-item12'>Route:<br /> " + (i + 1) + "-" + number_of_pickup + "<br /></div></td></div>";
                    }

                    d_width = d_width + 40;
                }
                Order_View += "</tr></table>";

                Order_View += "<table id='mt_table' width='" + d_width + "px' style='margin-top:0px;'><tr><td><div class='sortable-item13_TR'>T/R</div></td></tr><tr align='left'><td align='left' id='left_td' valign='top' style='width:30px'><ul class='sortable-list11'>";
                int aa = 0;
                for (int i = 0; i < ((pickup_end - pickup_start) / 15); i++)
                {
                    if (i == 0)
                    {
                        aa = 0;
                        aa = pickup_start;
                    }
                    int ptt = aa - ((aa / 60) * 60);

                    string ptts = "";
                    if (ptt < 10)
                    {
                        ptts = "0" + Convert.ToString(ptt);
                    }
                    else
                    {
                        ptts = Convert.ToString(ptt);
                    }

                    string pahar = "";

                    if ((aa / 60) > 12)
                    {
                        pahar = "<br />PM";
                    }
                    else
                    {
                        pahar = "<br />AM";
                    }

                    string cc_o_time = Convert.ToString(aa / 60) + ":" + ptts + pahar;

                    Order_View += "<li class='sortable-item11' id='Li1'>" + cc_o_time + "</li>";

                    aa = aa + 15;
                }
                Order_View += "</ul></td>";

                drag_route.DefaultView.Sort = "Route_Id ASC";
                drag_route = drag_route.DefaultView.ToTable();
                drag_route.AcceptChanges();

                for (int r = 0; r < Route_Id + 1; r++)
                {
                    p_check = 0;
                    css = "class='div_css'";
                    phlebo_free_time_mnt_1 = 0;
                    Order_View += "<td id='tr_mar'>";

                    DataTable drag = new DataTable();
                    drag = drag_route.Clone();
                    DataRow[] result = drag_route.Select("Route_Id=" + (r + 1) + "");
                    foreach (DataRow row in result)
                    {
                        drag.Rows.Add(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13], row[14], row[15], row[16], row[17], row[18]);
                    }

                    int ff = 0;
                    for (int i = 0; i < ((pickup_end - pickup_start) / 15); i++)
                    {
                        if (i == 0)
                        {
                            ff = 0;
                            ff = pickup_start;
                            css = "class='div_css'";
                        }

                        DataTable main_loop = new DataTable(); main_loop = drag.Clone();
                        DataRow[] resultmain = drag.Select("New_Pickup_Time='" + ff + "'");
                        foreach (DataRow row in resultmain)
                        {
                            main_loop.Rows.Add(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13], row[14], row[15], row[16], row[17], row[18]);
                        }
                        if (main_loop.Rows.Count > 0)
                        {
                            css = "class='div_css'";
                            p_check = p_check + 1;
                            int aaa = Convert.ToInt32(main_loop.Rows[0]["old_o_time"].ToString());
                            int bb = Convert.ToInt32(main_loop.Rows[0]["New_Pickup_Time"].ToString());
                            int ptt = aaa - ((aaa / 60) * 60);

                            string ptts = "";
                            if (ptt < 10)
                            {
                                ptts = "0" + Convert.ToString(ptt);
                            }
                            else
                            {
                                ptts = Convert.ToString(ptt);
                            }

                            string pahar = "";

                            if ((aaa / 60) > 12)
                            {
                                pahar = " PM";
                            }
                            else
                            {
                                pahar = " AM";
                            }

                            string cc_o_time = Convert.ToString(aaa / 60) + ":" + ptts + pahar;

                            int ptb = bb - ((bb / 60) * 60);
                            string ptbs = "";
                            if (ptb < 10)
                            {
                                ptbs = "0" + Convert.ToString(ptb);
                            }
                            else
                            {
                                ptbs = Convert.ToString(ptb);
                            }

                            string pahar1 = "";

                            if ((bb / 60) > 12)
                            {
                                pahar1 = " PM";
                            }
                            else
                            {
                                pahar1 = " AM";
                            }

                            string ccb_New_Pickup_Time = Convert.ToString(bb / 60) + ":" + ptbs + pahar1;

                            string id = (main_loop.Rows[0]["Pickup_Address"].ToString() + "#" + main_loop.Rows[0]["o_date"].ToString() + "#" + main_loop.Rows[0]["Order_id"].ToString() + "#" + main_loop.Rows[0]["o_time"].ToString());
                            string[] chars = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N","O", "P", "Q", "R", "S",

                        "T", "U", "V", "W", "X", "Y", "Z"};

                            Random rnd = new Random();

                            random = string.Empty;

                            for (int ie = 0; ie < 6; ie++)
                            {
                                random += chars[rnd.Next(0, 26)];
                            }
                            string[] chars1 = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13","14", "15", "16", "17", "18",

                        "19", "20", "21", "22", "23", "24", "25"};

                            Random rnd1 = new Random();

                            random_number = string.Empty;

                            for (int ie = 0; ie < 6; ie++)
                            {
                                random_number += chars[rnd.Next(0, 26)];
                            }
                            string idd = random + random_number;

                            //string[] add = main_loop.Rows[0]["a_geo_Address"].ToString().Split(',');
                            //string form_add = "";
                            //for (int e = 0; e < add.Length; e++)
                            //{
                            //    form_add += add[e].ToString() + "<br />";
                            //}

                            //form_add = form_add.Substring(0, form_add.Length - 6);

                            string Details = "<table style='width:98%'><tr><td><p style='margin-top:-0.5px;text-align:left;width:95%;word-wrap: break-word; white-space: wrap; word-wrap: break-word;font-size: 8.5px;'>" + main_loop.Rows[0]["a_geo_Address"].ToString() + "<br />" + "OPT: " + cc_o_time + "&nbsp;" + "NPT: " + ccb_New_Pickup_Time + "<br /></p></td></tr></table>";
                            string Min_Details = "<p style='margin-top:-0.5px;text-align:center'>" + main_loop.Rows[0]["a_geo_Address1"].ToString() + "</p>";
                            string main_id = Convert.ToString(r + 1) + "#" + Convert.ToString(ff) + "#" + idd;

                            if (p_check == 1)
                            {

                                from_latitude = "";
                                from_longitude = "";
                                From_New_Pickup_Time = 0;

                                from_latitude = main_loop.Rows[0]["a_geo_latitude"].ToString();
                                from_longitude = main_loop.Rows[0]["a_geo_longitude"].ToString();
                                From_New_Pickup_Time = Convert.ToInt32(main_loop.Rows[0]["New_Pickup_Time"].ToString());
                            }

                            if (p_check > 1)
                            {
                                double rlat1 = Math.PI * Convert.ToDouble(from_latitude) / 180;
                                double rlat2 = Math.PI * Convert.ToDouble(main_loop.Rows[0]["a_geo_latitude"].ToString()) / 180;
                                double theta = Convert.ToDouble(from_longitude) - Convert.ToDouble(main_loop.Rows[0]["a_geo_longitude"].ToString());
                                double rtheta = Math.PI * theta / 180;
                                double dist =
                                    Math.Sin(rlat1) * Math.Sin(rlat2) + Math.Cos(rlat1) *
                                    Math.Cos(rlat2) * Math.Cos(rtheta);
                                dist = Math.Acos(dist);
                                dist = dist * 180 / Math.PI;
                                dist = dist * 60 * 1.1515;
                                dist = dist * 1.609344;
                                double dist_km = dist;

                                if (Convert.ToString(dist_km) == "NaN")
                                {
                                    dist_km = 0;
                                }
                                distance_km = Convert.ToDouble(dist_km + (dist_km * 45 / 100));

                                duration_mnt = (Convert.ToDouble(distance_km / 30) * 60) + 10;

                                if (duration_mnt == 10)
                                {
                                    duration_mnt = 20;
                                }

                                phlebo_free_time_mnt_1 = (Convert.ToInt32(main_loop.Rows[0]["New_Pickup_Time"].ToString()) - Convert.ToInt32(From_New_Pickup_Time)) - ((Convert.ToInt32(main_loop.Rows[0]["number_of_pickup"].ToString()) * 15) + Convert.ToInt32(duration_mnt));

                                from_latitude = main_loop.Rows[0]["a_geo_latitude"].ToString();
                                from_longitude = main_loop.Rows[0]["a_geo_longitude"].ToString();
                                From_New_Pickup_Time = Convert.ToInt32(main_loop.Rows[0]["New_Pickup_Time"].ToString());
                            }

                            string[] a;
                            string o_id = "";
                            try
                            {
                                a = id.ToString().Split('#');
                                o_id = a[2].ToString().Trim().TrimEnd(',');
                            }
                            catch (Exception)
                            {
                            }

                            //try
                            //{
                            //    if (o_id.ToString() != "" && o_id.ToString() != null)
                            //    {

                            //        if (object.Equals(dbc, null))
                            //        {
                            //            dbc = new DBController();
                            //        }
                            //        SqlParameter[] sqlParam = new SqlParameter[1];
                            //        sqlParam[0] = dbc.MakeInParameter("@o_id", SqlDbType.VarChar, 500, o_id.ToString());
                            //        dbc.RunProcedure("sp_get_order_status_and_disposition", sqlParam, out ds);

                            //        if (ds.Tables[0].Rows.Count > 0)
                            //        {
                            //            if (ds.Tables[0].Rows[0]["o_status"].ToString() != "1")
                            //            {
                            //                css = "class='div_css_5'";
                            //            }
                            //            else if (ds.Tables[0].Rows[0]["o_status"].ToString() == "1" && ds.Tables[0].Rows[0]["Desposition"].ToString() != "")
                            //            {
                            //                css = "class='div_css_6'";
                            //            }
                            //        }
                            //    }
                            //}
                            //catch (Exception)
                            //{

                            //}

                            if (main_loop.Rows[0]["old_o_time"].ToString() == main_loop.Rows[0]["New_Pickup_Time"].ToString() && phlebo_free_time_mnt_1 >= 0)
                            {
                                css = "class='div_css'";
                            }
                            else if (main_loop.Rows[0]["old_o_time"].ToString() != main_loop.Rows[0]["New_Pickup_Time"].ToString() && phlebo_free_time_mnt_1 >= 0)
                            {
                                css = "class='div_css_1'";
                            }
                            else if (main_loop.Rows[0]["old_o_time"].ToString() == main_loop.Rows[0]["New_Pickup_Time"].ToString() && phlebo_free_time_mnt_1 < 0)
                            {
                                css = "class='div_css_2'";
                            }
                            else if (main_loop.Rows[0]["old_o_time"].ToString() != main_loop.Rows[0]["New_Pickup_Time"].ToString() && phlebo_free_time_mnt_1 < 0)
                            {
                                css = "class='div_css_3'";
                            }

                            if (main_loop.Rows[0]["dup_number"].ToString() == "1")
                            {
                                css = "class='div_css_4'";
                            }

                            if (main_loop.Rows[0]["isinprocess"].ToString() == "1")
                            {
                                css = "class='div_css_6'";
                            }

                            Order_View += "<a runat='server' style='text-decoration:none' onclick='ShowPopup(this.id);' id='" + id.ToString() + "' class='gridViewToolTip'><div " + css + " id='" + main_id + "'>";
                            Order_View += "<div " + css + " id='" + id.ToString() + "' draggable='true' ondragstart='drag(event)'>" + Details + "</div>";
                            Order_View += "</div></a>";
                            ff = ff + 15;
                        }
                        else
                        {
                            string main_string = Convert.ToString(r + 1) + "#" + Convert.ToString(ff);
                            Order_View += "<div class='div_css_blank' id='" + main_string + "' onclick='drop(this.id)'></div>";

                            string latitude_from = "";
                            string longitude_from = "";
                            string main_id = "";
                            string bloog_Id = "";
                            string pickup_time_from = "";

                            DataTable sorted_dt = new DataTable();
                            sorted_dt.Columns.Add("Bloog_Id", typeof(string));
                            sorted_dt.Columns.Add("Main_Id", typeof(string));
                            sorted_dt.Columns.Add("Km", typeof(double));
                            sorted_dt.Columns.Add("Duration_Mnt", typeof(int));
                            sorted_dt.Columns.Add("Phlebo_Free_Time", typeof(int));

                            for (int tt = 0; tt < drag_route.Rows.Count; tt++)
                            {
                                if (drag_route.Rows[tt]["isinprocess"].ToString() == "1")
                                {
                                    latitude_from = drag_route.Rows[tt]["a_geo_latitude"].ToString();
                                    longitude_from = drag_route.Rows[tt]["a_geo_longitude"].ToString();
                                    main_id = (drag_route.Rows[tt]["Pickup_Address"].ToString() + "#" + drag_route.Rows[tt]["o_date"].ToString() + "#" + drag_route.Rows[tt]["Order_id"].ToString() + "#" + drag_route.Rows[tt]["old_o_time"].ToString());
                                    pickup_time_from = drag_route.Rows[tt]["old_o_time"].ToString();
                                }
                            }
                            if (latitude_from.ToString() != "" && longitude_from.ToString() != "" && main_id.ToString() != "" && pickup_time_from.ToString() != "")
                            {
                                for (int ab = 0; ab < ((pickup_end - pickup_start) / 15); ab++)
                                {

                                }

                                //for (int ii = 0; ii < drag.Rows.Count; ii++)
                                //{
                                //    if (drag.Rows[ii]["isinprocess"].ToString() != "1")
                                //    {
                                //        double rlat1 = Math.PI * Convert.ToDouble(latitude_from) / 180;
                                //        double rlat2 = Math.PI * Convert.ToDouble(drag.Rows[ii]["a_geo_latitude"].ToString()) / 180;
                                //        double theta = Convert.ToDouble(longitude_from) - Convert.ToDouble(drag.Rows[ii]["a_geo_longitude"].ToString());
                                //        double rtheta = Math.PI * theta / 180;
                                //        double dist =
                                //            Math.Sin(rlat1) * Math.Sin(rlat2) + Math.Cos(rlat1) *
                                //            Math.Cos(rlat2) * Math.Cos(rtheta);
                                //        dist = Math.Acos(dist);
                                //        dist = dist * 180 / Math.PI;
                                //        dist = dist * 60 * 1.1515;
                                //        dist = dist * 1.609344;
                                //        double dist_km = dist;

                                //        if (Convert.ToString(dist_km) == "NaN")
                                //        {
                                //            dist_km = 0;
                                //        }
                                //        distance_km = Convert.ToDouble(dist_km + (dist_km * Convert.ToInt32(txt_Average_Per.Text.Trim()) / 100));

                                //        duration_mnt = Convert.ToDouble(distance_km / Convert.ToInt32(txt_km_Per_Hrs.Text.Trim())) * 60 + Convert.ToInt32(txt_Grace_Time.Text.Trim());

                                //        bloog_Id = Convert.ToString(drag.Rows[ii]["Route_Id"].ToString()) + "#" + Convert.ToString(drag.Rows[ii]["o_time"].ToString());

                                //        int phlebo_free_time_mnt = (Convert.ToInt32(pickup_time_from) - Convert.ToInt32(drag.Rows[ii]["o_time"].ToString())) - ((Convert.ToInt32(drag.Rows[ii]["number_of_pickup"].ToString()) * 15) + Convert.ToInt32(duration_mnt));
                                //        sorted_dt.Rows.Add(bloog_Id, main_id, distance_km, duration_mnt, phlebo_free_time_mnt);
                                //    }
                                //}
                            }
                            ff = ff + 15;
                        }
                    }

                    Order_View += "</td>";
                }

                Order_View += "</tr></table></div></div></td><td align='left' valign='top' style='width:150px;position: fixed;'>";

                DataTable drag_outher = new DataTable();
                drag_outher = drag_route.Clone();
                DataRow[] free_result = drag_route.Select("Route_Id=0");
                foreach (DataRow row in free_result)
                {
                    drag_outher.Rows.Add(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13], row[14], row[15], row[16]);
                }

                Order_View += "<table align='left' valign='top' style='width:30px;margin-top:45px;'>";

                DataView dv = drag_outher.DefaultView;
                dv.Sort = "ZONE desc";
                drag_outher = dv.ToTable();


                for (int t = 0; t < drag_outher.Rows.Count; t++)
                {
                    int aaa = Convert.ToInt32(drag_outher.Rows[t]["old_o_time"].ToString());
                    int bb = Convert.ToInt32(drag_outher.Rows[t]["New_Pickup_Time"].ToString());
                    int ptt = aaa - ((aaa / 60) * 60);

                    string ptts = "";
                    if (ptt < 10)
                    {
                        ptts = "0" + Convert.ToString(ptt);
                    }
                    else
                    {
                        ptts = Convert.ToString(ptt);
                    }

                    string pahar = "";

                    if ((aaa / 60) > 12)
                    {
                        pahar = " PM";
                    }
                    else
                    {
                        pahar = " AM";
                    }

                    string cc_o_time = Convert.ToString(aaa / 60) + ":" + ptts + pahar;

                    int ptb = bb - ((bb / 60) * 60);
                    string ptbs = "";
                    if (ptb < 10)
                    {
                        ptbs = "0" + Convert.ToString(ptb);
                    }
                    else
                    {
                        ptbs = Convert.ToString(ptb);
                    }

                    string pahar1 = "";

                    if ((bb / 60) > 12)
                    {
                        pahar1 = " PM";
                    }
                    else
                    {
                        pahar1 = " AM";
                    }

                    string ccb_New_Pickup_Time = Convert.ToString(bb / 60) + ":" + ptbs + pahar1;

                    string id = (drag_outher.Rows[t]["Pickup_Address"].ToString() + "#" + drag_outher.Rows[t]["o_date"].ToString() + "#" + drag_outher.Rows[t]["Order_id"].ToString() + "#" + drag_outher.Rows[0]["old_o_time"].ToString());
                    string[] chars = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N","O", "P", "Q", "R", "S",

                        "T", "U", "V", "W", "X", "Y", "Z"};

                    Random rnd = new Random();

                    random = string.Empty;

                    for (int ie = 0; ie < 6; ie++)
                    {
                        random += chars[rnd.Next(0, 26)];
                    }
                    string[] chars1 = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13","14", "15", "16", "17", "18",

                        "19", "20", "21", "22", "23", "24", "25"};

                    Random rnd1 = new Random();

                    random_number = string.Empty;

                    for (int ie = 0; ie < 6; ie++)
                    {
                        random_number += chars[rnd.Next(0, 26)];
                    }
                    string idd = random + random_number;
                    string[] add = drag_outher.Rows[t]["a_geo_Address"].ToString().Split(',');
                    string form_add = "";
                    for (int e = 0; e < add.Length; e++)
                    {
                        form_add += add[e].ToString() + "<br />";
                    }

                    form_add = form_add.Substring(0, form_add.Length - 6);
                    string Details = "<table style='width:200px'><tr><td><p>" + "Route Id: " + drag_outher.Rows[t]["Route_Id"].ToString() + "<br />" + "Geo Add: " + form_add.ToString() + "<br />" + "OPT: " + cc_o_time + "<br />" + "NPT: " + ccb_New_Pickup_Time + "<br />" + "No. Of Pickup: " + drag_outher.Rows[t]["number_of_pickup"].ToString() + "<br />" + "CM Id: " + drag_outher.Rows[t]["ca_mob"].ToString() + "</td></tr></table></p>";
                    string Min_Details = "<p style='margin-top:-0.5px;text-align:center'>" + drag_outher.Rows[t]["a_geo_Address1"].ToString() + "";

                    //css = "";
                    if (drag_outher.Rows[t]["old_o_time"].ToString() == drag_outher.Rows[t]["New_Pickup_Time"].ToString())
                    {
                        css = "class='sortable-item'";
                    }
                    else
                    {
                        css = "class='sortable-item_d'";
                    }
                    string main_id = Convert.ToString(0) + "#" + Convert.ToString(0) + "#" + idd;
                    Order_View += "<tr><td><a style='text-decoration:none' onclick='ShowPopup(this.id);' id='" + id.ToString() + "' class='gridViewToolTip'><div class='div_css' id='" + main_id + "' onclick='drop(this.id)'";
                    Order_View += "<div class='div_css' id='" + drag_outher.Rows[t]["Order_id"].ToString() + "' draggable='true' ondragstart='drag(event)'>" + Details + "</div>";
                    Order_View += "</div></a>";
                    Order_View += "</td></tr>";
                }
                Order_View += "</table></td></tr></table>";
            }
        }
        return Order_View;
    }
