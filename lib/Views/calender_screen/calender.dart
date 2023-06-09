
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kolazz_book/Models/get_calendar_jobs_model.dart';
import 'package:kolazz_book/Services/request_keys.dart';
import 'package:kolazz_book/Utils/colors.dart';
import 'package:kolazz_book/Utils/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<ClientJobs> getClientJobs = [];
  List<Freelancer> getFreelancingJobs = [];
  List<String> dates = [];
  bool isSelected = true;

  getCalendarJobs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? id = preferences.getString('id');
    var uri =
    Uri.parse(getCalendarJobsApi.toString());
    // '${Apipath.getCitiesUrl}');
    var request = http.MultipartRequest("POST", uri);
    // request.fields.addAll({
    //   "user_id": id.toString(),
    //   "type" :"client",
    //   "date"
    // })
    request.fields[RequestKeys.userId] = id!;
    request.fields[RequestKeys.type] = 'client';
    request.fields['date']= DateFormat('yyyy-MM-dd').format(_selectedDay).toString();
     print("this is my request ${request.fields.toString()}");
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);

    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    setState(() {
      getClientJobs = GetCalendarJobsModel.fromJson(userData).data!;
       getFreelancingJobs = GetCalendarJobsModel.fromJson(userData).freelancer!;
      dates = GetCalendarJobsModel.fromJson(userData).dates!;
    });
    print("this s E${getClientJobs.length} and ${getFreelancingJobs.length}");
   for(var i = 0; i < dates.length; i++ ){
     setState(() {
       _selectedDates.add(DateTime.parse(dates[i]));
     });
     print("this is selected dates $_selectedDates}");
   }
  }

  @override
  void initState() {
    super.initState();
    getCalendarJobs();
  }

   Set<DateTime> _selectedDates = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgruond,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff303030),
        actions: const [
          Padding(
            padding: EdgeInsets.all(15),
            child: Center(
                child: Text("Calendar",
                    style: TextStyle(
                        fontSize: 16,
                        color: AppColors.AppbtnColor,
                        fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      // appBar: AppBar(
      //   title: Text('TableCalendar - Basics'),
      // ),
      body: Column(
        children: [
          const SizedBox(height: 15,),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
               // height: MediaQuery.of(context).size.height/1.9,
              color: AppColors.grd1,
              child: TableCalendar(
                headerStyle: const HeaderStyle(
                    leftChevronVisible: false,
                    titleCentered: true,
                    formatButtonVisible: false,
                    rightChevronVisible: false,
                    decoration: BoxDecoration(color: AppColors.primary5),
                    titleTextStyle: TextStyle(color: AppColors.whit)),
                daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: AppColors.whit),
                    weekendStyle: TextStyle(color: AppColors.back)),
                // firstDay: kFirstDay,
                // lastDay: kLastDay,
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                daysOfWeekHeight: 40,
                calendarStyle:  CalendarStyle(
                    todayDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.AppbtnColor.withOpacity(0.4)
                    ),
                    selectedTextStyle: const TextStyle(color: AppColors.whit),
                    disabledTextStyle: const TextStyle(color: AppColors.back)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return _selectedDates.contains(day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  print("this is mt selected days $selectedDay");
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    // _selectedDates.add(selectedDay);
                  });
                  getCalendarJobs();
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),

              // TableCalendar(
              //   daysOfWeekHeight: 40,
              //   calendarStyle:  CalendarStyle(
              //     todayDecoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       color: AppColors.AppbtnColor.withOpacity(0.4)
              //     ),
              //       selectedTextStyle: TextStyle(color: AppColors.whit),
              //       disabledTextStyle: TextStyle(color: AppColors.back)),
              //   selectedDayPredicate: (day) {
              //     return _selectedDates.contains(day);
              //   },
              //   headerStyle: const HeaderStyle(
              //     leftChevronVisible: false,
              //       titleCentered: true,
              //       formatButtonVisible: false,
              //       rightChevronVisible: false,
              //       decoration: BoxDecoration(color: AppColors.primary5),
              //       titleTextStyle: TextStyle(color: AppColors.whit)),
              //   daysOfWeekStyle: const DaysOfWeekStyle(
              //       weekdayStyle: TextStyle(color: AppColors.whit),
              //       weekendStyle: TextStyle(color: AppColors.back)),
              //   firstDay: kFirstDay,
              //   lastDay: kLastDay,
              //   focusedDay: _focusedDay,
              //   calendarFormat: _calendarFormat,
              //   selectedDayPredicate: (day) {
              //     return isSameDay(_selectedDay, day);
              //   },
              //   onDaySelected: (selectedDay, focusedDay) {
              //     if (!isSameDay(_selectedDay, selectedDay)) {
              //       // Call `setState()` when updating the selected day
              //       setState(() {
              //         _selectedDay = selectedDay;
              //         _focusedDay = focusedDay;
              //       });
              //       getCalendarJobs();
              //       print("this is selected date $_selectedDay");
              //     }
              //   },
              //   onFormatChanged: (format) {
              //     if (_calendarFormat != format) {
              //       // Call `setState()` when updating calendar format
              //       setState(() {
              //         _calendarFormat = format;
              //       });
              //     }
              //   },
              //   onPageChanged: (focusedDay) {
              //     // No need to call `setState()` here
              //     _focusedDay = focusedDay;
              //   },
              // ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: AppColors.containerclr,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          isSelected = true;
                        });
                      },
                      child: Container(
                          height: 40,
                          width: 120,
                          child: Center(
                            child: Text(
                              'Client',
                              style: TextStyle(
                                color: isSelected
                                    ? Color(0xffffffff)
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.AppbtnColor
                                : AppColors.containerclr,
                            // border: Border.all(color: AppColors.AppbtnColor),
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          // Navigator.of(context).push(MaterialPageRoute(
                          //   builder: (context) => NextPage(),
                          // ));
                          isSelected = false;
                        });
                      },
                      child: Container(
                          height: 40,
                          width: 130,
                          child: Center(
                            child: Text(
                              'Freelancing',
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.whit
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.containerclr
                                  : AppColors.AppbtnColor,
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ],
                ),
              )
            ],
          ),
          isSelected ?
          Expanded(
            // height: MediaQuery.of(context).size.height/4,
            // width: MediaQuery.of(context).size.width,
            child: getClientJobs.isNotEmpty ?
            ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: getClientJobs.length ,
              physics: ScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                var data = getClientJobs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),
                  child: InkWell(
                    onTap: (){
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>EditQuotation()));
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.black12,
                      elevation: 1,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                 Text("${data.clientName}",style: TextStyle(color: AppColors.pdfbtn,fontSize: 14,fontWeight: FontWeight.bold),),
                                Container(
                                    padding: EdgeInsets.symmetric(horizontal: 14,vertical: 3),
                                    decoration: BoxDecoration(
                                        color: AppColors.lightwhite,

                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Text("${data.qid}",style: TextStyle(color: AppColors.whit,),)),
                              ],
                            ),
                          ),



                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${data.city}",style: TextStyle(color: AppColors.whit,fontSize: 14),),
                                Text("${data.eventName}",style: TextStyle(color: AppColors.whit),),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10,),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //      const  Text("Venue",style: TextStyle(color: AppColors.pdfbtn,fontSize: 14,fontWeight: FontWeight.bold),),
                          //       Text("${data.city}",style: TextStyle(color: AppColors.whit),),
                          //     ],
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //      const Text("Amount",style: TextStyle(color: AppColors.pdfbtn,fontSize: 14,fontWeight: FontWeight.bold),),
                          //       Text("${data.amount}",style: TextStyle(color: AppColors.whit),),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),),
                  ),
                );
              },
            )
            : const Center(
              child: Text("No data to show", style: TextStyle(
                color: AppColors.whit
              ),),
            ),
          )
              :    Expanded(
            // height: MediaQuery.of(context).size.height/4,
            // width: MediaQuery.of(context).size.width,
            child: getFreelancingJobs.isNotEmpty ?
            ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: getFreelancingJobs.length ,
              physics: ScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                var data = getFreelancingJobs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),
                  child: InkWell(
                    onTap: (){
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>EditQuotation()));
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.black12,
                      elevation: 1,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                 Text("${data.photographerName}",style: TextStyle(color: AppColors.pdfbtn,fontSize: 14,fontWeight: FontWeight.bold),),
                                Container(
                                    padding: EdgeInsets.symmetric(horizontal: 14,vertical: 3),
                                    decoration: BoxDecoration(
                                        color: AppColors.lightwhite,

                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Text("${data.uid}",style: TextStyle(color: AppColors.whit,),)),
                              ],
                            ),
                          ),

                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       const Text("Photographer Name",style: TextStyle(color: AppColors.pdfbtn,fontWeight: FontWeight.bold,fontSize: 14),),
                          //       Text("${data.photographerName}",style: TextStyle(color: AppColors.whit),),
                          //     ],
                          //   ),
                          // ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${data.cityName}",style: TextStyle(color: AppColors.whit),),
                                Text("${data.eventName}",style: TextStyle(color: AppColors.whit),),
                              ],
                            ),
                          ),

                        ],
                      ),),
                  ),
                );
              },
            )
                : const Center(
              child: Text("No data to show", style: TextStyle(
                  color: AppColors.whit
              ),),
            ),
          )
        ],
      ),
    );
  }
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
