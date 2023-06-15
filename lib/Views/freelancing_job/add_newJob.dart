

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kolazz_book/Controller/ad_new_job_Controller.dart';
import 'package:kolazz_book/Models/Type_of_photography_model.dart';
import 'package:kolazz_book/Models/event_type_model.dart';
import 'package:kolazz_book/Models/get_cities_model.dart';
import 'package:kolazz_book/Models/photographer_list_model.dart';
import 'package:kolazz_book/Utils/strings.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/colors.dart';

class addNewJob extends StatefulWidget {
  const addNewJob({Key? key}) : super(key: key);

  @override
  State<addNewJob> createState() => _freelancing_job_updateState();
}

class _freelancing_job_updateState extends State<addNewJob> {
  String? _chosenValue;
  var item = ['Kaushik Prajapati', ' Prajapati', 'Kaushik Prajapati',];
  String? _cityValue;
  var item2 = ['Mumbai', ' indore', 'delhi ',];
  String? _photography;
  var item3 = ['Mumbai', ' indore', 'delhi ',];

  List<Categories> typeofPhotographyEvent = [];
  List<Data> photographersList = [];
  List<EventType> eventList = [];
  List<CityList> citiesList = [];
TextEditingController amountt=TextEditingController();

  var eventController;
  var cityController;
  var photographerType;
  var photographer;
  String? selectDates;
  String? selectTimes;
  var photographeridd;
  var totall=0;
  List<int> amountlist=[];



  getPhotographerType() async {
    var uri =
    Uri.parse(getPhotographerApi.toString());
    // '${Apipath.getCitiesUrl}');
    var request = http.MultipartRequest("GET", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    // request.fields['type_id'] = "1";
    // request.fields['vendor_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    // collectionModal = AllCateModel.fromJson(userData);
    typeofPhotographyEvent = TypeofPhotography.fromJson(userData).categories!;
    // print(
    //     "ooooo ${collectionModal!.status} and ${collectionModal!.categories!.length} and ${userID}");
    print("this is photographer $typeofPhotographyEvent");
  }

  getPhotographerList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('id');
    var uri = Uri.parse(getQuotationDetailsApi.toString());

    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.fields.addAll({
      'user_id': userId.toString(),
      'type':'photographers',
    });
    request.headers.addAll(headers);
     // request.fields['user_id'] = userId.toString();
     // request.fields['type'] = 'photographer';
    print("this is my photographer requeswt ${request.fields.toString()}");
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    final result = PhotographerListModel.fromJson(userData);
    setState(() {
      photographersList = result.data!;
      photographeridd=photographersList[0].id;
    });
    print("this is photographersList ${photographersList[0].firstName}");

  }

  getEventTypes() async {
    var uri =
    Uri.parse(getEventsApis.toString());
    // '${Apipath.getCitiesUrl}');
    var request = http.MultipartRequest("GET", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    // request.fields['type_id'] = "1";
    // request.fields['vendor_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    setState(() {
      eventList = EventTypeModel.fromJson(userData).categories!;
    });
  }

  getCitiesList() async {
    var uri =
    Uri.parse(getCitiesApi.toString());
    // '${Apipath.getCitiesUrl}');
    var request = http.MultipartRequest("GET", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    // request.fields['type_id'] = "1";
    // request.fields['vendor_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    setState(() {
      citiesList = GetCitiesModel.fromJson(userData).data!;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPhotographerType();
      getPhotographerList();
    getEventTypes();
    getCitiesList();
  }
  addFreelancer() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('id');
    var headers = {
      'Cookie': 'ci_session=b222ee2ce87968a446feacdb861ad51c821bdf6d'
    };
    var request = http.MultipartRequest('POST', Uri.parse(addFreelancerApi.toString()));
    request.fields.addAll({
      'client_name':photographer.toString(),
      //clientNameController.text.toString(),
      'city': cityController.toString(),
      'type_event': eventController.toString(),
      'amount[]':amountt.text.toString(),
      'date[]': selectDates.toString(),
      'time[]': selectTimes.toString(),
      'total':totall.toString(),
      'type':photographerType.toString(),
      'user_id': userId.toString(),
      'photographer_id': photographeridd.toString(),
    });
    print("this is add quotation request ${request.fields.toString()}");

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseData = await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);


      Navigator.pop(context);
      Fluttertoast.showToast(msg: userData['message']);

    }
    else {
      print(response.reasonPhrase);
    }

  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: AddJobController(),
      builder: (controller) {
        return  Scaffold(backgroundColor: AppColors.backgruond,
            appBar: AppBar(
              backgroundColor: Color(0xff303030),
              leading: InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios, color: Color(0xff1E90FF))),
              actions: const [
                 Center(
                  child: Padding(
                    padding:  EdgeInsets.only(right:14),
                    child: Text("Add Freelancing Job", style: TextStyle(fontSize: 14, color: Color(0xff1E90FF), fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 15),
              child: SingleChildScrollView(
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xff3B3B3B),
                        ),
                        child: Column(
                          children: [
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       Text("Auto Job ID",
                            //         style: TextStyle(color: Color(0xff42ACFE),fontWeight: FontWeight.bold),),
                            //       Container(width:180,
                            //         height: 30,
                            //         decoration: BoxDecoration(
                            //           borderRadius: BorderRadius.circular(8),
                            //           color: AppColors.backgruond,
                            //         ),
                            //
                            //         child: Align(alignment: Alignment.centerLeft, child: Padding(
                            //           padding: const EdgeInsets.all(8.0),
                            //           child: Text("FJ001",style: TextStyle(color: AppColors.whit),),
                            //         )),)
                            //     ],
                            //   ),
                            //
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Photographer",
                                  style: TextStyle(color: AppColors.pdfbtn),
                                ),
                                Padding(
                                  padding:const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 0),
                                  child: Container(
                                    padding: EdgeInsets.only(left: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: AppColors.containerclr2),
                                    width:
                                    MediaQuery.of(context).size.width / 2.1,
                                    child:   DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: AppColors.cardclr,
                                        // Initial Value
                                        value: photographer,
                                        isExpanded: true,
                                        hint: const Text(
                                          "Photographer",
                                          style: TextStyle(
                                              color: AppColors.textclr),
                                        ),
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppColors.textclr,
                                        ),
                                        // Array list of items
                                        items: photographersList
                                            .map((items) {
                                          return DropdownMenuItem(
                                            value: items.firstName.toString(),
                                            child: Text(
                                              items.firstName.toString(),
                                              style: const TextStyle(
                                                  color:
                                                  AppColors.textclr),
                                            ),
                                          );
                                        }).toList(),
                                        // After selecting the desired option,it will
                                        // change button value to selected value
                                        onChanged: (newValue) {
                                          setState(() {
                                            photographer = newValue;
                                          });
                                        },
                                      ),
                                    ),

                                    // TextFormField(
                                    //   style:
                                    //      const TextStyle(color: AppColors.textclr),
                                    //   controller: eventController,
                                    //   keyboardType: TextInputType.name,
                                    //   validator: (value) => value!.isEmpty
                                    //       ? ' Events cannot be blank'
                                    //       : null,
                                    //   decoration: const InputDecoration(
                                    //       hintText: 'Enter Events',
                                    //       hintStyle: TextStyle(
                                    //           color: AppColors.textclr,
                                    //           fontSize: 14),
                                    //       border: InputBorder.none,
                                    //       contentPadding: EdgeInsets.only(
                                    //           left: 10, bottom: 6)),
                                    // ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "City/Venue",
                                  style: TextStyle(color: AppColors.pdfbtn),
                                ),
                                Padding(
                                  padding:const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 0),
                                  child: Container(
                                    padding: EdgeInsets.only(left: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: AppColors.containerclr2),
                                    width:
                                    MediaQuery.of(context).size.width / 2.1,
                                    child:   DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: AppColors.cardclr,
                                        // Initial Value
                                        value: cityController,
                                        isExpanded: true,
                                        hint: const Text(
                                          "City",
                                          style: TextStyle(
                                              color: AppColors.textclr),
                                        ),
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppColors.textclr,
                                        ),
                                        // Array list of items
                                        items: citiesList
                                            .map((items) {
                                          return DropdownMenuItem(
                                            value: items.name.toString(),
                                            child: Text(
                                              items.name.toString(),
                                              style: const TextStyle(
                                                  color:
                                                  AppColors.textclr),
                                            ),
                                          );
                                        }).toList(),
                                        // After selecting the desired option,it will
                                        // change button value to selected value
                                        onChanged: (newValue) {
                                          setState(() {
                                            cityController = newValue;
                                          });
                                        },
                                      ),
                                    ),

                                    // TextFormField(
                                    //   style:
                                    //      const TextStyle(color: AppColors.textclr),
                                    //   controller: eventController,
                                    //   keyboardType: TextInputType.name,
                                    //   validator: (value) => value!.isEmpty
                                    //       ? ' Events cannot be blank'
                                    //       : null,
                                    //   decoration: const InputDecoration(
                                    //       hintText: 'Enter Events',
                                    //       hintStyle: TextStyle(
                                    //           color: AppColors.textclr,
                                    //           fontSize: 14),
                                    //       border: InputBorder.none,
                                    //       contentPadding: EdgeInsets.only(
                                    //           left: 10, bottom: 6)),
                                    // ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Event",
                                  style: TextStyle(color: AppColors.pdfbtn),
                                ),
                                Padding(
                                  padding:const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 0),
                                  child: Container(
                                    padding: EdgeInsets.only(left: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: AppColors.containerclr2),
                                    width:
                                    MediaQuery.of(context).size.width / 2.1,
                                    child:   DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: AppColors.cardclr,
                                        // Initial Value
                                        value: eventController,
                                        isExpanded: true,
                                        hint: const Text(
                                          "Event",
                                          style: TextStyle(
                                              color: AppColors.textclr),
                                        ),
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppColors.textclr,
                                        ),
                                        // Array list of items
                                        items: eventList
                                            .map((items) {
                                          return DropdownMenuItem(
                                            value: items.cName.toString(),
                                            child: Text(
                                              items.cName.toString(),
                                              style: const TextStyle(
                                                  color:
                                                  AppColors.textclr),
                                            ),
                                          );
                                        }).toList(),
                                        // After selecting the desired option,it will
                                        // change button value to selected value
                                        onChanged: (newValue) {
                                          setState(() {
                                            eventController = newValue;
                                          });
                                        },
                                      ),
                                    ),

                                    // TextFormField(
                                    //   style:
                                    //      const TextStyle(color: AppColors.textclr),
                                    //   controller: eventController,
                                    //   keyboardType: TextInputType.name,
                                    //   validator: (value) => value!.isEmpty
                                    //       ? ' Events cannot be blank'
                                    //       : null,
                                    //   decoration: const InputDecoration(
                                    //       hintText: 'Enter Events',
                                    //       hintStyle: TextStyle(
                                    //           color: AppColors.textclr,
                                    //           fontSize: 14),
                                    //       border: InputBorder.none,
                                    //       contentPadding: EdgeInsets.only(
                                    //           left: 10, bottom: 6)),
                                    // ),
                                  ),
                                )
                              ],
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       Text("City/Venue",
                            //         style: TextStyle(color: Color(0xff42ACFE),fontWeight: FontWeight.bold),),
                            //       Container(width:180,
                            //         height: 30,
                            //         decoration: BoxDecoration(
                            //           borderRadius: BorderRadius.circular(8),
                            //           color: AppColors.backgruond,
                            //         ),
                            //         child: Align(alignment: Alignment.centerLeft, child: Padding(
                            //           padding: const EdgeInsets.all(8.0),
                            //           child: Text("Mumbai",style: TextStyle(color: AppColors.whit),),
                            //         )),)
                            //     ],
                            //   ),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       Text("Events",
                            //         style: TextStyle(color: Color(0xff42ACFE),fontWeight: FontWeight.bold),),
                            //       Container(
                            //         width:180,
                            //         height: 35,
                            //         decoration: BoxDecoration(
                            //           borderRadius: BorderRadius.circular(8),
                            //           color: AppColors.backgruond,
                            //         ),
                            //         child: DropdownButtonHideUnderline(
                            //           child: DropdownButton(
                            //             elevation: 0,
                            //             underline: Container(),
                            //             isExpanded: true,
                            //             value: _cityValue,
                            //             icon: const Icon(Icons.keyboard_arrow_down,size: 40,color: Color(0xff3B3B3B),),
                            //             hint: const Align(alignment: Alignment.centerLeft,
                            //               child: Padding(
                            //                 padding:  EdgeInsets.all(8.0),
                            //                 child: Text("Mumbai", style: TextStyle(
                            //                     color:AppColors.whit
                            //                 ),),
                            //               ),
                            //             ),
                            //             items:item2.map((String items) {
                            //               return DropdownMenuItem(
                            //                   value: items,
                            //                   child: Text(items)
                            //               );
                            //             }
                            //             ).toList(),
                            //             onChanged: (String? newValue){
                            //               setState(() {
                            //                 _cityValue = newValue!;
                            //               });
                            //             },
                            //
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),

                          ],
                        ),
                      ),
                      SizedBox(height: 12,),
                      Container(

                        height: 90,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:Color(0xff8B8B8B),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            children: [
                              Align(alignment: Alignment.topCenter, child: Text("Type Of Photography",style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.whit,fontSize: 14),)),
                              const SizedBox(height: 8,),
                              Container(
                                padding: const EdgeInsets.only(left: 8),
                                height: 35,
                                width:220 ,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color(0xffbfbfbf),
                                ),
                                child:DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    dropdownColor: AppColors.cardclr,
                                    // Initial Value
                                    value: photographerType,
                                    isExpanded: true,
                                    hint: const Text(
                                      "Type Of Photography",
                                      style: TextStyle(
                                          color: AppColors.textclr),
                                    ),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: AppColors.textclr,
                                    ),
                                    // Array list of items
                                    items: typeofPhotographyEvent
                                        .map((items) {
                                      return DropdownMenuItem(
                                        value: items.resName.toString(),
                                        child: Text(
                                          items.resName.toString(),
                                          style: const TextStyle(
                                              color:
                                              AppColors.textclr),
                                        ),
                                      );
                                    }).toList(),
                                    // After selecting the desired option,it will
                                    // change button value to selected value
                                    onChanged: (newValue) {
                                      setState(() {
                                        photographerType = newValue;
                                      });
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12,),
                      Container(height: 45,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:Color(0xff42ACFE),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Date",style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.whit),),
                              Text("Time",style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.whit),),
                              Text("Amount",style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.whit),),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: Expanded(
                          child: ListView.builder(
                            // physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.adMore,
                            itemBuilder: (context, index) {
                            return  Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Container(
                                height: 45,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color:Color(0xff8B8B8B),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap : (){
                                          controller.selectDate(context, index);
                                          selectDates = controller.selectedDates.join(',');
                                          print('this is selected dates $selectDates');
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                                          decoration: const BoxDecoration(
                                            // color:AppColors.datecontainer,
                                          ),
                                          child: Text(
                                            controller.selectedDates[index] != null
                                                ? ' ${DateFormat('MM-dd-yyyy').format(controller.selectedDates[index])}' :
                                                 'Select Date ',style: TextStyle(color: AppColors.textclr,fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      // Text("(MM-DD-YYYY)",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: AppColors.whit,fontStyle: FontStyle.italic),),
                                      InkWell(
                                        onTap: (){
                                          controller.selectTime(context);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                                          decoration: const BoxDecoration(
                                            // color:AppColors.datecontainer,
                                          ),
                                          child: Text(
                                            controller. selectedTime != null
                                                ? ' ${controller.selectedTime.format(context)} to ${controller.selectedTime2.format(context)}'
                                                : 'Select Time For Bookings',style: TextStyle(color: AppColors.textclr,fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            // color:  Color(0xffbfbfbf),
                                            borderRadius: BorderRadius.circular(10)),
                                        // height: 35,
                                        width: 100,
                                        child: TextFormField(
                                          style: TextStyle(color: AppColors.textclr),
                                          // controller: controller.outputController,
                                          keyboardType: TextInputType.number,
                                          controller: amountt,
                                          validator: (value) => value!.isEmpty ? 'Amount cannot be blank':null,
                                          decoration: InputDecoration(
                                              hintText: 'Enter Amount',hintStyle: TextStyle(color: AppColors.textclr,fontSize: 14),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.only(left:8,bottom: 15)

                                          ),
                                         
                                        ),
                                      ),
                                      // Text("Enter Time Optional",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: AppColors.whit,fontStyle: FontStyle.italic),),
                                      // Text("Enter Amount",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: AppColors.whit,fontStyle: FontStyle.italic),),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },),
                        ),
                      ),

                      InkWell(
                        onTap: (){
                          if(controller.formKey.currentState!.validate() && controller.selectedDates.isNotEmpty) {
                            controller.increment();
                          }
                        },
                        child: Container(height: 45,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color:Color(0xff8B8B8B),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: (){
                                if(controller.formKey.currentState!.validate()) {
                                  controller.increment();

  var a=int.parse(amountt.text);
  totall=(totall+a);

  //amountt.clear();
  a=0;




                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_circle_outline,color:Color(0xff42ACFE) ,size: 30,),
                                  Text("Add More",style: TextStyle(color:Color(0xff42ACFE),fontWeight: FontWeight.bold),)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Align(alignment: Alignment.centerLeft, child: Text("Total",style: TextStyle(fontWeight: FontWeight.bold,color:AppColors.whit),)),
                              Container(height: 30,width: 230,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color(0xffbfbfbf),
                                ),
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text("${totall}   =Sum(Amount)",style: TextStyle(color: AppColors.whit,fontStyle: FontStyle.italic),)),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 20,),
                      Align(
                        alignment: Alignment.center,
                        child:   InkWell(
                          onTap: (){
                            addFreelancer();
                            // Navigator.push(context, MaterialPageRoute(builder: (context)=>MyApp()));
                          },
                          child: Container(
                              height: 55,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color:  AppColors.pdfbtn),
                              width: MediaQuery.of(context).size.width/1.5,
                              child: Center(child: Text("Add", style: TextStyle(fontSize: 18, color: AppColors.textclr)))
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                    ],
                  ),
                ),
              ),
            ));
      },);
  }

}
