# GraftcodeGateway

## Usage

Type ./gg --help to display help

To use Graftcode Gateway (GG), run the executable with the appropriate command line options:

- `--projectName`: Project name (can be custom or taken from Graftcode Portal)
- `--runtime` : Runtime to be hosted
- `--modules` : Comma-separated list of modules/libraries to be loaded
- `--port` : port used for communication (default: 80)
- `--GV` : Use Graftcode Module Azalyzer to analyze and dislay Graftcode Vision (graphic representation of your modules)
- `--httpPort` : port used for hosting Graftcode Vision (default:81)
- `--mcpBaseClass` : name of class which contains static method to be used by MCP Client 

Available runtimes:
- `netcore` - GG hosts latest .NET installed on machine, supported .NET Core 3.1 or newer
- `clr` - GG hosts latest .NET Framework installed on machine, supported .NET Core 4.7.2 or newer
- `java` - GG hosts Java Runtime installed on machine and pointed by JAVA_HOME environment variable, supported JAVA 1.8 or newer
- `python` -- GG hosts latest Python installed on machine, supported Python 3.6 or newer 
- `ruby` -- GG hosts Ruby installed on machine, supported Ruby 3
- `nodejs` -- GG hosts Node.js installed on machine, supported Node.js 20 or newer
- `php` -- GG hosts PHP installed on machine, supported PHP 7.4 or newer
- `perl` -- GG hosts Perl installed on machine
- `python2` -- GG hosts Python2 installed on machine

Example usage:

- `./gg --runtime netcore --modules /path/to/your.dll --GV --port 8888 --httpPort 8889`
- `./gg --runtime python --modules /path/to/directory/with/modules --GV --port 8888 --httpPort=8889`
- `./gg --runtime java --modules /path/to/your.jar --GV --port 8888 --httpPort=8889`
- - `./gg --runtime netcore --modules /path/to/your.dll --GV --port 8888 --httpPort 8889 --mcpBaseClass Mynamespace.MyClass`


The following environment variable are applicable:

- `GG_DEBUG`: Enable console logging of all incoming and outgoing byte arrays. To enable logging to console set it to "1"
