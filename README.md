# Graftcode Gateway (GG)

Native gateway that hosts your modules behind WebSocket, HTTP, optional TCP, and optional HTTP/2 servers. It can run **Graftcode Vision** (web UI) and the **Graftcode Module Analyzer (GMA)** for a graph view of loaded modules.


## Usage

All Graftcode Gateway CLI options are optional.

GG can be used just by launching it in a directory which contains the modules to host. By default, GG will scan the current directory for modules and try to detect the runtime. If you want to specify the modules and runtime explicitly, use the `--modules` and `--runtime` options.

See Known issues below for common pitfalls and troubleshooting tips, especially when communication with the gateway fails or modules are not loaded.

Run `gg --help` (or `gg.exe --help` on Windows) for the full CLI.

You may pass the main module path as the **first positional argument** instead of `--modules` (for example: `./gg ./MyApp.dll --port 8888`). If both are provided, `--modules` takes precedence.

Option names are case-insensitive (for example `--httpport` and `--httpPort` are equivalent).

### CLI options

| Option | Default | Description |
|--------|---------|-------------|
| `--runtime` | `auto` | Runtime to host: `auto`, `clr`, `netcore`, `java`, `jvm`, `python`, `python27`, `ruby`, `nodejs`, `php` |
| `--modules` | *(empty)* | Comma-separated list of modules to host (DLLs, JARs, package paths, etc.) |
| `--config` | *(empty)* | Path to a JSON config file or inline JSON string (see [Plugin server config](#plugin-server-config)) |
| `--projectKey` | *(empty)* | JWT for portal authentication and project metadata. Get your key from [Graftcode Portal](https://portal.graftcode.com/). |
| `--endpoint` | `https://grft.dev` | Graftcode API endpoint URL used for GSMU upload and related services |
| `--port` | `80` | WebSocket server port |
| `--httpPort` | `81` | HTTP server port for Graftcode Vision (used when `--GV` is enabled) |
| `--tcpPort` | `82` | TCP server port when `--tcpServer` is enabled |
| `--http2Port` | `83` | HTTP/2 server port when `--http2Server` is enabled |
| `--GV` | `true` | Host Graftcode Vision. When enabled, also turns on `--GMA` and `--GSMU` |
| `--GMA` | `false` | Run the Graftcode Module Analyzer to build the Unified Graft Model |
| `--GSMU` | `false` | Upload the Unified Graft Model to GSMU |
| `--types` | *(empty)* | Comma-separated list of types to expose from hosted modules |
| `--tcpServer` | `false` | Enable the TCP server |
| `--http2Server` | `false` | Enable the HTTP/2 server |
| `--runApp` | `false` | Run the hosted application entry point |
| `--mcpBaseClass` | *(empty)* | Optional declaring type FQN from the UGM (language-specific, e.g. `MyAsm.MyNs.MyClass`, `com.app.Util`, `package.module`) used when MCP `tools/call` uses a bare method name, `params.class` is empty, and the name is not in the MCP registry |
| `--noVersioning` | `false` | Disable versioning for hosted modules |
| `--keepVersioning` | `true` | Enable versioning for hosted modules |
| `--useContext` | `false` | **[DEPRECATED]** Previously enabled Graftcode Context manually. Context is now auto-detected at startup when the hosted module provides it |
| `--corsAllowedOrigins` | *(empty)* | Comma-separated CORS origin allowlist (for example `http://localhost:3000,https://app.example.com` or `*`) |
| `--corsConfig` | *(empty)* | Path to a CORS config file (`key=value` format) |
| `--doNotExtractBinaries` | `false` | Do not extract bundled binaries; you must provide them yourself |

### Versioning

Versioning behavior is resolved after CLI and environment-variable parsing:

- Without a `--projectKey` (or `GC_PROJECT_KEY`), the gateway runs in standalone mode and **disables versioning** by default.
- `--keepVersioning` (default `true`) re-enables versioning even without a project key.
- `--noVersioning` explicitly disables versioning regardless of project key.

The WebSocket server always starts. The HTTP server (Graftcode Vision) starts only when `--GV` is enabled (default).

### Runtimes (typical setups)

- **`auto`** — Let GG detect the runtime (default)
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
./gg /path/to/lib.dll --httpPort 8888 --corsConfig ./cors.config
./gg /path/to/lib.dll --GMA --noVersioning
```

### CORS config file (`--corsConfig`)

Pass a file path with `--corsConfig` to control CORS from configuration instead of code.

Supported keys:

- `allowedOrigins` or `origins`
- `allowedMethods` or `methods`
- `allowedHeaders` or `headers`
- `exposedHeaders` or `exposeHeaders`
- `allowCredentials` or `credentials` (`true/false`, `1/0`, `yes/no`)

Example `cors.config`:

```ini
# Comma-separated values
allowedOrigins=http://localhost:3000,https://app.example.com
allowedMethods=GET,POST,PUT,PATCH,DELETE,OPTIONS
allowedHeaders=content-type,authorization,MCP-Protocol-Version,Mcp-Session-Id
exposedHeaders=Mcp-Session-Id,MCP-Protocol-Version
allowCredentials=false
```

Notes:

- If `allowedOrigins` is empty or missing, CORS headers are not added.
- If `allowedOrigins=*` and `allowCredentials=true`, gateway responds with request origin (not `*`) to keep browser behavior valid.
- `--corsAllowedOrigins` works without a config file; when both are provided, values from `--corsConfig` are applied during startup and can override CLI defaults.

## Environment variables

Environment variables are read after CLI parsing and override matching CLI values.

| Variable | Purpose |
|----------|---------|
| `GG_DEBUG` | Set to `1` or `TRUE` to log incoming and outgoing byte traffic to the console |
| `GSMU_ENDPOINT` | When set, overrides the gateway endpoint from `--endpoint` (default CLI value is `https://grft.dev`) |
| `GC_PROJECT_KEY` | JWT project key; when set, overrides `--projectKey` |


## Plugin server config

You can run an external server plugin by passing a config file path or inline JSON to `--config`:

```bash
./gg --config /path/to/plugin-config.json
./gg /path/to/lib.dll --config '{"name":"RabbitmqPlugin","queue":"gg","replyQueue":"gg.reply"}'
```

Example config:

```json
{
  "name": "RabbitmqPlugin",
  "queue": "gg",
  "replyQueue": "gg.reply",
  "user": "guest",
  "password": "guest",
  "vhost": "/",
  "rpcTimeoutMs": 30000
}
```

`name` is treated as a base library name and mapped by OS:

- Windows: `<name>.dll`
- Linux: `lib<name>.so`
- macOS: `lib<name>.dylib`

The library is searched first in the same directory as the config file (when a file path is used), then in the current working directory.

The plugin library must export both factory functions:

- `CreateServer`
- `DestroyServer`

and return an instance implementing `GraftcodeGateway::IServer`. The gateway calls `configure(jsonConfig, processMessage)` on the plugin before `start()`, passing the JSON config and a callback used to process incoming messages and write responses.

The same `--config` value is also forwarded to the runtime transmitter configuration.

## Known issues

- If Graftcode Gateway does not respond on default ports, check if the ports are not blocked by firewall or used by other applications. You can also specify custom ports using `--port`, `--httpPort`, `--tcpPort`, and `--http2Port` options. Default ports may require elevated permissions on some operating systems. If you encounter permission issues, try using different ports. Default port for WebSocket is set to 80 to be easily accessible, e.g. on web applications without the need to specify port in the URL. If you are hosting a web application on the same machine, make sure to use different ports for the gateway and your application to avoid conflicts.

- If Graftcode Gateway is launched in auto mode it will try to detect the runtime based on the provided modules.

- If `--modules` are not specified, GG will scan current directory for modules to host. If current directory contains many different files, GG may fail to detect the runtime or load modules. To fix this, specify the modules explicitly or run GG in a directory with only the relevant modules.

- If you are hosting .NET Framework runtime (CLR) and your modules target .NET Core, GG may fail to load them. Make sure to use the appropriate runtime for your modules.

- If you are hosting Java runtime and your modules are not packaged as JAR files, GG may fail to load them. Make sure to package your Java modules as JAR files or specify the correct paths to the class files.

- If you are hosting Python runtime and your modules have dependencies that are not installed in the Python environment, GG may fail to load them. Make sure to install all required dependencies in the Python environment before hosting the modules.

- If you are hosting Ruby runtime and your modules have dependencies that are not installed in the Ruby environment, GG may fail to load them. Make sure to install all required dependencies in the Ruby environment before hosting the modules.
