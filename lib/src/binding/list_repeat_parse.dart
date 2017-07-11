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

import 'binding_types.dart';
import 'binding_parser.dart';


abstract class IListItemBind {
  static const String LIST_ITEM_STR = 'item';
  static const String LIST_ITEM_DOT_STR = 'item.';//Dot for member access operator.

  Map<String, PropertyBind> bindListAt();
}

PropertyBind<T> bindAtFactory<T>(final String signatur, T t){
  return new PropertyBind(IListItemBind.LIST_ITEM_DOT_STR + signatur, () => t);
}

Map<String, PropertyBind> buildAccessMap(final List<PropertyBind> l){
  Map<String, PropertyBind> accessMap = new Map<String, PropertyBind>();
  l.forEach((final PropertyBind p){ accessMap[p.signatureDom] = p; });
  return accessMap;
}

Map<String, PropertyBind> buildBindMap<T>(final List<T> l, int i){

  //Structured types.
  if (l.first is IListItemBind){
    return (l[i] as IListItemBind).bindListAt();
  }

  //Unstructured type.
  return {IListItemBind.LIST_ITEM_STR : new PropertyBind(IListItemBind.LIST_ITEM_STR, () => l[i])};
}

Node buildStampedNodeFromList<T>(final DocumentFragment content, final List<NodeBindWrap> contentWrap,
                                 final List<T> dataList, final int index){

  contentWrap.forEach((final NodeBindWrap nw){
    nw.updateContent((final String s) => buildBindMap(dataList, index)[s]);
  });
  return content.clone(true);
}

List<Node> buildStampNodeList<T>(final DocumentFragment content, final List<T> dataList){

  final DocumentFragment contentClone = content.clone(true);
  List<Node> nodeList = new List<Node>();
  Map<String, List<NodeBindWrap>> wrappedContentMap = BindingParser.wrapTextNodes(contentClone);

  //Collect all in one list. //TODO consider for optimization only update for subset of binds.
  List<NodeBindWrap> wrappedContentList = new List<NodeBindWrap>();

  //Unique with toSet().
  wrappedContentMap.values.toSet().toList().forEach((final List<NodeBindWrap> l){wrappedContentList.addAll(l);});

  for (int i = 0; i < dataList.length; ++i){
    Map<String, PropertyBind> bindMap = buildBindMap(dataList, i);

    //TODO not nessecary with check of all list elements.
    if (!bindMap.keys.toSet().containsAll(wrappedContentMap.keys)){
      final LogMdcda _log = new LogMdcda('list_repeat_parse.buildStampNodeList');

      _log.warn('buildStampNodeList warning unmatched binding, template : ' + wrappedContentMap.keys.toString());
      _log.warn('buildStampNodeList warning unmatched binding, datastructure : ' + bindMap.keys.toString());
    }

    nodeList.add(buildStampedNodeFromList(contentClone, wrappedContentList, dataList, i));
  }

  return nodeList;
}