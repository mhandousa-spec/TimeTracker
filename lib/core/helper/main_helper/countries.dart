/// Module: core/helper
///
///*************************** FILE INFO ****************************///
/// File Name: countries.dart
/// Purpose: The full country list, assembled from the split data files.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Was 7,574 LOC of inline data. The rows now live in
///          core/constants/countries/ and this file only joins them. It is
///          still a `const` list, so `countries` behaves exactly as before
///          and no call site had to change. `Country` is re-exported so files
///          that imported it from here keep compiling.

import 'package:knowticed_plus/core/constants/countries/countries_part_1.dart';
import 'package:knowticed_plus/core/constants/countries/countries_part_2.dart';
import 'package:knowticed_plus/core/constants/countries/countries_part_3.dart';
import 'package:knowticed_plus/core/constants/countries/countries_part_4.dart';
import 'package:knowticed_plus/core/constants/countries/countries_part_5.dart';
import 'package:knowticed_plus/core/constants/countries/countries_part_6.dart';
import 'package:knowticed_plus/core/constants/countries/countries_part_7.dart';
import 'package:knowticed_plus/core/constants/countries/countries_part_8.dart';
import 'package:knowticed_plus/core/constants/countries/countries_part_9.dart';
import 'package:knowticed_plus/core/constants/countries/countries_part_10.dart';

// `Country` needs BOTH directives. The `export` re-exposes it to files that
// import this one (call sites used to get `Country` from here, before the type
// was split out). The `import` is what brings it into scope *here* — without
// it `const List<Country>` below does not resolve, which is what produced
// "The name 'Country' isn't a type", and then a cascade of
// "receiver can be 'null'" errors at every `countries.firstWhere(...)` call
// site, because `countries` had an unresolved element type.
import 'package:knowticed_plus/core/helper/main_helper/country.dart';
export 'package:knowticed_plus/core/helper/main_helper/country.dart';

const List<Country> countries = <Country>[
  ...countriesPart1,
  ...countriesPart2,
  ...countriesPart3,
  ...countriesPart4,
  ...countriesPart5,
  ...countriesPart6,
  ...countriesPart7,
  ...countriesPart8,
  ...countriesPart9,
  ...countriesPart10,
];
