import 'dart:io';
import 'package:flutter/material.dart' show Color, Colors, ThemeData;
import 'package:vector_math/vector_math.dart' hide Colors;

import 'dart:math';


const Color backgroundColor2 = Color(0xFF17203A);
const Color backgroundColorLight = Color(0xFFF2F6FF);
const Color backgroundColorDark = Color(0xFF25254B);
const Color shadowColorLight = Color(0xFF4A5367);
const Color shadowColorDark = Color.fromARGB(255, 29, 0, 0);


const String EMERGENCY_VEHICLE_ID = "197";

const int PREVIUOS_POSITION_COUNT = 50;
const int BUFFER_SIZE = 5;

const double WIDTH_OF_ROAD = 3.75;

Directory outputdir = new Directory("E:\FYP\data\est.txt");




List<String> splitString(String csvString) {
  // Split the string using commas as delimiters
  List<String> elements = csvString.split(',');
  
  // Trim whitespace from each element
  elements = elements.map((element) => element.trim()).toList();
  
  // Return the resulting array
  return elements;
}

double acceleration(double v1, double v2, double t1, double t2 ){
  if(t1==t1){
    return 0;
  }
  else{
    return ((v2-v1)*1000/(t2-t1)*3600);
  }
}

double distance(double lon1, double lat1, double lon2 , double lat2) {
  // WGS-84 ellipsoid constants
  const double a = 6378137.0;
  const double f = 1/298.257223563;
  const double pi = 3.1415926535897;

  // Convert latitude and longitude from decimal degrees to radians
  final double phi1 = radians(lat1);
  final double lambda1 = radians(lon1);
  final double phi2 = radians(lat2);
  final double lambda2 = radians(lon2);

  // Calculate the distance using the Vincenty formula
  double L = lambda2 - lambda1;
  double tan_u1 = (1 - f) * tan(phi1);
  double cos_u1 = 1 / sqrt((1 + tan_u1 * tan_u1));
  double sin_u1 = tan_u1 * cos_u1;
  double tan_u2 = (1 - f) * tan(phi2);
  double cos_u2 = 1 / sqrt((1 + tan_u2 * tan_u2));
  double sin_u2 = tan_u2 * cos_u2;
  double sigma = 0;
  double delta_sigma = 2 * pi;
  while (delta_sigma.abs() > 1e-12) {
    double sin_sigma = sqrt(pow(cos_u2 * sin(L), 2) +
        pow(cos_u1 * sin_u2 - sin_u1 * cos_u2 * cos(L), 2));
    double cos_sigma = sin_u1 * sin_u2 + cos_u1 * cos_u2 * cos(L);
    double sigma_prime = sigma;
    sigma = atan2(sin_sigma, cos_sigma);
    double sin_alpha = (cos_u1 * cos_u2 * sin(L)) / sin_sigma;
    double cos_sq_alpha = 1 - sin_alpha * sin_alpha;
    double cos_2sigma_m = cos_sigma - (2 * sin_u1 * sin_u2 / cos_sq_alpha);
    double C = f / 16 * cos_sq_alpha * (4 + f * (4 - 3 * cos_sq_alpha));
    double delta_L = L;
    L = (lambda2 - lambda1) +
        (1 - C) *
            f *
            sin_alpha *
            (sigma +
                C *
                    sin_sigma *
                    (cos_2sigma_m +
                        C * cos_sigma * (-1 + 2 * cos_2sigma_m * cos_2sigma_m)));
    delta_sigma = sigma - sigma_prime;
  }

  // Calculate the distance in meters
  double s = a * sigma;
  return double.parse(s.toStringAsFixed(2));
}


///////////////////////////////////////// to identify vehicles in same and opposite lanes ///////////////////////////////////////////////
String separateLanes(double headingX, double headingH) {
  double headingDifference = (headingX - headingH).abs();
  double theta = 45; // theta = threshold heading difference

  if ((headingDifference < theta) ||
      (((360 - theta) < headingDifference) && (headingDifference < 360))) {
    return "same";
  } else if (((180 - theta) < headingDifference) &&
      (headingDifference < (180 + theta))) {
    return "opposite";
  } else {
    return "discard";
  }
}



//////////////////////////////////////////////////// to identify vehicles which are in front and behind in the same lane //////////////////////////////////////////////

//////////////////////////////////////////////////// to identify vehicles which are in front and behind in the SAME lane //////////////////////////////////////////////
String prev_state="";
String inFrontBehind(double lonH1, double latH1, double lonX1, double latX1, double lonH2, double latH2, double lonX2, double latX2) {
  double X1_H1 = distance(lonH1, latH1, lonX1, latX1);
  double X2_H1 = distance(lonH1, latH1, lonX2, latX2);
  double H2_H1 = distance(lonH2, latH2, lonH1, latH1);
  double X2_X1 = distance(lonX2, latX2, lonX1, latX1);
  double H2_X1 = distance(lonH2, latH2, lonX1, latX1);

  if ((X2_H1 - X1_H1).abs() < 0.5) {
    X2_H1 = X1_H1;
  }
  if (X2_H1 > X1_H1) {
    if (H2_H1 > X2_H1) {
      prev_state = "behind";
      print('behind');
      return "behind";
    } else {
      prev_state = "infront";
      print('infront');
      return "infront";
    }
  } else if (X2_H1 == X1_H1) {
    if (H2_X1 > X1_H1) {
      prev_state = "behind";
      print('behind');
      return "behind";
    } else if (H2_X1 < X1_H1) {
      prev_state = "infront";
      print('infront');
      return "infront";
    } else {
      print(prev_state);
      return prev_state;
    }
  } else {
    if (X2_X1 < H2_X1) {
      prev_state = "behind";
      print('behind');
      return "behind";
    } else {
      prev_state = "infront";
      print('infront');
      return "infront";
    }
  }
}


int emgcount =0;
 int noemgcount =0;

///////////////////////////////////////// emergency vehicle sample //////////////////////////////////////////////////
String emergencyAlert(double Heading_H, double Heading_X, double lonH1, double latH1, double lonX1, double latX1, double lonH2, double latH2, double lonX2, double latX2) {
  // if (separateLanes(Heading_X, Heading_H) == "same") {
    if (inFrontBehind(lonH1, latH1, lonX1, latX1, lonH2, latH2, lonX2, latX2) == "behind") {
      emgcount=emgcount+1;
      return "emergency";
    }
    else{
      noemgcount = noemgcount+1;
    return "no emergency";
    }
  }
  // else{
  //   noemgcount= noemgcount+1;
  //   print("heading problem");
  //   return "no emergency ";
  // }
//}
///////////////////////////////////////// accident ahead sample //////////////////////////////////////////////////
String accidentAheadAlert(double Heading_H, double Heading_X, double lonH1, double latH1, double lonX1, double latX1, double lonH2, double latH2, double lonX2, double latX2, double spdX2) {
  if (separateLanes(Heading_X, Heading_H) == "same") {
    if (inFrontBehind(lonH1, latH1, lonX1, latX1, lonH2, latH2, lonX2, latX2) == "infront" && spdX2 <10) {
      return "accident";
    }
  }
  return "";
}

/////////////////////////////////to identify vehicles which are in front and behind in the DIFFERENT lanes /////////////////////////////////
bool inFrontBehindDifferent(double lonH1, double latH1, double lonX1,double latX1, double lonH2, double latH2, double lonX2, double latX2) {
  double X1_H1 = distance(lonH1, latH1, lonX1, latX1);
  double X2_H2 = distance(lonH2, latH2, lonX2, latX2);
  double H2_H1 = distance(lonH2, latH2, lonH1, latH1);
  double X2_H1 = distance(lonX2, latX2, lonH1, latH1);

  if (X2_H2 > X1_H1) {
    return false; // false = behind
  } else {
    if (H2_H1 > X2_H1) {
      return false; // behind
    } else {
      return true; // in front
    }
  }
}

///////////////////////////////////////// Right Turn sample //////////////////////////////////////////////////
///for the vehicle which is expecting to do a right turn///
bool possibleToRightTurn(
    double latH1,
    double lonH1,
    double latH2,
    double lonH2,
    double spdH2,
    double latX1,
    double lonX1,
    double latX2,
    double lonX2,
    double spdX2) {
  // Assumes the vehicle expecting to turn right is at a velocity of 0ms-1 at the junction.
  if (inFrontBehindDifferent(
      lonH1, latH1, lonX1, latX1, lonH2, latH2, lonX2, latX2)) {
    spdH2 = 0;
    double widthOfRoad = 3.75; // Data
    double d = pow(spdX2, 2) /
        (2 * (distance(lonH2, latH2, lonX2, latX2) - (widthOfRoad / 2)));
    double dMax =
        4.6; // https://www.jsheld.com/insights/articles/a-naturalistic-study-of-vehicle-acceleration-and-deceleration-at-an-intersection
    if (d <= dMax) {
      print("Safer for a right turn");
      return true;
    } else {
      print("Wait more for a right turn");
      return false;
    }
  } else {
    return false;
  }
}

///for the vehicle which is allowing oncoming to do a right turn///
bool possibleToDecelerate(
    double latH1,
    double lonH1,
    double latH2,
    double lonH2,
    double spdH2,
    double latX1,
    double lonX1,
    double latX2,
    double lonX2,
    double spdX2) {
  // Assumes the vehicle expecting to turn right is at a velocity of 0ms-1 at the junction.
  if (inFrontBehindDifferent(
      lonH1, latH1, lonX1, latX1, lonH2, latH2, lonX2, latX2)) {
    spdX2 = 0;
    double widthOfRoad = 3.75; // Data
    double d = pow(spdH2, 2) /
        (2 * (distance(lonH2, latH2, lonX2, latX2) - (widthOfRoad / 2)));
    double dMax =
        4.6; // https://www.jsheld.com/insights/articles/a-naturalistic-study-of-vehicle-acceleration-and-deceleration-at-an-intersection
    if (d <= dMax) {
      print("Decelerate and stop at the intersection ahead");
      return true;
    } else {
      print("Proceed");
      return false;
    }
  } else {
    return false;
  }
}




class ThemeClass{
 
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    
    
  );
 
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    
  );
}