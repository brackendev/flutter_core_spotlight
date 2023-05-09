import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';

typedef UserActivityCallback = Function(FlutterSpotlightUserActivity?);

class FlutterSpotlightItem {
  FlutterSpotlightItem({
    required this.uniqueIdentifier,
    required this.domainIdentifier,
    required this.attributeTitle,
    required this.attributeDescription,
    this.attributeEndDate = null,
    this.attributeThumbnailImage = null,
    this.attributeStartDate = null,
  });

  factory FlutterSpotlightItem.fromJson(String source) =>
      FlutterSpotlightItem.fromMap(json.decode(source));

  factory FlutterSpotlightItem.fromMap(Map<String, dynamic> map) {
    return FlutterSpotlightItem(
      uniqueIdentifier: map['uniqueIdentifier'],
      domainIdentifier: map['domainIdentifier'],
      attributeTitle: map['attributeTitle'],
      attributeDescription: map['attributeDescription'],
      attributeEndDate: map['attributeEndDate'],
      attributeThumbnailImage: map['attributeThumbnailImage'],
      attributeStartDate: map['attributeStartDate'],
    );
  }

  final String attributeDescription;
  final String attributeTitle;
  final String domainIdentifier;
  final String uniqueIdentifier;
  final DateTime? endDate;
  final Image? thumbnailImage;
  final DateTime? startDate;

  Map<String, dynamic> toMap() {
    return {
      'uniqueIdentifier': uniqueIdentifier,
      'domainIdentifier': domainIdentifier,
      'attributeTitle': attributeTitle,
      'attributeDescription': attributeDescription,
      'attributeEndDate': attributeEndDate,
      'attributeThumbnailImage': attributeThumbnailImage,
      'attributeStartDate': attributeStartDate,
    };
  }

  String toJson() => json.encode(toMap());
}

class FlutterSpotlightUserActivity {
  FlutterSpotlightUserActivity({
    this.key,
    this.uniqueIdentifier,
    this.userInfo,
  });

  factory FlutterSpotlightUserActivity.fromJson(String source) =>
      FlutterSpotlightUserActivity.fromMap(json.decode(source));

  factory FlutterSpotlightUserActivity.fromMap(Map<String, dynamic> map) {
    return FlutterSpotlightUserActivity(
      key: map['key'],
      uniqueIdentifier: map['uniqueIdentifier'],
      userInfo: Map<String, dynamic>.from(map['userInfo']),
    );
  }

  final String? key;
  final String? uniqueIdentifier;
  final Map<String, dynamic>? userInfo;

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'uniqueIdentifier': uniqueIdentifier,
      'userInfo': userInfo,
    };
  }

  String toJson() => json.encode(toMap());
}

class FlutterCoreSpotlight {
  FlutterCoreSpotlight._();

  static final FlutterCoreSpotlight instance = FlutterCoreSpotlight._();

  static const MethodChannel _channel =
      const MethodChannel('flutter_core_spotlight');

  UserActivityCallback? _onSearchableItemSelected;

  Future<String> indexSearchableItems(
      List<FlutterSpotlightItem> spotlightItems) async {
    return await _channel.invokeMethod('index_searchable_items',
        spotlightItems.map((e) => e.toMap()).toList());
  }

  Future<String> deleteSearchableItems(List<String> identifiers) async {
    return await _channel.invokeMethod('delete_searchable_items', identifiers);
  }

  void configure({required UserActivityCallback onSearchableItemSelected}) {
    _onSearchableItemSelected = onSearchableItemSelected;
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onSearchableItemSelected':
        final Map<String, dynamic> args =
            call.arguments.cast<String, dynamic>();
        _onSearchableItemSelected!(FlutterSpotlightUserActivity.fromMap(args));
        break;
      default:
        throw UnsupportedError('Unrecognized JSON message');
    }
  }
}
