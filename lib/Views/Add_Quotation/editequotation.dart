import 'dart:convert';
import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kolazz_book/Models/client_model.dart';
import 'package:kolazz_book/Models/event_type_model.dart';
import 'package:kolazz_book/Models/get_cities_model.dart';
import 'package:kolazz_book/Models/get_quotation_model.dart';
import 'package:kolazz_book/Services/request_keys.dart';
import 'package:kolazz_book/Utils/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Controller/addQuatation_controller.dart';
import '../../Models/Type_of_photography_model.dart';
import '../../Utils/colors.dart';
import 'package:http/http.dart' as http;


class EditQuotationScreen extends StatefulWidget {
  final String? qid, id;
  const EditQuotationScreen({Key? key, this.qid, this.id}) : super(key: key);

  @override
  State<EditQuotationScreen> createState() => _EditQuotationScreenState();
}

class _EditQuotationScreenState extends State<EditQuotationScreen> {
  List<Widget> customWidgets = [];
  int cardCount = 0;
  int value1 = 0;
  List<String> selectedvlaue = [];

  List<List<String>> stringList = [];
  List<Categories> typeofPhotographyEvent = [];
  List<EventType> eventList = [];
  List<CityList> citiesList = [];
  List photographerType = [];
  bool isLast = false;

  String photographer = "photographer";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  createClientJob(BuildContext context) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // String? userId = preferences.getString('id');
    var uri = Uri.parse(createClientJobApi.toString());

    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.fields.addAll({
      // 'user_id': userId.toString(),
      // 'type': 'client',
      'id': widget.id.toString(),
    });
    request.headers.addAll(headers);
    // request.fields['user_id'] = userId.toString();
    // request.fields['type'] = 'photographer';
    print("this is my quotation Details  ${request.fields.toString()}");
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    Fluttertoast.showToast(msg: userData['message']);
    Navigator.pop(context);
    Navigator.pop(context, true);
  }

  updateQuotation() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('id');
    var headers = {
      'Cookie': 'ci_session=b222ee2ce87968a446feacdb861ad51c821bdf6d'
    };

    var request =
    http.MultipartRequest('POST', Uri.parse(addQuotationApi.toString()));

    request.fields.addAll({
      'client_name': clientNameController.text.toString(),
      'city': cityNameController.text.toString(),
      'mobile': clientId.toString(),
      'type_event': eventController.toString(),
      'output': outputController.text.toString(),
      'amount': amountController.text.toString(),
      // 'event[]': selectedEvents.toString(),
      'type': 'client',
      'event_details': finalList.toString(),
      // 'date[]': selectedDate.toString(),
      'user_id': userId.toString(),
      'id': widget.id.toString()
    });
    print("this is add quotation request ${request.fields.toString()}");

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseData =
      await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);
      Navigator.pop(context, true);
      Fluttertoast.showToast(msg: userData['message']);
    } else {
      print(response.reasonPhrase);
    }
  }

  String pdfUrl = '';
  downloadPdfs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? id = preferences.getString('id');
    var uri = Uri.parse(downloadPdfApi.toString());
    // '${Apipath.getCitiesUrl}');
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    request.fields[RequestKeys.userId] = id!;
    request.fields[RequestKeys.type] = 'jobs' ;
    request.fields[RequestKeys.jobStatus] = '0' ;
    // request.fields[RequestKeys.filter] =
    // widget.type == true ? 'all' : 'upcomings';
    request.fields[RequestKeys.jobId] = widget.id.toString();
    var response = await request.send();
    print("this is pdf download requests ${request.fields}");
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    setState(() {
      pdfUrl = userData['url'];
    });
    _showPdf(pdfUrl);
    print("this is our html content $pdfUrl");
    // downloadPdfs();
  }

  _showPdf(pdf) async {
    print("this is my url $pdf");
    var url = pdf.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(msg: "Could not open this pdf!");
      throw 'Could not launch $url';
    }
  }

  List selectedDates = [];

  DateTime? adquatationDate;
  List showSelectedDate = [];
  List showPhotographer = [];
  int currentIndex = 0;

  List up = [];
  final formKey = GlobalKey<FormState>();

  TextEditingController clientNameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController outputController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController cityNameController = TextEditingController();

  String? selectedEvents;
  var eventController;
  var cityController;
  var clientName;
  String? userId;
  String? clientId;
  List<ClientList> clientList = [];

  List<Setting> quotationData = [];
  List newQuotationData = [];

  getQuotationDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('id');
    var uri = Uri.parse(getQuotationApi.toString());

    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.fields.addAll({
      'user_id': userId.toString(),
      'type': 'client',
      'id': widget.id.toString(),
    });
    request.headers.addAll(headers);
    // request.fields['user_id'] = userId.toString();
    // request.fields['type'] = 'photographer';
    print("this is my quotation Details  ${request.fields.toString()}");
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    final result = GetQuotationModel.fromJson(userData);
    newQuotationData = userData['setting'];
    quotationData = result.setting!;
    clientNameController.text = quotationData[0].clientName.toString();
    cityController = quotationData[0].city.toString();
    cityNameController.text = quotationData[0].cityName.toString();
    clientId = quotationData[0].clientId.toString();
    eventController = quotationData[0].typeEvent.toString();
    amountController.text = quotationData[0].amount.toString();
    mobileController.text = quotationData[0].mobile.toString();
    outputController.text = quotationData[0].output.toString();
    setState(() {
      newList = newQuotationData[0]['photographers_details']!;
    });
    print("this i s my new list $newList");
    for(var i = 0; i< newList.length; i ++){
      up.add(newList[i]['date']);
    }
  setState(() {
    pType = newList[currentIndex]['data'];
  });

    print("this is my api data ${up.length} andf ${pType}");
    // clientNameController.text = quotationData![0].clientName.toString();
  }

  getPhotographerType() async {
    var uri = Uri.parse(getPhotographerApi.toString());
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

  getEventTypes() async {
    var uri = Uri.parse(getEventsApis.toString());
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

  getClients() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString('id');
    var uri = Uri.parse(getClientPhotographersApi.toString());
    // '${Apipath.getCitiesUrl}');
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    request.fields['type'] = "client";
    request.fields['user_id'] = userId.toString();
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    setState(() {
      clientList = ClientModel.fromJson(userData).data!;
    });
  }

  getCitiesList() async {
    var uri = Uri.parse(getCitiesApi.toString());
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

  void increment() {
    if ( pType.length < 10) {
      pType.length++;
    }
    print("this is working!");
    setState(() {});
  }

  deleteConfirmation(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.primary,
      title: const Text(
        'Delete Quotation!',
        style: TextStyle(color: AppColors.textclr),
      ),
      content: const Text(
        'Are you sure you want to delete this quotation?',
        style: TextStyle(color: AppColors.textclr),
      ),
      actions: [
        TextButton(
          child: Container(
              height: 25,
              width: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.AppbtnColor),
              child: const Center(
                  child: Text(
                    'No',
                    style: TextStyle(color: AppColors.textclr),
                  ))),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Container(
              height: 25,
              width: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.AppbtnColor),
              child: const Center(
                  child: Text(
                    'Yes',
                    style: TextStyle(color: AppColors.textclr),
                  ))),
          onPressed: () {
            deleteQuotation(quotationData[0].id.toString(), context);
          },
        ),
      ],
    );
  }

  deleteQuotation(String id, BuildContext context) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();ff
    // String? userId = preferences.getString('id');
    var headers = {
      'Cookie': 'ci_session=b222ee2ce87968a446feacdb861ad51c821bdf6d'
    };
    var request =
    http.MultipartRequest('POST', Uri.parse(deleteQuotationApi.toString()));
    request.fields.addAll({'id': id.toString()});
    print(
        "this is delete quotation request ${request.fields.toString()} and $deleteQuotationApi");

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseData =
      await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);
      if (userData['error'] == false) {

        Fluttertoast.showToast(msg: userData['message']);
        if(mounted){
          Navigator.pop(context);
          Navigator.pop(context, false);
        }


      } else {
        Fluttertoast.showToast(msg: userData['message']);
        // Fluttertoast.showToast(msg: userData['msg']);
      }
    } else {
      print(response.reasonPhrase);
    }
  }


  addDateDialog(
      BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          bool isChecked = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.back,
              content: Form(
                  key: _formKey,
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () async {
                          await selectDate(context, setState, 1, false);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2,
                          height: 45,
                          padding: const EdgeInsets.only(left: 8, top: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.containerclr2),
                          child: Text(
                            adquatationDate != null
                                ? ' ${DateFormat('dd-MM-yyyy').format(adquatationDate!)}'
                                : 'Select Date',
                            style: const TextStyle(
                                color: AppColors.textclr, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15,),
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                if(up.isNotEmpty ){
                                  newList[currentIndex]['data'] = pType;
                                  print("this is my ptype $pType");
                                  pType = [];
                                  print("this is my ptype $pType");
                                }
                                up.add(DateFormat('dd-MM-yyyy').format(adquatationDate!).toString());
                                currentIndex = up.length - 1;
                                newList.add({'date': DateFormat('dd-MM-yyyy').format(adquatationDate!).toString(),'data': pType});
                                adquatationDate = null;
                                // if(currentIndex != 0 ) {
                                //   if(adquatationDate != null){
                                //     newList.add({
                                //       "date": DateFormat('dd-MM-yyyy').format(
                                //           adquatationDate!).toString(),
                                //       "data": pType
                                //     });
                                //   }
                                //   else{
                                //     Fluttertoast.showToast(msg: "Please select date first");
                                //   }
                                //   print("this is my lidst $newList");
                                //   setState(() {
                                //     pType = [];
                                //   });
                                // }else{
                                //   if(adquatationDate != null){
                                //     newList.add({
                                //       "date": DateFormat('dd-MM-yyyy').format(
                                //           adquatationDate!).toString(),
                                //       "data": pType
                                //     });
                                //   }
                                //   else{
                                //     Fluttertoast.showToast(msg: "Please select date first");
                                //   }

                                // setState(() {
                                //   pType = [];
                                // });
                                // }
                                Navigator.pop(context);

                                // if(widget.type == true) {
                                //   setState((){
                                //     totalAmount = double.parse(
                                //         widget.allJobs!.totalAmount.toString()) + double.parse(amountController.text.toString());
                                //   });
                                // }else {
                                //   setState(() {
                                //     totalAmount = double.parse(
                                //         widget.upcomingJobs!.totalAmount.toString()) +
                                //         double.parse(amountController.text.toString());
                                //   });
                                // }
                                // // setState(() {
                                // //   // widget.allJobs!.jsonData!.se = amountController.text.toString();
                                // //   // descriptionController  = TextEditingController(
                                // //   //     text: widget.allJobs?.jsonData?[index].description
                                // //   // );
                                // //   // data.se= amountController.text.toString();
                                // //   // data.description =
                                // //   //     descriptionController.text.toString();
                                // // });
                                //
                                // Navigator.pop(context, {
                                //   'date' : selectedDates,
                                //   'amount': amountController.text.toString(),
                                //   // 'description': descriptionController.text.toString()
                                // });
                              },
                              child: Container(
                                  height: 40,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: AppColors.pdfbtn),
                                  child: const Center(
                                      child: Text("Add",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: AppColors.textclr)))),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            );
          });
        });
  }

  editUpdateDateDialog(
      BuildContext context, int index) async {
    return await showDialog(
        context: context,
        builder: (context) {
          bool isChecked = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.back,
              content: Form(
                  key: _formKey,
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () async {
                          await selectDate(context, setState, index, true);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2,
                          height: 45,
                          padding: const EdgeInsets.only(left: 8, top: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.containerclr2),
                          child: Text(

                            adquatationDate != null
                                ? DateFormat('dd-MM-yyyy').format(adquatationDate!)
                                : up.isNotEmpty ?
                            up[index]
                                : 'Select Date',
                            style: const TextStyle(
                                color: AppColors.textclr, fontSize: 12),
                          ),
                        ),
                      ),


                      const SizedBox(height: 15,),
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                setState((){});
                                Navigator.pop(context,  DateFormat('dd-MM-yyyy').format(adquatationDate!)
                                );
                              },
                              child: Container(
                                  height: 40,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: AppColors.pdfbtn),
                                  child: const Center(
                                      child: Text("Update",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: AppColors.textclr)))),
                            ),
                            // InkWell(
                            //   onTap: () async{
                            //     // setState(() {
                            //     // });
                            //     // await jsData.removeAt(index);
                            //     Navigator.pop(context,true);
                            //     setState((){});
                            //   },
                            //   child: Container(
                            //       height: 40,
                            //       width: 100,
                            //       decoration: BoxDecoration(
                            //           borderRadius: BorderRadius.circular(50),
                            //           color: AppColors.contaccontainerred),
                            //       child: const Center(
                            //           child: Text("Delete",
                            //               style: TextStyle(
                            //                   fontSize: 18,
                            //                   color: AppColors.textclr)))),
                            // ),

                          ],
                        ),
                      ),
                    ],
                  )),
            );
          });
        });
  }

  String? selectedDate;

  Future<void> selectDate(BuildContext context, setState, index, bool edit) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != adquatationDate) {
      setState(() {
        adquatationDate = picked;
      });
      if(edit){
        setState((){
          newList[index]['date'] = DateFormat('dd-MM-yyyy').format(picked);
          pType = [];
        });
      }

    }else{
      Fluttertoast.showToast(msg: "Date Already selected!");
    }
  }

  Widget photographerCard1(int ind) {

    return Container(
      decoration: const BoxDecoration(
          color: AppColors.teamcard2,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10))),
      child: Column(
        children: [

          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Type Of Photographer",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textclr,
                          fontSize: 18),
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: pType.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0.0, vertical: 5),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 30,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(0),
                                color: AppColors.datecontainer),
                            width: MediaQuery.of(context).size.width / 1.4,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                dropdownColor: AppColors.cardclr,
                                // Initial Value
                                value: pType[index]== null ?pType[index] : pType[index]['photographer_type'] ,
                                // photographerType[index],
                                //  typeofPhotographyEvent[index].selectedValue,
                                isExpanded: true,
                                hint: const Text(
                                  "Type Of Photography",
                                  style: TextStyle(color: AppColors.textclr),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.textclr,
                                ),
                                // Array list of items
                                items: typeofPhotographyEvent
                                    .map(( items) {
                                  return DropdownMenuItem(
                                    value: items.resName,
                                    child: Text(
                                      items.resName.toString(),
                                      style: const TextStyle(
                                          color: AppColors.textclr),
                                    ),
                                  );
                                }).toList(),
                                // After selecting the desired option,it will
                                // change button value to selected value
                                onChanged: (newValue) {
                                  print("my selected val $newValue");

                                  pType[index] = {'photographer_type': newValue};

                                  setState(() {

                                  });

                                },
                              ),
                            ),
                          ),
                          InkWell(
                              onTap: (){
                                setState(() {
                                  pType.removeAt(index);
                                });

                              }, child: Icon(Icons.delete_forever, color: Colors.red,))
                        ],
                      ),
                    );
                  },
                ),

              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              // addTypeDialog(context);
              increment();

            },
            child: Column(
              children: const [
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.add_circle_outline,
                    color: AppColors.temtextclr,
                    size: 30,
                  ),
                ),
                Text(
                  "Add Type Of Photographer",
                  style: TextStyle(
                      color: AppColors.temtextclr,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  bool show = false;

  Widget dateCard(int index) {
    return InkWell(
      onLongPress: () async{
        var result  =  await editUpdateDateDialog(context, index);
        print("this is my result #$result");
        if(result == null){

        }
        else if(result == true){
          setState(() {
            up.removeAt(index);
          });
        }else{
          print("this is ${up[index]}");
          setState(() {
            up[index] = result;
            adquatationDate = null ;
          });
        }
      },
      onTap: () async {
        setState(() {
          newList[currentIndex]['data'] = pType;
          currentIndex = index;
          pType = newList[currentIndex]['data'];
        });

      },
      child: Stack(
        children: [
          Container(
            // width: 100,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8), topLeft: Radius.circular(8)),
              color: AppColors.teamcard2,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration:   BoxDecoration(
                  color: currentIndex == index ?
                  AppColors.AppbtnColor :
                  AppColors.datecontainer,
                ),
                child: Text(
                  up[index] != null
                      ? ' ${up[index]}'
                      : 'Select Date',
                  style:
                  const TextStyle(color: AppColors.textclr, fontSize: 12),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getQuotationDetails();
    getPhotographerType();
    getEventTypes();
    getCitiesList();
    getClients();
  }

  List pType = [];
  List pData = [];
  List newList = [];
  String finalList = '';

  addQuotation() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString('id');
    var headers = {
      'Cookie': 'ci_session=b222ee2ce87968a446feacdb861ad51c821bdf6d'
    };

    var request =
    http.MultipartRequest('POST', Uri.parse(addQuotationApi.toString()));

    request.fields.addAll({
      'client_name': clientName.toString(),
      'city': cityNameController.text.toString(),
      'mobile': mobileController.text.toString(),
      'type_event': eventController.toString(),
      'output': outputController.text.toString(),
      'amount': amountController.text.toString(),
      // 'event[]': selectedEvents.toString(),
      'type': 'client',
      'event_details': finalList.toString(),
      // 'date[]': selectedDate.toString(),
      'user_id': userId.toString()
    });
    print("this is add quotation request ${request.fields.toString()}");

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseData =
      await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);
      Navigator.pop(context, true);
      Fluttertoast.showToast(msg: userData['message']);
    } else {
      print(response.reasonPhrase);
    }
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: AddQuatationController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.back,
          appBar: AppBar(
            leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.AppbtnColor,
                )),
            backgroundColor: AppColors.secondary,
            actions: const [
              Padding(
                padding: EdgeInsets.all(15),
                child: Center(
                  child: Text("Edit Quotation",
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.AppbtnColor,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 0),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xff3B3B3B),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Auto CF ID",
                                  style: TextStyle(
                                      color: Color(0xff42ACFE),
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  width:
                                  MediaQuery.of(context).size.width / 2.1,
                                  // width:180,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: AppColors.backgruond,
                                  ),

                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          widget.qid.toString(),
                                          // quotationData![0].qid.toString(),
                                          style:
                                          TextStyle(color: AppColors.whit),
                                        ),
                                      )),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Client Name",
                                  style: TextStyle(
                                      color: Color(0xff42ACFE),
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: AppColors.containerclr2),
                                    // padding: EdgeInsets.symmetric(vertical: 1),
                                    // width:180,
                                    // height: 30,
                                    width:
                                    MediaQuery.of(context).size.width / 2.1,
                                    child: TextFormField(
                                      readOnly: true,
                                      style: const TextStyle(
                                          color: AppColors.textclr),
                                      controller: clientNameController,
                                      keyboardType: TextInputType.name,
                                      validator: (value) => value!.isEmpty
                                          ? 'Client Name cannot be blank'
                                          : null,
                                      decoration: const InputDecoration(
                                          hintText: 'Enter Client Name',
                                          hintStyle: TextStyle(
                                              color: AppColors.textclr,
                                              fontSize: 14),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 8, bottom: 12)),
                                    ),
                                  ),
                                )
                                // Container(
                                //   width:180,
                                //   height: 35,
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(8),
                                //     color: AppColors.backgruond,
                                //   ),
                                //   child: DropdownButtonHideUnderline(
                                //     child: DropdownButton(
                                //       elevation: 0,
                                //       underline: Container(),
                                //       isExpanded: true,
                                //       value: _chosenValue,
                                //       icon: Icon(Icons.keyboard_arrow_down,size: 40,color: Color(0xff3B3B3B),),
                                //       hint: Align(alignment: Alignment.centerLeft,
                                //         child: Padding(
                                //           padding: const EdgeInsets.all(8.0),
                                //           child: Text("Kaushik Prajapati", style: TextStyle(
                                //               color:AppColors.whit
                                //           ),),
                                //         ),
                                //       ),
                                //       items:item.map((String items) {
                                //         return DropdownMenuItem(
                                //             value: items,
                                //             child: Text(items)
                                //         );
                                //       }
                                //       ).toList(),
                                //       onChanged: (String? newValue){
                                //         setState(() {
                                //           _chosenValue = newValue!;
                                //         });
                                //       },
                                //
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "City/Venue",
                                  style: TextStyle(color: AppColors.pdfbtn),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: AppColors.containerclr2),
                                    width:
                                    MediaQuery.of(context).size.width / 2.1,
                                    child: TextFormField(
                                      style: const TextStyle(
                                          color: AppColors.textclr),
                                      controller: cityNameController,
                                      keyboardType: TextInputType.name,
                                      validator: (value) => value!.isEmpty
                                          ? ' City/Venue cannot be blank'
                                          : null,
                                      decoration: const InputDecoration(
                                          hintText: 'City/Venue',
                                          hintStyle: TextStyle(
                                              color: AppColors.textclr,
                                              fontSize: 14),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 6)),
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
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Event",
                                  style: TextStyle(color: AppColors.pdfbtn),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 0),
                                  child: Container(
                                    padding: EdgeInsets.only(left: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: AppColors.containerclr2),
                                    width:
                                    MediaQuery.of(context).size.width / 2.1,
                                    child: DropdownButtonHideUnderline(
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
                                        items: eventList.map((items) {
                                          return DropdownMenuItem(
                                            value: items.id.toString(),
                                            child: Text(
                                              items.cName.toString(),
                                              style: const TextStyle(
                                                  color: AppColors.textclr),
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
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Mobile Number",
                                  style: TextStyle(color: AppColors.pdfbtn),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: AppColors.containerclr2),
                                    width:
                                    MediaQuery.of(context).size.width / 2.1,
                                    child: TextFormField(
                                      style: const TextStyle(
                                          color: AppColors.textclr),
                                      controller: mobileController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 10,
                                      validator: (value) => value!.isEmpty
                                          ? ' Mobile Number cannot be blank'
                                          : null,
                                      decoration: const InputDecoration(
                                          counterText: '',
                                          hintText: 'Enter Mobile',
                                          hintStyle: TextStyle(
                                              color: AppColors.textclr,
                                              fontSize: 14),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10, bottom: 6)),
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 40,
                          width: up.isEmpty
                              ? 125
                              : MediaQuery.of(context).size.width - 125,
                          child: up.isEmpty
                              ? InkWell(
                            onTap: () {
                              // if(currentIndex == index){
                              //   setState(() {
                              //     show = true;
                              //   });
                              // }
                            },
                            child: Container(
                              width: 125,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    topLeft: Radius.circular(8)),
                                color: AppColors.teamcard2,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  decoration: const BoxDecoration(
                                    color: AppColors.datecontainer,
                                  ),
                                  child: const Text(
                                    // showSelectedDate[index] != null
                                    //     ? ' ${DateFormat('yyyy-MM-dd').format(showSelectedDate[index])}'
                                    'Select Date',
                                    style: TextStyle(
                                        color: AppColors.textclr,
                                        fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          )
                              : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: up.length,
                              itemBuilder: (context, index) {
                                // currentIndex = index;
                                return dateCard(index);
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: InkWell(
                            onTap: ()  async {
                              await addDateDialog(context);


                              print("this is my lidst $newList");
                              setState(() {
                                adquatationDate = null;
                              });

                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.temtextclr,
                                  size: 28,
                                ),
                                Text(
                                  "Add Date",
                                  style: TextStyle(
                                      color: AppColors.temtextclr,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    photographerCard1(currentIndex),


                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,

                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Output",
                            style: TextStyle(
                                color: AppColors.textclr,
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.teamcard,
                                borderRadius: BorderRadius.circular(10)),
                            height: 70,
                            width: MediaQuery.of(context).size.width / 1.5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                maxLines: 4,
                                style: const TextStyle(
                                    color: AppColors.textclr, fontSize: 14),
                                controller: outputController,
                                keyboardType: TextInputType.name,
                                validator: (value) => value!.isEmpty
                                    ? 'Output cannot be blank'
                                    : null,
                                decoration: const InputDecoration(
                                    hintText: '',
                                    hintStyle: TextStyle(
                                        color: AppColors.textclr, fontSize: 14),
                                    border: InputBorder.none,
                                    contentPadding:
                                    EdgeInsets.only(left: 10, bottom: 10)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          const Text(
                            "Amount",
                            style: TextStyle(
                                color: AppColors.textclr,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Spacer(),
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.teamcard,
                                borderRadius: BorderRadius.circular(10)),
                            height: 35,
                            width: MediaQuery.of(context).size.width / 1.5,
                            child: TextFormField(
                              style: TextStyle(color: AppColors.textclr),
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty
                                  ? 'Amount cannot be blank'
                                  : null,
                              decoration: const InputDecoration(
                                  hintText: '',
                                  hintStyle: TextStyle(
                                      color: AppColors.textclr, fontSize: 14),
                                  border: InputBorder.none,
                                  contentPadding:
                                  EdgeInsets.only(left: 10, bottom: 10)),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              finalList = jsonEncode(newList);
                              print("this final List $newList and $finalList");

                              if(eventController != null) {
                                updateQuotation();
                              }
                              else {
                                Fluttertoast.showToast(
                                    msg: "Please select city or event!");
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please select city or event!");
                            }

                          },
                          child: Container(
                            height: 35,
                            width: 100,
                            decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    offset: Offset(1, 2),
                                    blurRadius: 1,
                                    color: AppColors.greyColor,
                                  )
                                ],
                                color: AppColors.AppbtnColor,
                                borderRadius: BorderRadius.circular(30)),
                            child: const Center(
                                child: Text(
                                  "Update",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textclr,
                                      fontSize: 18),
                                )),
                          ),
                        ),

                        InkWell(
                          onTap: (){
                            downloadPdfs();
                          },
                          child
                              : Image.asset(
                            "assets/images/pdf.png",
                            scale: 1.6,
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            await showDialog(
                                context: context,
                                builder: (context) {
                                  return deleteConfirmation(context);
                                });
                          },
                          child: Container(
                            height: 35,
                            width: 100,
                            decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    offset: Offset(1, 2),
                                    blurRadius: 1,
                                    color: AppColors.greyColor,
                                  )
                                ],
                                color: AppColors.contaccontainerred,
                                borderRadius: BorderRadius.circular(30)),
                            child: const Center(
                                child: Text(
                                  "Delete",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textclr,
                                      fontSize: 18),
                                )),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          finalList = jsonEncode(newList);
                          print("this final List $newList and $finalList");

                          if(eventController != null) {
                            createClientJob(context);
                          }
                          else {
                            Fluttertoast.showToast(
                                msg: "Please select city or event!");
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please select city or event!");
                        }


                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => MoreQuatations()));
                      },
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width / 2,
                        decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                offset: Offset(1, 2),
                                blurRadius: 1,
                                color: AppColors.greyColor,
                              )
                            ],
                            borderRadius: BorderRadius.circular(40),
                            color: AppColors.greenbtn),
                        child: const Center(
                          child: Text("Final Booking",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.whit)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

