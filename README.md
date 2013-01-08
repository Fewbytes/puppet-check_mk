# check-mk

This is the check-mk module. This module installs and configures CheckMK monitoring system on top of Nagios.

## Usage
This module relies on Puppet 3.x hiera integration and will generally not need class parameters.
However, due to lack of support for per-modules hiera data in puppet 3.0.x 
hiera data yaml files (in data folder of the module) will need to be manually merged with your global hiera data.
This restriction should be lifted when puppet 3.1.x is out.

## License
Apache V2


## Contact


