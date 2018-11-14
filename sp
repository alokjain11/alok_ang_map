                            
           
                            
CREATE proc [dbo].[SP_Get_Phlebos_Trackers_V2]                                                                      
(                                                                      
@Action int =3,                                                                      
@Phlebos_ManagerId int = 0,                                                                    
@phleboId Varchar(max)='2228',                                                        
@Detail varchar(50)='TotalCancelled',                                                      
@OrderId varchar(30)='',                      
@CmId Int=0                                                                   
)                                                                      
AS                                                                
                                                          
                                                                 
BEGIN                                                                      
                                                                    
   Declare @Date date=cast(dateadd(minute,330,Getdate()) as date)          
   Declare @Online Int                
   Declare @Offline Int                
   Declare @NotAssigned Int                                                     
   Declare @Total Int         
   Declare @TotalAdd Int         
   Declare @Reschedule int        
   Declare @LateCancel int        
   Declare @RecentlyCancelled int        
   Declare @TotalCancelledAddress int        
   Declare @TotalCancelled int        
   Declare @OnTime int        
   Declare @Late int        
   Declare @CompletedPickUpAddress int          
   Declare @CompletedPickUp int          
   Declare @PendingPickUp int        
                                                                        
  Declare @tab table(id int identity(1,1),Phleboid int)                                                                    
                                                                    
  Insert into  @tab                                                                    
  Select * from dbo.SplitString(@phleboId,',')                                                                    
              
  Declare @tbl TABLE(Id int identity(1,1),PhleboId int,PhleboStatus varchar(50))                
              
  Insert Into @tbl          
  Select phra.phlebo_id,isnull('('+ISNULL(max(l.l_ShortName),'')+'-A'+cast(count(phlebo_id) as varchar)          
  +'/P'+cast(count(case when (o_status!=99 and ps_date=o_date ) then phlebo_id end) as varchar)+          
   +'/R'+cast(count(case when (o_status!=99 and ps_date<o_date) then phlebo_id end) as varchar)+          
  '/C' +Cast(count(case when o_status=99 then phlebo_id end) as varchar)+')','') C  from           
  customer_order ord           
  inner join pickup_schedule ps on ord.o_id=ps.order_o_id   --and ps_date=o_date                                                         
  inner join pickup_route_assign ra on ra.ps_id = ps.ps_id and status=1                                                                                              
  inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id  and Status_Info=1                                                          
  Inner join reporting_to r on r.re_userid=phra.phlebo_id                    
  inner join user_informations u on r.re_userid=u.userid                                                        
  inner join User_login ul on ul.user_id=u.userid            
  left join  locations l on l.locations_id=u.u_locations and l.l_status=1                                                       
  where u.u_enable=1 and r.re_enable=1  and ul.user_role_r_id=8 and ul.U_enable=1 and ps_date=@Date and          
  r.re_reporting_id=case when @Phlebos_ManagerId=0 then r.re_reporting_id else @Phlebos_ManagerId end             
  group by phra.phlebo_id            
                                                                    
if (@Action = 1)                                                
                                                                    
 begin                                                                    
          
  Select u.userid,u.u_name from User_login ul                                                                       
  inner join user_informations u on ul.user_id=u.userid                                                                      
  Where user_role_r_id = 9 and u.u_enable=1 and ul.U_enable=1                
  and u.userid=case when @Phlebos_ManagerId=0 then u.userid else @Phlebos_ManagerId end              
  order by u.u_name                                                                      
                                                 
 end                                                                      
                                                                      
else if (@Action = 2)                                                                    
                                                                    
 begin                                                                      
                                                                     
  Select u.userid,u.u_name+' '+isnull(t.PhleboStatus,'(A0/P0/R0/C0)') as u_name from reporting_to r                                                                      
  inner join user_informations u on r.re_userid=u.userid                                                                    
  inner join  User_login ul on ul.user_id=u.userid          
  left join @tbl t on t.PhleboId=u.userid                                                                      
  where u.u_enable=1 and r.re_enable=1  and ul.user_role_r_id=8 and  ul.U_enable=1 and                                                                 
  re_reporting_id=case when @Phlebos_ManagerId=0 then re_reporting_id else @Phlebos_ManagerId end                            
  order by u.u_name                                                              
                                                            
  Select @TotalAdd=count(distinct cm_id) ,@CompletedPickUpAddress=count(distinct case when (ord.o_status not in (1,2,3)) then cm_id end),             
  @Total=count(cm_id),@CompletedPickUp=count(case when (ord.o_status not in (1,2,3)) then cm_id end),                      
  @PendingPickUp=count(case when (ord.o_status in (1,2,3)) then cm_id end) from             
  customer_account ac             
  Inner join customer_order ord on ord.ca_id=ac.ca_id            
  inner join pickup_schedule ps on ord.o_id=ps.order_o_id  and ps_date=o_date                                                                
  inner join pickup_route_assign ra on ra.ps_id = ps.ps_id  and status=1                                                                                                     
  inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id  and Status_Info=1                                                                  
  Inner join reporting_to r on r.re_userid=phra.phlebo_id                                                                  
  where ps_date=@Date and r.re_reporting_id=case when @Phlebos_ManagerId=0 then r.re_reporting_id else @Phlebos_ManagerId end          
          
  Select  @TotalAdd as TotalPickupAddress,@CompletedPickUpAddress as CompletedPickUpAddress,@Total as TotalPickup,@CompletedPickUp as CompletedPickUp,        
   cast(@PendingPickUp as varchar(10)) +' ('+ cast(cast((@PendingPickUp*100/cast(@Total as float)) as decimal(10,2)) as varchar(20))+'%)' as PendingPickUp                                                        
                          
                                                                         
 end                          
                             
else if (@Action = 3)                                                                    
                                                         
 begin                                                                      
                               
                       
 Select  *,case when PickUpStatus1='NotCmpleted' and r=1 then 'OnGoing' else PickUpStatus1 end  PickUpStatus                 
  Into #t1 from(                                        
  Select distinct cm_id,              
  phlebo_id p,ps_time h,                        
  sch.ps_time,CONVERT(VARCHAR(5), sch.ps_time, 108) + ' ' +RIGHT(CONVERT(VARCHAR(30), sch.ps_time, 9),2) pickuptime,                                 
  REPLACE(REPLACE ((ISNULL(addr.a_address_line_1,'')+'/'+ISNULL(a_address_line_2,'')+'/'+ISNULL(replace(a_landmark,'/',''),'')+'/'+ISNULL(a_geo_address,'')),'''',''),'"','') pickupaddress,                                                               
  left(a_geo_longitude,10) a_geo_longitude,left(a_geo_latitude,10) a_geo_latitude,pt.Latitude lat,pt.Longitude logi,                                                                
  dense_rank() over (partition by phlebo_id order by ps_time,left(a_geo_longitude,10)+''+left(a_geo_latitude,10))OrderSequence,                                                                    
  dense_rank() over (order by phlebo_id) PhleboOrder,                                        
  dense_rank() over (Partition by Phlebo_Reached_Time Order by  ps_time) r,phlebo_id as PhleboId,ui.u_name as PhleboName,ui.u_mobileno as PhleboMobileNo,                            
  case when ord.o_status=99 then 'Cancelled' else  case when (ps_date<o_date ) then 'Reschedule'          
   when (ps_date=o_date and (sch.Phlebo_Reached_Time is not null or ord.o_status>=5)) then 'Completed'                               
  else 'NotCmpleted' end end PickUpStatus1,ca_mob CustomerMobileNo,                                            
  case when uis.L_latitude is null then ui.lat else uis.L_latitude end OfficeLat,          
  case when uis.L_Longitude is null then ui.logi else uis.L_Longitude end OfficeLong                                                                  
  ,datediff(Minute,cast(dateadd(minute,330,getdate()) as time),sch.ps_time) TimeDiff ,ui.lat PhleboHomeLat,ui.logi PhleboHomeLong,CONVERT(VARCHAR(20), pt.TrackDateTime, 113) PhleboDateTime,              
   Phlebo_Reached_Time,case when sch.ps_time<Phlebo_Reached_Time then cast(abs(datediff(Minute,Phlebo_Reached_Time,sch.ps_time)) as varchar)+' Min Late' end ReachedTimeDiff              
  FROM customer_order ord                                                                    
  inner join customer_account acc on acc.ca_id = ord.ca_id                                                                                                       
  inner join customer_order_pickup_address addr on addr.order_id = ord.o_id                                                                   
  inner join pickup_schedule sch on sch.order_o_id = addr.order_id --and ps_date=o_date                                                                                                      
  inner join pickup_route_assign ra on ra.ps_id = sch.ps_id  and status=1                                                                                             
  inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id and Status_Info=1                                                                     
  inner join user_informations ui on ui.userid=phlebo_id                                               
  left join locations uis on uis.locations_id=ui.u_locations and uis.l_status=1                                           
  left join tbl_phlebo_live_Track pt on pt.PhleboId=phlebo_id                                                                   
  where phlebo_id In  (Select Phleboid from @tab) and ui.u_enable=1 and phra.Status_Info=1 and ra.status=1 and ps_date = @Date                                                                                  
   )c             
  order by phleboid,ps_time                    
                  
 Select distinct t1.cm_id,t1.ps_time,t1.pickuptime,t1.pickupaddress,t1.a_geo_longitude,t1.a_geo_latitude,t1.lat,t1.logi,t1.OrderSequence,t1.PhleboOrder,t1.r,t1.PhleboId,                
 t1.PhleboName,t1.PhleboMobileNo,t1.OfficeLat,t1.OfficeLong,t1.TimeDiff,t1.PhleboHomeLat,t1.PhleboHomeLong,                
 CASE WHEN max(T1.PICKUPSTATUS1)='Completed' THEN 'Completed' else max(T1.PICKUPSTATUS1) end PICKUPSTATUS,          
 CASE WHEN max(T1.PICKUPSTATUS1)!=min(T1.PICKUPSTATUS1) THEN 'PC' when max(T1.PICKUPSTATUS1)='Cancelled' THEN 'CA'           
 when max(T1.PICKUPSTATUS1)='Completed' THEN 'CO' else max(T1.PICKUPSTATUS1) end PICKUPSTATUSColor          
 ,PhleboDateTime,Phlebo_Reached_Time,ReachedTimeDiff,a_geo_longitude+''+a_geo_latitude              
  from #t1 t1                
 group by                 
 t1.cm_id,t1.ps_time,t1.pickuptime,t1.pickupaddress,t1.a_geo_longitude,t1.a_geo_latitude,t1.lat,t1.logi,t1.OrderSequence,t1.PhleboOrder,t1.r,t1.PhleboId,                
 t1.PhleboName,t1.PhleboMobileNo,t1.OfficeLat,t1.OfficeLong,t1.TimeDiff,t1.PhleboHomeLat,t1.PhleboHomeLong,t1.PhleboDateTime,t1.Phlebo_Reached_Time,ReachedTimeDiff              
 order by t1.ps_time,a_geo_longitude+''+a_geo_latitude               
                 
    Drop Table #t1                                                              
                                                                 
 end                                                               
                                                          
else if(@Action=4)                                                          
                                                          
 begin                                                          
                             
                                                           
  Select Distinct case when datediff(Minute,TrackDateTime,dateadd(minute,330,getdate()))<=10 then 'Online' else 'Offline'  end PhleboStatus,u.userid,u.u_name                                                           
  into #t from                   
  pickup_schedule ps --on ord.o_id=ps.order_o_id                                                                  
  inner join pickup_route_assign ra on ra.ps_id = ps.ps_id  and status=1                                                                                                     
  inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id  and Status_Info=1                       
  inner join reporting_to r on r.re_userid =phra.phlebo_id                                          
  inner join user_informations u on r.re_userid=u.userid                              
  inner join  User_login ul on ul.user_id=u.userid                                                          
  left join tbl_phlebo_live_Track lt on lt.PhleboId=u.userid                                                          
  where ps_date=@Date and u.u_enable=1 and r.re_enable=1  and ul.user_role_r_id=8 and  ul.U_enable=1    and                                                      
  re_reporting_id=case when @Phlebos_ManagerId=0 then re_reporting_id else @Phlebos_ManagerId end                             
  order by u.u_name                               
                      
                                                           
    Select @Online=count(Case when PhleboStatus='Online' then 1 end)                                                         
   ,@Offline=count(Case when PhleboStatus='Offline' then 1 end)  from #t                   
                 
    Select @Total=count(distinct u.userid),@NotAssigned=count(distinct u.userid)-count(distinct t.userid) from user_informations u                   
    inner join User_login ul on ul.user_id=u.userid            
    inner join reporting_to r on r.re_userid=ul.user_id                  
    left join #t t on t.userid=u.userid                 
    where ul.user_role_r_id=8           
 and ul.U_enable=1 and u.u_enable=1 and  re_reporting_id=case when @Phlebos_ManagerId=0 then re_reporting_id else @Phlebos_ManagerId end                 
                              
  Select  cast(@Online as varchar(10)) +' ('+ cast(cast((@Online*100/cast(@Total as float)) as decimal(10,2)) as varchar(20))+'%)' as 'Online',        
  cast(@Offline as varchar(10)) +' ('+ cast(cast((@Offline*100/cast(@Total as float)) as decimal(10,2)) as varchar(20))+'%)' as 'Offline',        
  cast(@NotAssigned as varchar(10)) +' ('+ cast(cast((@NotAssigned*100/cast(@Total as float)) as decimal(10,2)) as varchar(20))+'%)' as 'NotAssigned'        
         
  --Select  @Online as 'Online',@Offline as 'Offline',@NotAssigned as 'NotAssigned'                                     
                                                           
  If(@Detail='Online')                                                          
                        
  begin                                                          
                                                            
     Select Distinct userid,u_name+' '+isnull(t.PhleboStatus,'(A0/P0/R0/C0)') as u_name from #t  left join @tbl t on t.PhleboId=userid   where #t.PhleboStatus='Online'           
  order by u_name                                                        
                                                            
  end                                                       
                                                            
  Else If (@Detail='Offline')                                                            
                                                            
  Begin                                                          
                                                            
     Select Distinct userid,u_name+' '+isnull(t.PhleboStatus,'(A0/P0/R0/C0)') as u_name from #t  left join @tbl t on t.PhleboId=userid   where #t.PhleboStatus='Offline'           
  order by u_name                                                       
                                                            
  end                                                          
                                                 
  Else If (@Detail='All')                                                            
                                             
  Begin                           
                                                            
     Select Distinct userid,u_name+' '+isnull(t.PhleboStatus,'(A0/P0/R0/C0)') as u_name from #t  left join @tbl t on t.PhleboId=userid  order by u_name                                                         
                                                            
  end                   
                    
   Else If (@Detail='NotAssigned')                                                            
                                                            
  Begin                                                          
                                                            
    Select distinct '' PhleboStatus,userid,u_name+' '+isnull(t.PhleboStatus,'(A0/P0/R0/C0)') as u_name from user_informations u                   
    inner join User_login ul on ul.user_id=u.userid            
 left join @tbl t on t.PhleboId=userid                 
    where userid not in (Select userid from #t)  and ul.user_role_r_id=8 and ul.U_enable=1 and u.u_enable=1                  
                                                            
  end                                                          
                                         
                                                            
     Drop Table #t                                                          
                                                           
                                                           
 end                                                           
                                                      
else if(@Action=5)                                                      
          
 begin                                                      
                                                       
  Select *,case when PickUpStatus1='NotCmpleted' and r=1 then 'OnGoing' else PickUpStatus1 end  PickUpStatus from(                                        
  Select distinct ord.o_id,o_number, sch.ps_time,CONVERT(VARCHAR(5), sch.ps_time, 108) + ' ' +RIGHT(CONVERT(VARCHAR(30), sch.ps_time, 9),2) pickuptime,                                                                                        
  ISNULL(acc.ca_title,'') +'/'+ISNULL(acc.ca_fname,'')+'/'+ISNULL(acc.ca_middle_name,'') +'/'+ISNULL(acc.ca_sname,'')                                                                                                       
  customer_name,(SELECT [dbo].[findproductname](ord.o_id)) packages,o_net_payable,                                    
  REPLACE(REPLACE ((ISNULL(addr.a_address_line_1,'')+'/'+ISNULL(a_address_line_2,'')+'/'+ISNULL(a_landmark,'')+'/'+ISNULL(a_geo_address,'')),'''',''),'"','') pickupaddress,                                                                       
  a_geo_longitude,a_geo_latitude,pt.Latitude lat,Longitude logi,ui.u_address,CAST(o_date AS VARCHAR(10)) o_date,              
  ca_mob,(SELECT [dbo].[fn_CheckdoctorandDietitian] (ord.o_id,'doc')) isdoc,                                                                    
  ROW_NUMBER() over (partition by phlebo_id order by sch.ps_time) OrderSequence,                                                                    
  dense_rank() over (order by phlebo_id) PhleboOrder,                                        
  ROW_NUMBER() over (Partition by Phleboid,Phlebo_Reached_Time Order by  ps_time) r,phlebo_id as PhleboId,ui.u_name as PhleboName,ui.u_mobileno as PhleboMobileNo,                                                                  
  case when ord.o_status=99 then 'Cancelled' else case when (sch.Phlebo_Reached_Time is not null or ord.o_status>=5) then 'Completed'                           
  else 'NotCmpleted' end end PickUpStatus1,ca_mob CustomerMobileNo,                                            
  case when uis.L_latitude is null  then ui.lat else uis.L_latitude end OfficeLat,          
  case when uis.L_Longitude is null  then ui.logi else uis.L_Longitude end OfficeLong,Phlebo_Reached_Time,                                
  datediff(Minute,cast(dateadd(minute,330,getdate()) as time),sch.ps_time) TimeDiff,ui.lat PhleboHomeLat,ui.logi PhleboHomeLong,            
  CONVERT(VARCHAR(20), pt.TrackDateTime, 113) PhleboDateTime                                                                   
  FROM customer_order ord                                                                                                      
  inner join customer_account acc on acc.ca_id = ord.ca_id                                                          
  inner join customer_order_pickup_address addr on addr.order_id = ord.o_id                                                
  inner join pickup_schedule sch on sch.order_o_id = addr.order_id --and ps_date=o_date                                                                        
  inner join pickup_route_assign ra on ra.ps_id = sch.ps_id and status=1                                                                                                
  inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id and Status_Info=1                                                                     
  inner join user_informations ui on ui.userid=phlebo_id                                                
  left join locations uis on uis.locations_id=ui.u_locations and uis.l_status=1                                           
  left join tbl_phlebo_live_Track pt on pt.PhleboId=phlebo_id                                                                   
  where  ui.u_enable=1 and phra.Status_Info=1 and ra.status=1 and phlebo_id In (Select Phleboid from @tab) and  o_number=@OrderId   and ps_date = @Date                                    
  )c                                                             
                                                       
 end                         
                       
else if (@Action=6)                      
                      
  begin                      
                        
                                     
   Select phra.phlebo_id,u.userid,u.u_name,ord.o_id,cm_id,                      
   case when (datediff(minute,o_time,Phlebo_Reached_Time)>1 or Phlebo_Reached_Time is null) then 'Late' when  
   datediff(minute,o_time,Phlebo_Reached_Time)<1 then 'OnTime' end TimeStatus,                      
   case when (o_status=99 and (ord.o_date=ps_date)) then 'TotalCancelled' end  TotalCancelled,        
   case when (o_status=99 and (ord.o_date=ps_date) and datediff(MINUTE,ord.updated_date,dateadd(minute,330,getdate()))<=20) then 'RecentlyCancelled' end RecentlyCancelled,        
   case when (o_status=99 and (ord.o_date=ps_date) and (datediff(minute,o_time,Phlebo_Reached_Time)>1or Phlebo_Reached_Time is null)) then 'LateCancel' end LateCancel,        
  CASE WHEN (ps_date<ord.o_date and  ord.o_status!=99) THEN 'Reschedule' end Reschedule                        
   Into #tmp from customer_account ac              
   Inner join customer_order ord on ac.ca_id=ord.ca_id                     
   inner join  pickup_schedule ps on ord.o_id=ps.order_o_id --and ps_date=o_date                                                             
   inner join pickup_route_assign ra on ra.ps_id = ps.ps_id and status=1                                                                                                  
   inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id  and Status_Info=1                                                              
   Inner join reporting_to r on r.re_userid=phra.phlebo_id                        
   inner join user_informations u on r.re_userid=u.userid                                                            
   inner join  User_login ul on ul.user_id=u.userid     
     inner join customer_order_booked_amount f on ord.o_id=f.o_id                                                            
   where u.u_enable=1 and r.re_enable=1  and ul.user_role_r_id=8 and  ul.U_enable=1    and ps_date = @Date                 
   and re_reporting_id=case when @Phlebos_ManagerId=0 then re_reporting_id else @Phlebos_ManagerId end                             
   order by u.u_name                                
                                                           
  Select         
  @Total=count(cm_id),        
  @TotalAdd=count(Distinct cm_id),        
  @Late=count(Distinct Case when TimeStatus='Late' then cm_id end),        
  @OnTime=count(Distinct Case when TimeStatus='OnTime' then cm_id end),                      
  @TotalCancelled=Count(distinct case when TotalCancelled='TotalCancelled' then o_id end),           
  @TotalCancelledAddress=Count(Distinct case when TotalCancelled='TotalCancelled' then cm_id end),                      
  @RecentlyCancelled=isnull(Count(case when RecentlyCancelled='RecentlyCancelled' then cm_id end),0),            
  @LateCancel=isnull(Count(distinct  case when LateCancel='LateCancel' then o_id end),0),         
  @Reschedule=isnull(Count(distinct case when Reschedule='Reschedule' then o_id end),0)  from #tmp           
          
  Select  cast(@Late as varchar(10)) +' ('+ cast(cast((@Late*100/cast(@TotalAdd as float)) as decimal(10,2)) as varchar(20))+'%)' as 'Late',        
  cast(@OnTime as varchar(10)) +' ('+ cast(cast((@OnTime*100/cast(@TotalAdd as float)) as decimal(10,2)) as varchar(20))+'%)' as 'OnTime',        
  cast(@TotalCancelled as varchar(10)) +' ('+ cast(cast((@TotalCancelled*100/cast(@Total as float)) as decimal(10,2)) as varchar(20))+'%)' as 'TotalCancelled',        
  cast(@TotalCancelledAddress as varchar(10)) +' ('+ cast(cast((@TotalCancelledAddress*100/cast(@TotalAdd as float)) as decimal(10,2)) as varchar(20))+'%)' as 'TotalCancelledAddress',      
  cast(@RecentlyCancelled as varchar(10)) +' ('+ cast(cast((@RecentlyCancelled*100/cast(@Total as float)) as decimal(10,2)) as varchar(20))+'%)' as 'RecentlyCancelled',        
  cast(@LateCancel as varchar(10)) +' ('+ cast(cast((@LateCancel*100/cast(@Total as float)) as decimal(10,2)) as varchar(20))+'%)' as 'LateCancel',        
  cast(@Reschedule as varchar(10)) +' ('+ cast(cast((@Reschedule*100/cast(@Total as float)) as decimal(10,2)) as varchar(20))+'%)' as 'Reschedule'        
                                                         
                                                
  If(@Detail='Late')                        
                        
  begin                                                          
                                                            
   Select distinct phlebo_id,userid,u_name+' '+isnull(t.PhleboStatus,'(A0/P0/R0/C0)') as u_name,'' TimeStatus from #tmp left join @tbl t on t.PhleboId=userid            
   where TimeStatus='Late'           
   order by u_name                                                         
                                                            
  end                                                            
                                                            
  Else If (@Detail='OnTime')                                                            
                                                            
  Begin                                                          
                                                            
   Select distinct phlebo_id,userid,u_name+' '+isnull(t.PhleboStatus,'(A0/P0/R0/C0)') as u_name,'' TimeStatus from #tmp left join @tbl t on t.PhleboId=userid            
   where TimeStatus='OnTime'           
   order by u_name                                                          
                                                            
  end                       
                        
  Else If (@Detail='TotalCancelled')                                                            
                                                            
  Begin                 
                                                            
   Select distinct phlebo_id,userid,u_name+' '+isnull(t.PhleboStatus,'(A0/P0/R0/C0)') as u_name,'' TimeStatus from #tmp left join @tbl t on t.PhleboId=userid            
   where TotalCancelled='TotalCancelled'           
   order by u_name                                                        
                                                            
  end           
            
   Else If (@Detail='TotalCancelledAddress')                                                            
                                                            
  Begin                                                          
                                                            
   Select distinct phlebo_id,userid,u_name+' '+isnull(t.PhleboStatus,'(A0/P0/R0/C0)') as u_name,'' TimeStatus from #tmp left join @tbl t on t.PhleboId=userid            
   where TotalCancelled='TotalCancelled'           
   order by u_name                                                        
                                                            
  end           
                
              
  Else If (@Detail='LateCancel')                                                            
                                                            
  Begin                                                          
                                                            
   Select distinct phlebo_id,userid,u_name+' '+isnull(t.PhleboStatus,'(A0/P0/R0/C0)') as u_name,'' TimeStatus from #tmp left join @tbl t on t.PhleboId=userid            
   where LateCancel='LateCancel'           
   order by u_name                                                         
                                                            
  end                       
                       
  Else If (@Detail='RecentlyCancelled')         
                                                            
  Begin                                                          
                                                            
   Select distinct phlebo_id,userid,u_name+' '+isnull(t.PhleboStatus,'(A0/P0/R0/C0)') as u_name,'' TimeStatus from #tmp left join @tbl t on t.PhleboId=userid            
   where RecentlyCancelled='RecentlyCancelled'           
   order by u_name                                                          
                                                            
  end         
          
   Else If (@Detail='Reschedule')                                                            
                                                            
  Begin                                                          
                                                            
   Select distinct phlebo_id,userid,u_name+' '+isnull(t.PhleboStatus,'(A0/P0/R0/C0)') as u_name,'' TimeStatus from #tmp left join @tbl t on t.PhleboId=userid            
   where Reschedule='Reschedule'           
   order by u_name                                                          
                                                            
  end                                                          
                                                 
  Else If (@Detail='All')                                                            
                                                            
  Begin                                                          
                                                            
  Select distinct phlebo_id,userid,u_name+' '+isnull(t.PhleboStatus,'(A0/P0/R0/C0)') as u_name,'' TimeStatus from #tmp left join @tbl t on t.PhleboId=userid            
  order by u_name                                                           
                                                            
  end                                                          
               
                                                            
     Drop Table #tmp                        
                      
                      
  end                         
                        
  Else if(@Action=7)                      
                      
     Begin                      
                                                                 
  Select distinct u.userid,u.u_name+' '+isnull(t.PhleboStatus,'(A0/P0/R0/C0)') as u_name from customer_order ord                       
  inner join pickup_schedule ps on ord.o_id=ps.order_o_id  and ps_date=o_date                                      
  inner join pickup_route_assign ra on ra.ps_id = ps.ps_id   and status=1                                                                                                    
  inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id  and Status_Info=1                                                                  
  Inner join reporting_to r on r.re_userid=phra.phlebo_id                        
  inner join user_informations u on phra.phlebo_id=u.userid           
  left join @tbl t on t.PhleboId=userid                                                                 
  where o_date=@Date and ord.o_status in (1,2,3) and                       
  r.re_reporting_id=case when @Phlebos_ManagerId=0 then r.re_reporting_id else @Phlebos_ManagerId end               
                
  Select count(distinct cm_id) TotalPickupAddress,count(distinct case when (ord.o_status not in (1,2,3)) then cm_id end) CompletedPickUpAddress,             
  count(cm_id) TotalPickup,count(case when (ord.o_status not in (1,2,3)) then cm_id end) CompletedPickUp,                      
  count(case when (ord.o_status in (1,2,3)) then cm_id end) PendingPickUp from             
  customer_account ac             
  Inner join customer_order ord on ord.ca_id=ac.ca_id            
  inner join pickup_schedule ps on ord.o_id=ps.order_o_id  and ps_date=o_date                                                                
  inner join pickup_route_assign ra on ra.ps_id = ps.ps_id  and status=1                                                                                                     
  inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id  and Status_Info=1                                                                  
  Inner join reporting_to r on r.re_userid=phra.phlebo_id                                                                  
  where o_date=@Date and r.re_reporting_id=case when @Phlebos_ManagerId=0 then r.re_reporting_id else @Phlebos_ManagerId end                                                                  
                                  
                      
  end                      
                      
 Else If(@Action=8)                      
                      
  Begin                      
                      
                        
  Select *,case when PickUpStatus1='NotCmpleted' and r=1 then 'OnGoing' else PickUpStatus1 end  PickUpStatus from(                                        
  Select distinct cm_id,ord.o_id,o_number, sch.ps_time,CONVERT(VARCHAR(5), sch.ps_time, 108) + ' ' +RIGHT(CONVERT(VARCHAR(30), sch.ps_time, 9),2) pickuptime,                                 
  ISNULL(acc.ca_title,'') +'/'+ISNULL(acc.ca_fname,'')+'/'+ISNULL(acc.ca_middle_name,'') +'/'+ISNULL(acc.ca_sname,'')                                                                 
  customer_name,(SELECT [dbo].[findproductname](ord.o_id)) packages,o_net_payable,                                                                                     
  REPLACE(REPLACE ((ISNULL(addr.a_address_line_1,'')+'/'+ISNULL(a_address_line_2,'')+'/'+ISNULL(a_landmark,'')+'/'+ISNULL(a_geo_address,'')),'''',''),'"','') pickupaddress,                                                         
  a_geo_longitude,a_geo_latitude,pt.Latitude lat,pt.Longitude logi,ui.u_address,CAST(o_date AS VARCHAR(10)) o_date,                                                                                                      
  ca_mob,(SELECT [dbo].[fn_CheckdoctorandDietitian] (ord.o_id,'doc')) isdoc,                                               
  ROW_NUMBER() over (partition by phlebo_id order by sch.ps_time) OrderSequence,                                                                    
  dense_rank() over (order by phlebo_id) PhleboOrder,                                        
  ROW_NUMBER() over (Partition by Phleboid,Phlebo_Reached_Time Order by  ps_time) r,phlebo_id as PhleboId,ui.u_name as PhleboName,ui.u_mobileno as PhleboMobileNo,                                    
  case when ord.o_status=99 then 'Cancelled' else case when (ps_date<o_date ) then 'Reschedule'          
   when (ps_date=o_date and (sch.Phlebo_Reached_Time is not null or ord.o_status>=5)) then 'Completed'                            
  else 'NotCmpleted' end end PickUpStatus1,ca_mob CustomerMobileNo,                                            
  case when uis.L_latitude is null  then ui.lat else uis.L_latitude end OfficeLat,          
  case when uis.L_Longitude is null  then ui.logi else uis.L_Longitude end OfficeLong    ,Phlebo_Reached_Time                                                                  
  ,datediff(Minute,cast(dateadd(minute,330,getdate()) as time),sch.ps_time) TimeDiff,ui.lat PhleboHomeLat,ui.logi PhleboHomeLong,            
  CONVERT(VARCHAR(20), pt.TrackDateTime, 113) PhleboDateTime                                                                                                          
                        
  FROM customer_order ord                                                                    
  inner join customer_account acc on acc.ca_id = ord.ca_id                                                                                                       
  inner join customer_order_pickup_address addr on addr.order_id = ord.o_id            
  inner join pickup_schedule sch on sch.order_o_id = addr.order_id-- and ps_date=o_date                                  
  inner join pickup_route_assign ra on ra.ps_id = sch.ps_id  and status=1                                                                                             
  inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id and Status_Info=1                                                                     
  inner join user_informations ui on ui.userid=phlebo_id                                               
    left join locations uis on uis.locations_id=ui.u_locations and uis.l_status=1                                            
  left join tbl_phlebo_live_Track pt on pt.PhleboId=phlebo_id                                                                   
 where ui.u_enable=1 and phra.Status_Info=1 and ra.status=1 and cm_id=@CmId and ps_date = @Date                                                                                     
   )c                                                             
  order by PhleboId,ps_time                        
                      
          --SELECT             
  End                      
                  
  Else If(@Action=9)                  
               
  Begin                  
                
                 
   If Exists( Select Top 1 1 from tbl_phlebo_Track where Cast(TrackDateTime as date)=@Date and PhleboId  In  (Select Phleboid from @tab))              
                  
 Begin              
                 
  Select phlebo_TrackId,PhleboId,CONVERT(VARCHAR(20),TrackDateTime, 113) TrackDateTime,Latitute,Longitute,Speed,CreatedDate,IsActive from tbl_phlebo_Track                   
  where Cast(TrackDateTime as date)=@Date and PhleboId  In  (Select Phleboid from @tab)                  
  Order by TrackDateTime      
 --   Select phlebo_TrackId,PhleboId,CONVERT(VARCHAR(20),TrackDateTime, 113) TrackDateTime,Latitute,Longitute,concat('[',Latitute,',',Longitute,']') LatLong,Speed,CreatedDate,IsActive   
 --into #t2 from tbl_phlebo_Track                   
 --   where Cast(TrackDateTime as date)=@Date and PhleboId In  (Select Phleboid from @tab)                 
 --   Order by TrackDateTime    
  
 --   Select * from #t2 order by TrackDateTime  
  
 --   select PhleboId,stuff((select ',' + LatLong from #t2 t where t.PhleboId = t1.PhleboId order by TrackDateTime for xml path('')),1,1,'' ) as comment from #t2 t1   
 --group by PhleboId    
  
  
 --drop table #t2              
              
 End              
              
 Else              
              
 Begin              
              
  Select phlebo_live_TrackId phlebo_TrackId,PhleboId,CONVERT(VARCHAR(20),TrackDateTime, 113) TrackDateTime,Latitude Latitute,Longitude Longitute,Speed,CreatedDate,IsActive             
  from tbl_phlebo_live_Track where PhleboId  In  (Select Phleboid from @tab)              
              
 End              
              
                  
                  
  End                
                
  Else If(@Action=10)                  
                  
  Begin                  
                
  If(@Detail='Pending')              
              
  begin              
                
 Select distinct u.userid PhleboId,u.u_name PhleboName,u.u_mobileno PhleboMobile,              
 ISNULL(ac.ca_title,'') +'/'+ISNULL(ac.ca_fname,'')+'/'+ISNULL(ac.ca_middle_name,'') +'/'+ISNULL(ac.ca_sname,'')                                                                 
 CustomerName,ac.ca_mob CustomerMobile,(SELECT [dbo].[findproductname](ord.o_id)) PackageName,                                                                                     
 REPLACE(REPLACE ((ISNULL(addr.a_address_line_1,'')+'/'+ISNULL(a_address_line_2,'')+'/'+              
 ISNULL(a_landmark,'')+'/'+ISNULL(a_geo_address,'')),'''',''),'"','') PickUpAddress,ps.ps_time PickUpTime,o_number OrderNumber,      
 '' ReachedTime,'' Reasone, '' CancelStatus,'Pending' [Type]          
 from customer_account ac              
 Inner join customer_order ord on ac.ca_id=ord.ca_id              
 Inner join customer_pickup_address addr on addr.customer_account_ca_id=ac.ca_id              
 inner join pickup_schedule ps on ord.o_id=ps.order_o_id    and ps_date=o_date                                    
 inner join pickup_route_assign ra on ra.ps_id = ps.ps_id   and status=1                                                                                                    
 inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id  and Status_Info=1                                                                  
 Inner join reporting_to r on r.re_userid=phra.phlebo_id                        
 inner join user_informations u on phra.phlebo_id=u.userid                                                                
 where ps_date=@Date and ord.o_status in (1,2,3) and                       
 r.re_reporting_id=case when @Phlebos_ManagerId=0 then r.re_reporting_id else @Phlebos_ManagerId end                   
               
  end              
              
  else if(@Detail='TotalCancelled')              
              
  begin              
              
 Select distinct u.userid PhleboId,u.u_name PhleboName,u.u_mobileno PhleboMobile,              
 ISNULL(ac.ca_title,'') +'/'+ISNULL(ac.ca_fname,'')+'/'+ISNULL(ac.ca_middle_name,'') +'/'+ISNULL(ac.ca_sname,'')                                                                 
 CustomerName,ac.ca_mob CustomerMobile,(SELECT [dbo].[findproductname](ord.o_id)) PackageName,                                                                                     
 REPLACE(REPLACE ((ISNULL(addr.a_address_line_1,'')+'/'+ISNULL(a_address_line_2,'')+'/'+              
 ISNULL(a_landmark,'')+'/'+ISNULL(a_geo_address,'')),'''',''),'"','') PickUpAddress,ps.ps_time PickUpTime,o_number OrderNumber,          
 Phlebo_Reached_Time ReachedTime,comment Reasone,        
 case when (o_status=99 and (datediff(minute,o_time,Phlebo_Reached_Time)>1 or Phlebo_Reached_Time is null and ord.o_date=ps_date) and ord.o_date=ps_date) then 'Late'         
 when (ord.o_date>ps_date) then 'ReScheduled'         
 Else 'OnTime'         
 End CancelStatus,'TotalCancelled' [Type]        
 from customer_account ac              
 Inner join customer_order ord on ac.ca_id=ord.ca_id              
 Inner join customer_pickup_address addr on addr.customer_account_ca_id=ac.ca_id              
 inner join pickup_schedule ps on ord.o_id=ps.order_o_id   --and ps_date=o_date                                     
 inner join pickup_route_assign ra on ra.ps_id = ps.ps_id   and status=1                                                                                                    
 inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id  and Status_Info=1                                                                  
 Inner join reporting_to r on r.re_userid=phra.phlebo_id                        
 inner join user_informations u on phra.phlebo_id=u.userid     
  inner join customer_order_booked_amount f on ord.o_id=f.o_id   
  left join (select order_o_id,sh_os_code_id,stuff((select ',' + t.comment from customer_order_status_history t where t.order_o_id = t1.order_o_id and t.Status_Info=1      
    for xml path('')),1,1,'') as comment from customer_order_status_history t1 group by order_o_id,sh_os_code_id) h on h.order_o_id=ord.o_id and h.sh_os_code_id=ord.o_status     
 --left join customer_order_status_history h on h.order_o_id=ord.o_id and h.sh_os_code_id=ord.o_status and   h.Status_Info=1                                                               
 where ps_date=@Date and ord.o_status=99 and (ord.o_date=ps_date)   and                 
 r.re_reporting_id=case when @Phlebos_ManagerId=0 then r.re_reporting_id else @Phlebos_ManagerId end                     
               
  end       
       
 else if(@Detail='LateCancel')              
              
  begin              
              
 Select distinct u.userid PhleboId,u.u_name PhleboName,u.u_mobileno PhleboMobile,              
 ISNULL(ac.ca_title,'') +'/'+ISNULL(ac.ca_fname,'')+'/'+ISNULL(ac.ca_middle_name,'') +'/'+ISNULL(ac.ca_sname,'')                                        
 CustomerName,ac.ca_mob CustomerMobile,(SELECT [dbo].[findproductname](ord.o_id)) PackageName,                                                                                     
 REPLACE(REPLACE ((ISNULL(addr.a_address_line_1,'')+'/'+ISNULL(a_address_line_2,'')+'/'+              
 ISNULL(a_landmark,'')+'/'+ISNULL(a_geo_address,'')),'''',''),'"','') PickUpAddress,ps.ps_time PickUpTime,o_number OrderNumber,          
 Phlebo_Reached_Time ReachedTime,comment Reasone      
 from customer_account ac              
 Inner join customer_order ord on ac.ca_id=ord.ca_id              
 Inner join customer_pickup_address addr on addr.customer_account_ca_id=ac.ca_id              
 inner join pickup_schedule ps on ord.o_id=ps.order_o_id   --and ps_date=o_date                                     
 inner join pickup_route_assign ra on ra.ps_id = ps.ps_id   and status=1                                                                                                    
 inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id  and Status_Info=1                                                                  
 Inner join reporting_to r on r.re_userid=phra.phlebo_id                        
 inner join user_informations u on phra.phlebo_id=u.userid     
  inner join customer_order_booked_amount f on ord.o_id=f.o_id   
   left join (select order_o_id,sh_os_code_id,stuff((select ',' + t.comment from customer_order_status_history t where t.order_o_id = t1.order_o_id and t.Status_Info=1      
    for xml path('')),1,1,'') as comment from customer_order_status_history t1 group by order_o_id,sh_os_code_id) h on h.order_o_id=ord.o_id and h.sh_os_code_id=ord.o_status        
 --left join customer_order_status_history h on h.order_o_id=ord.o_id and h.sh_os_code_id=ord.o_status and   h.Status_Info=1                                                               
 where ps_date=@Date and ord.o_status=99   and         
 (datediff(minute,o_time,Phlebo_Reached_Time)>1 or Phlebo_Reached_Time is null and ord.o_date=ps_date) and ord.o_date=ps_date and              
 r.re_reporting_id=case when @Phlebos_ManagerId=0 then r.re_reporting_id else @Phlebos_ManagerId end                     
               
  end       
        
  else if(@Detail='Late')              
              
  begin              
                        
  Select distinct u.userid PhleboId,u.u_name PhleboName,u.u_mobileno PhleboMobile,'' CustomerName,'' CustomerMobile,'' PackageName,                                                                                           
 REPLACE(REPLACE ((ISNULL(addr.a_address_line_1,'')+'/'+ISNULL(a_address_line_2,'')+'/'+              
 ISNULL(a_landmark,'')+'/'+ISNULL(a_geo_address,'')),'''',''),'"','') PickUpAddress,ps.ps_time PickUpTime, '' OrderNumber,       
 Phlebo_Reached_Time ReachedTime,'' Reasone        
 from customer_account ac              
 Inner join customer_order ord on ac.ca_id=ord.ca_id       
 Inner join customer_pickup_address addr on addr.customer_account_ca_id=ac.ca_id              
 inner join pickup_schedule ps on ord.o_id=ps.order_o_id   --and ps_date=o_date                                     
 inner join pickup_route_assign ra on ra.ps_id = ps.ps_id   and status=1                                                                                                    
 inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id  and Status_Info=1                                                                  
 Inner join reporting_to r on r.re_userid=phra.phlebo_id                        
 inner join user_informations u on phra.phlebo_id=u.userid                                                          
 where ps_date=@Date and        
 (datediff(minute,o_time,Phlebo_Reached_Time)>1 or Phlebo_Reached_Time is null) and      
  r.re_reporting_id=case when @Phlebos_ManagerId=0 then r.re_reporting_id else @Phlebos_ManagerId end             
               
  end          
        
 else if(@Detail='OnTime')              
  
  begin              
                        
  Select distinct u.userid PhleboId,u.u_name PhleboName,u.u_mobileno PhleboMobile,'' CustomerName,'' CustomerMobile,'' PackageName  ,                                                                                         
 REPLACE(REPLACE ((ISNULL(addr.a_address_line_1,'')+'/'+ISNULL(a_address_line_2,'')+'/'+              
 ISNULL(a_landmark,'')+'/'+ISNULL(a_geo_address,'')),'''',''),'"','') PickUpAddress,ps.ps_time PickUpTime, '' OrderNumber,       
 Phlebo_Reached_Time ReachedTime,'' Reasone      
 from customer_account ac              
 Inner join customer_order ord on ac.ca_id=ord.ca_id              
 Inner join customer_pickup_address addr on addr.customer_account_ca_id=ac.ca_id              
 inner join pickup_schedule ps on ord.o_id=ps.order_o_id   --and ps_date=o_date                                     
 inner join pickup_route_assign ra on ra.ps_id = ps.ps_id   and status=1                                                                                                    
 inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id  and Status_Info=1                                                                  
 Inner join reporting_to r on r.re_userid=phra.phlebo_id                        
 inner join user_informations u on phra.phlebo_id=u.userid    
  inner join customer_order_booked_amount f on ord.o_id=f.o_id                                                         
 where ps_date=@Date and        
 (datediff(minute,o_time,Phlebo_Reached_Time)<1) and      
  r.re_reporting_id=case when @Phlebos_ManagerId=0 then r.re_reporting_id else @Phlebos_ManagerId end             
               
  end          
        
    
   else if(@Detail='Reschedule')              
              
  begin              
                        
  Select distinct u.userid PhleboId,u.u_name PhleboName,u.u_mobileno PhleboMobile,              
 ISNULL(ac.ca_title,'') +'/'+ISNULL(ac.ca_fname,'')+'/'+ISNULL(ac.ca_middle_name,'') +'/'+ISNULL(ac.ca_sname,'')                                                                 
 CustomerName,ac.ca_mob CustomerMobile,(SELECT [dbo].[findproductname](ord.o_id)) PackageName,                                                                                     
 REPLACE(REPLACE ((ISNULL(addr.a_address_line_1,'')+'/'+ISNULL(a_address_line_2,'')+'/'+              
 ISNULL(a_landmark,'')+'/'+ISNULL(a_geo_address,'')),'''',''),'"','') PickUpAddress,ps.ps_time PickUpTime,o_number OrderNumber,          
 Phlebo_Reached_Time ReachedTime,comment  Reasone      
 from customer_account ac              
 Inner join customer_order ord on ac.ca_id=ord.ca_id              
 Inner join customer_pickup_address addr on addr.customer_account_ca_id=ac.ca_id              
 inner join pickup_schedule ps on ord.o_id=ps.order_o_id   --and ps_date=o_date                                     
 inner join pickup_route_assign ra on ra.ps_id = ps.ps_id   and status=1                                                                                                    
 inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id  and Status_Info=1                                                                  
 Inner join reporting_to r on r.re_userid=phra.phlebo_id                        
 inner join user_informations u on phra.phlebo_id=u.userid   
 inner join customer_order_booked_amount f on ord.o_id=f.o_id   
   left join (select order_o_id,sh_os_code_id,stuff((select ',' + t.comment from customer_order_status_history t where t.order_o_id = t1.order_o_id and t.Status_Info=1      
    for xml path('')),1,1,'') as comment from customer_order_status_history t1 group by order_o_id,sh_os_code_id) h on h.order_o_id=ord.o_id and h.sh_os_code_id=ord.o_status          
  --left join customer_order_status_history h on h.order_o_id=ord.o_id and h.sh_os_code_id=ord.o_status and   h.Status_Info=1                                                           
 where ps_date=@Date and ord.o_date>ps_date and  ord.o_status!=99  and  
  r.re_reporting_id=case when @Phlebos_ManagerId=0 then r.re_reporting_id else @Phlebos_ManagerId end             
               
  end        
        
        
   else if(@Detail='TotalCancelledAddress')   --TotalCancelled           
              
  begin              
              
   Select distinct u.userid PhleboId,u.u_name PhleboName,u.u_mobileno PhleboMobile,'' CustomerName,'' CustomerMobile,'' PackageName ,                                                                                          
 REPLACE(REPLACE ((ISNULL(addr.a_address_line_1,'')+'/'+ISNULL(a_address_line_2,'')+'/'+              
 ISNULL(a_landmark,'')+'/'+ISNULL(a_geo_address,'')),'''',''),'"','') PickUpAddress,ps.ps_time PickUpTime,'' OrderNumber,        
 Phlebo_Reached_Time ReachedTime,'' Reasone        
 from customer_account ac              
 Inner join customer_order ord on ac.ca_id=ord.ca_id              
 Inner join customer_pickup_address addr on addr.customer_account_ca_id=ac.ca_id              
 inner join pickup_schedule ps on ord.o_id=ps.order_o_id   --and ps_date=o_date                                     
 inner join pickup_route_assign ra on ra.ps_id = ps.ps_id   and status=1                                                                                                    
 inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id  and Status_Info=1                                                                  
 Inner join reporting_to r on r.re_userid=phra.phlebo_id                        
 inner join user_informations u on phra.phlebo_id=u.userid        
 left join customer_order_status_history h on h.order_o_id=ord.o_id and h.sh_os_code_id=ord.o_status and   h.Status_Info=1                                                               
 where ps_date=@Date and ord.o_status=99   and o_date=ps_date and              
 r.re_reporting_id=case when @Phlebos_ManagerId=0 then r.re_reporting_id else @Phlebos_ManagerId end                     
               
  end            
        
   else if(@Detail='RecentlyCancelled')              
              
  begin              
              
  Select distinct u.userid PhleboId,u.u_name PhleboName,u.u_mobileno PhleboMobile,              
 ISNULL(ac.ca_title,'') +'/'+ISNULL(ac.ca_fname,'')+'/'+ISNULL(ac.ca_middle_name,'') +'/'+ISNULL(ac.ca_sname,'')                                                                 
 CustomerName,ac.ca_mob CustomerMobile,(SELECT [dbo].[findproductname](ord.o_id)) PackageName,                                                                                     
 REPLACE(REPLACE ((ISNULL(addr.a_address_line_1,'')+'/'+ISNULL(a_address_line_2,'')+'/'+              
 ISNULL(a_landmark,'')+'/'+ISNULL(a_geo_address,'')),'''',''),'"','') PickUpAddress,ps.ps_time PickUpTime,o_number OrderNumber,          
 Phlebo_Reached_Time ReachedTime,comment  Reasone      
 from customer_account ac              
 Inner join customer_order ord on ac.ca_id=ord.ca_id              
 Inner join customer_pickup_address addr on addr.customer_account_ca_id=ac.ca_id              
 inner join pickup_schedule ps on ord.o_id=ps.order_o_id   --and ps_date=o_date                                     
 inner join pickup_route_assign ra on ra.ps_id = ps.ps_id   and status=1                                                                                                    
 inner join phlebo_route_assign phra on phra.pra_id = ra.pra_id  and Status_Info=1                                                                  
 Inner join reporting_to r on r.re_userid=phra.phlebo_id                        
 inner join user_informations u on phra.phlebo_id=u.userid        
 left join customer_order_status_history h on h.order_o_id=ord.o_id and h.sh_os_code_id=ord.o_status and   h.Status_Info=1                
 where ps_date=@Date and o_status=99 and datediff(MINUTE,ord.updated_date,dateadd(minute,330,getdate()))<=20 and           
 r.re_reporting_id=case when @Phlebos_ManagerId=0 then r.re_reporting_id else @Phlebos_ManagerId end                     
           
  end             
            
  else          
            
  begin          
            
  Select 'No Key' as [Result]          
          
  end              
              
                  
                  
  End                
                  
                                                     
                                                                  
                                                                     
END                                     
                                            
                                            
--Select * from customer_order where o_date='2018-10-26'                                         
                                        
--Select * from pickup_schedule where ps_date='2018-05-10'                                        
                                        
                                  
------------------------------------------------------------------------------------------------------------------- 
