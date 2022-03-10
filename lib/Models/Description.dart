/*
  Description.dart: a model class for the description of each image
  AUTHOR: Caitlin Gapuzan
  DATE CREATED: 2 August 2021
 */

enum Gender { female, male }

enum ViewType { lateral, anterior, posterior, supine }

enum AgeRange { child, adult, elderly }

enum SIDistance { SID100cm, SID180cm }

enum Grid { yes, no }

class Description {
  late final String gender;
  final int age;
  late final String viewType;
  late final String ageRange;
  late final String SID;
  late final String grid;

  Description(
      {required Gender gender,
      required this.age,
      required ViewType viewType,
      required AgeRange ageRange,
      required SIDistance SID,
      required Grid grid}) {
    //Retrieve string from map
    //Do null check ?? and put empty string
    //so we don't crash at runtime
    //if someone forgets to add a string for one
    this.gender = gendersMap[gender] ?? '';
    this.viewType = viewTypesMap[viewType] ?? '';
    this.ageRange = ageRangesMap[ageRange] ?? '';
    this.SID = SIDinstancesMap[SID] ?? '';
    this.grid = gridsMap[grid] ?? '';
  }

  //Maps for nicely formatted strings that are consistent and grouped together

  static final Map<Gender, String> gendersMap = {
    Gender.female: 'female',
    Gender.male: 'male'
  };

  static final Map<ViewType, String> viewTypesMap = {
    ViewType.lateral: 'Lateral',
    ViewType.anterior: 'Anterior',
    ViewType.posterior: 'Posterior',
    ViewType.supine: 'Supine'
  };

  static final Map<AgeRange, String> ageRangesMap = {
    AgeRange.child: 'child',
    AgeRange.adult: 'adult',
    AgeRange.elderly: 'elderly'
  };

  static final Map<SIDistance, String> SIDinstancesMap = {
    SIDistance.SID100cm: '100cm',
    SIDistance.SID180cm: '180cm'
  };

  static final Map<Grid, String> gridsMap = {Grid.yes: 'yes', Grid.no: 'no'};
}
