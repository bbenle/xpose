import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:x_ray_simulator/Models/Data.dart';
import 'package:x_ray_simulator/Models/Description.dart' as xray;
import 'package:x_ray_simulator/Models/Images.dart';
import 'package:x_ray_simulator/Models/XRayScans.dart';
import 'package:x_ray_simulator/screens/Control%20Panel/control_panel.dart';

void main() {
  //Tests to ensure data lists are populated
  group('Data - populated', () {
    test('data should have scans', () {
      expect(Data().listOfScans.length > 0, true);
    });
  });

  //Tests to ensure the class defined constants are being used
  group('Data - using predefined constants', () {
    Data().listOfScans.asMap().forEach((index, scans) {
      testBodyPartConstants(scans, index);
      testDescriptionConstants(scans.description, index);
    });
  });

  group('Data - has correct combinations of kVp and mAs ranges', () {
    Data().listOfScans.asMap().forEach((index, scans) {
      testKvpMasRangeGroups(scans, index);
    });
  });

  group('Data - all input result in matching image', () {
    Data().listOfScans.asMap().forEach((index, scans) {
      testAllKvpMasInputs(scans, index);
      testAllImagesExist(scans, index);
    });
  });
}

void testBodyPartConstants(XRayScans scans, int index) {
  test('XRayScans[$index].bodyPart should be existing constant', () {
    expect(XRayScans.bodyPartsMap.containsValue(scans.bodyPart), true,
        reason: 'Fault: Value not in map:\n' + '\tBodyPart');
  });
}

void testDescriptionConstants(xray.Description description, int index) {
  test('XRayScans[$index].description fields should use existing constant', () {
    List<String> notInMap = [];

    if (!xray.Description.gendersMap.containsValue(description.gender)) {
      notInMap.add('Gender');
    }

    if (!xray.Description.viewTypesMap.containsValue(description.viewType)) {
      notInMap.add('ViewType');
    }

    if (!xray.Description.ageRangesMap.containsValue(description.ageRange)) {
      notInMap.add('AgeRange');
    }

    if (!xray.Description.SIDinstancesMap.containsValue(description.SID)) {
      notInMap.add('SID');
    }

    if (!xray.Description.gridsMap.containsValue(description.grid)) {
      notInMap.add('Grid');
    }

    String output = listToString(notInMap);

    expect(notInMap.length, 0, reason: 'Fault: Values not in map:\n' + output);
  });
}

void testKvpMasRangeGroups(XRayScans scans, int index) {
  final List<int> kvpValues = [
    scans.kvpLower - 1, //low
    scans.kvpIdeal - 1, //acceptable
    scans.kvpIdeal, //ideal
    scans.kvpUpper + 1 //high
  ];
  final List<num> masValues = [
    scans.masLower - 1, //low
    scans.masIdeal - 0.1, //acceptable
    scans.masIdeal, //ideal
    scans.masUpper + 1 //high
  ];

  List<String> ranges = [];
  Images.rangesMap.forEach((key, value) {
    ranges.add(value);
  });

  test('XRayScans[$index] should have all kVp and mAs ranges', () {
    List<String> missingRanges = [];

    ranges.forEach((kvpRange) {
      ranges.forEach((masRange) {
        bool match = false;
        Images image = scans.getImage(0, 0); //initialise because non-nullable

        kvpValues.forEach((kvpValue) {
          masValues.forEach((masValue) {
            image = scans.getImage(kvpValue, masValue);

            if (image.kvpRange == kvpRange && image.masRange == masRange) {
              match = true;
            }
          });
        });

        if (!match) {
          String fault = kvpRange + ' kVp and ' + masRange + ' mAs';
          if (!missingRanges.contains(fault)) {
            missingRanges.add(fault);
          }
        }
      });
    });

    String output = listToString(missingRanges);

    expect(missingRanges.length, 0,
        reason: 'Fault: Missing ranges:\n' + output);
  });

  test('XRayScans[$index] should not have duplicate kVp and mAs ranges', () {
    List<String> duplicateRanges = [];
    List<String> previousRanges = [];

    kvpValues.forEach((kvpValue) {
      masValues.forEach((masValue) {
        Images image = scans.getImage(0, 0); //initialise because non-nullable

        image = scans.getImage(kvpValue, masValue);
        String range = image.kvpRange + image.masRange;

        if (!previousRanges.contains(range)) {
          previousRanges.add(range);
        } else {
          String fault = image.kvpRange + ' kVp and ' + image.masRange + ' mAs';
          if (!duplicateRanges.contains(fault)) {
            duplicateRanges.add(fault);
          }
        }
      });
    });

    String output = listToString(duplicateRanges);

    expect(duplicateRanges.length, 0,
        reason: 'Fault: Duplicate ranges:\n' + output);
  });
}

void testAllKvpMasInputs(XRayScans scans, int index) {
  test('XRayScans[$index] should find an image for all possible inputs', () {
    List<String> noImage = [];
    Images? image;
    final List<num> masValues = Data().masValues;

    for (int kvp = ControlPanel.KVP_MIN;
        kvp < ControlPanel.KVP_MAX + 1;
        kvp++) {
      for (int masIndex = 0; masIndex < masValues.length; masIndex++) {
        image = scans.getImage(kvp, masValues[masIndex]);

        if (image == null) {
          noImage.add('kVp: $kvp and mAs: ${masValues[masIndex]}');
        }
      }
    }

    String output = listToString(noImage);

    expect(noImage.length, 0,
        reason: 'Fault: Couldn\'t find images for values:\n' + output);
  });
}

void testAllImagesExist(XRayScans scans, int index) {
  final List<int> kvpValues = [
    scans.kvpLower - 1, //low
    scans.kvpIdeal, //ideal
    scans.kvpUpper + 1 //high
  ];
  final List<num> masValues = [
    scans.masLower - 1, //low
    scans.masIdeal, //ideal
    scans.masUpper + 1 //high
  ];

  test('XRayScans[$index] should find an image for all possible inputs', () {
    List<String> noFile = [];

    kvpValues.forEach((kvpValue) {
      masValues.forEach((masValue) {
        Images image = scans.getImage(kvpValue, masValue);

        String assetFolderPath = Platform.environment['UNIT_TEST_ASSETS'] ?? '';
        bool exists = File('$assetFolderPath/${image.filePath}').existsSync();

        if (!exists) {
          noFile.add(image.filePath);
        }
      });
    });

    String output = listToString(noFile);

    expect(noFile.length, 0,
        reason: 'Fault: Couldn\'t find image file from path:\n' + output);
  });
}

String listToString(List<String> list) {
  String output = '';
  list.forEach((line) {
    output += '\t' + line + '\n';
  });
  return output;
}
