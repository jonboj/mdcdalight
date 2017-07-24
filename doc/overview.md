# mdcdalight overview

mdcdalight is a [Polymer](https://www.polymer-project.org) inspired dart lib for wrapping of mdc web components with custom elements.

## Introduction

[mdc web](https://github.com/material-components/material-components-web) provides components implementing Material Design Components for the web. The mdc web components exposes interfaces for frameworks to these components. mdcdalight is a dart lib, that interfaces the mdc web components, using the simple approach [wrapping mdc vanilla components](https://github.com/material-components/material-components-web/blob/master/docs/integrating-into-frameworks.md#the-simple-approach-wrapping-mdc-web-vanilla-components). e.g. the mdc-web component `MDCTemporaryDrawer` is wrapped to a corresponding custom element `MdcTemporaryDrawerDart`.

mdcdalight provides functionality for:

* Wrapping a mdc web component with a custom element.

* Implement a custom element from a template html document.

* A Polymer inspired data binding system for custom elements.

Main focus in this document is on the html constructs and very brief on the dart constructs for bindings and custom elements.

## Custom Elements

A primer on Custom elements v1 https://developers.google.com/web/fundamentals/getting-started/primers/customelements
 or https://www.polymer-project.org/2.0/docs/devguide/custom-elements.

### Web components v0 vs v1

The dart sdk project is working on an update from web components v0 to v1, for status https://github.com/dart-lang/sdk/issues/27445.
mdcdalight is implemented with web components v0.
This section is a lineup of custom elements on a basic level without version specific details. The source code of mdcdalight uses the v0 api. v0 is legacy and in mdcdalight intended to be replaced with use of v1, when v1 becomes available.


## Bindings

Bindings are setup in the host template document. mdcdalight uses similar concepts of host and target elements as Polymer https://www.polymer-project.org/2.0/docs/devguide/data-binding. Next two sections describes how host and target concepts are used in mdcdalight. A custom element can be created from a template element specified in a html document. Cases where the element isn't created from a template element is a simplification and hence covered by the template case. Similar in a general case a custom element instance has both host and target roles.

### Roles of custom element instances

An instance of a custom element can have both host and target role. Same instance can be target of an other element and can it self host other target elements.

#### Host role

A custom element e.g. `my-elem` only has one host role template specification, specified by the corresponding template element from which it is created. In mdcdalight by html doc `my_elem.html`. The template elements subnodes can be instances of custom elements with bindings, these elements are the target elements.

#### Target role

A custom element sub node in the template element for a host element.

### Example with roles

Concept of host / target roles is illustrated below with a little example. mdcdalight name convention for custom elements is used in the example.

`my-elem` host role with targets `elem-a` and `elem-b`:
``` html
<!-- my_elem.html -->
<template>
  <elem-a></elem-a>
  <elem-b></elem-b>
</template>
```

host `elem-ha` with two instances of `my-elem` :
``` html
<!-- elem_ha.html -->
<template>
  ...
  <my-elem></my-elem>
  ...
  <my-elem></my-elem>
  ...
</template>
```
host `elem-hb` with one instance of `my-elem` :
``` html
<!-- elem_hb.html -->
<template>
  <my-elem></my-elem>
</template>
```

For custom elements the template docs are specifications of elements, instances are created by html docs as normal native elements. e.g. the `index.html` below results in 4 instances of `my-elem` each instance has an instance of `elem-a` and `elem-b`

``` html
<!-- index.html -->
<body>
  <my-elem></my-elem>
  <elem-ha></elem-ha>
  <elem-hb></elem-hb>  
</body>
```

### Binding types

Bindings are specified in the template html of the host. 4 types of bindings are implemented:

* Listener binding. In attribute of a target element register a host method as handler.

* One-way binding to sub text node `...[[v1]]...`. Bind a host property `v1` to content of a text node.

* One-way binding to target element property `a="[[v1]]"`. Bind a host property to a target property, update from host to target.    

* Two-way binding to target element property `a="{{v1}}"`. Bind a host property to a target property, update both from host to target and opporsite way. ( _In current version is only implemented target to host update. Update from host to target is given prio to be implemented later._ )


#### Listener Binding

Provides a subset of https://www.polymer-project.org/2.0/docs/devguide/events. Current only support for the `click` event and `MdcdaEvent`s. Subscription and binding is based on the event typename, so extending to other eventtypes should be straight ahead. By setting target attribute with `on-` prefix, events emitted by the target element will trigger the named method at the host. In example below `click` on `elem-a` invokes `incCounter` on `my-elem`, on `elem-b` invokes `decCounter`.

``` html
<!-- my_elem.html -->
<template>
  <elem-a on-click="incCounter"></elem-a>
  <elem-b on-click="decCounter"></elem-b>
</template>
```

#### One way binding to text nodes

This type of binding is setup by inserting name of the property between `[[` and `]]`. Text content of node is composed with value of `.toString()` for the binded host element property.

`BindBaseCtrl.updateProps` on the host element updates content of binded text node.

``` html
<!-- my_elem.html -->
<template>
  Name : [[firstname]]
</template>
```

#### One way binding to target element property

This type of binding is setup in the attribute list of the target element. The name of the target property is set as attribute name, while the value of the attribute specify the host property. e.g. with target property `a` and host property `v` it becomes `a="[[v]]"`.  The two properties should have same type, alternatively a corresponding assignment operator defined for the target type.

`BindBaseCtrl.updateProps` on the host element updates the binded target property `a` with the value of host property `v`.

``` html
<!-- my_elem.html -->
<template>
  <elem-t a="[[v]]"></elem-t>
</template>
```

#### Two way binding to target element property

This type binding is setup by in the attribute list of the target element. The name of the target property is set as attribute name, while the value of the attribute specify the host property. e.g. with target property `a` and host property `v` it becomes `a="{{v}}"`. The two properties should have same type, alternatively corresponding assignments operators defined.

Update to the target property is done similar to one way binding. (_not supported, will be implemented later_)

Host property update is done in two steps. First `BindBaseCtrl.updateProps` on the target element notify the binded host property.
Afterwards the host property is updated with `BindBaseCtrl.updateProps` on the host element, this will update host property `v` with value of target property `a`.  

``` html
<!-- my_elem.html -->
<template>
  <elem-t a="{{v}}"></elem-t>
</template>
```

## mdc web wrap

mdcdalight expose classes for wrapping [mdc web vanilla components](https://github.com/material-components/material-components-web/blob/master/docs/integrating-into-frameworks.md#the-simple-approach-wrapping-mdc-web-vanilla-components) with dart custom elements. In mdc web a component is implemented with javascript/css or only css. Some of mdc-web css only components don't fit to an interpretation as a html element, e.g. `mdc-theme`. The three different types are listed in following sections.

### mdc web only css - style import

mdc-web components like `mdc-theme`, `mdc-typography`, `mdc-elevation` don't map well to a html-element. And for some like `mdc-list` no significant benefits are obtained by mapping to a html-element. These mdc-components are used in mdcdalight by import of the css styles. 

### mdc web only css
`MDCButton` is an example of a mdc-web component only implemented with css, it hasn't a `index.js` or `foundation.js` see [mdc-button implementation](https://github.com/material-components/material-components-web/blob/master/packages/mdc-button).

 This category benefits of functionality from a mapping to `HtmlElement` or a subtype of it, like `ButtonElement`. 
This type of components are wrapped by extending from `HtmlElement` or a subtype and in `created` method adding the css style using `classes.add`


### mdc web javascript

`MDCTemporaryDrawer` is an example of a component with javascript functionality, [mdc-drawer/temporary](https://github.com/material-components/material-components-web/blob/master/packages/mdc-drawer/temporary)

This category of components are wrapped by interfacing with a js-interop object e.g `MdcTemporaryDrawerDart` contains an instance of the js-interop object `MDCTemporaryDrawer` with the interface below.

``` dart
@JS()
class MDCTemporaryDrawer {
  external factory MDCTemporaryDrawer(final Element e);
  external void set open(final bool state);
  external bool get open;
}
```

### Import of components from mdc web

The wrapped components implemented in mdcdalight serves for demo and tutorial.
In order to make the maintainment more sustainable, the import is done by the developer.
 
The `css` and `js` files are build with the mdc-web build, see [how to doc](mdcwebimport.md) for a step by step walkthrough.

## Design decisions

A summary of some of the design decisions chosen in mdcdalight.

###### Buildtime evaluation

For performance and transparency in design, prioritize a design when possible compile/build evaluation is chosen instead of runtime instantiation.

###### Use web api

When possible use web api e.g. `import` and `querySelector` instead of direct file processing.

###### Instrumentation of bindings with mixin

Kept from initial phase of prototyping is using of mixin for instrumentation of the element properties. In a later phase maybe consider to be refactored to annotations. Instrumentation of bindings with mixin adds complexity of boilerplate code, but contributes with some benefits. Considered to cut download loadtime of app, more transparent to debug, understand and handle by tools.

###### Import from mdc web by developer

The github repo for mdcdalight only has illustrative demo/tutorial imports and wrapping of the mdc web components. As an alternative to a full import a detailed and updated step by step description is provided. Even with regular full versionized imports/wraps of components from mdc web, a developer needs to follow documentation, versioning, issues, releases schedules etc. from mdc web. Hence most optimal if the relationship and import is as transparent to the developer as possible. In an optimal workflow the imported `css` and `js` files are buildproducts from the mdc-web project. 

###### Use light DOM

At creation of an element the content is appended into light DOM. This could be reconsidered in a later version. One reason for this initial decision is that mdc web styling and theming is based on light DOM, not obvious how this should be transfered into the shadow DOMs of custom elements. Additional web components v0 and v1 differs significant for shadow DOM. So here a pragmatic approach is used staying with light DOM, with option for refactor if e.g. Polymer 2 presents a design applicable to mdcdalight.

###### Use of closure references

Bindings between element properties are implemented by wrapping a class member with a closure, which expose `set`/`get` methods, this simplifies some of the design. Benchmarking shows that for more complex types, only a neglible performance penalty is introduced. Measurements without DOM interaction, shows when handling a closure to e.g. a `Map` with a `String` the performance penality becomes around 10%. With DOM interaction, the relative contribution will decrease.     

## What is next

###### Optimized release builds
For performance the html/css/js files in a build should be bundled and minimized. 

Until web components v1 becomes available, the project will be in a consolidation and refinement phase of existing functionality. It is stated that v1 could be revealed together with a ddc/bazel solution, this implies a major refactor of the dev and build environment. So until this solution becomes available, minor effort is put into release builds and optimization of dev builds. 

###### mdcda elements

The mdc-web components provides basecomponents. For development of apps, components with more complex logic are needed, similar to some of the Polymer elements. For the `daflight` app two components are designed, but other types of apps will need more.

###### generated bind mixins

In current version properties with bindings are instrumented with coded mixins, this is a mechanical process and intended to be replaced with a solution implemented with e.g. `source_gen`, `code_builder` or other tool. To integrate a tooled instrumentation of the bindings is postponed until web components v1 becomes available.

###### computed bindings

A basis structure for computed bindings is implemented and unit tested. Full integration is set later until upgrade of web components from v0 to v1 and tooling of bind mixins for property bindings is implemented.   