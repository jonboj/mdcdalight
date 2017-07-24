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

import '../util/log_mdcda.dart';

class AttrEventType {
  static const String CLICK = 'click';
  static const List<String> EVENT_LIST = const [CLICK];
}

abstract class ListenerAttrBinding {

  static final LogMdcda _log = new LogMdcda.fromType(ListenerAttrBinding);

  static const String ON_EVENT_PREFIX = 'on-';

  //From tag binding in html doc to the host class method.
  Map<String, EventListener> _listenerHandlerMap;

  //Map from binded target and event type to listener method.
  Map<String, String> _bindListenerMap = new Map<String, String>();

  //Cache build for event targets in tree of binded target.
  Map<Element, Element> _eventTartBindParentMap = new Map<Element, Element>();

  //List of target nodes with listener bindings
  List<Element> _bindedNodes = new List<Element>();

  void registerAttributeEventHandlers(final Element element, final List<String> eventTypes){
    eventTypes.forEach(
        (final String eventTypeStr){
          _bindedNodes.addAll(_addAttributeEventHandlers(element, eventTypeStr));
        });
  }

  void set listenerHandlers(final Map<String, EventListener> listenerHandler){
    _listenerHandlerMap = listenerHandler;
  }

  //Callback to added to listener.
  void handleDomEvent(Event event){
    _log.debug('handleDomEvent event target : ' + event.target.hashCode.toString() + ', ' + event.type);

    Element bindTarget = _getBindedTarget(event.target);

    if (bindTarget == null){
      //Binded parent not found, is not event for an attributebinding.
      _log.debug('handleDomEvent - event dont match a parent binding, type of event : ' + event.type);
      return;
    }

    //The element with the binding maps to the method.
    final String methodName = _bindListenerMap[_targetHashKey(event.type, bindTarget)];
    if (_listenerHandlerMap.containsKey(methodName)){
      _listenerHandlerMap[methodName](event);
      return;
    }

    //else received a non subscribed event, could be from other node.
  }

  List<Element> _addAttributeEventHandlers(final Element element, final String eventType){
    final String onEventType = ON_EVENT_PREFIX + eventType;
    final List<Element> nodes = element.querySelectorAll('[' + onEventType + ']:not([' + onEventType + '=""])');

    nodes.forEach((final Element e){
      _log.debug('_addAttributeEventHandlers - element with hashcode : ' + e.hashCode.toString());
      _log.debug('_addAttributeEventHandlers - element attributes : ' + e.attributes.toString());

      final String bindingStr = e.attributes[onEventType];
      _log.debug('Attribute with ' + onEventType + ', ' + e.hashCode.toString() + ' on : ' + bindingStr);
      if (_listenerHandlerMap.containsKey(bindingStr)){
        _bindListenerMap[_targetHashKey(eventType, e)] = bindingStr;
      }else {
        _log.warn('_addAttributeEventHandlers attribute binding to method not defined : ' + bindingStr);
      }
    });

    element.addEventListener(eventType, handleDomEvent);
    return nodes;
  }

  String _targetHashKey(final String eventType, final EventTarget target){
    return eventType + target.hashCode.toString();
  }

  Element _getBindedTarget(final Element eventTarget){

    //If cached use this. Initialized with null.
    if (_eventTartBindParentMap.containsKey(eventTarget)){
      return _eventTartBindParentMap[eventTarget];
    }

    //Loop to break with return when parent found.
    for (int i = 0; i < _bindedNodes.length; ++i){
      final Element e = _bindedNodes[i];
      if (e.contains(eventTarget)) {
        _eventTartBindParentMap[eventTarget] = e;
        return e;
      }
    }

    return null;
  }

}
