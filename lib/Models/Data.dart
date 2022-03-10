/*
  Data.dart: a singleton class that stores all the data needed for the app
  AUTHOR: Caitlin Gapuzan
  DATE CREATED: 2 August 2021
 */

import 'package:x_ray_simulator/Models/Description.dart';
import 'package:x_ray_simulator/Models/XRayScans.dart';

class Data {
  //class fields
  List<XRayScans> listOfScans = [];

  final List<num> masValues = [
    0.0,
    0.1,
    0.2,
    0.3,
    0.4,
    0.5,
    0.6,
    0.7,
    0.8,
    0.9,
    1.0,
    1.1,
    1.2,
    1.4,
    1.6,
    1.8,
    2.0,
    2.2,
    2.5,
    2.8,
    3.2,
    3.6,
    4.0,
    4.5,
    5.0,
    5.6,
    6.3,
    7.1,
    8.0,
    9.0,
    10,
    11,
    12,
    14,
    16,
    18,
    20,
    22,
    25,
    28,
    32,
    36,
    40,
    45,
    50,
    56,
    63,
    71,
    80,
    90,
    100,
    110,
    125,
    140,
    160,
    180,
    200
  ];

  static final Data _instance = Data._internal();

  factory Data() {
    return _instance;
  }

  Data._internal() {
    //initialise
    listOfScans.add(_initKnee());
    listOfScans.add(_initAbdo());
    listOfScans.add(_initSpine());

  }

  XRayScans _initKnee() {
    return XRayScans(
        bodyPart: BodyPart.knee,
        description: Description(gender: Gender.female, age: 24, viewType: ViewType.lateral,
            ageRange: AgeRange.adult, SID: SIDistance.SID100cm, grid: Grid.no),
        filePath: "assets/scans/knee/",
        kvpLower: 58,
        kvpIdeal: 60,
        kvpUpper: 62,
        masLower: 4.0,
        masIdeal: 5.0,
        masUpper: 6.0);
  }

  XRayScans _initAbdo() {
    return XRayScans(
        bodyPart: BodyPart.abdomen,
        description: Description(gender: Gender.male, age: 10, viewType: ViewType.supine,
            ageRange: AgeRange.child, SID: SIDistance.SID100cm, grid: Grid.yes),
        filePath: "assets/scans/abdomen/",
        kvpLower: 60,
        kvpIdeal: 65,
        kvpUpper: 70,
        masLower: 17,
        masIdeal: 20,
        masUpper: 25);
  }

  XRayScans _initSpine() {
    return XRayScans(
        bodyPart: BodyPart.c_spine,
        description: Description(gender: Gender.female, age: 69, viewType: ViewType.lateral,
            ageRange: AgeRange.adult, SID: SIDistance.SID180cm, grid: Grid.yes),
        filePath: "assets/scans/c_spine/",
        kvpLower: 67,
        kvpIdeal: 70,
        kvpUpper: 74,
        masLower: 10,
        masIdeal: 12,
        masUpper: 15);
  }
}
