# PR: Add NixOS module for isolated system user

## Issue

https://github.com/moltbot/nix-moltbot/issues/22

Upstream issue: https://github.com/moltbot/moltbot/issues/2341

## Goal

Add a NixOS module (`nixosModules.moltbot`) that runs the gateway as an isolated system user instead of the personal user account.

## Security Motivation

Currently the gateway runs as the user's personal account, giving the LLM full access to SSH keys, credentials, personal files, etc. Running as a dedicated locked-down user contains the blast radius if the LLM is compromised.

## Status: Working

Tested and deployed successfully. The service runs with full systemd hardening.

## Implementation

### Files

- `nix/modules/nixos/moltbot.nix` - Main module
- `nix/modules/nixos/options.nix` - Option definitions
- `nix/modules/nixos/documents-skills.nix` - Documents and skills installation

### Features

- Dedicated `moltbot` system user with minimal privileges
- System-level systemd service with hardening:
  - `ProtectHome=true`
  - `ProtectSystem=strict`
  - `PrivateTmp=true`, `PrivateDevices=true`
  - `NoNewPrivileges=true`
  - `CapabilityBoundingSet=""` (no capabilities)
  - `SystemCallFilter=@system-service`
  - `RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX AF_NETLINK`
  - Full namespace/kernel protection
- Multi-instance support via `instances.<name>`
- Credential loading from files at runtime (wrapper script)

### Credential Management

Uses `providers.anthropic.oauthTokenFile` - a long-lived token from `claude setup-token`.

```nix
services.moltbot = {
  enable = true;
  providers.anthropic.oauthTokenFile = config.age.secrets.moltbot-token.path;
  providers.telegram = {
    enable = true;
    botTokenFile = config.age.secrets.telegram-token.path;
    allowFrom = [ 12345678 ];
  };
};
```

The deprecated `anthropic:claude-cli` profile (which tried to sync OAuth from `~/.claude/`) was not implemented - upstream deprecated it in favor of `setup-token` flow.

### Gateway Auth

Upstream now requires gateway authentication. Options:

- `gateway.auth.tokenFile` / `gateway.auth.passwordFile` - load from file
- `instances.<name>.configOverrides.gateway.auth` - inline in config (for non-sensitive cases)

## Notes

- Node.js JIT requires `SystemCallFilter=@system-service` (can't use `~@privileged`)
- `AF_NETLINK` needed for `os.networkInterfaces()` in Node.js
