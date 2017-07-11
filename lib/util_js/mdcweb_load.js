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

const PACKAGE_DIR = 'packages/mdcdalight/mdc_web_js_v0_15_0/';

var MDCSnackbar;
require([PACKAGE_DIR + 'mdc.snackbar'], mdcSnackbar => {
    const MDCSnackbarLoc = mdcSnackbar.MDCSnackbar;
    const MDCSnackbarFoundation = mdcSnackbar.MDCSnackbarFoundation;
    MDCSnackbar = MDCSnackbarLoc;
    console.log('mdcweb_load.js - loaded : mdc.snackbar');
});

var MDCRipple;
require([PACKAGE_DIR + 'mdc.ripple'], mdcRipple => {
    const MDCRippleLoc = mdcRipple.MDCRipple;
    const MDCRippleFoundation = mdcRipple.MDCRippleFoundation;
    MDCRipple = MDCRippleLoc;
    console.log('mdcweb_load.js - loaded : mdc.ripple');
});

var MDCTemporaryDrawer;
require([PACKAGE_DIR + 'mdc.drawer'], mdcDrawer => {
    const MDCTemporaryDrawerLoc = mdcDrawer.MDCTemporaryDrawer;
    const MDCTemporaryDrawerFoundation = mdcDrawer.MDCTemporaryDrawerFoundation;
    const util = mdcDrawer.util;
    MDCTemporaryDrawer = MDCTemporaryDrawerLoc;
    console.log('mdcweb_load.js - loaded : mdc.drawer');
});

var MDCSimpleMenu;
require([PACKAGE_DIR + 'mdc.menu'], mdcMenu => {
    const MDCSimpleMenuLoc = mdcMenu.MDCSimpleMenu;
    const MDCSimpleMenuFoundation = mdcMenu.MDCSimpleMenuFoundation;
    MDCSimpleMenu = MDCSimpleMenuLoc
    console.log('mdcweb_load.js - loaded : mdc.menu');
});

var MDCTextfield;
require([PACKAGE_DIR + 'mdc.textfield'], mdcTextfield => {
    const MDCTextfieldLoc = mdcTextfield.MDCTextfield;
    const MDCTextfieldFoundation = mdcTextfield.MDCTextfieldFoundation;
    MDCTextfield = MDCTextfieldLoc;
    console.log('mdcweb_load.js - loaded : mdc.textfield');
});
