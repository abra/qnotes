# image_service

Manages image files embedded in Quill notes.

## Why this package exists

When a user inserts an image into a note, Quill stores the file path as plain text inside
the Delta JSON content. `ImageService` ensures those files are stored in a stable location
and cleaned up when notes are deleted.

## Storage

All images are copied into `<appDocuments>/nota_images/` with a timestamp-based filename.
This ensures paths remain valid regardless of where the original file came from (camera,
gallery, temp cache).

## API

```dart
// Copy a picked image to permanent storage, returns the stable path
final path = await imageService.saveImage(sourcePath);

// Delete a single image file (silently ignores missing files)
await imageService.deleteImage(imagePath);

// Parse a Quill Delta JSON string and delete all referenced image files
await imageService.deleteImagesFromContent(note.content);
```

## Error handling

`saveImage` and `_imagesDir` wrap all IO failures in `ImageServiceException(message, cause, stackTrace)`.
Callers can catch it explicitly:

```dart
try {
  final path = await imageService.saveImage(sourcePath);
} on ImageServiceException catch (e) {
  // handle or rethrow
}
```

`deleteImage` and `deleteImagesFromContent` are **best-effort**: missing files are silently
ignored (`existsSync` check). However, unexpected IO errors from the platform will propagate
as unhandled exceptions — BLoCs catch them with a generic `catch (e, st)` and log via
`addError`, without changing the success state (the note is already deleted from the DB).

## Usage

`deleteImagesFromContent` is called by `NoteListBloc` whenever a note (or a batch of
notes) is deleted, so image files don't accumulate as orphans on disk.

`saveImage` is called by `note_details` when the user picks an image to insert into the
editor.
