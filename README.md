# Graftcode Gateway (GG)

Native gateway that hosts your modules behind WebSocket, HTTP, optional TCP, and optional HTTP/2 servers. It can run **Graftcode Vision** (web UI) and the **Graftcode Module Analyzer (GMA)** for a graph view of loaded modules.


## Usage

All Graftcode Gateway CLI options are optional.

GG can be used just by launching it in a directory which contains the modules to host. By default, GG will scan the current directory for modules and try to detect the runtime. If you want to specify the modules and runtime explicitly, use the `--modules` and `--runtime` options.

See Known issues below for common pitfalls and troubleshooting tips, especially when communication with the gateway fails or modules are not loaded.

Run `gg --help` (or `gg.exe --help` on Windows) for the full CLI.

You may pass the main module path as the **first positional argument** instead of `--modules` (for example: `./gg ./MyApp.dll --port 8888`).

### Common options

| Option | Description |
|------------|-------------|
| `--projectKey` | JWT used for portal authentication and project metadata. Log in to Graftcode Portal (https://portal.graftcode.com/) to get your project key. |
| `--modules` | Comma-separated list of modules (DLLs, JARs, paths, etc.) |
| `--runtime` | Runtime to host: `auto`, `clr`, `netcore`, `java`, `jvm`, `python`, `python27`, `ruby`, `nodejs`, `php`, `perl` (default: `auto`) |
| `--endpoint` | Gateway endpoint URL (default: `https://grft.dev`) |
| `--port` | WebSocket server port (default: **80**) |
| `--httpPort` | HTTP server port for Graftcode Vision (default: **81**) |
| `--tcpPort` | TCP server port when `--tcpServer` is set (default: **82**) |
| `--http2Port` | HTTP/2 server port when `--http2Server` is set (default: **83**) |
| `--GV` | Host Graftcode Vision (default: **on**) |
| `--tcpServer` | Enable the TCP server |
| `--http2Server` | Enable the HTTP/2 server |
| `--types` | Comma-separated list of types to host |
| `--runApp` | Run the application entry point |
| `--mcpBaseClass` | Optional declaring type FQN for MCP `tools/call` resolution |
| `--noVersioning` | Disable versioning for hosted modules |
| `--doNotExtractBinaries` | Skip extracting bundled binaries (you supply them) |

### Runtimes (typical setups)

- **`auto`** — Let the GG detect the runtime (default)
- **`netcore`** — latest .NET (Core) runtime installed on machine. Supported versions: .NET Core 3.1, .NET 5 or newer
- **`clr`** — .NET Framework runtime installed on the machine; 4.7.2 or newer  
- **`java` / `jvm`** — Java installed on the machine; `JAVA_HOME` should point at the JDK; Java 8 or newer  
- **`python`** — Python 3 installed on the machine; Python 3.6 or newer
- **`python27`** — Python 2.7 installed on the machine
- **`ruby`** — Ruby 3 installed on the machine. Supported Ruby 3 or newer
- **`nodejs`** — Node.js 22 installed on the machine. Supported Node.js 22 or newer
- **`php`** — PHP 7.4 installed on the machine. Supported PHP 7.4 or newer

### Examples

```bash
./gg /path/to/your.dll --port 8888 --httpPort 8889
./gg /path/to/package/dir --port 8888 --httpPort=8889
./gg /path/to/your.jar --port 8888 --httpPort 8889
./gg /path/to/lib.dll --http2Server --http2Port 8989 --tcpServer --tcpPort 8990
```

## Environment variables

| Variable | Purpose |
|----------|---------|
| `GG_DEBUG` | Set to `1` or `TRUE` to log incoming and outgoing byte traffic to the console |
| `GSMU_ENDPOINT` | When set, overrides the gateway endpoint from `--endpoint` (default CLI value is `https://grft.dev`) |
| `GC_PROJECT_KEY` | JWT project key; when set, overrides `--projectKey` |


## Known issues
- If Graftcode Gateway does not respond on default ports, check if the ports are not blocked by firewall or used by other applications. You can also specify custom ports using `--port`, `--httpPort`, `--tcpPort`, and `--http2Port` options.
Default ports may require elevated permissions on some operating systems. If you encounter permission issues, try using a different ports.
Default port for Websocet is set to 80 to be easily accesible f.e. on web application without the need to specify port in the URL. If you are hosting a web application on the same machine, make sure to use different ports for the gateway and your application to avoid conflicts.

- If Graftcode Gateway is launched in auto mode it will try to detect the runtime based on the provided modules.

- If `--modules` are not specified, GG will scan current directory for modules to host. If current directory contains many different files, GG may fail to detect the runtime or load modules. To fix this, specify the modules explicitly or run GG in a directory with only the relevant modules.

- If you are hosting .NET Framework runtime (CLR) and your modules target .NET Core, GG may fail to load them. Make sure to use the appropriate runtime for your modules.

- If you are hosting Java runtime and your modules are not packaged as JAR files, GG may fail to load them. Make sure to package your Java modules as JAR files or specify the correct paths to the class files.

- If you are hosting Python runtime and your modules have dependencies that are not installed in the Python environment, GG may fail to load them. Make sure to install all required dependencies in the Python environment before hosting the modules.

- If you are hosting Ruby runtime and your modules have dependencies that are not installed in the Ruby environment, GG may fail to load them. Make sure to install all required dependencies in the Ruby environment before hosting the modules.

