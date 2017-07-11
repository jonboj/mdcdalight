

import '../../../lib/src/binding/bind_base_ctrl.dart';
import '../../../lib/src/binding/binding_types.dart';


abstract class ElemDepthPropBind implements IPropBind {

  int pdown;
  int pup;

  //// Binding instrumentation section ////
  static const String PDOWN = 'pdown';
  static const String PUP = 'pup';
  static const Map<String, int> _propNameMap = const {PDOWN : 0, PUP : 1};
  static final List<String> _attrKeys = attrKeyFromProp(_propNameMap);

  Map<String, int> get propNameIndex => _propNameMap;
  List<String> get attrKeys => _attrKeys;
  List<PropertyBindSet> get bindProp => [
    new PropertyBindSet(PDOWN, () => pdown, (final int i){pdown = i;}),
    new PropertyBindSet(PUP, () => pup, (final int i){pup = i;})];

}
