/// Module: services_management_module
/// Description: `selectServiceProvider` — workload-balanced provider
///              selection for the main create-services flow (part of csv_helper.dart).
/// Author: Amr Mesbah
/// Date: 30/8/2025
/// Dependencies: cloud_firestore, core/network/get_base_url.dart (via csv_helper.dart)
/// Revision History: Initial version — auto-split from csv_helper.dart to keep
///                    each physical file ≤800 LOC (audit fix #1).
// Auto-split from csv_helper.dart — part of the same library.
part of 'csv_helper.dart';

Future<Map<String, dynamic>?> selectServiceProvider(String currentServiceDocId) async {
  final firestore = FirebaseFirestore.instance;

  try {
    if (kDebugMode) print("🔍 Looking for service: $currentServiceDocId");

    // ✅ UPDATED: Get document directly from CreateServices collection
    final createServicesPath = getBaseUrl(FirestoreCollections.createServicesRoot);
    // Path may be any odd-segment length
    // (e.g. Demo/{id}/Modules/services/CreateServices).
    // Firestore.collection() accepts a full slash-delimited path directly.
    final DocumentReference<Map<String, dynamic>> currentServiceDocRef =
        firestore.collection(createServicesPath).doc(currentServiceDocId);

    final currentServiceDoc = await currentServiceDocRef.get();

    if (!currentServiceDoc.exists) {
      if (kDebugMode) print("❌ Service not found: $currentServiceDocId");
      return null;
    }

    final currentData = currentServiceDoc.data();
    final currentProviderServices = currentData?['Provider_Services'];

    if (currentProviderServices == null) {
      if (kDebugMode) print("❌ No providers for service: $currentServiceDocId");
      return null;
    }

    // Parse providers (handle list format)
    List<dynamic> parsedCurrentProviders = _parseProvidersList(currentProviderServices);

    if (parsedCurrentProviders.isEmpty) {
      if (kDebugMode) print("❌ Empty providers list");
      return null;
    }

    // If only 1 provider, return it
    if (parsedCurrentProviders.length == 1) {
      final provider = parsedCurrentProviders[0];
      if (provider is Map<String, dynamic>) {
        if (kDebugMode) print("✅ Single provider: ${provider['email']}");
        return provider;
      }
      return null;
    }

    // ✅ For multiple providers, calculate workload across ALL services
    if (kDebugMode) print("📊 Multiple providers (${parsedCurrentProviders.length}), calculating workload...");

    // ✅ UPDATED: Get all services from CreateServices collection
    final CollectionReference<Map<String, dynamic>> createServicesCollection =
        firestore.collection(createServicesPath);

    final allServicesSnapshot = await createServicesCollection.get();
    if (kDebugMode) print("📊 Total CreateServices docs found: ${allServicesSnapshot.docs.length}");

    final Map<String, double> emailTotalDuration = {};
    final Map<String, int> emailFrequency = {};

    // Process all services to calculate provider workload
    for (var serviceDoc in allServicesSnapshot.docs) {
      final data = serviceDoc.data();
      final providerServices = data['Provider_Services'];

      // ✅ UPDATED: Calculate duration (handle list format)
      final durationData = data['Duration_Of_Services'];
      String? durationValueStr;

      if (durationData is List && durationData.isNotEmpty) {
        final lastEntry = durationData.last;
        if (lastEntry is Map) {
          var durVal = lastEntry['value'] ?? lastEntry['values'];
          if (durVal is List && durVal.isNotEmpty) {
            durationValueStr = durVal[0].toString();
          } else {
            durationValueStr = durVal?.toString();
          }
        } else {
          durationValueStr = lastEntry.toString();
        }
      } else if (durationData is Map) {
        var durVal = durationData['value'] ?? durationData['values'];
        if (durVal is List && durVal.isNotEmpty) {
          durationValueStr = durVal[0].toString();
        } else {
          durationValueStr = durVal?.toString();
        }
      } else {
        durationValueStr = durationData?.toString();
      }

      // ✅ UPDATED: Get duration unit (handle list format)
      final durationUnitData = data['Selected_Duration_Unit'];
      String? durationUnit;

      if (durationUnitData is List && durationUnitData.isNotEmpty) {
        final lastEntry = durationUnitData.last;
        if (lastEntry is Map) {
          var unitVal = lastEntry['value'] ?? lastEntry['values'];
          if (unitVal is List && unitVal.isNotEmpty) {
            durationUnit = unitVal[0].toString().toLowerCase();
          } else {
            durationUnit = unitVal?.toString().toLowerCase();
          }
        } else {
          durationUnit = lastEntry.toString().toLowerCase();
        }
      } else if (durationUnitData is Map) {
        var unitVal = durationUnitData['value'] ?? durationUnitData['values'];
        if (unitVal is List && unitVal.isNotEmpty) {
          durationUnit = unitVal[0].toString().toLowerCase();
        } else {
          durationUnit = unitVal?.toString().toLowerCase();
        }
      } else {
        durationUnit = durationUnitData?.toString().toLowerCase();
      }

      double durationValue = double.tryParse(durationValueStr ?? '0') ?? 0;

      double durationInMin = switch (durationUnit) {
        "minutes" || "minute" || "min" => durationValue,
        "hours" || "hour" || "hr" => durationValue * 60,
        "days" || "day" => durationValue * 1440,
        "weeks" || "week" => durationValue * 10080,
        _ => durationValue
      };

      // Count workload per provider (handle list format)
      if (providerServices != null) {
        dynamic providersList;

        if (providerServices is List && providerServices.isNotEmpty) {
          final lastEntry = providerServices.last;
          if (lastEntry is String) {
            // JSON string format
            providersList = lastEntry;
          } else {
            providersList = providerServices;
          }
        } else if (providerServices is Map) {
          providersList = providerServices['values'] ?? providerServices['value'];
        } else {
          continue;
        }

        List<dynamic> parsedProviders = _parseProvidersList(providersList);

        for (var provider in parsedProviders) {
          if (provider is Map<String, dynamic>) {
            final email = provider['email'];
            if (email != null && email is String) {
              emailTotalDuration[email] = (emailTotalDuration[email] ?? 0) + durationInMin;
              emailFrequency[email] = (emailFrequency[email] ?? 0) + 1;
            }
          }
        }
      }
    }

    if (kDebugMode) print("📊 Workload calculated:");
    emailTotalDuration.forEach((email, duration) {
      if (kDebugMode) print("  $email: ${duration}min (${emailFrequency[email]} services)");
    });

    // Sort providers by workload (least busy first)
    final validProviders = parsedCurrentProviders
        .where((p) => p is Map<String, dynamic> && p['email'] != null)
        .cast<Map<String, dynamic>>()
        .toList();

    if (validProviders.isEmpty) {
      if (kDebugMode) print("❌ No valid providers");
      return null;
    }

    validProviders.sort((a, b) {
      final emailA = a['email'] as String?;
      final emailB = b['email'] as String?;

      if (emailA == null || emailB == null) return 0;

      final durationA = emailTotalDuration[emailA] ?? 0;
      final durationB = emailTotalDuration[emailB] ?? 0;

      if (durationA != durationB) {
        return durationA.compareTo(durationB);
      }

      final freqA = emailFrequency[emailA] ?? 0;
      final freqB = emailFrequency[emailB] ?? 0;
      return freqA.compareTo(freqB);
    });

    final selectedProvider = validProviders.first;
    final selectedEmail = selectedProvider['email'];
    if (kDebugMode) print("✅ Selected provider (least busy): $selectedEmail");
    if (kDebugMode) print("   Total workload: ${emailTotalDuration[selectedEmail] ?? 0}min");
    if (kDebugMode) print("   Service count: ${emailFrequency[selectedEmail] ?? 0}");

    return selectedProvider;

  } catch (e, stackTrace) {
    if (kDebugMode) print("❌ ERROR in selectServiceProvider: $e");
    if (kDebugMode) print("❌ Stack Trace: $stackTrace");
    return null;
  }
}






List<dynamic> _parseProvidersList(dynamic providersList) {
  // print("  🔧 Parsing providers list...");
  // print("  🔧 Input Type: ${providersList?.runtimeType}");

  if (providersList == null) {
    // print("  ❌ Providers list is null");
    return [];
  }

  // If it's already a list
  if (providersList is List) {
    // print("  ✅ Input is a List with ${providersList.length} items");

    // Check if first element is a List (nested array)
    if (providersList.isNotEmpty && providersList[0] is List) {
      // print("  🔄 Unwrapping nested array");
      providersList = providersList[0];
    }

    // Check if first element is a JSON string
    if (providersList.isNotEmpty && providersList[0] is String) {
      // print("  🔄 First element is a String, attempting JSON decode");
      try {
        final decoded = jsonDecode(providersList[0]);
        // print("  ✅ Successfully decoded JSON string");
        if (decoded is List) {
          return decoded;
        } else if (decoded is Map) {
          return [decoded];
        }
      } catch (e) {
        // print("  ❌ Failed to decode JSON: $e");
      }
    }

    // Return the list as-is if elements are Maps
    return providersList;
  }

  // If it's a String (JSON)
  if (providersList is String) {
    // print("  🔄 Input is a String, attempting JSON decode");
    try {
      final decoded = jsonDecode(providersList);
      // print("  ✅ Successfully decoded JSON string");
      if (decoded is List) {
        return decoded;
      } else if (decoded is Map) {
        return [decoded];
      }
    } catch (e) {
      // print("  ❌ Failed to decode JSON string: $e");
    }
  }

  // print("  ❌ Unable to parse providers list");
  return [];
}


