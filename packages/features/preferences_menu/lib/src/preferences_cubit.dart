import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preferences_service/preferences_service.dart';

class PreferencesCubit extends Cubit<Preferences> {
  PreferencesCubit({required PreferencesService service})
    : _service = service,
      super(service.current);

  final PreferencesService _service;

  Future<void> update(Preferences Function(Preferences) transform) async {
    await _service.update(transform);
    emit(_service.current);
  }
}
