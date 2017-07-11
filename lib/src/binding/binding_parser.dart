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

import '../util/utils.dart';
import 'binding_types.dart';

abstract class BaseToken {
  final String idStr;
  const BaseToken(final String this.idStr);
}

//String id used as literal content.
class LiteralToken extends BaseToken {
  const LiteralToken(final String idStr):super(idStr);
}

//String id used as reference to binded host property.
class BindingToken extends BaseToken {
  const BindingToken(final String idStr):super(idStr);
}

const bindTokenFilter = const TypeFilter<BindingToken, BaseToken>();

//Wraps a node of type text.
class NodeBindWrap {
  final Node _n;
  final List<BaseToken> _contentTokens;

  NodeBindWrap(final Node this._n, final List<BaseToken> this._contentTokens);

  String get nodeText => _n.text;

  set nodeText(final String s){ _n.text = s; }

  //bindingsMap is the host elements registery of the bindings.
  updateContent(getBindFromStr_t getF){
    String s = '';
    _contentTokens.forEach((final BaseToken tok){
      if (tok is LiteralToken){
        s += tok.idStr;
      }

      if (tok is BindingToken){
        s += getF(tok.idStr).value.toString();
      }
    });
    _n.text = s;
  }

  List<BindingToken> getBindingTokens(){
    //Filter to only BindingToken
    return bindTokenFilter.list(_contentTokens);
  }
}

class BindingParser {

  static const String LEFT_TAG = '[[';
  static const String RIGHT_TAG = ']]';

  //static final RegExp REG_EXP_ANN = new RegExp(r'\[\[\w+\]\]');//[[word]]
  static final RegExp REG_EXP_ANN = new RegExp(r'\[\[\w+\.?\w+(\([\w\,\ ]*\))?\]\]');////[[word]] optional (arglist)

  static List<BaseToken> parseTokensStr(final String str){

    if (str.indexOf(REG_EXP_ANN).isNegative){
      //No annotation found, no binding.
      return [];//A solo literal is no binding and represented with empty set.
    }

    List<BaseToken> listTokens = new List<BaseToken>();
    String parseStr = str;
    while (parseStr.isNotEmpty){
      final int indexFirstAnn = parseStr.indexOf(REG_EXP_ANN);

      if (indexFirstAnn.isNegative){
        //No more annotations
        listTokens.add(new LiteralToken(parseStr));
        parseStr = '';
      }

      if (indexFirstAnn > 0){
        //A literal before annotation
        //Optimization could be done since annotation already found.

        listTokens.add(new LiteralToken(parseStr.substring(0, indexFirstAnn)));
        parseStr = parseStr.substring(indexFirstAnn);
      }

      if (indexFirstAnn == 0){
        //Next part is an annotation
        final int indexRightTag = parseStr.indexOf(RIGHT_TAG);
        final String annTag = parseStr.substring(LEFT_TAG.length, indexRightTag);
        listTokens.add(new BindingToken(annTag));
        parseStr = parseStr.substring(indexRightTag + RIGHT_TAG.length);
      }
    }

    return listTokens;
  }

  //Wrap text node which contains bindings with a binding representation.
  //The binding is represented by a String id.
  static Map<String, List<NodeBindWrap>> wrapTextNodes(final Node node){

    Map<String, List<NodeBindWrap>> mNodes = new Map<String, List<NodeBindWrap>>();

    if (node.nodeType == Node.TEXT_NODE){
      //build the content binding.
      List<BaseToken> lNodeTokens = parseTokensStr(node.text);
      if (lNodeTokens.isNotEmpty){
        //This text node contains bindings.
        NodeBindWrap nW = new NodeBindWrap(node, lNodeTokens);
        List<BindingToken> lBindings = nW.getBindingTokens();

        //Setup mapping to the wrapped node.
        lBindings.forEach((final BindingToken bt){
          mNodes.putIfAbsent(bt.idStr, () => new List<NodeBindWrap>());
          mNodes[bt.idStr].add(nW);
        });
      }
    }
    //Recurse into child nodes.
    node.childNodes.forEach((final Node n) => mapUnionList(mNodes, wrapTextNodes(n)));
    return mNodes;
  }


}