import 'package:flutter/material.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';

const Color backgroundColor2 = Color(0xFF17203A);
const Color backgroundColorLight = Color(0xFFF2F6FF);
const Color backgroundColorDark = Color(0xFF25254B);
const Color shadowColorLight = Color(0xFF4A5367);
const Color shadowColorDark = Color.fromARGB(255, 29, 0, 0);

List<String> splitString(String csvString) {
  // Split the string using commas as delimiters
  List<String> elements = csvString.split(',');
  
  // Trim whitespace from each element
  elements = elements.map((element) => element.trim()).toList();
  
  // Return the resulting array
  return elements;
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

