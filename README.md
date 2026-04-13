# Graftcode Gateway (GG)

Native gateway that hosts your modules behind WebSocket, HTTP, optional TCP, and optional HTTP/2 servers. It can run **Graftcode Vision** (web UI) and the **Graftcode Module Analyzer (GMA)** for a graph view of loaded modules.


## Usage

Run `gg --help` (or `gg.exe --help` on Windows) for the full CLI.

You may pass the main module path as the **first positional argument** instead of `--modules` (for example: `./gg ./MyApp.dll --port 8888`).

### Common options

| Option | Description |
|--------|-------------|
| `--runtime` | Runtime to host: `auto`, `clr`, `netcore`, `java`, `jvm`, `python`, `python27`, `ruby`, `nodejs`, `php`, `perl` (default: `auto`) |
| `--modules` | Comma-separated list of modules (DLLs, JARs, paths, etc.) |
| `--endpoint` | Gateway endpoint URL (default: `https://grft.dev`) |
| `--projectKey` | JWT used for portal authentication and project metadata |
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

- **`netcore`** — .NET (Core) runtime on the machine; .NET Core 3.1 or newer  
- **`clr`** — .NET Framework on the machine; 4.7.2 or newer  
- **`java` / `jvm`** — JVM; `JAVA_HOME` should point at the JDK; Java 8 or newer  
- **`python`** — Python 3  
- **`python27`** — Python 2.7  
- **`ruby`** — Ruby 3  
- **`nodejs`** — Node.js 20 or newer  
- **`php`** — PHP 7.4 or newer  
- **`perl`** — Perl  
- **`auto`** — Let the gateway choose the runtime  

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
- If Graftcode gateway does not respond on default ports, check if the ports are not blocked by firewall or used by other applications. You can also specify custom ports using `--port`, `--httpPort`, `--tcpPort`, and `--http2Port` options.
Default ports may require elevated permissions on some operating systems. If you encounter permission issues, try using a different ports.
Default port for Websocet is set to 80 to be easily accesible f.e. on web application without the need to specify port in the URL. If you are hosting a web application on the same machine, make sure to use different ports for the gateway and your application to avoid conflicts.
