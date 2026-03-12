import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/app/dependency_container.dart';
import 'package:nota/app/router/app_routes.dart';
import 'package:note_details/note_details.dart';
import 'package:note_list/note_list.dart';
import 'package:preferences_menu/preferences_menu.dart';

GoRouter buildRouter({required DependenciesContainer dependencies}) {
  dependencies.logger.debug('buildRouter: GoRouter created');

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.notes,
    routes: [
      GoRoute(
        path: AppRoutes.notes,
        builder: (context, state) => NoteListScreen(
          noteRepository: dependencies.noteRepository,
          onAddPressed: () => context.push(AppRoutes.newNote),
          onNotePressed: (note) => context.push(AppRoutes.noteEditor(note.id)),
          onSettingsPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => PreferencesBottomSheet(
              preferencesService: dependencies.preferencesService,
              supportedLanguages: dependencies.supportedLanguages,
            ),
          ),
        ),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => NoteDetailsScreen(
              noteRepository: dependencies.noteRepository,
              onBackPressed: () => context.pop(),
            ),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => NoteDetailsScreen(
              noteRepository: dependencies.noteRepository,
              noteId: state.pathParameters['id'],
              onBackPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    ],
  );
}
