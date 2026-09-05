/// Encode a protobuf message as a Firestore value, and decode it back.
///
/// See `docs/encoding.md` for the encoding rules.
library;

export 'src/codec.dart' show FirestoreProtoCodec, maxNestingDepth;
export 'src/errors.dart' show CodecError, CodecErrorCode;
export 'src/schema.dart' show FieldRules, SchemaRegistry;
export 'src/values.dart'
    show DefaultFirestoreTypes, FirestoreTypes, FsBlob, FsGeoPoint, FsTimestamp;
