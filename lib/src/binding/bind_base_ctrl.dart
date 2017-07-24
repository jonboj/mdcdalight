// Copyright 2017 Jonas Bojesen. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:html';
import 'dart:convert';

import '../binding/binding_types.dart';
import '../binding/binding_parser.dart';

import '../util/utils.dart';
import '../util/log_mdcda.dart';

import 'bind_base_util.dart';
import '../custom_element/html_import_manager.dart';

typedef void propUpdateCallback();

List<String> attrKeyFromProp(final Map<String, int> propMap) =>
    propMap.keys.map((final String key) => property2Attr(key)).toList();


//Interface for the class binding info.
abstract class IPropBind {
  Map<String, int> get propNameIndex;
  List<PropertyBindSet> get bindProp;
  List<String> get attrKeys;
}

abstract class IComputedBind {
  Map<String, ComputedBind> get bindComputed;
}

//Interface to bundle requirement of HtmlElement with property binding.
//Implemented by customelement with bindings.
abstract class ICustomBindElement implements HtmlElement, IPropBind {
}

//Interface for the handler of different binding types.
abstract class IBindHandler {
  bool get isNotEmpty;
  //Updates and returns a Set with the bindings which obtained a value different from previous.
  Set<String> updateProperties(final List<String> bindIds);
}

//Main class for controlling all binding types.
class BindBaseCtrl {

  static final LogMdcda _log = new LogMdcda.fromType(BindBaseCtrl);

  static const TypeFilter<BindBaseCtrl, Element> _filterBindBaseCtrl = const TypeFilter<BindBaseCtrl, Element>();

  static const String START_ONE_WAY = '[[';
  static const String END_ONE_WAY = ']]';
  static const AttrBindTags _oneWayMatcher = const AttrBindTags(START_ONE_WAY, END_ONE_WAY);

  static const String START_TWO_WAY = '{{';
  static const String END_TWO_WAY = '}}';
  static const AttrBindTags _twoWayMatcher = const AttrBindTags(START_TWO_WAY, END_TWO_WAY);

  /// Host role ///
  ICustomBindElement host;//Reference to host element

  //Bindings to host properties.
  PropertyListStrIndex<PropertyBindSet> propertyMap;

  /// Target role ///
  _TargetNodeTwoWayPropBind _targetTwoWayBind;

  // The different bindings handles
  List<IBindHandler> _regBindHandlers = new List<IBindHandler>();

  //The TwoWay bindings, notifications from target.
  Map<String, PropertyBind> _twoWayBindsNotifications = new Map<String, PropertyBind>();

  Map<String, propUpdateCallback> _updateNotifications = new Map<String, propUpdateCallback>();

  //// Construction ////
  void createBindFromElement(final ICustomBindElement e)  {
    host = e;
    propertyMap = new PropertyListStrIndex<PropertyBindSet>(e.propNameIndex, e.bindProp, e.attrKeys);

    //Setting up binding in text nodes.
    _HostTextNodeBind hostTextNodeBind = new _HostTextNodeBind(this);
    if (hostTextNodeBind.isNotEmpty){
      _regBindHandlers.add(hostTextNodeBind);
    }

    //Scan target classes for attribute bindings and setup target bindings.
    List<BindBaseCtrl> targetList = _targetElementsWithAttributeBind();
    _log.debug(() => 'createBindFromElement - host : ' + host.tagName
        + ', The targetlist length : ' + targetList.length.toString());

    if (targetList.isNotEmpty){

      //HostTargetNodePropBind
      _TargetOneWayAttrBind hostTargetNodePropBind = new _TargetOneWayAttrBind(this, targetList);
      if (hostTargetNodePropBind.isNotEmpty){
        _regBindHandlers.add(hostTargetNodePropBind);
      }

      //Search and register targets for twoway bindings.
      registerTwoWayBindingsTargets(targetList);
    }

    //Initial update after construction.
    updateProps(propertyMap.keys.toList());
  }

  //For subscription to updates
  void registerPropNotification(final String signId, final propUpdateCallback cb){
    _updateNotifications[signId] = cb;
  }

  void registerTwoWayBindingsTargets(final List<BindBaseCtrl> targetList){
    targetList.forEach((final BindBaseCtrl targetCtrl) {
      targetCtrl.registerTwoWayHost(this);
    });
  }

  /// Notification ///
  void updateProps(final List<String> bindIds) {

    _log.debug(()=> 'updateProps : ' + bindIds.toString());

    //Update the twoway notifications from targets.
    List<String> bindsToUpdateFromTwoWay =
      bindIds.toSet().intersection(_twoWayBindsNotifications.keys.toSet()).toList();

    bindsToUpdateFromTwoWay.forEach((final String s){
      propertyMap[s].value = _twoWayBindsNotifications[s].value;
      _twoWayBindsNotifications.remove(s);
    });

    _log.debug(()=> 'updateProps _twoWayBindsNotifications.len : ' + _twoWayBindsNotifications.length.toString());

    //Update all registered handler
    Set<String> bindsWithNewValue = new Set<String>();
    _regBindHandlers.forEach((final IBindHandler bindHandler){
      bindsWithNewValue.addAll(bindHandler.updateProperties(bindIds));
    });

    //Notify subscriptions.
    final List<String> subScribedBindsToNotify =
      bindsWithNewValue.intersection(_updateNotifications.keys.toSet()).toList();
    //Call the registered callback.
    subScribedBindsToNotify.forEach((final String idSign){_updateNotifications[idSign]();});
  }

  /// Dif util methods ///
  List<BindBaseCtrl> _targetElementsWithAttributeBind(){
    final String bindAttrSelector = '[' + HtmlImportManager.attrStrTargetTag(host) + ']';
    final List<Element> lTarget = host.querySelectorAll(bindAttrSelector);
    return _filterBindBaseCtrl.list(lTarget);
  }

  Bind getBinding(final String idBindStr){
    if (propertyMap.keys.contains(idBindStr)){
      return propertyMap[idBindStr];
    }

    if (host is IComputedBind){
      return (host as IComputedBind).bindComputed[idBindStr];
    }

    return null;
  }

  /// Interface taget node  ///
  //Construction
  Map<String, PropertyBindSet> getAttrOneWayBindings(){

    Map<String, PropertyBindSet> attrBindMap = new Map<String, PropertyBindSet>();
    //Get binded properties which occur as attributes for current target node.
    List<String> lBindAttr = propertyMap.attrKeys.toSet().intersection(host.attributes.keys.toSet()).toList();
    lBindAttr.forEach((final String attrStr){
      final String valueStr = _oneWayMatcher.parseValueStr(host.attributes[attrStr]);
      if (valueStr.isNotEmpty){
        //This is a binding
        final String propKey = propertyMap.propKeyFromAttrFormat(attrStr);
        attrBindMap[valueStr] = propertyMap[propKey];
      }
    });
    return attrBindMap;
  }

  //Invoked from twoway bind host.
  void registerTwoWayHost(final BindBaseCtrl hostTwoWay){
    Map<String, String> twoWayBindAttrMap = _getAttrTwoWayBindings();
    _targetTwoWayBind = new _TargetNodeTwoWayPropBind(this, hostTwoWay, twoWayBindAttrMap);

    //If empty no two-way bindings at this target.
    if (_targetTwoWayBind.isNotEmpty){
      _regBindHandlers.add(_targetTwoWayBind);
    }
  }

  //Notification
  void twoWayNotifyFromTarget(final String hostPropSig, final PropertyBind targetProp){
    //If previous binding is stored then replaces with latest.
    _twoWayBindsNotifications[hostPropSig] = targetProp;

    if(_updateNotifications.containsKey(hostPropSig)){
      _updateNotifications[hostPropSig]();//Call the registered callback.
    }
  }

  Map<String, String> _getAttrTwoWayBindings(){

    Map<String, String> attrBindMap = new Map<String, String>();
    //Get binded properties which occur as attributes for current target node.
    List<String> lBindAttr = host.attributes.keys.toSet().intersection(propertyMap.attrKeys.toSet()).toList();
    lBindAttr.forEach((final String attrStr){
      final String valueStr = _twoWayMatcher.parseValueStr(host.attributes[attrStr]);
      if (valueStr.isNotEmpty){
        //This is a binding
        final String propKey = propertyMap.propKeyFromAttrFormat(attrStr);
        attrBindMap[propKey] = valueStr;
      }
    });
    return attrBindMap;
  }

}

//For a host node handles bindings to sub text nodes bindings.
class _HostTextNodeBind implements IBindHandler {

  final BindBaseCtrl _ctrl;

  Map<String, List<NodeBindWrap>> _bindingToNodeMap;

  //// Construction ////
  _HostTextNodeBind(final BindBaseCtrl this._ctrl){
    //Build the dependencies map.
    _bindingToNodeMap = BindingParser.wrapTextNodes(_ctrl.host);

    if (_ctrl.host is IComputedBind){
      //Translate computed bindings to property dependencies.
      _transformCompDeps();
    }
  }

  /// Interface IBindHandler ///
  bool get isNotEmpty => _bindingToNodeMap.isNotEmpty;

  /// Notification ///
  Set<String> updateProperties(final List<String> bindIds){
    //Find common bindings to update.
    final Set<String> bindIdsInProp = bindIds.toSet().intersection(_bindingToNodeMap.keys.toSet());

    Set<NodeBindWrap> nodesToUpdate = new Set<NodeBindWrap>();//Same binding could occur for more than one node.
    bindIdsInProp.forEach((final String bindId) => nodesToUpdate.addAll(_bindingToNodeMap[bindId]));
    nodesToUpdate.forEach((final NodeBindWrap nB) => nB.updateContent(_ctrl.getBinding));

    //Content of the text node is updated, not the value of the binded property.
    return new Set<String>();
  }

  //When a binding is updated computed bindings which depends on this needs update, this
  //is setup from the found bindings.
  _transformCompDeps(){
    final Map<String, ComputedBind> bindComp = (_ctrl.host as IComputedBind).bindComputed;
    final Set<String> bindSign = bindComp.keys.toSet().intersection(_bindingToNodeMap.keys.toSet());

    bindSign.forEach((final String compBindSignature){
      //For each computed binding move wrapped nodes to dependent bindings.
      final List<NodeBindWrap> nodeWraps = _bindingToNodeMap[compBindSignature];
      final ComputedBind cBind = bindComp[compBindSignature];
      cBind.deps.forEach((final String depBindStr){
        if (_bindingToNodeMap.containsKey(depBindStr)){
          _bindingToNodeMap[depBindStr].addAll(nodeWraps);
        }else {
          _bindingToNodeMap[depBindStr] = nodeWraps;
        }
      });

    });
  }
}

//For a host node handle set bindings to target nodes properties.
class _TargetOneWayAttrBind implements IBindHandler {

  static final LogMdcda _log = new LogMdcda.fromType(_TargetOneWayAttrBind);

  final BindBaseCtrl _ctrl;

  Map<String, List<PropertyBindSet>> _bindingToTargetProp = new Map<String, List<PropertyBindSet>>();

  //// Construction ////
  _TargetOneWayAttrBind(final BindBaseCtrl this._ctrl, final List<BindBaseCtrl> targetList){
    _registerOneWayBindings(targetList);
  }

  //Build the dependencies map.
  void _registerOneWayBindings(final List<BindBaseCtrl> targetList){
    targetList.forEach((final BindBaseCtrl targetCtrl){
      Map<String, PropertyBindSet> oneWayBindMap = targetCtrl.getAttrOneWayBindings();

      //Warn for unmatched bindings.
      Set<String> unMatched = oneWayBindMap.keys.toSet();
      unMatched.removeAll(_ctrl.propertyMap.keys);
      unMatched.forEach((final String s){
        _log.debug('_registerOneWayBindings - Literal or unmatched binding : ' + s + ', '
                    + oneWayBindMap[s].signatureDom);
      });
      if (unMatched.isNotEmpty){
        _updateTargetFromLiterals(targetCtrl, oneWayBindMap, unMatched.toList());
      }

      //Add bindings for node.
      mapUnionElement(_bindingToTargetProp, oneWayBindMap);
    });
  }

  void _updateTargetFromLiterals(final BindBaseCtrl targetCtrl,
                                 final Map<String, PropertyBindSet> oneWayBindMap, final List<String> literalsStr){

    const String STRING_TAG = '-string-';//Tag for mark of string literal.

    literalsStr.forEach((final String literalString) {

      if (literalString.startsWith(STRING_TAG)){
        //Tagged as type string.
        oneWayBindMap[literalString].value = literalString.substring(STRING_TAG.length);
      }
      else {

        try {
          Object objectFromJson = JSON.decode(literalString);
          _log.debug('_updateTargetFromLiterals - attr : ' + oneWayBindMap[literalString].signatureDom
              + ', with json decode object : ' + objectFromJson.toString());

          oneWayBindMap[literalString].value = objectFromJson;
        }catch (e){
          _log.error('_updateTargetFromLiterals - Exception : ' + e.toString());
          _log.error('_updateTargetFromLiterals attr : ' + oneWayBindMap[literalString].signatureDom
              + ', failed json decode of : ' + literalString);
        }
      }//else - Other literal than String.
    });
  }

  /// Interface IBindHandler ///
  bool get isNotEmpty => _bindingToTargetProp.isNotEmpty;

  /// Notification ///
  Set<String> updateProperties(final List<String> bindIds) {
    //Find common bindings to update.
    final Set<String> bindIdsInProp = bindIds.toSet().intersection(_bindingToTargetProp.keys.toSet());
    //For all host properties that is updated.
    Set<String> withDifValues = new Set<String>();
    bindIdsInProp.forEach((final String s) {
      //For this host property update all dependent target properties.
      _bindingToTargetProp[s].forEach((final PropertyBindSet p){
        if (p.value != _ctrl.propertyMap[s].value){
          p.value = _ctrl.propertyMap[s].value;
          withDifValues.add(s);
        }
      });
    });
    return withDifValues;
  }
}

//For a target node holds the binding info for notifying host.
class _TargetNodeTwoWayPropBind implements IBindHandler {

  static final LogMdcda _log = new LogMdcda.fromType(_TargetNodeTwoWayPropBind);

  final BindBaseCtrl _ctrl;//Node in target role.

  final BindBaseCtrl _twoWayBindHost;//Host node registering.

  final Map<String, String> _targetToHostSignatures;

  _TargetNodeTwoWayPropBind(final BindBaseCtrl this._ctrl, final BindBaseCtrl this._twoWayBindHost,
      final Map<String, String> this._targetToHostSignatures) {
    //Build the dependencies map. Done as target node. host is the two-way bind host, not this rolle as host.

    //Should match binded host property, unmatched are traced.
    Set<String> unMatchedBinds = _targetToHostSignatures.values.toSet();
    unMatchedBinds.removeAll(_twoWayBindHost.propertyMap.keys);
    if (unMatchedBinds.isNotEmpty){
      //Un matched bindings trace with warning
      unMatchedBinds.forEach((final String s) => _log.warn(' Unmatched bindings : ' + _targetToHostSignatures[s]));
      _log.warn('Full attribute bind map : ' + _targetToHostSignatures.toString());
      //By intention unmatched bindings aren't removed, just warned.
    }
  }

  /// Interface IBindHandler ///
  bool get isNotEmpty => _targetToHostSignatures.isNotEmpty;

  /// Notification ///
  Set<String> updateProperties(final List<String> bindIds) {
    //Find common bindings to update.
    final Set<String> bindIdsInProp = bindIds.toSet().intersection(_targetToHostSignatures.keys.toSet());
    bindIdsInProp.forEach((final String s) {
      _twoWayBindHost.twoWayNotifyFromTarget(_targetToHostSignatures[s], _ctrl.getBinding(s));
    });

    //This update method takes care of host properties updates so no target property updated.
    return new Set<String>();
  }

}