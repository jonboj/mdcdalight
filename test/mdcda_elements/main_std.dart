import 'dart:html';

import "package:test/test.dart";

import '../../lib/src/util/load_sync_starter.dart';

import '../../lib/src/mdcda_elements/mdcda_list_select.dart';

import 'host_elem.dart';

main() async {
  print('======= Start of mdcda-repeat test =======');
  MdcdaListSelect.registerElement();
  HostElem.registerElement();

  const List<String> HTML_FILES = const ['packages/mdcdalight/mdcda_elements/mdcda_list_select.html',
                                         'host_elem.html'];
  await new LoadSyncStarter().startLoadOfElement(startUnitTest, HTML_FILES);
  print('======= End of mdcda-repeat test =======');
}

//For debug on failing unit test mdcda_elements.
//lTarget contains an instance of MdcdaListSelect with isn't not a BindBaseCtrl, this doesn't match declaration of
//MdcdaListSelect. Suspect somehow malcreated instance.

//////// From method BindBaseCtrl._targetElementsWithAttributeBind ///////
//    lTarget.forEach((final Element e) {
//      if (e is BindBaseCtrl){
//        _log.debug(() => '_targetElementsWithAttributeBind e is BindBaseCtrl : ' + e.runtimeType.toString());
//      }
//    });


void startUnitTest(){
  print('main_std::startUnitTest()');
  HostElem hostElem = document.body.querySelector('host-elem');
  MdcdaListSelect repElemInt = document.getElementById('id_int');
  //MdcdaListSelect repElemString = document.getElementById('id_string');
  //MdcdaListSelect repElemPerson = document.getElementById('id_person');

  test("Get mdcda-repeat int", () {
    hostElem.updateProps([HostElemPropBind.LIST1]);
    expect(repElemInt, isNotNull);
  });

  test("Get mdcda-repeat int got dataList", () {
    expect(repElemInt.dataList, [101, 0, -77]);
  });

//  test("Get mdcda-repeat string", () {
//    expect(repElemString, isNotNull);
//  });
//
//  test("Get mdcda-repeat string got dataList", () {
//    expect(repElemString.dataList, ['light', 'stronger', 'hot', 'burning', 'melting!']);
//  });
//
//  test("Get mdcda-repeat person", () {
//    expect(repElemPerson, isNotNull);
//  });
//
//  test("Get mdcda-repeat person got dataList", () {
//    expect(repElemPerson.dataList[0].name, new Person('Hans', 13).name);
//    expect(repElemPerson.dataList[1].name, new Person('Grete', 111).name);
//  });
//
//  test("Test list nodes in body - int", () {
//    List<Node> nl = document.body.querySelectorAll('.int-type');
//    expect(nl.length, 3);
//  });
//
//  test("Test list nodes in body - string", () {
//    List<Node> nl = document.body.querySelectorAll('.string-type');
//    expect(nl.length, 5);
//  });
//
//  test("Test list nodes in body - person", () {
//    List<Node> nl = document.body.querySelectorAll('.person-type');
//    expect(nl.length, 2);
//  });
//
//  test("Test add Person to list", () {
//    hostElem.addPerson(new Person('Mr. Jr. new', 71));
//    List<Node> nl = document.body.querySelectorAll('.person-type');
//    expect(nl.length, 3);
//  });

}



