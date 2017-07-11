
import 'dart:html';
import "package:test/test.dart";

import '../../../lib/src/binding/binding_parser.dart';

import 'test_mock_element.dart';


void BindingTypesTest(){

  ElemMock e = new ElemMock();

  group("Binding Types - references", (){

    test("Property binding before update", () {
      expect(e.v1, isNull);
    });

    test("Property int binding after update", () {
      e.v1 = 17;
      expect(e.getBind(0).value, 17);
    });

    test("Property string binding after update", () {
      e.s2 = 'e.s2';
      expect(e.getBind(1).value, 'e.s2');
    });

    test("Property computed before update", () {
      expect(e.getBind(2).value, 'e.s2 composedStr with : 17');
    });

    test("Property computed after update", () {
      e.prefix = '=>';
      expect(e.getBind(2).value, '=>e.s2 composedStr with : 17');
    });

  });

  group("Binding Types - int ", (){
    const String HTML_ID_INT_NODE = 'id_int_node';
    TemplateElement tempE = document.getElementById(HTML_ID_INT_NODE);

    List<BaseToken> lTokens = BindingParser.parseTokensStr(tempE.content.text);

    ElemMock e2 = new ElemMock();

    test("Second token is binding v1", () {
      e2.v1 = 31;
      expect(lTokens[1].idStr, 'v1');
    });

    test("Second token is binding v1", () {
      expect(lTokens[1].idStr, 'v1');
    });

    test("Value of v1 before update", () {
      e2.v1 = 31;
      expect(e2.getBindStr('v1').value, 31);
    });

    test("Content of node with int binding", () {
      e2.v1 = 31;
      NodeBindWrap nodeBindWrap = new NodeBindWrap(tempE, lTokens);
      nodeBindWrap.updateContent(e2.getBindStr);
      expect(tempE.text, 'Int solo 31');

      e2.v1 = 505;
      nodeBindWrap.updateContent(e2.getBindStr);
      expect(tempE.text, 'Int solo 505');
    });

  });


  group("Binding Types - string ", (){
    const String HTML_ID_STRING_NODE = 'id_string_node';
    TemplateElement tempE = document.getElementById(HTML_ID_STRING_NODE);

    List<BaseToken> lTokens = BindingParser.parseTokensStr(tempE.content.text);

    ElemMock e2 = new ElemMock();
    e2.s2 = 'str2';

    test("Second token is binding s2", () {
      expect(lTokens[1].idStr, 's2');
    });

    test("Value of s2 before update", () {
      e2.s2 += ' :-)';
      expect(e2.getBindStr('s2').value, 'str2 :-)');
    });

    test("Content of node with string binding", () {
      NodeBindWrap nodeBindWrap = new NodeBindWrap(tempE, lTokens);
      nodeBindWrap.updateContent(e2.getBindStr);
      expect(tempE.text, 'String solo str2 :-)');

      e2.s2 = 'end of story';
      nodeBindWrap.updateContent(e2.getBindStr);
      expect(tempE.text, 'String solo end of story');
    });

  });

  group("Binding Types - computed ", (){
    const String HTML_ID_COMPUTED_NODE = 'id_computed_node';
    TemplateElement tempE = document.getElementById(HTML_ID_COMPUTED_NODE);

    List<BaseToken> lTokens = BindingParser.parseTokensStr(tempE.content.text);

    ElemMock e2 = new ElemMock();

    test("Second token is binding ", () {
      expect(lTokens[1].idStr, 'composedStr(prefix)');
    });

    test("Value of s2 before update", () {
      e2.v1 = 101;
      e2.s2 += ' :-)';
      expect(e2.getBindStr('composedStr(prefix)').value, ' :-) composedStr with : 101');
    });

    test("Content of node with string binding", () {
      NodeBindWrap nodeBindWrap = new NodeBindWrap(tempE, lTokens);
      nodeBindWrap.updateContent(e2.getBindStr);
      expect(tempE.text, 'Computed solo  :-) composedStr with : 101');

      e2.prefix = '=>';
      nodeBindWrap.updateContent(e2.getBindStr);
      expect(tempE.text, 'Computed solo => :-) composedStr with : 101');
    });

  });

  group("Binding Types - combined ", (){
    const String HTML_ID_COMBINED = 'id_combined_node';
    TemplateElement tempE = document.getElementById(HTML_ID_COMBINED);

    List<BaseToken> lTokens = BindingParser.parseTokensStr(tempE.content.text);

    ElemMock e2 = new ElemMock();
    e2.v1 = -90;
    e2.s2 = ':-)';
    e2.prefix = '>';

    test("Content of node with combined bindings", () {
      NodeBindWrap nodeBindWrap = new NodeBindWrap(tempE, lTokens);
      nodeBindWrap.updateContent(e2.getBindStr);
      expect(tempE.text, 'Combined >:-) composedStr with : -90 from :-) , -90');
    });
  });

  group("Binding Types - nested int | ", (){
    const String HTML_ID_NESTED_NODE = 'id_nested_int_node';
    TemplateElement tempE = document.getElementById(HTML_ID_NESTED_NODE);

    ElemMock e2 = new ElemMock();
    e2.v1 = -90;
    e2.s2 = ':-)';
    e2.prefix = '>';

    DivElement divE = document.getElementById('id_container');
    divE.append(tempE.content.clone(true));
    Map<String, List<NodeBindWrap>> bindMap = BindingParser.wrapTextNodes(divE);

    test("Test number of bindings in nested node", () {
      expect(bindMap.keys, ['v1']);//A binding with 'v1'
    });

    test("Test number of references to binding nested node", () {
      expect(bindMap['v1'].length, 3);//Referenced by three nodes.
    });

    //Update all nodes which the binding referes to.
    test("Test update of nested node", () {
      bindMap['v1'].forEach((final NodeBindWrap nB) => nB.updateContent(e2.getBindStr));
      expect(bindMap['v1'][0].nodeText, 'div -90 text');
      expect(bindMap['v1'][1].nodeText, 'span -90 text');
      expect(bindMap['v1'][2].nodeText, 'a -90 text');
    });

    //Update all nodes which the binding referes to.
    test("Test update of nested node", () {
      e2.v1 = 1001;
      bindMap['v1'].forEach((final NodeBindWrap nB) => nB.updateContent(e2.getBindStr));
      expect(bindMap['v1'][0].nodeText, 'div 1001 text');
      expect(bindMap['v1'][1].nodeText, 'span 1001 text');
      expect(bindMap['v1'][2].nodeText, 'a 1001 text');
    });
  });

  group("Binding Types - nested mixed ", (){
    const String HTML_ID_MIXED_NODE = 'id_nested_mixed_node';
    TemplateElement tempE = document.getElementById(HTML_ID_MIXED_NODE);

    ElemMock e2 = new ElemMock();
    e2.v1 = -90;
    e2.s2 = ':-)';
    e2.prefix = '>';

    DivElement divECon = document.getElementById('id_container');
    DivElement divE = new DivElement();
    divECon.append(divE);//Get a new fresh div element.
    divE.append(tempE.content.clone(true));
    Map<String, List<NodeBindWrap>> bindMap1 = BindingParser.wrapTextNodes(divE);

    test("Test number of bindings in nested node", () {
      expect(bindMap1.keys, ['composedStr(prefix)', 's2', 'v1']);
    });

    test("Test number of references to binding nested node", () {
      expect(bindMap1['s2'].length, 1);//Referenced by three nodes.
    });

    //Update all nodes which the binding referes to.
    test("Test update of nested node 1", () {
      bindMap1['v1'].forEach((final NodeBindWrap nB) => nB.updateContent(e2.getBindStr));
      bindMap1['s2'].forEach((final NodeBindWrap nB) => nB.updateContent(e2.getBindStr));
      bindMap1['composedStr(prefix)'].forEach((final NodeBindWrap nB) => nB.updateContent(e2.getBindStr));
      expect(bindMap1['composedStr(prefix)'][0].nodeText, 'div >:-) composedStr with : -90 text');
      expect(bindMap1['s2'][0].nodeText, 'span :-) text');
      expect(bindMap1['v1'][0].nodeText, 'a -90 text');
    });

    //Update all nodes which the binding referes to.
    test("Test update of nested node 2", () {
      e2.v1 = 71;
      e2.s2 = ':-D';
      e2.prefix = '=>';

      bindMap1['v1'].forEach((final NodeBindWrap nB) => nB.updateContent(e2.getBindStr));
      bindMap1['s2'].forEach((final NodeBindWrap nB) => nB.updateContent(e2.getBindStr));
      bindMap1['composedStr(prefix)'].forEach((final NodeBindWrap nB) => nB.updateContent(e2.getBindStr));
      expect(bindMap1['composedStr(prefix)'][0].nodeText, 'div =>:-D composedStr with : 71 text');
      expect(bindMap1['s2'][0].nodeText, 'span :-D text');
      expect(bindMap1['v1'][0].nodeText, 'a 71 text');
    });
  });

}