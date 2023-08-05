import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_app_admin/admin_login_screen.dart';
import 'package:food_app_admin/util.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AdminUploadItems extends StatefulWidget {

  @override
  State<AdminUploadItems> createState() => _AdminUploadItemsState();
}

class _AdminUploadItemsState extends State<AdminUploadItems> {
  final ImagePicker _picker = new ImagePicker();
  XFile? pickedImage;
  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var ratingController = TextEditingController();
  var tagsController = TextEditingController();
  var priceController = TextEditingController();
  var sizeController = TextEditingController();
  var descriptionController = TextEditingController();
  var imageUrl = "";



  // default screen methods
  openPhoneCamera()
  async {
pickedImage =   await _picker.pickImage(source: ImageSource.camera);
Get.back();
setState(() {
  pickedImage;
});

  }

  openPhoneGallery()
  async {
    pickedImage =   await _picker.pickImage(source: ImageSource.gallery);
    Get.back();
    setState(() {
      pickedImage;
    });

  }

  shoeDialogForImageUpload()
  {

    return showDialog(context: context, builder: (context)
    {
      // simpledialog is a multi-children widget
return SimpleDialog(
  backgroundColor: Colors.black87 ,
  title: const Text("Item Image",
style: TextStyle(color: Colors.purpleAccent,
  fontWeight: FontWeight.bold,
),

  ),

  children: [
    SimpleDialogOption(
      onPressed: ()
      {
openPhoneCamera();

      },
      child: const Text(
        "Capture with phone camera",
        style: TextStyle(
          color: Colors.grey,
        ),

      ),
    ),
    SimpleDialogOption(
      onPressed: ()
      {
openPhoneGallery();

      },
      child: const Text(
        "Choose image from gallery",
        style: TextStyle(
          color: Colors.grey,
        ),

      ),
    ),
    SimpleDialogOption(
      onPressed: ()
      {
Get.back();

      },
      child: const Text(
        "Cancel",
        style: TextStyle(
          color: Colors.redAccent,
        ),

      ),
    ),



  ],
);

    }
    );
  }


// default screen methods ends here

  Widget defaultScreen()
  {



    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Welcome Admin"),
        centerTitle: true,
        // flexibleSpace is use when we want to use gradient colors
        flexibleSpace:Container(

          decoration: const BoxDecoration(
            // this is for background gradient
            gradient: LinearGradient(
              colors: [
                Colors.black54,
                Colors.deepPurple
              ],
            ),


          ),
        ) ,

      ),

      body: Container(
        decoration: const BoxDecoration(
          // this is for background gradient
          gradient: LinearGradient(
            colors: [
              Colors.black54,
              Colors.deepPurple
            ],
          ),


        ),
        // to center the column horizontally
        child: Center(
          child: Column(
            // to center the column vertically
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [

              const Icon(Icons.add_photo_alternate,
                color: Colors.white54,
                size: 200,
              ),

              Material(
                color: Colors.purpleAccent,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: ()
                  {
shoeDialogForImageUpload();
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 28,
                    ),
                    child: Text(
                      "Upload Photo",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,

                      ),
                    ),
                  ),

                ),
              ),
            ],
          ),
        ),

      ),

    );
  }
  uploadImageToImgur()
  async {
var requestImgurApi = http.MultipartRequest(
  "POST",
  Uri.parse("https://api.imgur.com/3/image"));

String imageName = DateTime.now().millisecondsSinceEpoch.toString();
requestImgurApi.fields['title'] = imageName;
requestImgurApi.headers['Authorization'] = "Client-ID " + "f8dad46571b9274";

var imageFile = await http.MultipartFile.fromPath(
    'image',
    pickedImage!.path,
  filename: imageName,
);

requestImgurApi.files.add(imageFile);
var responseFromImgurApi = await requestImgurApi.send();

var responseDataFromImgurApi = await responseFromImgurApi.stream.toBytes();
var resultFromImgurApi = String.fromCharCodes(responseDataFromImgurApi);


Map<String, dynamic> jsonRes = json.decode(resultFromImgurApi);
imageUrl = (jsonRes["data"]["link"]).toString();
String deleteHash = (jsonRes["data"]["deletehash"]).toString();

uploadFormToDatabase();

  }
  uploadFormToDatabase() async {

// In the app we have multiple tags for single item for-example for the pizza multiple tags like italy, dinner, italian, fastfood, italianfood, and soo on
  //sp for this we are splitting our tags with ',' and we are storing all the tags in a tagsList
    // later on we can use these tags to search the item
    // for instance if user search italianfood the app will show all the food that contains italianfood tag.
    List<String> tagsList =  tagsController.text.split(",");

    // S,M,L
    List<String> sizesList =  sizeController.text.split(",");

    List<String> pricesList =  priceController.text.split(",");


    try{

      var response = await http.post(
          Uri.parse(Util.upload),
         body: {
        'item-id' : '1',
           'name' : nameController.text.toString().trim(),
           'rating' : ratingController.text.toString().trim(),
           'tags' : tagsList.toString(),
           'price' : pricesList.toString(),
           'sizes' : sizesList.toString(),
           'description' : descriptionController.text.toString().trim(),
           'image' : imageUrl.toString(),
         },

      );

      if(response.statusCode == 200)
        {
// var responseBodyOfUploadItem = jsonDecode(response.body);
if(jsonDecode(response.body)['success'] == true)
  {
    Fluttertoast.showToast(msg: "Item Uploaded Successfully");
    setState(() {
      pickedImage = null;
      nameController.clear();
      ratingController.clear();
      tagsController.clear();
      priceController.clear();
      sizeController.clear();
      descriptionController.clear();


    });
    
    Get.to(AdminUploadItems());

  }

else {
  Fluttertoast.showToast(msg: "Item NOT Uploaded");


}

        }
    }

    catch(errorMsg)
    {
      Fluttertoast.showToast(msg: errorMsg.toString());

    }

  }



  Widget uploadItemFormScreen()
  {
return Scaffold(
  appBar: AppBar(
    automaticallyImplyLeading: false,
      title: const Text(
      "Upload Form"
  ),
      centerTitle: true,
    leading: IconButton(
    onPressed: ()
    {
setState(() {
  pickedImage = null;
  nameController.clear();
  ratingController.clear();
tagsController.clear();
priceController.clear();
sizeController.clear();
descriptionController.clear();


});

Get.to(AdminUploadItems());

    },

    icon: const Icon(Icons.clear),

),
      flexibleSpace:Container(

        decoration: const BoxDecoration(
          // this is for background gradient
          gradient: LinearGradient(
            colors: [
              Colors.black54,
              Colors.deepPurple
            ],
          ),


        ),
      )

  ),
  backgroundColor: Colors.black,
  body: ListView(
    children: [
      // ImageView
      Container(
  // here * 0.3 means image will occupy the 30% of the screen by height
  height:MediaQuery.of(context).size.height * 0.3,
        // here * 0.8 means it will cover the phone width by 80%
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          image: DecorationImage(
image: FileImage(
  // make sure to import File from import 'dart:io';
  File(pickedImage!.path),
),
            fit: BoxFit.cover,
          ),
        ),
      ),
      // ImageView ends here


    ],

  ),
);

  }


  @override
  Widget build(BuildContext context) {

    return pickedImage == null ? defaultScreen() : uploadItemFormScreen();

  }
}
