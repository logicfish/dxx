# dxx
D language utility library and modular application framework


## Utils

Constants - stores the values defined during compilation as runtime constants, so that we can compare versions at runtime, in a dynamic library for example.

## Application framework

We can hot-load dynamic modules from files, using the "reloaded" library.
The module loader takes care of version-checking.

Plugins are dynamic modules with a class activator. A plugin application create a 
class extending PluginDefault, and override
the activation methods. A single instance of the class should be created to register the plugin.



