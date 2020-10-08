import 'package:cloud_firestore/cloud_firestore.dart';

class Validator {
  static String validateEmail(String value) {
    Pattern pattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Please enter a valid email address.';
    else
      return null;
  }

  static String validatePassword(String value) {
    Pattern pattern = r'^.{6,}$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Password must be at least 6 characters.';
    else
      return null;
  }

  static String validateName(String value) {
    Pattern pattern = r'^.{6,}$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Please enter a name.';
    else
      return null;
  }


  static String validateGroupName(String value){
   Pattern pattern = r'^.{6,}$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Please enter a name.';
    else
      return null;
      //  return null;
   }

 
   static String validateNumber(String value) {
     Pattern pattern = r'^\D?(\d{3})\D?\D?(\d{3})\D?(\d{4})$';
     RegExp regex = new RegExp(pattern);
     if (!regex.hasMatch(value))
       return 'Please enter valid phoneNumber';
     else
       return null;
   }
   static String validatePayAmount(String value) {
     Pattern pattern = r'^[0-9]+';
     RegExp regex = new RegExp(pattern);
     if (!regex.hasMatch(value))
       return 'Please enter valid amount.';
     else
       return null;
   }

 }
 




