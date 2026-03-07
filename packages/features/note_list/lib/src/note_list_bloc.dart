import 'package:flutter_bloc/flutter_bloc.dart';

import 'note_list_event.dart';
import 'note_list_state.dart';

class NoteListBloc extends Bloc<NoteListEvent, NoteListState> {
  NoteListBloc(super.initialState);
}
