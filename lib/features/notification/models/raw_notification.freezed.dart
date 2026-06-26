// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'raw_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RawNotification {

 String get packageName; String get title; String get text; int get timestamp;
/// Create a copy of RawNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RawNotificationCopyWith<RawNotification> get copyWith => _$RawNotificationCopyWithImpl<RawNotification>(this as RawNotification, _$identity);

  /// Serializes this RawNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RawNotification&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.title, title) || other.title == title)&&(identical(other.text, text) || other.text == text)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageName,title,text,timestamp);

@override
String toString() {
  return 'RawNotification(packageName: $packageName, title: $title, text: $text, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $RawNotificationCopyWith<$Res>  {
  factory $RawNotificationCopyWith(RawNotification value, $Res Function(RawNotification) _then) = _$RawNotificationCopyWithImpl;
@useResult
$Res call({
 String packageName, String title, String text, int timestamp
});




}
/// @nodoc
class _$RawNotificationCopyWithImpl<$Res>
    implements $RawNotificationCopyWith<$Res> {
  _$RawNotificationCopyWithImpl(this._self, this._then);

  final RawNotification _self;
  final $Res Function(RawNotification) _then;

/// Create a copy of RawNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packageName = null,Object? title = null,Object? text = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RawNotification].
extension RawNotificationPatterns on RawNotification {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RawNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RawNotification() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RawNotification value)  $default,){
final _that = this;
switch (_that) {
case _RawNotification():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RawNotification value)?  $default,){
final _that = this;
switch (_that) {
case _RawNotification() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String packageName,  String title,  String text,  int timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RawNotification() when $default != null:
return $default(_that.packageName,_that.title,_that.text,_that.timestamp);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String packageName,  String title,  String text,  int timestamp)  $default,) {final _that = this;
switch (_that) {
case _RawNotification():
return $default(_that.packageName,_that.title,_that.text,_that.timestamp);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String packageName,  String title,  String text,  int timestamp)?  $default,) {final _that = this;
switch (_that) {
case _RawNotification() when $default != null:
return $default(_that.packageName,_that.title,_that.text,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RawNotification implements RawNotification {
  const _RawNotification({required this.packageName, required this.title, required this.text, required this.timestamp});
  factory _RawNotification.fromJson(Map<String, dynamic> json) => _$RawNotificationFromJson(json);

@override final  String packageName;
@override final  String title;
@override final  String text;
@override final  int timestamp;

/// Create a copy of RawNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RawNotificationCopyWith<_RawNotification> get copyWith => __$RawNotificationCopyWithImpl<_RawNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RawNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RawNotification&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.title, title) || other.title == title)&&(identical(other.text, text) || other.text == text)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageName,title,text,timestamp);

@override
String toString() {
  return 'RawNotification(packageName: $packageName, title: $title, text: $text, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$RawNotificationCopyWith<$Res> implements $RawNotificationCopyWith<$Res> {
  factory _$RawNotificationCopyWith(_RawNotification value, $Res Function(_RawNotification) _then) = __$RawNotificationCopyWithImpl;
@override @useResult
$Res call({
 String packageName, String title, String text, int timestamp
});




}
/// @nodoc
class __$RawNotificationCopyWithImpl<$Res>
    implements _$RawNotificationCopyWith<$Res> {
  __$RawNotificationCopyWithImpl(this._self, this._then);

  final _RawNotification _self;
  final $Res Function(_RawNotification) _then;

/// Create a copy of RawNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageName = null,Object? title = null,Object? text = null,Object? timestamp = null,}) {
  return _then(_RawNotification(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
