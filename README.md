Python for iOS
--------------

Please see README.orig for original copyright notices, information about
Python, etc.

This is an attempt to make Python buildable for embedding into iOS projects.

It is not an attempt to bring the full python environment over, but rather, a subset useful for most embedded tasks and compliant with the Apple Developer
Rules.

AT THIS TIME WE HAVE NOT DONE ANY SIGNIFICANT TESTING TO VERIFY THE LIBRARY'S FUNCTION OR THAT IT PASSES THE APPSTORE RULES.  USE THIS ENTIRELY AT YOUR OWN RISK.

License
-------
This is released under the Python license (see LICENSE).

Changes made are documented below.

Usage
-----

  1. Reference the xcode project in your app.
  
  2. Customise Modules/Setup if you need to add more binary modules to your interpreter
  
  3. Add libPython27.a and libz.dylib to your target's "Link Binary with Libraries" stage.
  
  4. Copy the python code you need (you need a site module at the absolute minimum) into a "Python" subdirectory of your app's resources directory.
  
Changes Made
------------

 * added iOS directory with Xcode project to build python.
 * Set up an initial module setup file (Modules/Setup) which brings in as much of the core as we could fudge together for now
 * Created a basic test that runs under the iOS simulator to make sure the interpreter links and runs without segfaulting.
 * Replaced getpath.c with a version that hardcodes the search prefix into the application bundle
  
TODO
----
 * Get a basic testsuite together to confirm that the interpreter is working correctly.
 * Work out a better way to allow users to customise the static module linkage for their projects
 * get sqlite module working
 * work out what the smallest sensible python library is for embedding
 * Write script/tool to compile python bytecode and add it to the application bundle
 * Patch the import methods so compiled bytecode gets written to an appropriate location.
 * Change the runtime default to not save bytecode on actual devices (as code should be put into the bundle, precompiled).
 * Patch the new getpath.m so it searches the bytecode output location.
 
