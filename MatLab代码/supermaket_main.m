%主函数测试程序

%C：是服务参数的类
%time_limit：仿真的时长
%num_gui：柜台数量
%simulation_times：仿真次数
%choos_methods：柜台的选择方法


clc
clear
load('my_halton.mat')%%自己产生的对应加分项1



C.lamdaA=5;
C.lamdaB=0.1;%%time of buying
C.lamdaS=1;%% time of serving
time_limit=180;%仿真时长



arrin=-1/C.lamdaA.*log(my_halton(1:1000,1));%到达的时间间隔
carral=cumsum(arrin);%到达时刻


ncus=max(find(carral<time_limit));%到达时刻在3个小时之前的人

carral=carral(1:ncus);%对应的到达时刻
buying_time=-1/C.lamdaB.*log(my_halton(1:1000,2));%购物所花费的时间
buying_time=buying_time(1:ncus);
serving_time=-1/C.lamdaS.*log(my_halton(1:1000,3));
arr_gui=carral+buying_time;%%time when arrive serving Gui
%innitial Gui
%---------------------------------------------------------------------------------
num_gui=5;
for g=1:num_gui
    Gui(g).qunue=[0,0];%first number:time;second number:0-n quenue?
    Gui(g).busy=[0,0];%first number:time;second number:0-1 busy?
    Gui(g).future_leavetime=0;
    Gui(g).customer_num=[];
    Gui(g).servetime=[];
    Gui(g).start_serve_time=[];%柜台开始服务的时间
    Gui(g).leavetime=[];%离开时间
    Gui(g).stay_time=[];
end
%---------------------------------------------------------------------------
%main
m=1;
num_arrive_customer=0;%到达顾客计数器
while num_arrive_customer<ncus
         [event_arrGui(m),id_arrGui]=min(arr_gui);
         leavetime=cell2mat({Gui.future_leavetime});%future_leavetime表示每个站台即将要离开的时刻
   if leavetime==zeros(1,num_gui) %初始情况下无人离开时
      event(m)=event_arrGui(m);%m为到达事件，对应的时刻为event(m)
      id=id_arrGui;
      arr_gui(id)=[];%事件表中删除事件
      arrive_flag=1;%是否为到达事件记录器
   else
         [event_leaveGui(m),id_leaveGui]=min(leavetime(leavetime~=0));
        if event_leaveGui(m)>event_arrGui(m)%如果离开时间的事件晚于到达事件的时间
            event(m)=event_arrGui(m);
            id=id_arrGui;
            arr_gui(id)=[];
            arrive_flag=1;
        else
            event(m)=event_leaveGui(m);
            id=id_leaveGui;
            arrive_flag=0;
        end
   end
   if arrive_flag==1  %%对到达事件的处理
       num_arrive_customer=num_arrive_customer+1;%%到达人数加1，推进事件
       quenue_length=zeros(1,num_gui);%%%用来记录当前每个站台前面的排队长度
         index_minlength_gui=choose_gui(Gui,"table_find");%%选择柜台函数
        arr_gui_customer_servingtime=serving_time(num_arrive_customer);%服务时间的选定
       Gui=enventarrival(Gui,index_minlength_gui,num_arrive_customer,arr_gui_customer_servingtime,event(m));%到达函数输入五个参数
   else         
        special2=find(leavetime==min(leavetime(leavetime~=0)));%找到当前站台中最早离开时间的站台
        if length(special2)==1%如只有一个，将此站台记录
             index_minleavetime_gui=special2;
         else
             index_minleavetime_gui=special2(randperm(length(special2),1));%概率很小，保证容错性，其实性质是同时处理，多个最早离开时间的站台，随机选择其中一个先处理
        end 
             Gui=eventleave(Gui,index_minleavetime_gui,event(m));%离开事件函数
   end
   m=m+1;
end
