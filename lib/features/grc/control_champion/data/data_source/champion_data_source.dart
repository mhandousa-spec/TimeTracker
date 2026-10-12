/// Module: Control Champion Management
/// Description: Data source contract for Control Champion CRUD operations,
///              independent of any specific backend.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: ChampionModel

import 'package:knowticed_plus/features/grc/control_champion/data/models/champion_model.dart';

abstract class ChampionDataSource {
  Future<ChampionModel> create(ChampionModel model, {required String moduleId});

  Future<ChampionModel?> get(String championEmail, {required String moduleId});

  Future<List<ChampionModel>> getAll({
    required String moduleId,
    bool includeRemoved = false,
  });

  Future<ChampionModel> update(ChampionModel updatedModel, {required String moduleId});
}
