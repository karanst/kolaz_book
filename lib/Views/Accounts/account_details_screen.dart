

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kolazz_book/Models/ledger_entries_model.dart';
import 'package:kolazz_book/Services/request_keys.dart';
import 'package:kolazz_book/Utils/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../Utils/colors.dart';

class AccountDetailsScreen extends StatefulWidget {
  final String? photographerName, pid, type;

  const AccountDetailsScreen({Key? key, this.photographerName, this.pid, this.type}) : super(key: key);

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {

  bool isClickable = true;
  bool isSelected = true;
  List<LedgerData> ledgerData = [];
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();


  Widget _paymentReceived() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        const Padding(
          padding:  EdgeInsets.all(8.0),
          child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 15.0),
                child: Text("Enter Received Amount",style: TextStyle(color: AppColors.textclr,fontSize: 15,fontWeight: FontWeight.w400),),
              )),
        ),
        Container(
          height: 60,
          width: MediaQuery.of(context).size.width/1.1,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.lightwhite),
          child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 5),
              child:TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,

                  // border: OutlineInputBorder()
                ),
              )
          ),
        ),
       const  SizedBox(height: 10,),
       const  Padding(
          padding:  EdgeInsets.all(8.0),
          child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 15.0),
                child: Text("Enter Short Description(Optional)",style: TextStyle(color: AppColors.textclr,fontSize: 15,fontWeight: FontWeight.w400),),
              )),
        ),
        Container(
          height: 60,
          width: MediaQuery.of(context).size.width/1.1,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.lightwhite),
          child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 5),
              child:TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,

                  // border: OutlineInputBorder()
                ),
              )
          ),
        ),
       const  SizedBox(height: 40,),

        InkWell(
          onTap: (){
              addAmount('debit');

          },
          child: Container(
              height: 55,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color:  AppColors.greenbtn),
              width: MediaQuery.of(context).size.width/1.5,
              child: const Center(child: Text("Add Payment", style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold, color: AppColors.textclr)))
          ),
        ),
        const  SizedBox(height: 20,),

      ],
    );
  }

  Widget _payout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
       const  Padding(
          padding:  EdgeInsets.all(8.0),
          child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 15.0),
                child: Text("Add Payout Amount",style: TextStyle(color: AppColors.textclr,fontSize: 15,fontWeight: FontWeight.w400),),
              )),
        ),
        Container(
          height: 60,
          width: MediaQuery.of(context).size.width/1.1,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.lightwhite),
          child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 5),
              child:TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,

                  // border: OutlineInputBorder()
                ),
              )
          ),
        ),
       const SizedBox(height: 10,),
       const Padding(
          padding:  EdgeInsets.all(8.0),
          child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 15.0),
                child: Text("Enter Short Description(Optional)",style: TextStyle(color: AppColors.textclr,fontSize: 15,fontWeight: FontWeight.w400),),
              )),
        ),
        Container(
          height: 60,
          width: MediaQuery.of(context).size.width/1.1,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.lightwhite),
          child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 5),
              child:TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,

                  // border: OutlineInputBorder()
                ),
              )
          ),
        ),
        const SizedBox(height: 40,),

        InkWell(
          onTap: (){
            addAmount('debit');
          },
          child: Container(
              height: 55,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color:  AppColors.contaccontainerred),
              width: MediaQuery.of(context).size.width/1.5,
              child: const Center(child: Text("Add Payment", style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold, color: AppColors.textclr)))
          ),
        ),

        const SizedBox(height: 20,),

      ],
    );
  }


  Widget extraCharge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        const  Padding(
          padding:  EdgeInsets.all(8.0),
          child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 15.0),
                child: Text("Enter Extra Charges",style: TextStyle(color: AppColors.textclr,fontSize: 15,fontWeight: FontWeight.w400),),
              )),
        ),
        Container(
          height: 60,
          width: MediaQuery.of(context).size.width/1.1,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.lightwhite),
          child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 5),
              child:TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,

                  // border: OutlineInputBorder()
                ),
              )
          ),
        ),
        const SizedBox(height: 10,),
        const Padding(
          padding:  EdgeInsets.all(8.0),
          child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 15.0),
                child: Text("Enter Short Description(Optional)",style: TextStyle(color: AppColors.textclr,fontSize: 15,fontWeight: FontWeight.w400),),
              )),
        ),
        Container(
          height: 60,
          width: MediaQuery.of(context).size.width/1.1,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.lightwhite),
          child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 5),
              child:TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,

                  // border: OutlineInputBorder()
                ),
              )
          ),
        ),
        const SizedBox(height: 40,),

        InkWell(
          onTap: (){
            addAmount("debit");
          },
          child: Container(
              height: 55,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color:  AppColors.AppbtnColor,),
              width: MediaQuery.of(context).size.width/1.5,
              child: const Center(child: Text("Add Extra Charges", style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold, color: AppColors.textclr)))
          ),
        ),

        const SizedBox(height: 20,),

      ],
    );
  }





  getAccountsData() async {
    print("account initiated!");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? id = preferences.getString('id');
    var uri = Uri.parse(ledgerDataApi.toString());
    // '${Apipath.getCitiesUrl}');
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields[RequestKeys.userId] = id!;
    request.fields[RequestKeys.userType] = isSelected ? 'client' : 'photographer';
    request.fields[RequestKeys.photographerId] = widget.pid.toString();

    print("this is ledger request ${request.fields.toString()} and $ledgerDataApi");
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    setState(() {
      ledgerData = LedgerEntriesModel.fromJson(userData).data!;
    });
    print("this is =====>>>>> ${ledgerData.length}");
  }

  addAmount(String transactionType) async {
    print("account initiated!");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? id = preferences.getString('id');
    var uri = Uri.parse(addPayoutApi.toString());
    // '${Apipath.getCitiesUrl}');
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields[RequestKeys.userId] = id!;
    request.fields[RequestKeys.userType] = isSelected ? 'client' : 'photographer';
    request.fields['amount'] = amountController.text.toString();
    request.fields['description'] = descriptionController.text.toString();
    request.fields['transaction_type'] = transactionType.toString();
    
    
    request.fields[RequestKeys.photographerId] = widget.pid.toString();

    print("this is add ledger request ${request.fields.toString()} and $addPayoutApi");
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    Navigator.pop(context);
    Fluttertoast.showToast(msg: "${userData['message']}");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAccountsData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: (){
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context,
                          Function(Function()) setState) {
                        return Container(
                          child: SingleChildScrollView(
                            child: Column(

                              children: [
                                SizedBox(
                                  height: 30,
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
                                                height: 50,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 14, left: 10, right: 10),
                                                  child: Text(
                                                    'Payment Received',
                                                    style: TextStyle(
                                                      color: isSelected
                                                          ? Color(0xffffffff)
                                                          : Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColors.greenbtn
                                                      : AppColors.containerclr,
                                                  // border: Border.all(color: AppColors.AppbtnColor),
                                                  borderRadius: BorderRadius.circular(10),
                                                )),
                                          ),
                                          widget.type == 'client' ?
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
                                                height: 50,
                                                width: 130,
                                                child: Center(
                                                  child: Text(
                                                    'Add Extra Charges',
                                                    style: TextStyle(
                                                      color: isSelected
                                                          ? AppColors.whit
                                                          : Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? AppColors.containerclr
                                                        : AppColors.AppbtnColor,
                                                    borderRadius: BorderRadius.circular(10))),
                                          )
                                          : InkWell(
                                            onTap: () {
                                              setState(() {
                                                // Navigator.of(context).push(MaterialPageRoute(
                                                //   builder: (context) => NextPage(),
                                                // ));
                                                isSelected = false;
                                              });
                                            },
                                            child: Container(
                                                height: 50,
                                                width: 130,
                                                child: Center(
                                                  child: Text(
                                                    'Payout',
                                                    style: TextStyle(
                                                      color: isSelected
                                                          ? AppColors.whit
                                                          : Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? AppColors.containerclr
                                                        : AppColors.contaccontainerred,
                                                    borderRadius: BorderRadius.circular(10))),
                                          ),
                                        ],
                                      ),)

                                  ],
                                ),
                                SizedBox(height: 10),
                                widget.type == 'client' ?
                                isSelected ? _paymentReceived() :
                                extraCharge()
                                : isSelected ? _paymentReceived() :
                                _payout(),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
                // Navigator.push(context, MaterialPageRoute(builder: (context) => AddAmountScreen()));
              },
              child: Container(
                height: 40,
                width: 160,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), color:AppColors.pdfbtn
                ),
                child: Center(
                  child: Text("Add Amount",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.whit)),
                ),
              ),
            ),
            Image.asset("assets/images/pdf.png", scale: 2.1,),
          ],
        ),
      ),
      backgroundColor: AppColors.backgruond,
      appBar: AppBar(
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
            child: Icon(Icons.arrow_back_ios, color: Color(0xff1E90FF))),
        backgroundColor: Color(0xff303030),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Center(child: Text("${widget.photographerName} Account",
                style: TextStyle(fontSize: 16, color:Color(0xff1E90FF), fontWeight: FontWeight.bold)
            )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            SizedBox(height: 20,),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Container(
            //       decoration: BoxDecoration(
            //           color: AppColors.containerclr,
            //           borderRadius: BorderRadius.circular(10)),
            //       child: Row(
            //         children: [
            //           InkWell(
            //             onTap: () {
            //               setState(() {
            //                 isSelected = true;
            //               });
            //               getAccountsData();
            //             },
            //             child: Container(
            //                 height: 50,
            //                 width: 120,
            //                 child: Center(
            //                   child: Text(
            //                     'Client',
            //                     style: TextStyle(
            //                       color: isSelected
            //                           ? Color(0xffffffff)
            //                           : Colors.white,
            //                       fontSize: 16,
            //                     ),
            //                   ),
            //                 ),
            //                 decoration: BoxDecoration(
            //                   color: isSelected
            //                       ? AppColors.AppbtnColor
            //                       : AppColors.containerclr,
            //                   // border: Border.all(color: AppColors.AppbtnColor),
            //                   borderRadius: BorderRadius.circular(10),
            //                 )),
            //           ),
            //           InkWell(
            //             onTap: () {
            //               setState(() {
            //                 // Navigator.of(context).push(MaterialPageRoute(
            //                 //   builder: (context) => NextPage(),
            //                 // ));
            //                 isSelected = false;
            //               });
            //               getAccountsData();
            //             },
            //             child: Container(
            //                 height: 50,
            //                 width: 130,
            //                 child: Center(
            //                   child: Text(
            //                     'Photographer',
            //                     style: TextStyle(
            //                       color: isSelected
            //                           ? AppColors.whit
            //                           : Colors.white,
            //                       fontSize: 16,
            //                     ),
            //                   ),
            //                 ),
            //                 decoration: BoxDecoration(
            //                     color: isSelected
            //                         ? AppColors.containerclr
            //                         : AppColors.AppbtnColor,
            //                     borderRadius: BorderRadius.circular(10))),
            //           ),
            //         ],
            //       ),
            //     )
            //   ],
            // ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, top: 10, bottom: 10),
              child: Container(
                height: 45,
                width: MediaQuery.of(context).size.width/1.0,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.lightwhite),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Date", style: TextStyle(color: AppColors.textclr),),
                      Text("Description", style: TextStyle(color: AppColors.textclr)),
                      Text("Credit", style: TextStyle(color: AppColors.textclr)),
                      Text("Debit", style: TextStyle(color: AppColors.textclr)),

                    ],
                  ),
                ),
              ),
            ),
            ledgerData.isNotEmpty ?  ListView.builder(
              shrinkWrap: true,
                itemCount: ledgerData.length,
                itemBuilder: (context, k){
              return Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Container(
                  height: 45,
                  width: MediaQuery.of(context).size.width/1.0,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.lightwhite),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ledgerData[k].date.toString(), style: TextStyle(color: AppColors.textclr),),
                        Text(ledgerData[k].description.toString(), style: TextStyle(color: AppColors.textclr)),
                        Text(ledgerData[k].credit.toString(), style: TextStyle(color: AppColors.textclr)),
                        Text(ledgerData[k].debit.toString(), style: TextStyle(color: AppColors.textclr)),

                      ],
                    ),
                  ),
                ),
              );
            })
            : Container(
              width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                child: Center(child: const Text("No data found!", style: TextStyle(color: AppColors.textclr),))),

            Container(
              height: 45,
              width: MediaQuery.of(context).size.width/1.1,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.lightwhite),
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Outstanding Amount", style: TextStyle(color: AppColors.textclr),),

                    Text("25000  Rs.", style: TextStyle(color: AppColors.textclr)),

                  ],
                ),
              ),
            ),



          ],
        ),
      ),
    );
  }
}