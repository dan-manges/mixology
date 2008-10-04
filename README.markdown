mixology
========

a gem that allows objects to effectively mixin and unmix modules

installation
------------

    gem install mixology

usage
-----

    require "mixology"
    
    mixin = Module.new { def foo; "foo from mixin"; end }
    object = Class.new { def foo; "foo from object"; end }.new

    object.mixin mixin
    object.foo #=> "foo from mixin"
    
    object.unmix mixin
    object.foo #=> "foo from object"
    
that's pretty much it. for other examples, take a look at the tests.

implementations
---------------

* MRI 1.8.x
* JRuby 1.1.x

collaborators
-------------

* [Patrick Farley](http://www.klankboomklang.com/)
* anonymous z
* [Dan Manges](http://www.dcmanges.com/blog)
* Clint Bishop

source
------

hosted on [github](http://github.com/dan-manges/mixology/tree/master)

license
-------

released under [Ruby's license](http://www.ruby-lang.org/en/LICENSE.txt)
