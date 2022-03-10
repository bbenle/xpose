/*
  XRayScans.dart: a model class for the collection of all the images
  AUTHOR: Caitlin Gapuzan
  DATE CREATED: 2 August 2021
 */

import 'package:x_ray_simulator/Models/Description.dart';
import 'package:x_ray_simulator/Models/Images.dart';

enum BodyPart { knee, abdomen, c_spine }

class XRayScans {
  late final String bodyPart;
  final Description description;
  final String filePath;
  final int kvpLower, kvpIdeal, kvpUpper;
  final num masLower, masIdeal, masUpper;

  XRayScans(
      {required BodyPart bodyPart,
      required this.description,
      required this.filePath,
      required this.kvpLower,
      required this.kvpIdeal,
      required this.kvpUpper,
      required this.masLower,
      required this.masIdeal,
      required this.masUpper}) {
    //Retrieve string from map
    //Do null check ?? and put empty string
    //so we don't crash at runtime
    //if someone forgets to add a string for one
    this.bodyPart = bodyPartsMap[bodyPart] ?? '';
  }

  static final Map<BodyPart, String> bodyPartsMap = {
    BodyPart.knee: 'Knee',
    BodyPart.abdomen: 'Abdomen',
    BodyPart.c_spine: 'Cervical Spine'
  };

  Images getImage(int kvpValue, num masValue) {
    //Default to low
    String kvpPath = 'lkvp';
    Range kvpRange = Range.low;
    String masPath = 'lmas';
    Range masRange = Range.low;

    //ALL CHECKS FOR KVP
    //Check if high range
    if (kvpValue > kvpUpper) {
      kvpPath = 'hkvp';
      kvpRange = Range.high;
    } else if (kvpValue > kvpLower) {
      //Check if acceptable range (Can't be high because we're in 'else')

      kvpPath = 'ikvp';
      if (kvpValue == kvpIdeal) {
        //acceptable or ideal?
        kvpRange = Range.ideal;
      } else {
        kvpRange = Range.acceptable;
      }
    } //else keep the default value of low

    //ALL CHECKS FOR MAS
    //Check if high range
    if (masValue > masUpper) {
      masPath = 'hmas';
      masRange = Range.high;
    } else if (masValue > masLower) {
      //Check if acceptable range (Can't be high because we're in 'else')

      masPath = 'imas';
      if (masValue == masIdeal) {
        //acceptable or ideal?
        masRange = Range.ideal;
      } else {
        masRange = Range.acceptable;
      }
    } //else keep the default value of low

    if (kvpValue == 0 || masValue == 0.0) {
      return Images(
          filePath: "assets/scans/white.png",
          kvpRange: kvpRange,
          masRange: masRange);
    }

    return Images(
        filePath: filePath + kvpPath + '_' + masPath + '.png',
        kvpRange: kvpRange,
        masRange: masRange);
  }
}
