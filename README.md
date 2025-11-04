# GraftcodeGateway

## Usage

To use GraftCodeGateway, run the executable with the appropriate command line options. Below are the available options:

- `--licenseKey` : License key to activate GrafCode Gateway.
- `--projectKey` : Project key to activate GrafCode Gateway. (overrides licenseKey)
- `--projectName`: Project name
- `--runtime` : Runtime to be hosted by GrafCode Gateway (e.g., `netcore`, `clr`, `jvm`, `python`, `ruby`, `nodejs`, `perl`, `python2`).
- `--modules` : Comma-separated list of modules to be hosted by GrafCode Gateway.
- `--config` : Path to configuration file.
- `--namespaces` : Comma-separated list of namespaces to be hosted by GrafCode Gateway.
- `--types` : Comma-separated list of types to be hosted by GrafCode Gateway.
- `--GMA` : Use Graftcode Module Azalyzer
- `--GV` : Host GrafCode Vision
- `--GSMU` : Send model GrafCode Service Model Uploader`

Example usage:

./gg --licenseKey=YOUR_LICENSE_KEY --runtime=netcore --modules=module1,module2 --config=path/to/config --namespaces=namespace1,namespace2 --types=type1,type2

./gg  --licenseKey "n9B5-Km7g-Pp69-j9FE-e9A5" --runtime netcore --port 8080 --httpPort=8081 --GMA --modules /home/michal/GRAFTCODE/test-modules/netcore/TestClass.dll

./gg  --licenseKey "n9B5-Km7g-Pp69-j9FE-e9A5" --runtime python --port 80
80 --httpPort=8081 --GMA --modules /home/michal/GRAFTCODE/test-modules/python

The following environment variable are applicable`:

- `LICENSE_KEY` : Provides the license key for activating GrafCode Gateway. It overrides command line --licenseKey value
- `PROJECT_KEY`: Provides the project key for activating GrafCode Gateway. It overrides command line --projectKey value. (not used now)
- `GG_DEBUG`: Enable console logging of all incoming and outgoing byte arrays. To enable logging to console set it to "1"
