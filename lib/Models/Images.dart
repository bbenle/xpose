/*
  Images.dart: a model class for the X-Ray images
  AUTHOR: Caitlin Gapuzan
  DATE CREATED: 2 August 2021
 */

enum Range { low, acceptable, ideal, high }

class Images {
  final String filePath;
  late final String kvpRange;
  late final String masRange;

  Images(
      {required this.filePath,
      required Range kvpRange,
      required Range masRange}) {
    //Retrieve string from map
    //Do null check ?? and put empty string
    //so we don't crash at runtime
    //if someone forgets to add a string for one
    this.kvpRange = rangesMap[kvpRange] ?? '';
    this.masRange = rangesMap[masRange] ?? '';
  }

  static final Map<Range, String> rangesMap = {
    Range.low: 'low',
    Range.acceptable: 'acceptable',
    Range.ideal: 'ideal',
    Range.high: 'high'
  };
}
