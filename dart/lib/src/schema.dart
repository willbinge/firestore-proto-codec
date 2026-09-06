import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

import 'generated/codebinge/firestore/codec/v1/options.pb.dart' as opt;
import 'generated/google/protobuf/descriptor.pb.dart' as pb;

/// Per-field encoding rules, resolved from custom options.
class FieldRules {
  const FieldRules({
    this.skip = false,
    this.name,
    this.enumAsNumber = false,
    this.omitWhenDefault = true,
    this.unsignedAsInteger = false,
    this.geoPoint = false,
  });

  final bool skip;
  final String? name;
  final bool enumAsNumber;
  final bool omitWhenDefault;
  final bool unsignedAsInteger;
  final bool geoPoint;

  static const defaults = FieldRules();
}

/// Holds the custom options for message types that use them.
///
/// Field *names* and real `oneof` groups come from reflection and need no
/// registration. Two things do not survive into `BuilderInfo` and require the
/// binary descriptor:
///
/// 1. The options in `codebinge/firestore/codec/v1/options.proto`.
/// 2. Proto3 `optional`. The runtime registers such a field identically to an
///    implicit-presence one, so without the descriptor the codec cannot tell
///    that a default value should still be written, and an unregistered
///    message silently omits its `optional` fields when they hold defaults.
///
/// A message using neither needs no registration.
class SchemaRegistry {
  SchemaRegistry();

  final Map<String, Map<int, FieldRules>> _byMessage = {};
  final Map<String, Set<int>> _explicitPresence = {};
  late final ExtensionRegistry _extensions = () {
    final r = ExtensionRegistry();
    opt.Options.registerAllExtensions(r);
    return r;
  }();

  /// Registers the options for [prototype], read from the `<name>Descriptor`
  /// constant in its generated `.pbjson.dart` file.
  ///
  /// ```dart
  /// registry.register(Unsigned(), unsignedDescriptor);
  /// ```
  void register(GeneratedMessage prototype, Uint8List descriptorBytes) {
    final descriptor =
        pb.DescriptorProto.fromBuffer(descriptorBytes, _extensions);
    final name = prototype.info_.qualifiedMessageName;
    _byMessage[name] = {
      for (final field in descriptor.field)
        if (field.hasOptions()) field.number: _rulesFrom(field.options),
    };
    // A synthetic oneof is how proto3 `optional` is represented, and this is
    // the only place the distinction survives: the runtime registers such a
    // field exactly like an implicit-presence one. Real oneof members are
    // also collected here, harmlessly; BuilderInfo.oneofs already covers them.
    _explicitPresence[name] = {
      for (final field in descriptor.field)
        if (field.hasOneofIndex()) field.number,
    };
  }

  /// Whether the field tracks presence, so that a default value is still
  /// written. False for unregistered messages, which is correct for any
  /// message without proto3 `optional` fields; real `oneof` members are
  /// handled from `BuilderInfo.oneofs` without registration.
  bool hasExplicitPresence(String qualifiedMessageName, int tagNumber) =>
      _explicitPresence[qualifiedMessageName]?.contains(tagNumber) ?? false;

  FieldRules rulesFor(String qualifiedMessageName, int tagNumber) =>
      _byMessage[qualifiedMessageName]?[tagNumber] ?? FieldRules.defaults;

  FieldRules _rulesFrom(pb.FieldOptions options) {
    if (!options.hasExtension(opt.Options.field_50000)) {
      return FieldRules.defaults;
    }
    final f = options.getExtension(opt.Options.field_50000) as opt.Field;
    return FieldRules(
      skip: f.skip,
      name: f.hasName() && f.name.isNotEmpty ? f.name : null,
      enumAsNumber: f.enumAs == opt.EnumEncoding.ENUM_ENCODING_NUMBER,
      // Explicit presence: the intended default is true, which an implicit
      // proto3 bool could not express.
      omitWhenDefault: f.hasOmitWhenDefault() ? f.omitWhenDefault : true,
      unsignedAsInteger: f.kind == opt.Kind.KIND_UNSIGNED_AS_INTEGER,
      geoPoint: f.kind == opt.Kind.KIND_GEO_POINT,
    );
  }
}
