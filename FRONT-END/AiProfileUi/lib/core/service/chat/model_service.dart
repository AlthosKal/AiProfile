import '../../../util/enums/model.dart';
import '../api_client.dart';

class ModelService {
  final _api = ApiClient();

  Future<List<Model>> getAllModels() async {
    final response = await _api.getChat('/model');

    if (response.statusCode != 200) {
      throw Exception('Error al listar modelos: código ${response.statusCode}');
    }

    final data = response.data;
    if (data is List) {
      return data.map((e) => Model.values.byName(e)).toList();
    } else {
      throw Exception('Respuesta inesperada del servidor');
    }
  }
}
