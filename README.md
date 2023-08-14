# ask-access

**ask-access** is a tool that automates asking for ssh-access.

## Usage


```console

USAGE: ask-access [--reset-token] [--tackarr] [--no-tackarr] [--send-from <send-from>] [--send-to <send-to>] [<project-name>]

ARGUMENTS:
  <project-name>          The project name.

OPTIONS:
  -r, --reset-token       Reset email token.
  --tackarr/--no-tackarr  Send thanks after access has been granted. (default: --tackarr)
  --send-from <send-from> Email to send from. (default: ASK_ACCESS_SEND_FROM env)
  --send-to <send-to>     Email to send to. (default: ASK_ACCESS_SEND_TO env)
  -h, --help              Show help information.

```

## Setup

1. Turn on two-factor authentication for your gmail account
2. Create an [application specific password](https://support.google.com/accounts/answer/185833?hl=en)
3. Run the application and input your app specific password

## Build

```sh

swift build -c release

```

After building, the final executable will be found in `.build/release`
