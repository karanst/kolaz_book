import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:kolazz_book/Controller/edit_profile_controller.dart';
import 'package:kolazz_book/Controller/home_controller.dart';
import 'package:kolazz_book/Models/banner_list_model.dart';
import 'package:kolazz_book/Models/get_client_jobs_model.dart';
import 'package:kolazz_book/Models/get_freelancer_jobs_model.dart';
import 'package:kolazz_book/Models/get_profile_model.dart';
import 'package:kolazz_book/Services/request_keys.dart';
import 'package:kolazz_book/Utils/strings.dart';
import 'package:kolazz_book/Views/Add_Quotation/edite_client_job.dart';
import 'package:kolazz_book/Views/Subscription/Subscription_screen.dart';
import 'package:kolazz_book/Views/freelancing_job/edit_freelance_job.dart';
import 'package:kolazz_book/Views/portfolio/portfolio_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/colors.dart';
import '../brodcast/Broadcast_screen.dart';
import '../edit_profile/edit_profile.dart';
import '../notification/Notification_screen.dart';
import '../profile/Profile.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  List<FreelancerJobs> freelancerJobs = [];

  getFreelancingJobs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? id = preferences.getString('id');
    var uri =
    Uri.parse(getFreelancingJobsApi.toString());
    // '${Apipath.getCitiesUrl}');
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    request.fields[RequestKeys.userId] = id!;
    request.fields[RequestKeys.type] = 'freelancer';
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    setState(() {
      freelancerJobs = GetFreelancerJobsModel.fromJson(userData).data!;
    });
  }

  List<JobData> getJobs = [];
  List jobs = [];

  getClientJobs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? id = preferences.getString('id');
    var uri =
    Uri.parse(getClientJobsApi.toString());
    // '${Apipath.getCitiesUrl}');
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    request.fields[RequestKeys.userId] = id!;
    // request.fields[RequestKeys.type] = 'client';
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    setState(() {
      getJobs = GetClientJobsModel.fromJson(userData).data!;
      jobs = userData['data'];
    });
  }

  List bannerList = [];

  getBannerImages() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? id = preferences.getString('id');
    var uri =
    Uri.parse(getBannersApi.toString());
    // '${Apipath.getCitiesUrl}');
    var request = http.MultipartRequest("GET", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);
    request.fields[RequestKeys.userId] = id!;
    // request.fields[RequestKeys.type] = 'client';
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);


    setState(() {
      bannerList = userData['data'];
      loading = false;
    });
    print("this is my bannerdata $bannerList");

    // Future.delayed(Duration(seconds: 5), (){
    //   setState(() {
    //     loading = false;
    //   });
    // });
  }


  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  bool loading = true;


  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    // buttonController!.dispose();

    // SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  _onPageChanged(int index) {
    if (mounted)
      setState(() {
        _currentPage = index;
      });
  }

  Widget _slider() {
    return PageView.builder(
      itemCount: bannerList.length,
      scrollDirection: Axis.horizontal,
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemBuilder: (BuildContext context, int index) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: (){
                  setState(() {
                    loading = true;
                  });
                },
                child: Container(
                  // height: MediaQuery.of(context).size.height ,
                  child: Image.network(
                    bannerList[index],
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              // Container(
              //     margin: EdgeInsetsDirectional.only(top: 20),
              //     child: Text(slideList[index].title,
              //         style: Theme.of(context).textTheme.headline5!.copyWith(
              //             color: Colors.black12,
              //             fontWeight: FontWeight.bold))),
              // Container(
              //   padding: EdgeInsetsDirectional.only(
              //       top: 30.0, start: 15.0, end: 15.0),
              //   child: Text(slideList[index].description,
              //       textAlign: TextAlign.center,
              //       style: Theme.of(context).textTheme.subtitle1!.copyWith(
              //           color: Colors.black12,
              //           fontWeight: FontWeight.normal)),
              // ),
            ],
          ),
        );
      },
    );
  }


  List<Widget> getList() {
    List<Widget> childs = [];

    for (int i = 0; i < bannerList.length; i++) {
      childs.add(Container(
          width: 10.0,
          height: 10.0,
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == i
                ? AppColors.AppbtnColor
                : AppColors.AppbtnColor.withOpacity((0.5)),
          )));
    }
    return childs;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getClientJobs();
    getFreelancingJobs();
    getClientJobs();
    getBannerImages();

  }

  skipBtn() {
    return Positioned(
      bottom: 50,
      child: InkWell(
        onTap: (){
          setState(() {
            loading = true;
          });
        },
        child: Container(
          height: 30,
          width: 80,
          decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  offset: Offset(1, 2),
                  blurRadius: 1,
                  color: AppColors.greyColor,
                )
              ],
              color: AppColors.lightwhite,
              borderRadius:
              BorderRadius.circular(30)),
          child: const Center(
            child: Text(
              "Skip",
              style: TextStyle(
                  color: AppColors.textclr,
                  fontWeight:
                  FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init:HomeController(),
      builder: (controller) {
        // if (connectivity.connectivitycheckConnectivity() == ConnectivityResult.wifi ||
        //  connectivity.checkConnectivity() == ConnectivityResult.mobile) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          backgroundColor:AppColors.secondary ,
          toolbarHeight: 79,
          leading:  Padding(
            padding: const EdgeInsets.only(left: 5, right: 0, top: 15, bottom: 15),
            child:
            GetBuilder(
            init: EditProfileController(),
        builder: (controller) {
        return GestureDetector(
              onTap: (){
                Get.to(EditProfileScreen());
               // Navigator.push(context, MaterialPageRoute(builder: (context)=>MyProfilePage()));
              },
              child:  Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(40)),
                child:   ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: controller.profilePic == null || controller.profilePic == '' || controller.profilePic == 'https://developmentalphawizz.com/kolaz_book/uploads/profile_pics/user_image.png' ?
                    ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: controller.imageFile != null
                            ? Image.file(controller.imageFile!, fit: BoxFit.cover, height: 40,width: 40,)
                            : Image.asset("assets/images/loginlogo.png",fit: BoxFit.fill,height: 40,width: 40,)
                    )
                        : ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child:
                        // rcImage != null ?
                        Image.network(controller.profilePic.toString(), fit: BoxFit.cover, height: 40,width: 40,)
                    )
                ),
              ),
            );}
            )
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              controller.profiledata != null || controller.profiledata == "" ? Text("${controller.profiledata!.fname} ${controller.profiledata!.lname} ",style: TextStyle(color: AppColors.AppbtnColor,fontSize: 15),): CircularProgressIndicator(),
              controller.profiledata != null ?
              controller.profiledata!.isPlanActive! == true ?
              Text(
                controller.profiledata != null ?
                "${controller.profiledata!.remainingDays} left "
                : "15 Days left ",style: const TextStyle(fontSize: 12),)
              : Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: InkWell(
                  onTap: (){
                    Get.to(SubscriptionScreen());
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                      decoration: BoxDecoration(
                          color: AppColors.lightwhite,

                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: const Text("Subscribe Now",style: TextStyle(color: AppColors.whit,
                      fontSize: 12),)),
                ),
              )
              : const Text("Something went wrong!", style: TextStyle(
                fontSize: 12
              ),),
            ],
          ),
          actions: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GestureDetector(
                    onTap: (){
                     if(controller.profiledata!.isTrial! == false) {
                       Navigator.push(context, MaterialPageRoute(
                           builder: (context) => PortfolioScreen()));
                     }else{
                       Fluttertoast.showToast(msg: "You are not permitted! Please subscribe first!");
                     }
                    },
                    child: Container(
                        height: 33,
                        width: 33,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.primary

                        ),
                        child: Icon(Icons.search_rounded)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> Notification_screen()));
                    },
                    child: Container(
                        height: 33,
                        width: 33,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.primary

                        ),
                        child: Icon(Icons.notifications)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GestureDetector(
                    onTap: (){
                      if(controller.profiledata!.isTrial! == false) {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => BroadcastScreen()));
                      }else{
                        Fluttertoast.showToast(msg: "You are not permitted! Please subscribe first!");
                      }

                    },
                    child: Container(
                        height: 33,
                        width: 33,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.primary

                        ),
                        child: Icon(Icons.message)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: InkWell(
                    onTap: (){
                      Get.to(MyProfilePage());
                    },
                    child: Container(
                        height: 33,
                        width: 33,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.primary,
                        ),
                        child: Icon(Icons.settings)),
                  ),
                ),

              ],)
          ],

          centerTitle: false,
        ),
        body: !loading ?
        Stack(
          alignment: Alignment.bottomCenter,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _slider(),
            skipBtn(),
            Positioned(
              bottom: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: getList()),
                  // Center(
                  //     child: Padding(
                  //       padding: const EdgeInsetsDirectional.only(bottom: 18.0),
                  //       child: AppBtn(
                  //           title: _currentPage == 0 || _currentPage == 1
                  //               ? getTranslated(context, 'NEXT_LBL')
                  //               : getTranslated(context, 'GET_STARTED'),
                  //           btnAnim: buttonSqueezeanimation,
                  //           btnCntrl: buttonController,
                  //           onBtnSelected: () {
                  //             if (_currentPage == 2) {
                  //               setPrefrenceBool(ISFIRSTTIME, true);
                  //               Navigator.pushReplacement(
                  //                 context,
                  //                 MaterialPageRoute(builder: (context) => SignInUpAcc()),
                  //               );
                  //             } else {
                  //               _currentPage = _currentPage + 1;
                  //               _pageController.animateToPage(_currentPage,
                  //                   curve: Curves.decelerate,
                  //                   duration: Duration(milliseconds: 300));
                  //             }
                  //           }),
                  //     )),
                ],
              ),
            ),
            // _btn(),
          ],
        )
        : Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary3,AppColors.grd1,AppColors.grd2],
                stops: [0, 1,1]),
          ),
          child: Column(children: [
            SizedBox(height: 20,),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  SizedBox(width: 5,),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0,top: 20),
                    child: Text("Upcoming Client Jobs", style: TextStyle(fontSize: 17, color: AppColors.whit, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5,),

            getJobs.isEmpty ?
            Container(
              height: 150,
              child: Center(
                child: Text("No Data to show!", style: TextStyle(
                    color: AppColors.whit

                ),),
              ),
            )
            : _clientCard(context),
            SizedBox(height: 30,),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  SizedBox(width: 5,),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text("Upcoming Freelencing jobs", style: TextStyle(fontSize: 17, color: AppColors.whit, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            freelancerJobs.isNotEmpty ?
            freelancerJobs[0].upcomingJobs!.isNotEmpty ?
            _clientCard2(context)
            : Container(
              height: 150,
              child: Center(child: Text("No Data to show!", style: TextStyle(color: AppColors.whit),)),
            )
            : Container(
              height: 150,
              child: Center(child: Text("No Data to show!", style: TextStyle(color: AppColors.whit),)),
            ),
            Spacer(),
            _homeLogo()

            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Container(
            //       width: double.infinity,
            //       child: Text("Photographer Yet To Be Allotment Clients Jobs ", style: TextStyle(fontSize: 17, color:AppColors.whit, fontWeight: FontWeight.w700,overflow: TextOverflow.ellipsis))),
            // ),
            // Container(
            //   height: 150,
            //   child: Center(child: Text("No Data to show!", style: TextStyle(color: AppColors.whit),)),
            // ),
            // _clientCard3(context),


          ],),
        ),
      );
    },);
  }

  Widget _clientCard(BuildContext context){
    return
    Container(
      height: 150,
      // height: MediaQuery.of(context).size.height/6.22,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: getJobs[0].upcomingJobs!.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio:0.5/1.2,
          crossAxisCount: 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          var data = getJobs[0].upcomingJobs![index];
          return InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> EditClientJob(
                type: false,
                upcomingJobs:  getJobs[0].upcomingJobs![index],
                data: jobs[0]['upcoming_jobs'][index] ,
              )));
            },
            child: Padding(
                padding: EdgeInsets.all(5),
                child:  Container(
                  width: 340,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    color: Colors.black12,
                    elevation: 2,
                    child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0,left: 10,right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(data.clientName.toString(),style: const TextStyle(color: AppColors.textclr,fontSize: 16,fontWeight: FontWeight.bold),),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 10),
                                decoration: BoxDecoration(
                                    color: AppColors.lightwhite,

                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text(data.qid.toString(),style: const TextStyle(color: AppColors.whit,),)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0,left: 10,right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(data.city.toString(),style: const TextStyle(color: AppColors.textclr,fontWeight: FontWeight.bold,fontSize: 16),),
                           const  Text("",style: TextStyle(color: AppColors.whit),),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 15.0,left: 10,right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(data.eventName.toString(),style: TextStyle(color: AppColors.textclr,fontSize: 16,fontWeight: FontWeight.bold),),
                            Text(
                              data.photographersDetails![0].date.toString(),style: TextStyle(color: AppColors.AppbtnColor, fontWeight: FontWeight.w600),),
                          ],
                        ),
                      ),
                    ],
                  ),),
                ),
            ),
          );
        },
      ),
    );
  }

  Widget _clientCard2(BuildContext context){
    return
      Container(
        height: 150,
        // height: MediaQuery.of(context).size.height/6.22,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: freelancerJobs[0].upcomingJobs!.length,
          gridDelegate:const  SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio:0.5/1.2,
            crossAxisCount: 1,
          ),
          itemBuilder: (BuildContext context, int index) {
            var data = freelancerJobs[0].upcomingJobs![index];
            return InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>EditFreelanceJob(
                    type: false,
                    upcomingJobs: freelancerJobs[0].upcomingJobs![index]
                )));
              },
              child: Padding(
                padding: EdgeInsets.all(5),
                child:  Container(
                  width: 340,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    color: AppColors.cardclr,
                    elevation: 2,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0,left: 10,right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${data.photographerName}',style: TextStyle(color: AppColors.textclr,fontSize: 16,fontWeight: FontWeight.bold),),
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14,vertical: 10),
                                  decoration: BoxDecoration(
                                      color: AppColors.lightwhite,

                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Text(data.uid.toString(),style: TextStyle(color: AppColors.whit,),)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0,left: 10,right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(data.cityName.toString(),style: TextStyle(color: AppColors.textclr,fontWeight: FontWeight.bold,fontSize: 16),),
                              Text("",style: TextStyle(color: AppColors.whit),),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 15.0,left: 10,right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(data.eventName.toString(),style: TextStyle(color: AppColors.textclr,fontSize: 16,fontWeight: FontWeight.bold),),
                              Text(data.jsonData![0].date.toString(),style: TextStyle(color: AppColors.AppbtnColor),),
                            ],
                          ),
                        ),
                      ],
                    ),),
                ),
              ),
            );
          },

        ),
      );
  }


  Widget _clientCard3(BuildContext context){
    return
      Container(
        height: 150,
        // height: MediaQuery.of(context).size.height/6.22,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio:0.5/1.2,
            crossAxisCount: 1,
          ),
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {

              },
              child: Padding(
                padding: EdgeInsets.all(5),
                child:  Container(
                  width: 340,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    color: Colors.black12,
                    elevation: 2,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0,left: 10,right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Jhanvi Singh",style: TextStyle(color: AppColors.textclr,fontSize: 16,fontWeight: FontWeight.bold),),
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14,vertical: 10),
                                  decoration: BoxDecoration(
                                      color: AppColors.lightwhite,

                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Text("KB003",style: TextStyle(color: AppColors.whit,),)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0,left: 10,right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("",style: TextStyle(color: AppColors.textclr,fontWeight: FontWeight.bold,fontSize: 16),),
                              Text("",style: TextStyle(color: AppColors.whit),),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0.0,left: 10,right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Mumbai",style: TextStyle(color: AppColors.textclr,fontSize: 16,fontWeight: FontWeight.bold),),
                              Text("",style: TextStyle(color: AppColors.whit),),
                            ],
                          ),
                        ),
                      ],
                    ),),
                ),
              ),
            );
          },

        ),
      );
  }
  Widget _homeLogo(){
    return Container(
      child: Image.asset("assets/images/applogo.png",height: 50,),
    );
  }
}
