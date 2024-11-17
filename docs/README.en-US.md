# WindowsConfigManager
Back to language menu [here](./README.md).

## Description

This project focuses on providing an easy way to change Windows configurations. It is an application designed to run constantly, recognizing and applying settings based on changes made to a configuration file. According to these changes, push notifications appear, notifying about new settings.

This project will often be updated with new features.

## Installation

1. Clone this repository.
2. Execute the following PowerShell file with administrator privileges:

```powershell
WindowsConfigManager.ps1
```

## Usage

To modify Windows settings with this application, change the configuration file `UserConfig-WindowsConfigManager.ini` in the `config` directory.

Ex.:

Change `deny` to `allow` in `task`:

Before:

```ini
[Microphone]
Task = deny
Verbose = false
```

After:

```ini
[Microphone]
Task = allow
Verbose = false
```

This will allow usage of microphone in Windows privacy setting.

*A full documentation of all usage possibilities will be available soon.*

## Testing

This step is still in development.

## Contribution

Feel free to contribute new settings or fix bugs.

If you prefer, contact me for discuss this project and new changes.
