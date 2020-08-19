import 'dart:ffi';

import 'package:dart_native/src/ios/common/callback_manager.dart';
import 'package:dart_native/src/ios/common/library.dart';
import 'package:dart_native/src/ios/runtime/block.dart';
import 'package:dart_native/src/ios/runtime/class.dart';
import 'package:dart_native/src/ios/runtime/functions.dart';
import 'package:dart_native/src/ios/runtime/id.dart';
import 'package:dart_native/src/ios/runtime/selector.dart';

final id nil = id(nullptr);

void passObjectToNative(NSObject obj) {
  if (initDartAPISuccess && obj.isa != null) {
    passObjectToC(obj, obj.pointer);
  } else {
    print('pass object to native failed! address=${obj.pointer}');
  }
}

/// The root class of most Objective-C class hierarchies, from which subclasses inherit a basic interface to the runtime system and the ability to behave as Objective-C objects.
class NSObject extends id {
  NSObject([Class isa]) : super(_new(isa)) {
    passObjectToNative(this);
  }

  NSObject.fromPointer(Pointer<Void> ptr) : super(ptr) {
    if (ptr == null || object_isClass(ptr) != 0) {
      throw 'Pointer $ptr is not for NSObject!';
    }
    passObjectToNative(this);
  }

  NSObject init() {
    return perform(SEL('init'));
  }

  NSObject copy() {
    NSObject result = perform(SEL('copy'));
    return NSObject.fromPointer(result.autorelease().pointer);
  }

  NSObject mutableCopy() {
    NSObject result = perform(SEL('mutableCopy'));
    return NSObject.fromPointer(result.autorelease().pointer);
  }

  NSObject autorelease() {
    return perform(SEL('autorelease'));
  }

  static Pointer<Void> _new(Class isa) {
    if (isa == null) {
      isa = Class('NSObject');
    }
    NSObject result = isa.perform(SEL('new'));
    return result.autorelease().pointer;
  }
}

Pointer<Void> alloc(Class isa) {
  if (isa == null) {
    isa = Class('NSObject');
  }
  NSObject result = isa.perform(SEL('alloc'));
  return result.autorelease().pointer;
}

typedef dynamic ConvertorFromPointer(Pointer<Void> ptr);

void registerTypeConvertor(String type, ConvertorFromPointer convertor) {
  if (_convertorCache[type] == null) {
    _convertorCache[type] = convertor;
  }
}

dynamic convertFromPointer(String type, dynamic arg) {
  Pointer<Void> ptr;
  if (arg is NSObject) {
    ptr = arg.pointer;
  } else if (arg is Pointer) {
    ptr = arg;
  } else {
    return arg;
  }

  if (ptr == nullptr) {
    return arg;
  }

  ConvertorFromPointer convertor = _convertorCache[type];
  if (convertor != null) {
    return convertor(ptr);
  } else if (arg is Pointer) {
    return NSObject.fromPointer(arg);
  }
  return arg;
}

Map<String, ConvertorFromPointer> _convertorCache = {};

void _dealloc(Pointer<Void> ptr) {
  if (ptr != nullptr) {
    CallbackManager.shared.clearAllCallbackOnTarget(ptr);
    removeBlockOnAddress(ptr.address);
  }
}

Pointer<NativeFunction<Void Function(Pointer<Void>)>> nativeObjectDeallocPtr =
    Pointer.fromFunction(_dealloc);