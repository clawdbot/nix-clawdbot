# Generated from upstream Clawdbot schema. DO NOT EDIT.
{ lib }:
let
  t = lib.types;
in
{
  agents = lib.mkOption {
    type = t.submodule { options = {
    defaults = lib.mkOption {
      type = t.submodule { options = {
      blockStreamingBreak = lib.mkOption {
        type = t.oneOf [ t.enum [ "text_end" ] t.enum [ "message_end" ] ];
      };
      blockStreamingChunk = lib.mkOption {
        type = t.submodule { options = {
        breakPreference = lib.mkOption {
          type = t.oneOf [ t.enum [ "paragraph" ] t.enum [ "newline" ] t.enum [ "sentence" ] ];
        };
        maxChars = lib.mkOption {
          type = t.int;
        };
        minChars = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.int;
        };
        maxChars = lib.mkOption {
          type = t.int;
        };
        minChars = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      blockStreamingDefault = lib.mkOption {
        type = t.oneOf [ t.enum [ "off" ] t.enum [ "on" ] ];
      };
      bootstrapMaxChars = lib.mkOption {
        type = t.int;
      };
      cliBackends = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        args = lib.mkOption {
          type = t.listOf (t.str);
        };
        clearEnv = lib.mkOption {
          type = t.listOf (t.str);
        };
        command = lib.mkOption {
          type = t.str;
        };
        env = lib.mkOption {
          type = t.attrsOf (t.str);
        };
        imageArg = lib.mkOption {
          type = t.str;
        };
        imageMode = lib.mkOption {
          type = t.oneOf [ t.enum [ "repeat" ] t.enum [ "list" ] ];
        };
        input = lib.mkOption {
          type = t.oneOf [ t.enum [ "arg" ] t.enum [ "stdin" ] ];
        };
        maxPromptArgChars = lib.mkOption {
          type = t.int;
        };
        modelAliases = lib.mkOption {
          type = t.attrsOf (t.str);
        };
        modelArg = lib.mkOption {
          type = t.str;
        };
        output = lib.mkOption {
          type = t.oneOf [ t.enum [ "json" ] t.enum [ "text" ] t.enum [ "jsonl" ] ];
        };
        resumeArgs = lib.mkOption {
          type = t.listOf (t.str);
        };
        resumeOutput = lib.mkOption {
          type = t.oneOf [ t.enum [ "json" ] t.enum [ "text" ] t.enum [ "jsonl" ] ];
        };
        serialize = lib.mkOption {
          type = t.bool;
        };
        sessionArg = lib.mkOption {
          type = t.str;
        };
        sessionArgs = lib.mkOption {
          type = t.listOf (t.str);
        };
        sessionIdFields = lib.mkOption {
          type = t.listOf (t.str);
        };
        sessionMode = lib.mkOption {
          type = t.oneOf [ t.enum [ "always" ] t.enum [ "existing" ] t.enum [ "none" ] ];
        };
        systemPromptArg = lib.mkOption {
          type = t.str;
        };
        systemPromptMode = lib.mkOption {
          type = t.oneOf [ t.enum [ "append" ] t.enum [ "replace" ] ];
        };
        systemPromptWhen = lib.mkOption {
          type = t.oneOf [ t.enum [ "first" ] t.enum [ "always" ] t.enum [ "never" ] ];
        };
      }; });
      };
      compaction = lib.mkOption {
        type = t.submodule { options = {
        memoryFlush = lib.mkOption {
          type = t.submodule { options = {
          enabled = lib.mkOption {
            type = t.bool;
          };
          prompt = lib.mkOption {
            type = t.str;
          };
          softThresholdTokens = lib.mkOption {
            type = t.int;
          };
          systemPrompt = lib.mkOption {
            type = t.str;
          };
        }; };
        };
        mode = lib.mkOption {
          type = t.oneOf [ t.enum [ "default" ] t.enum [ "safeguard" ] ];
        };
        reserveTokensFloor = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      contextPruning = lib.mkOption {
        type = t.submodule { options = {
        hardClear = lib.mkOption {
          type = t.submodule { options = {
          enabled = lib.mkOption {
            type = t.bool;
          };
          placeholder = lib.mkOption {
            type = t.str;
          };
        }; };
        };
        hardClearRatio = lib.mkOption {
          type = t.number;
        };
        keepLastAssistants = lib.mkOption {
          type = t.int;
        };
        minPrunableToolChars = lib.mkOption {
          type = t.int;
        };
        mode = lib.mkOption {
          type = t.oneOf [ t.enum [ "off" ] t.enum [ "adaptive" ] t.enum [ "aggressive" ] ];
        };
        softTrim = lib.mkOption {
          type = t.submodule { options = {
          headChars = lib.mkOption {
            type = t.int;
          };
          maxChars = lib.mkOption {
            type = t.int;
          };
          tailChars = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        softTrimRatio = lib.mkOption {
          type = t.number;
        };
        tools = lib.mkOption {
          type = t.submodule { options = {
          allow = lib.mkOption {
            type = t.listOf (t.str);
          };
          deny = lib.mkOption {
            type = t.listOf (t.str);
          };
        }; };
        };
      }; };
      };
      contextTokens = lib.mkOption {
        type = t.int;
      };
      elevatedDefault = lib.mkOption {
        type = t.oneOf [ t.enum [ "off" ] t.enum [ "on" ] ];
      };
      heartbeat = lib.mkOption {
        type = t.submodule { options = {
        ackMaxChars = lib.mkOption {
          type = t.int;
        };
        every = lib.mkOption {
          type = t.str;
        };
        includeReasoning = lib.mkOption {
          type = t.bool;
        };
        model = lib.mkOption {
          type = t.str;
        };
        prompt = lib.mkOption {
          type = t.str;
        };
        target = lib.mkOption {
          type = t.oneOf [ t.enum [ "last" ] t.enum [ "whatsapp" ] t.enum [ "telegram" ] t.enum [ "discord" ] t.enum [ "slack" ] t.enum [ "msteams" ] t.enum [ "signal" ] t.enum [ "imessage" ] t.enum [ "none" ] ];
        };
        to = lib.mkOption {
          type = t.str;
        };
      }; };
      };
      humanDelay = lib.mkOption {
        type = t.submodule { options = {
        maxMs = lib.mkOption {
          type = t.int;
        };
        minMs = lib.mkOption {
          type = t.int;
        };
        mode = lib.mkOption {
          type = t.oneOf [ t.enum [ "off" ] t.enum [ "natural" ] t.enum [ "custom" ] ];
        };
      }; };
      };
      imageModel = lib.mkOption {
        type = t.submodule { options = {
        fallbacks = lib.mkOption {
          type = t.listOf (t.str);
        };
        primary = lib.mkOption {
          type = t.str;
        };
      }; };
      };
      maxConcurrent = lib.mkOption {
        type = t.int;
      };
      mediaMaxMb = lib.mkOption {
        type = t.number;
      };
      memorySearch = lib.mkOption {
        type = t.submodule { options = {
        chunking = lib.mkOption {
          type = t.submodule { options = {
          overlap = lib.mkOption {
            type = t.int;
          };
          tokens = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        fallback = lib.mkOption {
          type = t.oneOf [ t.enum [ "openai" ] t.enum [ "none" ] ];
        };
        local = lib.mkOption {
          type = t.submodule { options = {
          modelCacheDir = lib.mkOption {
            type = t.str;
          };
          modelPath = lib.mkOption {
            type = t.str;
          };
        }; };
        };
        model = lib.mkOption {
          type = t.str;
        };
        provider = lib.mkOption {
          type = t.oneOf [ t.enum [ "openai" ] t.enum [ "local" ] ];
        };
        query = lib.mkOption {
          type = t.submodule { options = {
          maxResults = lib.mkOption {
            type = t.int;
          };
          minScore = lib.mkOption {
            type = t.number;
          };
        }; };
        };
        remote = lib.mkOption {
          type = t.submodule { options = {
          apiKey = lib.mkOption {
            type = t.str;
          };
          baseUrl = lib.mkOption {
            type = t.str;
          };
          headers = lib.mkOption {
            type = t.attrsOf (t.str);
          };
        }; };
        };
        store = lib.mkOption {
          type = t.submodule { options = {
          driver = lib.mkOption {
            type = t.enum [ "sqlite" ];
          };
          path = lib.mkOption {
            type = t.str;
          };
        }; };
        };
        sync = lib.mkOption {
          type = t.submodule { options = {
          intervalMinutes = lib.mkOption {
            type = t.int;
          };
          onSearch = lib.mkOption {
            type = t.bool;
          };
          onSessionStart = lib.mkOption {
            type = t.bool;
          };
          watch = lib.mkOption {
            type = t.bool;
          };
          watchDebounceMs = lib.mkOption {
            type = t.int;
          };
        }; };
        };
      }; };
      };
      model = lib.mkOption {
        type = t.submodule { options = {
        fallbacks = lib.mkOption {
          type = t.listOf (t.str);
        };
        primary = lib.mkOption {
          type = t.str;
        };
      }; };
      };
      models = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        alias = lib.mkOption {
          type = t.str;
        };
        params = lib.mkOption {
          type = t.attrsOf (t.anything);
        };
      }; });
      };
      sandbox = lib.mkOption {
        type = t.submodule { options = {
        browser = lib.mkOption {
          type = t.submodule { options = {
          allowHostControl = lib.mkOption {
            type = t.bool;
          };
          allowedControlHosts = lib.mkOption {
            type = t.listOf (t.str);
          };
          allowedControlPorts = lib.mkOption {
            type = t.listOf (t.int);
          };
          allowedControlUrls = lib.mkOption {
            type = t.listOf (t.str);
          };
          autoStart = lib.mkOption {
            type = t.bool;
          };
          autoStartTimeoutMs = lib.mkOption {
            type = t.int;
          };
          cdpPort = lib.mkOption {
            type = t.int;
          };
          containerPrefix = lib.mkOption {
            type = t.str;
          };
          enableNoVnc = lib.mkOption {
            type = t.bool;
          };
          enabled = lib.mkOption {
            type = t.bool;
          };
          headless = lib.mkOption {
            type = t.bool;
          };
          image = lib.mkOption {
            type = t.str;
          };
          noVncPort = lib.mkOption {
            type = t.int;
          };
          vncPort = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        docker = lib.mkOption {
          type = t.submodule { options = {
          apparmorProfile = lib.mkOption {
            type = t.str;
          };
          binds = lib.mkOption {
            type = t.listOf (t.str);
          };
          capDrop = lib.mkOption {
            type = t.listOf (t.str);
          };
          containerPrefix = lib.mkOption {
            type = t.str;
          };
          cpus = lib.mkOption {
            type = t.number;
          };
          dns = lib.mkOption {
            type = t.listOf (t.str);
          };
          env = lib.mkOption {
            type = t.attrsOf (t.str);
          };
          extraHosts = lib.mkOption {
            type = t.listOf (t.str);
          };
          image = lib.mkOption {
            type = t.str;
          };
          memory = lib.mkOption {
            type = t.oneOf [ t.str t.number ];
          };
          memorySwap = lib.mkOption {
            type = t.oneOf [ t.str t.number ];
          };
          network = lib.mkOption {
            type = t.str;
          };
          pidsLimit = lib.mkOption {
            type = t.int;
          };
          readOnlyRoot = lib.mkOption {
            type = t.bool;
          };
          seccompProfile = lib.mkOption {
            type = t.str;
          };
          setupCommand = lib.mkOption {
            type = t.str;
          };
          tmpfs = lib.mkOption {
            type = t.listOf (t.str);
          };
          ulimits = lib.mkOption {
            type = t.attrsOf (t.oneOf [ t.str t.number t.submodule { options = {
            hard = lib.mkOption {
              type = t.int;
            };
            soft = lib.mkOption {
              type = t.int;
            };
          }; } ]);
          };
          user = lib.mkOption {
            type = t.str;
          };
          workdir = lib.mkOption {
            type = t.str;
          };
        }; };
        };
        mode = lib.mkOption {
          type = t.oneOf [ t.enum [ "off" ] t.enum [ "non-main" ] t.enum [ "all" ] ];
        };
        perSession = lib.mkOption {
          type = t.bool;
        };
        prune = lib.mkOption {
          type = t.submodule { options = {
          idleHours = lib.mkOption {
            type = t.int;
          };
          maxAgeDays = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        scope = lib.mkOption {
          type = t.oneOf [ t.enum [ "session" ] t.enum [ "agent" ] t.enum [ "shared" ] ];
        };
        sessionToolsVisibility = lib.mkOption {
          type = t.oneOf [ t.enum [ "spawned" ] t.enum [ "all" ] ];
        };
        workspaceAccess = lib.mkOption {
          type = t.oneOf [ t.enum [ "none" ] t.enum [ "ro" ] t.enum [ "rw" ] ];
        };
        workspaceRoot = lib.mkOption {
          type = t.str;
        };
      }; };
      };
      skipBootstrap = lib.mkOption {
        type = t.bool;
      };
      subagents = lib.mkOption {
        type = t.submodule { options = {
        archiveAfterMinutes = lib.mkOption {
          type = t.int;
        };
        maxConcurrent = lib.mkOption {
          type = t.int;
        };
        model = lib.mkOption {
          type = t.oneOf [ t.str t.submodule { options = {
          fallbacks = lib.mkOption {
            type = t.listOf (t.str);
          };
          primary = lib.mkOption {
            type = t.str;
          };
        }; } ];
        };
      }; };
      };
      thinkingDefault = lib.mkOption {
        type = t.oneOf [ t.enum [ "off" ] t.enum [ "minimal" ] t.enum [ "low" ] t.enum [ "medium" ] t.enum [ "high" ] t.enum [ "xhigh" ] ];
      };
      timeFormat = lib.mkOption {
        type = t.oneOf [ t.enum [ "auto" ] t.enum [ "12" ] t.enum [ "24" ] ];
      };
      timeoutSeconds = lib.mkOption {
        type = t.int;
      };
      typingIntervalSeconds = lib.mkOption {
        type = t.int;
      };
      typingMode = lib.mkOption {
        type = t.oneOf [ t.enum [ "never" ] t.enum [ "instant" ] t.enum [ "thinking" ] t.enum [ "message" ] ];
      };
      userTimezone = lib.mkOption {
        type = t.str;
      };
      verboseDefault = lib.mkOption {
        type = t.oneOf [ t.enum [ "off" ] t.enum [ "on" ] t.enum [ "full" ] ];
      };
      workspace = lib.mkOption {
        type = t.str;
      };
    }; };
    };
    list = lib.mkOption {
      type = t.listOf (t.submodule { options = {
      agentDir = lib.mkOption {
        type = t.str;
      };
      default = lib.mkOption {
        type = t.bool;
      };
      groupChat = lib.mkOption {
        type = t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.int;
        };
        mentionPatterns = lib.mkOption {
          type = t.listOf (t.str);
        };
      }; };
      };
      heartbeat = lib.mkOption {
        type = t.submodule { options = {
        ackMaxChars = lib.mkOption {
          type = t.int;
        };
        every = lib.mkOption {
          type = t.str;
        };
        includeReasoning = lib.mkOption {
          type = t.bool;
        };
        model = lib.mkOption {
          type = t.str;
        };
        prompt = lib.mkOption {
          type = t.str;
        };
        target = lib.mkOption {
          type = t.oneOf [ t.enum [ "last" ] t.enum [ "whatsapp" ] t.enum [ "telegram" ] t.enum [ "discord" ] t.enum [ "slack" ] t.enum [ "msteams" ] t.enum [ "signal" ] t.enum [ "imessage" ] t.enum [ "none" ] ];
        };
        to = lib.mkOption {
          type = t.str;
        };
      }; };
      };
      humanDelay = lib.mkOption {
        type = t.submodule { options = {
        maxMs = lib.mkOption {
          type = t.int;
        };
        minMs = lib.mkOption {
          type = t.int;
        };
        mode = lib.mkOption {
          type = t.oneOf [ t.enum [ "off" ] t.enum [ "natural" ] t.enum [ "custom" ] ];
        };
      }; };
      };
      id = lib.mkOption {
        type = t.str;
      };
      identity = lib.mkOption {
        type = t.submodule { options = {
        emoji = lib.mkOption {
          type = t.str;
        };
        name = lib.mkOption {
          type = t.str;
        };
        theme = lib.mkOption {
          type = t.str;
        };
      }; };
      };
      memorySearch = lib.mkOption {
        type = t.submodule { options = {
        chunking = lib.mkOption {
          type = t.submodule { options = {
          overlap = lib.mkOption {
            type = t.int;
          };
          tokens = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        fallback = lib.mkOption {
          type = t.oneOf [ t.enum [ "openai" ] t.enum [ "none" ] ];
        };
        local = lib.mkOption {
          type = t.submodule { options = {
          modelCacheDir = lib.mkOption {
            type = t.str;
          };
          modelPath = lib.mkOption {
            type = t.str;
          };
        }; };
        };
        model = lib.mkOption {
          type = t.str;
        };
        provider = lib.mkOption {
          type = t.oneOf [ t.enum [ "openai" ] t.enum [ "local" ] ];
        };
        query = lib.mkOption {
          type = t.submodule { options = {
          maxResults = lib.mkOption {
            type = t.int;
          };
          minScore = lib.mkOption {
            type = t.number;
          };
        }; };
        };
        remote = lib.mkOption {
          type = t.submodule { options = {
          apiKey = lib.mkOption {
            type = t.str;
          };
          baseUrl = lib.mkOption {
            type = t.str;
          };
          headers = lib.mkOption {
            type = t.attrsOf (t.str);
          };
        }; };
        };
        store = lib.mkOption {
          type = t.submodule { options = {
          driver = lib.mkOption {
            type = t.enum [ "sqlite" ];
          };
          path = lib.mkOption {
            type = t.str;
          };
        }; };
        };
        sync = lib.mkOption {
          type = t.submodule { options = {
          intervalMinutes = lib.mkOption {
            type = t.int;
          };
          onSearch = lib.mkOption {
            type = t.bool;
          };
          onSessionStart = lib.mkOption {
            type = t.bool;
          };
          watch = lib.mkOption {
            type = t.bool;
          };
          watchDebounceMs = lib.mkOption {
            type = t.int;
          };
        }; };
        };
      }; };
      };
      model = lib.mkOption {
        type = t.oneOf [ t.str t.submodule { options = {
        fallbacks = lib.mkOption {
          type = t.listOf (t.str);
        };
        primary = lib.mkOption {
          type = t.str;
        };
      }; } ];
      };
      name = lib.mkOption {
        type = t.str;
      };
      sandbox = lib.mkOption {
        type = t.submodule { options = {
        browser = lib.mkOption {
          type = t.submodule { options = {
          allowHostControl = lib.mkOption {
            type = t.bool;
          };
          allowedControlHosts = lib.mkOption {
            type = t.listOf (t.str);
          };
          allowedControlPorts = lib.mkOption {
            type = t.listOf (t.int);
          };
          allowedControlUrls = lib.mkOption {
            type = t.listOf (t.str);
          };
          autoStart = lib.mkOption {
            type = t.bool;
          };
          autoStartTimeoutMs = lib.mkOption {
            type = t.int;
          };
          cdpPort = lib.mkOption {
            type = t.int;
          };
          containerPrefix = lib.mkOption {
            type = t.str;
          };
          enableNoVnc = lib.mkOption {
            type = t.bool;
          };
          enabled = lib.mkOption {
            type = t.bool;
          };
          headless = lib.mkOption {
            type = t.bool;
          };
          image = lib.mkOption {
            type = t.str;
          };
          noVncPort = lib.mkOption {
            type = t.int;
          };
          vncPort = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        docker = lib.mkOption {
          type = t.submodule { options = {
          apparmorProfile = lib.mkOption {
            type = t.str;
          };
          binds = lib.mkOption {
            type = t.listOf (t.str);
          };
          capDrop = lib.mkOption {
            type = t.listOf (t.str);
          };
          containerPrefix = lib.mkOption {
            type = t.str;
          };
          cpus = lib.mkOption {
            type = t.number;
          };
          dns = lib.mkOption {
            type = t.listOf (t.str);
          };
          env = lib.mkOption {
            type = t.attrsOf (t.str);
          };
          extraHosts = lib.mkOption {
            type = t.listOf (t.str);
          };
          image = lib.mkOption {
            type = t.str;
          };
          memory = lib.mkOption {
            type = t.oneOf [ t.str t.number ];
          };
          memorySwap = lib.mkOption {
            type = t.oneOf [ t.str t.number ];
          };
          network = lib.mkOption {
            type = t.str;
          };
          pidsLimit = lib.mkOption {
            type = t.int;
          };
          readOnlyRoot = lib.mkOption {
            type = t.bool;
          };
          seccompProfile = lib.mkOption {
            type = t.str;
          };
          setupCommand = lib.mkOption {
            type = t.str;
          };
          tmpfs = lib.mkOption {
            type = t.listOf (t.str);
          };
          ulimits = lib.mkOption {
            type = t.attrsOf (t.oneOf [ t.str t.number t.submodule { options = {
            hard = lib.mkOption {
              type = t.int;
            };
            soft = lib.mkOption {
              type = t.int;
            };
          }; } ]);
          };
          user = lib.mkOption {
            type = t.str;
          };
          workdir = lib.mkOption {
            type = t.str;
          };
        }; };
        };
        mode = lib.mkOption {
          type = t.oneOf [ t.enum [ "off" ] t.enum [ "non-main" ] t.enum [ "all" ] ];
        };
        perSession = lib.mkOption {
          type = t.bool;
        };
        prune = lib.mkOption {
          type = t.submodule { options = {
          idleHours = lib.mkOption {
            type = t.int;
          };
          maxAgeDays = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        scope = lib.mkOption {
          type = t.oneOf [ t.enum [ "session" ] t.enum [ "agent" ] t.enum [ "shared" ] ];
        };
        sessionToolsVisibility = lib.mkOption {
          type = t.oneOf [ t.enum [ "spawned" ] t.enum [ "all" ] ];
        };
        workspaceAccess = lib.mkOption {
          type = t.oneOf [ t.enum [ "none" ] t.enum [ "ro" ] t.enum [ "rw" ] ];
        };
        workspaceRoot = lib.mkOption {
          type = t.str;
        };
      }; };
      };
      subagents = lib.mkOption {
        type = t.submodule { options = {
        allowAgents = lib.mkOption {
          type = t.listOf (t.str);
        };
        model = lib.mkOption {
          type = t.oneOf [ t.str t.submodule { options = {
          fallbacks = lib.mkOption {
            type = t.listOf (t.str);
          };
          primary = lib.mkOption {
            type = t.str;
          };
        }; } ];
        };
      }; };
      };
      tools = lib.mkOption {
        type = t.submodule { options = {
        allow = lib.mkOption {
          type = t.listOf (t.str);
        };
        byProvider = lib.mkOption {
          type = t.attrsOf (t.submodule { options = {
          allow = lib.mkOption {
            type = t.listOf (t.str);
          };
          deny = lib.mkOption {
            type = t.listOf (t.str);
          };
          profile = lib.mkOption {
            type = t.oneOf [ t.enum [ "minimal" ] t.enum [ "coding" ] t.enum [ "messaging" ] t.enum [ "full" ] ];
          };
        }; });
        };
        deny = lib.mkOption {
          type = t.listOf (t.str);
        };
        elevated = lib.mkOption {
          type = t.submodule { options = {
          allowFrom = lib.mkOption {
            type = t.attrsOf (t.listOf (t.oneOf [ t.str t.number ]));
          };
          enabled = lib.mkOption {
            type = t.bool;
          };
        }; };
        };
        profile = lib.mkOption {
          type = t.oneOf [ t.enum [ "minimal" ] t.enum [ "coding" ] t.enum [ "messaging" ] t.enum [ "full" ] ];
        };
        sandbox = lib.mkOption {
          type = t.submodule { options = {
          tools = lib.mkOption {
            type = t.submodule { options = {
            allow = lib.mkOption {
              type = t.listOf (t.str);
            };
            deny = lib.mkOption {
              type = t.listOf (t.str);
            };
          }; };
          };
        }; };
        };
      }; };
      };
      workspace = lib.mkOption {
        type = t.str;
      };
    }; });
    };
  }; };
  };

  audio = lib.mkOption {
    type = t.submodule { options = {
    transcription = lib.mkOption {
      type = t.submodule { options = {
      command = lib.mkOption {
        type = t.listOf (t.str);
      };
      timeoutSeconds = lib.mkOption {
        type = t.int;
      };
    }; };
    };
  }; };
  };

  auth = lib.mkOption {
    type = t.submodule { options = {
    cooldowns = lib.mkOption {
      type = t.submodule { options = {
      billingBackoffHours = lib.mkOption {
        type = t.number;
      };
      billingBackoffHoursByProvider = lib.mkOption {
        type = t.attrsOf (t.number);
      };
      billingMaxHours = lib.mkOption {
        type = t.number;
      };
      failureWindowHours = lib.mkOption {
        type = t.number;
      };
    }; };
    };
    order = lib.mkOption {
      type = t.attrsOf (t.listOf (t.str));
    };
    profiles = lib.mkOption {
      type = t.attrsOf (t.submodule { options = {
      email = lib.mkOption {
        type = t.str;
      };
      mode = lib.mkOption {
        type = t.oneOf [ t.enum [ "api_key" ] t.enum [ "oauth" ] t.enum [ "token" ] ];
      };
      provider = lib.mkOption {
        type = t.str;
      };
    }; });
    };
  }; };
  };

  bindings = lib.mkOption {
    type = t.listOf (t.submodule { options = {
    agentId = lib.mkOption {
      type = t.str;
    };
    match = lib.mkOption {
      type = t.submodule { options = {
      accountId = lib.mkOption {
        type = t.str;
      };
      channel = lib.mkOption {
        type = t.str;
      };
      guildId = lib.mkOption {
        type = t.str;
      };
      peer = lib.mkOption {
        type = t.submodule { options = {
        id = lib.mkOption {
          type = t.str;
        };
        kind = lib.mkOption {
          type = t.oneOf [ t.enum [ "dm" ] t.enum [ "group" ] t.enum [ "channel" ] ];
        };
      }; };
      };
      teamId = lib.mkOption {
        type = t.str;
      };
    }; };
    };
  }; });
  };

  bridge = lib.mkOption {
    type = t.submodule { options = {
    bind = lib.mkOption {
      type = t.oneOf [ t.enum [ "auto" ] t.enum [ "lan" ] t.enum [ "tailnet" ] t.enum [ "loopback" ] ];
    };
    enabled = lib.mkOption {
      type = t.bool;
    };
    port = lib.mkOption {
      type = t.int;
    };
    tls = lib.mkOption {
      type = t.submodule { options = {
      autoGenerate = lib.mkOption {
        type = t.bool;
      };
      caPath = lib.mkOption {
        type = t.str;
      };
      certPath = lib.mkOption {
        type = t.str;
      };
      enabled = lib.mkOption {
        type = t.bool;
      };
      keyPath = lib.mkOption {
        type = t.str;
      };
    }; };
    };
  }; };
  };

  broadcast = lib.mkOption {
    type = t.submodule { options = {
    strategy = lib.mkOption {
      type = t.enum [ "parallel" "sequential" ];
    };
  }; };
  };

  browser = lib.mkOption {
    type = t.submodule { options = {
    attachOnly = lib.mkOption {
      type = t.bool;
    };
    cdpUrl = lib.mkOption {
      type = t.str;
    };
    color = lib.mkOption {
      type = t.str;
    };
    controlToken = lib.mkOption {
      type = t.str;
    };
    controlUrl = lib.mkOption {
      type = t.str;
    };
    defaultProfile = lib.mkOption {
      type = t.str;
    };
    enabled = lib.mkOption {
      type = t.bool;
    };
    executablePath = lib.mkOption {
      type = t.str;
    };
    headless = lib.mkOption {
      type = t.bool;
    };
    noSandbox = lib.mkOption {
      type = t.bool;
    };
    profiles = lib.mkOption {
      type = t.attrsOf (t.submodule { options = {
      cdpPort = lib.mkOption {
        type = t.int;
      };
      cdpUrl = lib.mkOption {
        type = t.str;
      };
      color = lib.mkOption {
        type = t.str;
      };
      driver = lib.mkOption {
        type = t.oneOf [ t.enum [ "clawd" ] t.enum [ "extension" ] ];
      };
    }; });
    };
    remoteCdpHandshakeTimeoutMs = lib.mkOption {
      type = t.int;
    };
    remoteCdpTimeoutMs = lib.mkOption {
      type = t.int;
    };
  }; };
  };

  canvasHost = lib.mkOption {
    type = t.submodule { options = {
    enabled = lib.mkOption {
      type = t.bool;
    };
    liveReload = lib.mkOption {
      type = t.bool;
    };
    port = lib.mkOption {
      type = t.int;
    };
    root = lib.mkOption {
      type = t.str;
    };
  }; };
  };

  channels = lib.mkOption {
    type = t.submodule { options = {
    discord = lib.mkOption {
      type = t.submodule { options = {
      accounts = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        actions = lib.mkOption {
          type = t.submodule { options = {
          channelInfo = lib.mkOption {
            type = t.bool;
          };
          channels = lib.mkOption {
            type = t.bool;
          };
          emojiUploads = lib.mkOption {
            type = t.bool;
          };
          events = lib.mkOption {
            type = t.bool;
          };
          memberInfo = lib.mkOption {
            type = t.bool;
          };
          messages = lib.mkOption {
            type = t.bool;
          };
          moderation = lib.mkOption {
            type = t.bool;
          };
          permissions = lib.mkOption {
            type = t.bool;
          };
          pins = lib.mkOption {
            type = t.bool;
          };
          polls = lib.mkOption {
            type = t.bool;
          };
          reactions = lib.mkOption {
            type = t.bool;
          };
          roleInfo = lib.mkOption {
            type = t.bool;
          };
          roles = lib.mkOption {
            type = t.bool;
          };
          search = lib.mkOption {
            type = t.bool;
          };
          stickerUploads = lib.mkOption {
            type = t.bool;
          };
          stickers = lib.mkOption {
            type = t.bool;
          };
          threads = lib.mkOption {
            type = t.bool;
          };
          voiceStatus = lib.mkOption {
            type = t.bool;
          };
        }; };
        };
        allowBots = lib.mkOption {
          type = t.bool;
        };
        blockStreaming = lib.mkOption {
          type = t.bool;
        };
        blockStreamingCoalesce = lib.mkOption {
          type = t.submodule { options = {
          idleMs = lib.mkOption {
            type = t.int;
          };
          maxChars = lib.mkOption {
            type = t.int;
          };
          minChars = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        capabilities = lib.mkOption {
          type = t.listOf (t.str);
        };
        commands = lib.mkOption {
          type = t.submodule { options = {
          native = lib.mkOption {
            type = t.oneOf [ t.bool t.enum [ "auto" ] ];
          };
          nativeSkills = lib.mkOption {
            type = t.oneOf [ t.bool t.enum [ "auto" ] ];
          };
        }; };
        };
        configWrites = lib.mkOption {
          type = t.bool;
        };
        dm = lib.mkOption {
          type = t.submodule { options = {
          allowFrom = lib.mkOption {
            type = t.listOf (t.oneOf [ t.str t.number ]);
          };
          enabled = lib.mkOption {
            type = t.bool;
          };
          groupChannels = lib.mkOption {
            type = t.listOf (t.oneOf [ t.str t.number ]);
          };
          groupEnabled = lib.mkOption {
            type = t.bool;
          };
          policy = lib.mkOption {
            type = t.enum [ "pairing" "allowlist" "open" "disabled" ];
          };
        }; };
        };
        dmHistoryLimit = lib.mkOption {
          type = t.int;
        };
        dms = lib.mkOption {
          type = t.attrsOf (t.submodule { options = {
          historyLimit = lib.mkOption {
            type = t.int;
          };
        }; });
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        groupPolicy = lib.mkOption {
          type = t.enum [ "open" "disabled" "allowlist" ];
        };
        guilds = lib.mkOption {
          type = t.attrsOf (t.submodule { options = {
          channels = lib.mkOption {
            type = t.attrsOf (t.submodule { options = {
            allow = lib.mkOption {
              type = t.bool;
            };
            autoThread = lib.mkOption {
              type = t.bool;
            };
            enabled = lib.mkOption {
              type = t.bool;
            };
            requireMention = lib.mkOption {
              type = t.bool;
            };
            skills = lib.mkOption {
              type = t.listOf (t.str);
            };
            systemPrompt = lib.mkOption {
              type = t.str;
            };
            users = lib.mkOption {
              type = t.listOf (t.oneOf [ t.str t.number ]);
            };
          }; });
          };
          reactionNotifications = lib.mkOption {
            type = t.enum [ "off" "own" "all" "allowlist" ];
          };
          requireMention = lib.mkOption {
            type = t.bool;
          };
          slug = lib.mkOption {
            type = t.str;
          };
          users = lib.mkOption {
            type = t.listOf (t.oneOf [ t.str t.number ]);
          };
        }; });
        };
        historyLimit = lib.mkOption {
          type = t.int;
        };
        maxLinesPerMessage = lib.mkOption {
          type = t.int;
        };
        mediaMaxMb = lib.mkOption {
          type = t.number;
        };
        name = lib.mkOption {
          type = t.str;
        };
        replyToMode = lib.mkOption {
          type = t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ];
        };
        retry = lib.mkOption {
          type = t.submodule { options = {
          attempts = lib.mkOption {
            type = t.int;
          };
          jitter = lib.mkOption {
            type = t.number;
          };
          maxDelayMs = lib.mkOption {
            type = t.int;
          };
          minDelayMs = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        textChunkLimit = lib.mkOption {
          type = t.int;
        };
        token = lib.mkOption {
          type = t.str;
        };
      }; });
      };
      actions = lib.mkOption {
        type = t.submodule { options = {
        channelInfo = lib.mkOption {
          type = t.bool;
        };
        channels = lib.mkOption {
          type = t.bool;
        };
        emojiUploads = lib.mkOption {
          type = t.bool;
        };
        events = lib.mkOption {
          type = t.bool;
        };
        memberInfo = lib.mkOption {
          type = t.bool;
        };
        messages = lib.mkOption {
          type = t.bool;
        };
        moderation = lib.mkOption {
          type = t.bool;
        };
        permissions = lib.mkOption {
          type = t.bool;
        };
        pins = lib.mkOption {
          type = t.bool;
        };
        polls = lib.mkOption {
          type = t.bool;
        };
        reactions = lib.mkOption {
          type = t.bool;
        };
        roleInfo = lib.mkOption {
          type = t.bool;
        };
        roles = lib.mkOption {
          type = t.bool;
        };
        search = lib.mkOption {
          type = t.bool;
        };
        stickerUploads = lib.mkOption {
          type = t.bool;
        };
        stickers = lib.mkOption {
          type = t.bool;
        };
        threads = lib.mkOption {
          type = t.bool;
        };
        voiceStatus = lib.mkOption {
          type = t.bool;
        };
      }; };
      };
      allowBots = lib.mkOption {
        type = t.bool;
      };
      blockStreaming = lib.mkOption {
        type = t.bool;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.int;
        };
        maxChars = lib.mkOption {
          type = t.int;
        };
        minChars = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      capabilities = lib.mkOption {
        type = t.listOf (t.str);
      };
      commands = lib.mkOption {
        type = t.submodule { options = {
        native = lib.mkOption {
          type = t.oneOf [ t.bool t.enum [ "auto" ] ];
        };
        nativeSkills = lib.mkOption {
          type = t.oneOf [ t.bool t.enum [ "auto" ] ];
        };
      }; };
      };
      configWrites = lib.mkOption {
        type = t.bool;
      };
      dm = lib.mkOption {
        type = t.submodule { options = {
        allowFrom = lib.mkOption {
          type = t.listOf (t.oneOf [ t.str t.number ]);
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        groupChannels = lib.mkOption {
          type = t.listOf (t.oneOf [ t.str t.number ]);
        };
        groupEnabled = lib.mkOption {
          type = t.bool;
        };
        policy = lib.mkOption {
          type = t.enum [ "pairing" "allowlist" "open" "disabled" ];
        };
      }; };
      };
      dmHistoryLimit = lib.mkOption {
        type = t.int;
      };
      dms = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.int;
        };
      }; });
      };
      enabled = lib.mkOption {
        type = t.bool;
      };
      groupPolicy = lib.mkOption {
        type = t.enum [ "open" "disabled" "allowlist" ];
      };
      guilds = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        channels = lib.mkOption {
          type = t.attrsOf (t.submodule { options = {
          allow = lib.mkOption {
            type = t.bool;
          };
          autoThread = lib.mkOption {
            type = t.bool;
          };
          enabled = lib.mkOption {
            type = t.bool;
          };
          requireMention = lib.mkOption {
            type = t.bool;
          };
          skills = lib.mkOption {
            type = t.listOf (t.str);
          };
          systemPrompt = lib.mkOption {
            type = t.str;
          };
          users = lib.mkOption {
            type = t.listOf (t.oneOf [ t.str t.number ]);
          };
        }; });
        };
        reactionNotifications = lib.mkOption {
          type = t.enum [ "off" "own" "all" "allowlist" ];
        };
        requireMention = lib.mkOption {
          type = t.bool;
        };
        slug = lib.mkOption {
          type = t.str;
        };
        users = lib.mkOption {
          type = t.listOf (t.oneOf [ t.str t.number ]);
        };
      }; });
      };
      historyLimit = lib.mkOption {
        type = t.int;
      };
      maxLinesPerMessage = lib.mkOption {
        type = t.int;
      };
      mediaMaxMb = lib.mkOption {
        type = t.number;
      };
      name = lib.mkOption {
        type = t.str;
      };
      replyToMode = lib.mkOption {
        type = t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ];
      };
      retry = lib.mkOption {
        type = t.submodule { options = {
        attempts = lib.mkOption {
          type = t.int;
        };
        jitter = lib.mkOption {
          type = t.number;
        };
        maxDelayMs = lib.mkOption {
          type = t.int;
        };
        minDelayMs = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      textChunkLimit = lib.mkOption {
        type = t.int;
      };
      token = lib.mkOption {
        type = t.str;
      };
    }; };
    };
    imessage = lib.mkOption {
      type = t.submodule { options = {
      accounts = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        allowFrom = lib.mkOption {
          type = t.listOf (t.oneOf [ t.str t.number ]);
        };
        blockStreaming = lib.mkOption {
          type = t.bool;
        };
        blockStreamingCoalesce = lib.mkOption {
          type = t.submodule { options = {
          idleMs = lib.mkOption {
            type = t.int;
          };
          maxChars = lib.mkOption {
            type = t.int;
          };
          minChars = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        capabilities = lib.mkOption {
          type = t.listOf (t.str);
        };
        cliPath = lib.mkOption {
          type = t.str;
        };
        configWrites = lib.mkOption {
          type = t.bool;
        };
        dbPath = lib.mkOption {
          type = t.str;
        };
        dmHistoryLimit = lib.mkOption {
          type = t.int;
        };
        dmPolicy = lib.mkOption {
          type = t.enum [ "pairing" "allowlist" "open" "disabled" ];
        };
        dms = lib.mkOption {
          type = t.attrsOf (t.submodule { options = {
          historyLimit = lib.mkOption {
            type = t.int;
          };
        }; });
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        groupAllowFrom = lib.mkOption {
          type = t.listOf (t.oneOf [ t.str t.number ]);
        };
        groupPolicy = lib.mkOption {
          type = t.enum [ "open" "disabled" "allowlist" ];
        };
        groups = lib.mkOption {
          type = t.attrsOf (t.submodule { options = {
          requireMention = lib.mkOption {
            type = t.bool;
          };
        }; });
        };
        historyLimit = lib.mkOption {
          type = t.int;
        };
        includeAttachments = lib.mkOption {
          type = t.bool;
        };
        mediaMaxMb = lib.mkOption {
          type = t.int;
        };
        name = lib.mkOption {
          type = t.str;
        };
        region = lib.mkOption {
          type = t.str;
        };
        remoteHost = lib.mkOption {
          type = t.str;
        };
        service = lib.mkOption {
          type = t.oneOf [ t.enum [ "imessage" ] t.enum [ "sms" ] t.enum [ "auto" ] ];
        };
        textChunkLimit = lib.mkOption {
          type = t.int;
        };
      }; });
      };
      allowFrom = lib.mkOption {
        type = t.listOf (t.oneOf [ t.str t.number ]);
      };
      blockStreaming = lib.mkOption {
        type = t.bool;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.int;
        };
        maxChars = lib.mkOption {
          type = t.int;
        };
        minChars = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      capabilities = lib.mkOption {
        type = t.listOf (t.str);
      };
      cliPath = lib.mkOption {
        type = t.str;
      };
      configWrites = lib.mkOption {
        type = t.bool;
      };
      dbPath = lib.mkOption {
        type = t.str;
      };
      dmHistoryLimit = lib.mkOption {
        type = t.int;
      };
      dmPolicy = lib.mkOption {
        type = t.enum [ "pairing" "allowlist" "open" "disabled" ];
      };
      dms = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.int;
        };
      }; });
      };
      enabled = lib.mkOption {
        type = t.bool;
      };
      groupAllowFrom = lib.mkOption {
        type = t.listOf (t.oneOf [ t.str t.number ]);
      };
      groupPolicy = lib.mkOption {
        type = t.enum [ "open" "disabled" "allowlist" ];
      };
      groups = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        requireMention = lib.mkOption {
          type = t.bool;
        };
      }; });
      };
      historyLimit = lib.mkOption {
        type = t.int;
      };
      includeAttachments = lib.mkOption {
        type = t.bool;
      };
      mediaMaxMb = lib.mkOption {
        type = t.int;
      };
      name = lib.mkOption {
        type = t.str;
      };
      region = lib.mkOption {
        type = t.str;
      };
      remoteHost = lib.mkOption {
        type = t.str;
      };
      service = lib.mkOption {
        type = t.oneOf [ t.enum [ "imessage" ] t.enum [ "sms" ] t.enum [ "auto" ] ];
      };
      textChunkLimit = lib.mkOption {
        type = t.int;
      };
    }; };
    };
    msteams = lib.mkOption {
      type = t.submodule { options = {
      allowFrom = lib.mkOption {
        type = t.listOf (t.str);
      };
      appId = lib.mkOption {
        type = t.str;
      };
      appPassword = lib.mkOption {
        type = t.str;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.int;
        };
        maxChars = lib.mkOption {
          type = t.int;
        };
        minChars = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      capabilities = lib.mkOption {
        type = t.listOf (t.str);
      };
      configWrites = lib.mkOption {
        type = t.bool;
      };
      dmHistoryLimit = lib.mkOption {
        type = t.int;
      };
      dmPolicy = lib.mkOption {
        type = t.enum [ "pairing" "allowlist" "open" "disabled" ];
      };
      dms = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.int;
        };
      }; });
      };
      enabled = lib.mkOption {
        type = t.bool;
      };
      groupAllowFrom = lib.mkOption {
        type = t.listOf (t.str);
      };
      groupPolicy = lib.mkOption {
        type = t.enum [ "open" "disabled" "allowlist" ];
      };
      historyLimit = lib.mkOption {
        type = t.int;
      };
      mediaAllowHosts = lib.mkOption {
        type = t.listOf (t.str);
      };
      replyStyle = lib.mkOption {
        type = t.enum [ "thread" "top-level" ];
      };
      requireMention = lib.mkOption {
        type = t.bool;
      };
      teams = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        channels = lib.mkOption {
          type = t.attrsOf (t.submodule { options = {
          replyStyle = lib.mkOption {
            type = t.enum [ "thread" "top-level" ];
          };
          requireMention = lib.mkOption {
            type = t.bool;
          };
        }; });
        };
        replyStyle = lib.mkOption {
          type = t.enum [ "thread" "top-level" ];
        };
        requireMention = lib.mkOption {
          type = t.bool;
        };
      }; });
      };
      tenantId = lib.mkOption {
        type = t.str;
      };
      textChunkLimit = lib.mkOption {
        type = t.int;
      };
      webhook = lib.mkOption {
        type = t.submodule { options = {
        path = lib.mkOption {
          type = t.str;
        };
        port = lib.mkOption {
          type = t.int;
        };
      }; };
      };
    }; };
    };
    signal = lib.mkOption {
      type = t.submodule { options = {
      account = lib.mkOption {
        type = t.str;
      };
      accounts = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        account = lib.mkOption {
          type = t.str;
        };
        allowFrom = lib.mkOption {
          type = t.listOf (t.oneOf [ t.str t.number ]);
        };
        autoStart = lib.mkOption {
          type = t.bool;
        };
        blockStreaming = lib.mkOption {
          type = t.bool;
        };
        blockStreamingCoalesce = lib.mkOption {
          type = t.submodule { options = {
          idleMs = lib.mkOption {
            type = t.int;
          };
          maxChars = lib.mkOption {
            type = t.int;
          };
          minChars = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        capabilities = lib.mkOption {
          type = t.listOf (t.str);
        };
        cliPath = lib.mkOption {
          type = t.str;
        };
        configWrites = lib.mkOption {
          type = t.bool;
        };
        dmHistoryLimit = lib.mkOption {
          type = t.int;
        };
        dmPolicy = lib.mkOption {
          type = t.enum [ "pairing" "allowlist" "open" "disabled" ];
        };
        dms = lib.mkOption {
          type = t.attrsOf (t.submodule { options = {
          historyLimit = lib.mkOption {
            type = t.int;
          };
        }; });
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        groupAllowFrom = lib.mkOption {
          type = t.listOf (t.oneOf [ t.str t.number ]);
        };
        groupPolicy = lib.mkOption {
          type = t.enum [ "open" "disabled" "allowlist" ];
        };
        historyLimit = lib.mkOption {
          type = t.int;
        };
        httpHost = lib.mkOption {
          type = t.str;
        };
        httpPort = lib.mkOption {
          type = t.int;
        };
        httpUrl = lib.mkOption {
          type = t.str;
        };
        ignoreAttachments = lib.mkOption {
          type = t.bool;
        };
        ignoreStories = lib.mkOption {
          type = t.bool;
        };
        mediaMaxMb = lib.mkOption {
          type = t.int;
        };
        name = lib.mkOption {
          type = t.str;
        };
        reactionAllowlist = lib.mkOption {
          type = t.listOf (t.oneOf [ t.str t.number ]);
        };
        reactionNotifications = lib.mkOption {
          type = t.enum [ "off" "own" "all" "allowlist" ];
        };
        receiveMode = lib.mkOption {
          type = t.oneOf [ t.enum [ "on-start" ] t.enum [ "manual" ] ];
        };
        sendReadReceipts = lib.mkOption {
          type = t.bool;
        };
        textChunkLimit = lib.mkOption {
          type = t.int;
        };
      }; });
      };
      allowFrom = lib.mkOption {
        type = t.listOf (t.oneOf [ t.str t.number ]);
      };
      autoStart = lib.mkOption {
        type = t.bool;
      };
      blockStreaming = lib.mkOption {
        type = t.bool;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.int;
        };
        maxChars = lib.mkOption {
          type = t.int;
        };
        minChars = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      capabilities = lib.mkOption {
        type = t.listOf (t.str);
      };
      cliPath = lib.mkOption {
        type = t.str;
      };
      configWrites = lib.mkOption {
        type = t.bool;
      };
      dmHistoryLimit = lib.mkOption {
        type = t.int;
      };
      dmPolicy = lib.mkOption {
        type = t.enum [ "pairing" "allowlist" "open" "disabled" ];
      };
      dms = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.int;
        };
      }; });
      };
      enabled = lib.mkOption {
        type = t.bool;
      };
      groupAllowFrom = lib.mkOption {
        type = t.listOf (t.oneOf [ t.str t.number ]);
      };
      groupPolicy = lib.mkOption {
        type = t.enum [ "open" "disabled" "allowlist" ];
      };
      historyLimit = lib.mkOption {
        type = t.int;
      };
      httpHost = lib.mkOption {
        type = t.str;
      };
      httpPort = lib.mkOption {
        type = t.int;
      };
      httpUrl = lib.mkOption {
        type = t.str;
      };
      ignoreAttachments = lib.mkOption {
        type = t.bool;
      };
      ignoreStories = lib.mkOption {
        type = t.bool;
      };
      mediaMaxMb = lib.mkOption {
        type = t.int;
      };
      name = lib.mkOption {
        type = t.str;
      };
      reactionAllowlist = lib.mkOption {
        type = t.listOf (t.oneOf [ t.str t.number ]);
      };
      reactionNotifications = lib.mkOption {
        type = t.enum [ "off" "own" "all" "allowlist" ];
      };
      receiveMode = lib.mkOption {
        type = t.oneOf [ t.enum [ "on-start" ] t.enum [ "manual" ] ];
      };
      sendReadReceipts = lib.mkOption {
        type = t.bool;
      };
      textChunkLimit = lib.mkOption {
        type = t.int;
      };
    }; };
    };
    slack = lib.mkOption {
      type = t.submodule { options = {
      accounts = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        actions = lib.mkOption {
          type = t.submodule { options = {
          channelInfo = lib.mkOption {
            type = t.bool;
          };
          emojiList = lib.mkOption {
            type = t.bool;
          };
          memberInfo = lib.mkOption {
            type = t.bool;
          };
          messages = lib.mkOption {
            type = t.bool;
          };
          permissions = lib.mkOption {
            type = t.bool;
          };
          pins = lib.mkOption {
            type = t.bool;
          };
          reactions = lib.mkOption {
            type = t.bool;
          };
          search = lib.mkOption {
            type = t.bool;
          };
        }; };
        };
        allowBots = lib.mkOption {
          type = t.bool;
        };
        appToken = lib.mkOption {
          type = t.str;
        };
        blockStreaming = lib.mkOption {
          type = t.bool;
        };
        blockStreamingCoalesce = lib.mkOption {
          type = t.submodule { options = {
          idleMs = lib.mkOption {
            type = t.int;
          };
          maxChars = lib.mkOption {
            type = t.int;
          };
          minChars = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        botToken = lib.mkOption {
          type = t.str;
        };
        capabilities = lib.mkOption {
          type = t.listOf (t.str);
        };
        channels = lib.mkOption {
          type = t.attrsOf (t.submodule { options = {
          allow = lib.mkOption {
            type = t.bool;
          };
          allowBots = lib.mkOption {
            type = t.bool;
          };
          enabled = lib.mkOption {
            type = t.bool;
          };
          requireMention = lib.mkOption {
            type = t.bool;
          };
          skills = lib.mkOption {
            type = t.listOf (t.str);
          };
          systemPrompt = lib.mkOption {
            type = t.str;
          };
          users = lib.mkOption {
            type = t.listOf (t.oneOf [ t.str t.number ]);
          };
        }; });
        };
        commands = lib.mkOption {
          type = t.submodule { options = {
          native = lib.mkOption {
            type = t.oneOf [ t.bool t.enum [ "auto" ] ];
          };
          nativeSkills = lib.mkOption {
            type = t.oneOf [ t.bool t.enum [ "auto" ] ];
          };
        }; };
        };
        configWrites = lib.mkOption {
          type = t.bool;
        };
        dm = lib.mkOption {
          type = t.submodule { options = {
          allowFrom = lib.mkOption {
            type = t.listOf (t.oneOf [ t.str t.number ]);
          };
          enabled = lib.mkOption {
            type = t.bool;
          };
          groupChannels = lib.mkOption {
            type = t.listOf (t.oneOf [ t.str t.number ]);
          };
          groupEnabled = lib.mkOption {
            type = t.bool;
          };
          policy = lib.mkOption {
            type = t.enum [ "pairing" "allowlist" "open" "disabled" ];
          };
        }; };
        };
        dmHistoryLimit = lib.mkOption {
          type = t.int;
        };
        dms = lib.mkOption {
          type = t.attrsOf (t.submodule { options = {
          historyLimit = lib.mkOption {
            type = t.int;
          };
        }; });
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        groupPolicy = lib.mkOption {
          type = t.enum [ "open" "disabled" "allowlist" ];
        };
        historyLimit = lib.mkOption {
          type = t.int;
        };
        mediaMaxMb = lib.mkOption {
          type = t.number;
        };
        name = lib.mkOption {
          type = t.str;
        };
        reactionAllowlist = lib.mkOption {
          type = t.listOf (t.oneOf [ t.str t.number ]);
        };
        reactionNotifications = lib.mkOption {
          type = t.enum [ "off" "own" "all" "allowlist" ];
        };
        replyToMode = lib.mkOption {
          type = t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ];
        };
        requireMention = lib.mkOption {
          type = t.bool;
        };
        slashCommand = lib.mkOption {
          type = t.submodule { options = {
          enabled = lib.mkOption {
            type = t.bool;
          };
          ephemeral = lib.mkOption {
            type = t.bool;
          };
          name = lib.mkOption {
            type = t.str;
          };
          sessionPrefix = lib.mkOption {
            type = t.str;
          };
        }; };
        };
        textChunkLimit = lib.mkOption {
          type = t.int;
        };
        thread = lib.mkOption {
          type = t.submodule { options = {
          historyScope = lib.mkOption {
            type = t.enum [ "thread" "channel" ];
          };
          inheritParent = lib.mkOption {
            type = t.bool;
          };
        }; };
        };
        userToken = lib.mkOption {
          type = t.str;
        };
        userTokenReadOnly = lib.mkOption {
          type = t.bool;
        };
      }; });
      };
      actions = lib.mkOption {
        type = t.submodule { options = {
        channelInfo = lib.mkOption {
          type = t.bool;
        };
        emojiList = lib.mkOption {
          type = t.bool;
        };
        memberInfo = lib.mkOption {
          type = t.bool;
        };
        messages = lib.mkOption {
          type = t.bool;
        };
        permissions = lib.mkOption {
          type = t.bool;
        };
        pins = lib.mkOption {
          type = t.bool;
        };
        reactions = lib.mkOption {
          type = t.bool;
        };
        search = lib.mkOption {
          type = t.bool;
        };
      }; };
      };
      allowBots = lib.mkOption {
        type = t.bool;
      };
      appToken = lib.mkOption {
        type = t.str;
      };
      blockStreaming = lib.mkOption {
        type = t.bool;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.int;
        };
        maxChars = lib.mkOption {
          type = t.int;
        };
        minChars = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      botToken = lib.mkOption {
        type = t.str;
      };
      capabilities = lib.mkOption {
        type = t.listOf (t.str);
      };
      channels = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        allow = lib.mkOption {
          type = t.bool;
        };
        allowBots = lib.mkOption {
          type = t.bool;
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        requireMention = lib.mkOption {
          type = t.bool;
        };
        skills = lib.mkOption {
          type = t.listOf (t.str);
        };
        systemPrompt = lib.mkOption {
          type = t.str;
        };
        users = lib.mkOption {
          type = t.listOf (t.oneOf [ t.str t.number ]);
        };
      }; });
      };
      commands = lib.mkOption {
        type = t.submodule { options = {
        native = lib.mkOption {
          type = t.oneOf [ t.bool t.enum [ "auto" ] ];
        };
        nativeSkills = lib.mkOption {
          type = t.oneOf [ t.bool t.enum [ "auto" ] ];
        };
      }; };
      };
      configWrites = lib.mkOption {
        type = t.bool;
      };
      dm = lib.mkOption {
        type = t.submodule { options = {
        allowFrom = lib.mkOption {
          type = t.listOf (t.oneOf [ t.str t.number ]);
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        groupChannels = lib.mkOption {
          type = t.listOf (t.oneOf [ t.str t.number ]);
        };
        groupEnabled = lib.mkOption {
          type = t.bool;
        };
        policy = lib.mkOption {
          type = t.enum [ "pairing" "allowlist" "open" "disabled" ];
        };
      }; };
      };
      dmHistoryLimit = lib.mkOption {
        type = t.int;
      };
      dms = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.int;
        };
      }; });
      };
      enabled = lib.mkOption {
        type = t.bool;
      };
      groupPolicy = lib.mkOption {
        type = t.enum [ "open" "disabled" "allowlist" ];
      };
      historyLimit = lib.mkOption {
        type = t.int;
      };
      mediaMaxMb = lib.mkOption {
        type = t.number;
      };
      name = lib.mkOption {
        type = t.str;
      };
      reactionAllowlist = lib.mkOption {
        type = t.listOf (t.oneOf [ t.str t.number ]);
      };
      reactionNotifications = lib.mkOption {
        type = t.enum [ "off" "own" "all" "allowlist" ];
      };
      replyToMode = lib.mkOption {
        type = t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ];
      };
      requireMention = lib.mkOption {
        type = t.bool;
      };
      slashCommand = lib.mkOption {
        type = t.submodule { options = {
        enabled = lib.mkOption {
          type = t.bool;
        };
        ephemeral = lib.mkOption {
          type = t.bool;
        };
        name = lib.mkOption {
          type = t.str;
        };
        sessionPrefix = lib.mkOption {
          type = t.str;
        };
      }; };
      };
      textChunkLimit = lib.mkOption {
        type = t.int;
      };
      thread = lib.mkOption {
        type = t.submodule { options = {
        historyScope = lib.mkOption {
          type = t.enum [ "thread" "channel" ];
        };
        inheritParent = lib.mkOption {
          type = t.bool;
        };
      }; };
      };
      userToken = lib.mkOption {
        type = t.str;
      };
      userTokenReadOnly = lib.mkOption {
        type = t.bool;
      };
    }; };
    };
    telegram = lib.mkOption {
      type = t.submodule { options = {
      accounts = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        actions = lib.mkOption {
          type = t.submodule { options = {
          deleteMessage = lib.mkOption {
            type = t.bool;
          };
          reactions = lib.mkOption {
            type = t.bool;
          };
          sendMessage = lib.mkOption {
            type = t.bool;
          };
        }; };
        };
        allowFrom = lib.mkOption {
          type = t.listOf (t.oneOf [ t.str t.number ]);
        };
        blockStreaming = lib.mkOption {
          type = t.bool;
        };
        blockStreamingCoalesce = lib.mkOption {
          type = t.submodule { options = {
          idleMs = lib.mkOption {
            type = t.int;
          };
          maxChars = lib.mkOption {
            type = t.int;
          };
          minChars = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        botToken = lib.mkOption {
          type = t.str;
        };
        capabilities = lib.mkOption {
          type = t.oneOf [ t.listOf (t.str) t.submodule { options = {
          inlineButtons = lib.mkOption {
            type = t.enum [ "off" "dm" "group" "all" "allowlist" ];
          };
        }; } ];
        };
        commands = lib.mkOption {
          type = t.submodule { options = {
          native = lib.mkOption {
            type = t.oneOf [ t.bool t.enum [ "auto" ] ];
          };
          nativeSkills = lib.mkOption {
            type = t.oneOf [ t.bool t.enum [ "auto" ] ];
          };
        }; };
        };
        configWrites = lib.mkOption {
          type = t.bool;
        };
        customCommands = lib.mkOption {
          type = t.listOf (t.submodule { options = {
          command = lib.mkOption {
            type = t.anything;
          };
          description = lib.mkOption {
            type = t.anything;
          };
        }; });
        };
        dmHistoryLimit = lib.mkOption {
          type = t.int;
        };
        dmPolicy = lib.mkOption {
          type = t.enum [ "pairing" "allowlist" "open" "disabled" ];
        };
        dms = lib.mkOption {
          type = t.attrsOf (t.submodule { options = {
          historyLimit = lib.mkOption {
            type = t.int;
          };
        }; });
        };
        draftChunk = lib.mkOption {
          type = t.submodule { options = {
          breakPreference = lib.mkOption {
            type = t.oneOf [ t.enum [ "paragraph" ] t.enum [ "newline" ] t.enum [ "sentence" ] ];
          };
          maxChars = lib.mkOption {
            type = t.int;
          };
          minChars = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        groupAllowFrom = lib.mkOption {
          type = t.listOf (t.oneOf [ t.str t.number ]);
        };
        groupPolicy = lib.mkOption {
          type = t.enum [ "open" "disabled" "allowlist" ];
        };
        groups = lib.mkOption {
          type = t.attrsOf (t.submodule { options = {
          allowFrom = lib.mkOption {
            type = t.listOf (t.oneOf [ t.str t.number ]);
          };
          enabled = lib.mkOption {
            type = t.bool;
          };
          requireMention = lib.mkOption {
            type = t.bool;
          };
          skills = lib.mkOption {
            type = t.listOf (t.str);
          };
          systemPrompt = lib.mkOption {
            type = t.str;
          };
          topics = lib.mkOption {
            type = t.attrsOf (t.submodule { options = {
            allowFrom = lib.mkOption {
              type = t.listOf (t.oneOf [ t.str t.number ]);
            };
            enabled = lib.mkOption {
              type = t.bool;
            };
            requireMention = lib.mkOption {
              type = t.bool;
            };
            skills = lib.mkOption {
              type = t.listOf (t.str);
            };
            systemPrompt = lib.mkOption {
              type = t.str;
            };
          }; });
          };
        }; });
        };
        historyLimit = lib.mkOption {
          type = t.int;
        };
        mediaMaxMb = lib.mkOption {
          type = t.number;
        };
        name = lib.mkOption {
          type = t.str;
        };
        proxy = lib.mkOption {
          type = t.str;
        };
        reactionLevel = lib.mkOption {
          type = t.enum [ "off" "ack" "minimal" "extensive" ];
        };
        reactionNotifications = lib.mkOption {
          type = t.enum [ "off" "own" "all" ];
        };
        replyToMode = lib.mkOption {
          type = t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ];
        };
        retry = lib.mkOption {
          type = t.submodule { options = {
          attempts = lib.mkOption {
            type = t.int;
          };
          jitter = lib.mkOption {
            type = t.number;
          };
          maxDelayMs = lib.mkOption {
            type = t.int;
          };
          minDelayMs = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        streamMode = lib.mkOption {
          type = t.enum [ "off" "partial" "block" ];
        };
        textChunkLimit = lib.mkOption {
          type = t.int;
        };
        timeoutSeconds = lib.mkOption {
          type = t.int;
        };
        tokenFile = lib.mkOption {
          type = t.str;
        };
        webhookPath = lib.mkOption {
          type = t.str;
        };
        webhookSecret = lib.mkOption {
          type = t.str;
        };
        webhookUrl = lib.mkOption {
          type = t.str;
        };
      }; });
      };
      actions = lib.mkOption {
        type = t.submodule { options = {
        deleteMessage = lib.mkOption {
          type = t.bool;
        };
        reactions = lib.mkOption {
          type = t.bool;
        };
        sendMessage = lib.mkOption {
          type = t.bool;
        };
      }; };
      };
      allowFrom = lib.mkOption {
        type = t.listOf (t.oneOf [ t.str t.number ]);
      };
      blockStreaming = lib.mkOption {
        type = t.bool;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.int;
        };
        maxChars = lib.mkOption {
          type = t.int;
        };
        minChars = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      botToken = lib.mkOption {
        type = t.str;
      };
      capabilities = lib.mkOption {
        type = t.oneOf [ t.listOf (t.str) t.submodule { options = {
        inlineButtons = lib.mkOption {
          type = t.enum [ "off" "dm" "group" "all" "allowlist" ];
        };
      }; } ];
      };
      commands = lib.mkOption {
        type = t.submodule { options = {
        native = lib.mkOption {
          type = t.oneOf [ t.bool t.enum [ "auto" ] ];
        };
        nativeSkills = lib.mkOption {
          type = t.oneOf [ t.bool t.enum [ "auto" ] ];
        };
      }; };
      };
      configWrites = lib.mkOption {
        type = t.bool;
      };
      customCommands = lib.mkOption {
        type = t.listOf (t.submodule { options = {
        command = lib.mkOption {
          type = t.anything;
        };
        description = lib.mkOption {
          type = t.anything;
        };
      }; });
      };
      dmHistoryLimit = lib.mkOption {
        type = t.int;
      };
      dmPolicy = lib.mkOption {
        type = t.enum [ "pairing" "allowlist" "open" "disabled" ];
      };
      dms = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.int;
        };
      }; });
      };
      draftChunk = lib.mkOption {
        type = t.submodule { options = {
        breakPreference = lib.mkOption {
          type = t.oneOf [ t.enum [ "paragraph" ] t.enum [ "newline" ] t.enum [ "sentence" ] ];
        };
        maxChars = lib.mkOption {
          type = t.int;
        };
        minChars = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      enabled = lib.mkOption {
        type = t.bool;
      };
      groupAllowFrom = lib.mkOption {
        type = t.listOf (t.oneOf [ t.str t.number ]);
      };
      groupPolicy = lib.mkOption {
        type = t.enum [ "open" "disabled" "allowlist" ];
      };
      groups = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        allowFrom = lib.mkOption {
          type = t.listOf (t.oneOf [ t.str t.number ]);
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        requireMention = lib.mkOption {
          type = t.bool;
        };
        skills = lib.mkOption {
          type = t.listOf (t.str);
        };
        systemPrompt = lib.mkOption {
          type = t.str;
        };
        topics = lib.mkOption {
          type = t.attrsOf (t.submodule { options = {
          allowFrom = lib.mkOption {
            type = t.listOf (t.oneOf [ t.str t.number ]);
          };
          enabled = lib.mkOption {
            type = t.bool;
          };
          requireMention = lib.mkOption {
            type = t.bool;
          };
          skills = lib.mkOption {
            type = t.listOf (t.str);
          };
          systemPrompt = lib.mkOption {
            type = t.str;
          };
        }; });
        };
      }; });
      };
      historyLimit = lib.mkOption {
        type = t.int;
      };
      mediaMaxMb = lib.mkOption {
        type = t.number;
      };
      name = lib.mkOption {
        type = t.str;
      };
      proxy = lib.mkOption {
        type = t.str;
      };
      reactionLevel = lib.mkOption {
        type = t.enum [ "off" "ack" "minimal" "extensive" ];
      };
      reactionNotifications = lib.mkOption {
        type = t.enum [ "off" "own" "all" ];
      };
      replyToMode = lib.mkOption {
        type = t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ];
      };
      retry = lib.mkOption {
        type = t.submodule { options = {
        attempts = lib.mkOption {
          type = t.int;
        };
        jitter = lib.mkOption {
          type = t.number;
        };
        maxDelayMs = lib.mkOption {
          type = t.int;
        };
        minDelayMs = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      streamMode = lib.mkOption {
        type = t.enum [ "off" "partial" "block" ];
      };
      textChunkLimit = lib.mkOption {
        type = t.int;
      };
      timeoutSeconds = lib.mkOption {
        type = t.int;
      };
      tokenFile = lib.mkOption {
        type = t.str;
      };
      webhookPath = lib.mkOption {
        type = t.str;
      };
      webhookSecret = lib.mkOption {
        type = t.str;
      };
      webhookUrl = lib.mkOption {
        type = t.str;
      };
    }; };
    };
    whatsapp = lib.mkOption {
      type = t.submodule { options = {
      accounts = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        ackReaction = lib.mkOption {
          type = t.submodule { options = {
          direct = lib.mkOption {
            type = t.bool;
          };
          emoji = lib.mkOption {
            type = t.str;
          };
          group = lib.mkOption {
            type = t.enum [ "always" "mentions" "never" ];
          };
        }; };
        };
        allowFrom = lib.mkOption {
          type = t.listOf (t.str);
        };
        authDir = lib.mkOption {
          type = t.str;
        };
        blockStreaming = lib.mkOption {
          type = t.bool;
        };
        blockStreamingCoalesce = lib.mkOption {
          type = t.submodule { options = {
          idleMs = lib.mkOption {
            type = t.int;
          };
          maxChars = lib.mkOption {
            type = t.int;
          };
          minChars = lib.mkOption {
            type = t.int;
          };
        }; };
        };
        capabilities = lib.mkOption {
          type = t.listOf (t.str);
        };
        configWrites = lib.mkOption {
          type = t.bool;
        };
        debounceMs = lib.mkOption {
          type = t.int;
        };
        dmHistoryLimit = lib.mkOption {
          type = t.int;
        };
        dmPolicy = lib.mkOption {
          type = t.enum [ "pairing" "allowlist" "open" "disabled" ];
        };
        dms = lib.mkOption {
          type = t.attrsOf (t.submodule { options = {
          historyLimit = lib.mkOption {
            type = t.int;
          };
        }; });
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        groupAllowFrom = lib.mkOption {
          type = t.listOf (t.str);
        };
        groupPolicy = lib.mkOption {
          type = t.enum [ "open" "disabled" "allowlist" ];
        };
        groups = lib.mkOption {
          type = t.attrsOf (t.submodule { options = {
          requireMention = lib.mkOption {
            type = t.bool;
          };
        }; });
        };
        historyLimit = lib.mkOption {
          type = t.int;
        };
        mediaMaxMb = lib.mkOption {
          type = t.int;
        };
        messagePrefix = lib.mkOption {
          type = t.str;
        };
        name = lib.mkOption {
          type = t.str;
        };
        selfChatMode = lib.mkOption {
          type = t.bool;
        };
        sendReadReceipts = lib.mkOption {
          type = t.bool;
        };
        textChunkLimit = lib.mkOption {
          type = t.int;
        };
      }; });
      };
      ackReaction = lib.mkOption {
        type = t.submodule { options = {
        direct = lib.mkOption {
          type = t.bool;
        };
        emoji = lib.mkOption {
          type = t.str;
        };
        group = lib.mkOption {
          type = t.enum [ "always" "mentions" "never" ];
        };
      }; };
      };
      actions = lib.mkOption {
        type = t.submodule { options = {
        polls = lib.mkOption {
          type = t.bool;
        };
        reactions = lib.mkOption {
          type = t.bool;
        };
        sendMessage = lib.mkOption {
          type = t.bool;
        };
      }; };
      };
      allowFrom = lib.mkOption {
        type = t.listOf (t.str);
      };
      blockStreaming = lib.mkOption {
        type = t.bool;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.int;
        };
        maxChars = lib.mkOption {
          type = t.int;
        };
        minChars = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      capabilities = lib.mkOption {
        type = t.listOf (t.str);
      };
      configWrites = lib.mkOption {
        type = t.bool;
      };
      debounceMs = lib.mkOption {
        type = t.int;
      };
      dmHistoryLimit = lib.mkOption {
        type = t.int;
      };
      dmPolicy = lib.mkOption {
        type = t.enum [ "pairing" "allowlist" "open" "disabled" ];
      };
      dms = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.int;
        };
      }; });
      };
      groupAllowFrom = lib.mkOption {
        type = t.listOf (t.str);
      };
      groupPolicy = lib.mkOption {
        type = t.enum [ "open" "disabled" "allowlist" ];
      };
      groups = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        requireMention = lib.mkOption {
          type = t.bool;
        };
      }; });
      };
      historyLimit = lib.mkOption {
        type = t.int;
      };
      mediaMaxMb = lib.mkOption {
        type = t.int;
      };
      messagePrefix = lib.mkOption {
        type = t.str;
      };
      selfChatMode = lib.mkOption {
        type = t.bool;
      };
      sendReadReceipts = lib.mkOption {
        type = t.bool;
      };
      textChunkLimit = lib.mkOption {
        type = t.int;
      };
    }; };
    };
  }; };
  };

  commands = lib.mkOption {
    type = t.submodule { options = {
    bash = lib.mkOption {
      type = t.bool;
    };
    bashForegroundMs = lib.mkOption {
      type = t.int;
    };
    config = lib.mkOption {
      type = t.bool;
    };
    debug = lib.mkOption {
      type = t.bool;
    };
    native = lib.mkOption {
      type = t.oneOf [ t.bool t.enum [ "auto" ] ];
    };
    nativeSkills = lib.mkOption {
      type = t.oneOf [ t.bool t.enum [ "auto" ] ];
    };
    restart = lib.mkOption {
      type = t.bool;
    };
    text = lib.mkOption {
      type = t.bool;
    };
    useAccessGroups = lib.mkOption {
      type = t.bool;
    };
  }; };
  };

  cron = lib.mkOption {
    type = t.submodule { options = {
    enabled = lib.mkOption {
      type = t.bool;
    };
    maxConcurrentRuns = lib.mkOption {
      type = t.int;
    };
    store = lib.mkOption {
      type = t.str;
    };
  }; };
  };

  discovery = lib.mkOption {
    type = t.submodule { options = {
    wideArea = lib.mkOption {
      type = t.submodule { options = {
      enabled = lib.mkOption {
        type = t.bool;
      };
    }; };
    };
  }; };
  };

  env = lib.mkOption {
    type = t.submodule { options = {
    shellEnv = lib.mkOption {
      type = t.submodule { options = {
      enabled = lib.mkOption {
        type = t.bool;
      };
      timeoutMs = lib.mkOption {
        type = t.int;
      };
    }; };
    };
    vars = lib.mkOption {
      type = t.attrsOf (t.str);
    };
  }; };
  };

  gateway = lib.mkOption {
    type = t.submodule { options = {
    auth = lib.mkOption {
      type = t.submodule { options = {
      allowTailscale = lib.mkOption {
        type = t.bool;
      };
      mode = lib.mkOption {
        type = t.oneOf [ t.enum [ "token" ] t.enum [ "password" ] ];
      };
      password = lib.mkOption {
        type = t.str;
      };
      token = lib.mkOption {
        type = t.str;
      };
    }; };
    };
    bind = lib.mkOption {
      type = t.oneOf [ t.enum [ "auto" ] t.enum [ "lan" ] t.enum [ "tailnet" ] t.enum [ "loopback" ] ];
    };
    controlUi = lib.mkOption {
      type = t.submodule { options = {
      basePath = lib.mkOption {
        type = t.str;
      };
      enabled = lib.mkOption {
        type = t.bool;
      };
    }; };
    };
    http = lib.mkOption {
      type = t.submodule { options = {
      endpoints = lib.mkOption {
        type = t.submodule { options = {
        chatCompletions = lib.mkOption {
          type = t.submodule { options = {
          enabled = lib.mkOption {
            type = t.bool;
          };
        }; };
        };
      }; };
      };
    }; };
    };
    mode = lib.mkOption {
      type = t.oneOf [ t.enum [ "local" ] t.enum [ "remote" ] ];
    };
    port = lib.mkOption {
      type = t.int;
    };
    reload = lib.mkOption {
      type = t.submodule { options = {
      debounceMs = lib.mkOption {
        type = t.int;
      };
      mode = lib.mkOption {
        type = t.oneOf [ t.enum [ "off" ] t.enum [ "restart" ] t.enum [ "hot" ] t.enum [ "hybrid" ] ];
      };
    }; };
    };
    remote = lib.mkOption {
      type = t.submodule { options = {
      password = lib.mkOption {
        type = t.str;
      };
      sshIdentity = lib.mkOption {
        type = t.str;
      };
      sshTarget = lib.mkOption {
        type = t.str;
      };
      token = lib.mkOption {
        type = t.str;
      };
      url = lib.mkOption {
        type = t.str;
      };
    }; };
    };
    tailscale = lib.mkOption {
      type = t.submodule { options = {
      mode = lib.mkOption {
        type = t.oneOf [ t.enum [ "off" ] t.enum [ "serve" ] t.enum [ "funnel" ] ];
      };
      resetOnExit = lib.mkOption {
        type = t.bool;
      };
    }; };
    };
  }; };
  };

  hooks = lib.mkOption {
    type = t.submodule { options = {
    enabled = lib.mkOption {
      type = t.bool;
    };
    gmail = lib.mkOption {
      type = t.submodule { options = {
      account = lib.mkOption {
        type = t.str;
      };
      hookUrl = lib.mkOption {
        type = t.str;
      };
      includeBody = lib.mkOption {
        type = t.bool;
      };
      label = lib.mkOption {
        type = t.str;
      };
      maxBytes = lib.mkOption {
        type = t.int;
      };
      model = lib.mkOption {
        type = t.str;
      };
      pushToken = lib.mkOption {
        type = t.str;
      };
      renewEveryMinutes = lib.mkOption {
        type = t.int;
      };
      serve = lib.mkOption {
        type = t.submodule { options = {
        bind = lib.mkOption {
          type = t.str;
        };
        path = lib.mkOption {
          type = t.str;
        };
        port = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      subscription = lib.mkOption {
        type = t.str;
      };
      tailscale = lib.mkOption {
        type = t.submodule { options = {
        mode = lib.mkOption {
          type = t.oneOf [ t.enum [ "off" ] t.enum [ "serve" ] t.enum [ "funnel" ] ];
        };
        path = lib.mkOption {
          type = t.str;
        };
        target = lib.mkOption {
          type = t.str;
        };
      }; };
      };
      thinking = lib.mkOption {
        type = t.oneOf [ t.enum [ "off" ] t.enum [ "minimal" ] t.enum [ "low" ] t.enum [ "medium" ] t.enum [ "high" ] ];
      };
      topic = lib.mkOption {
        type = t.str;
      };
    }; };
    };
    internal = lib.mkOption {
      type = t.submodule { options = {
      enabled = lib.mkOption {
        type = t.bool;
      };
      entries = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        enabled = lib.mkOption {
          type = t.bool;
        };
        env = lib.mkOption {
          type = t.attrsOf (t.str);
        };
      }; });
      };
      handlers = lib.mkOption {
        type = t.listOf (t.submodule { options = {
        event = lib.mkOption {
          type = t.str;
        };
        export = lib.mkOption {
          type = t.str;
        };
        module = lib.mkOption {
          type = t.str;
        };
      }; });
      };
      installs = lib.mkOption {
        type = t.attrsOf (t.submodule { options = {
        hooks = lib.mkOption {
          type = t.listOf (t.str);
        };
        installPath = lib.mkOption {
          type = t.str;
        };
        installedAt = lib.mkOption {
          type = t.str;
        };
        source = lib.mkOption {
          type = t.oneOf [ t.enum [ "npm" ] t.enum [ "archive" ] t.enum [ "path" ] ];
        };
        sourcePath = lib.mkOption {
          type = t.str;
        };
        spec = lib.mkOption {
          type = t.str;
        };
        version = lib.mkOption {
          type = t.str;
        };
      }; });
      };
      load = lib.mkOption {
        type = t.submodule { options = {
        extraDirs = lib.mkOption {
          type = t.listOf (t.str);
        };
      }; };
      };
    }; };
    };
    mappings = lib.mkOption {
      type = t.listOf (t.submodule { options = {
      action = lib.mkOption {
        type = t.oneOf [ t.enum [ "wake" ] t.enum [ "agent" ] ];
      };
      channel = lib.mkOption {
        type = t.oneOf [ t.enum [ "last" ] t.enum [ "whatsapp" ] t.enum [ "telegram" ] t.enum [ "discord" ] t.enum [ "slack" ] t.enum [ "signal" ] t.enum [ "imessage" ] t.enum [ "msteams" ] ];
      };
      deliver = lib.mkOption {
        type = t.bool;
      };
      id = lib.mkOption {
        type = t.str;
      };
      match = lib.mkOption {
        type = t.submodule { options = {
        path = lib.mkOption {
          type = t.str;
        };
        source = lib.mkOption {
          type = t.str;
        };
      }; };
      };
      messageTemplate = lib.mkOption {
        type = t.str;
      };
      model = lib.mkOption {
        type = t.str;
      };
      name = lib.mkOption {
        type = t.str;
      };
      sessionKey = lib.mkOption {
        type = t.str;
      };
      textTemplate = lib.mkOption {
        type = t.str;
      };
      thinking = lib.mkOption {
        type = t.str;
      };
      timeoutSeconds = lib.mkOption {
        type = t.int;
      };
      to = lib.mkOption {
        type = t.str;
      };
      transform = lib.mkOption {
        type = t.submodule { options = {
        export = lib.mkOption {
          type = t.str;
        };
        module = lib.mkOption {
          type = t.str;
        };
      }; };
      };
      wakeMode = lib.mkOption {
        type = t.oneOf [ t.enum [ "now" ] t.enum [ "next-heartbeat" ] ];
      };
    }; });
    };
    maxBodyBytes = lib.mkOption {
      type = t.int;
    };
    path = lib.mkOption {
      type = t.str;
    };
    presets = lib.mkOption {
      type = t.listOf (t.str);
    };
    token = lib.mkOption {
      type = t.str;
    };
    transformsDir = lib.mkOption {
      type = t.str;
    };
  }; };
  };

  logging = lib.mkOption {
    type = t.submodule { options = {
    consoleLevel = lib.mkOption {
      type = t.oneOf [ t.enum [ "silent" ] t.enum [ "fatal" ] t.enum [ "error" ] t.enum [ "warn" ] t.enum [ "info" ] t.enum [ "debug" ] t.enum [ "trace" ] ];
    };
    consoleStyle = lib.mkOption {
      type = t.oneOf [ t.enum [ "pretty" ] t.enum [ "compact" ] t.enum [ "json" ] ];
    };
    file = lib.mkOption {
      type = t.str;
    };
    level = lib.mkOption {
      type = t.oneOf [ t.enum [ "silent" ] t.enum [ "fatal" ] t.enum [ "error" ] t.enum [ "warn" ] t.enum [ "info" ] t.enum [ "debug" ] t.enum [ "trace" ] ];
    };
    redactPatterns = lib.mkOption {
      type = t.listOf (t.str);
    };
    redactSensitive = lib.mkOption {
      type = t.oneOf [ t.enum [ "off" ] t.enum [ "tools" ] ];
    };
  }; };
  };

  messages = lib.mkOption {
    type = t.submodule { options = {
    ackReaction = lib.mkOption {
      type = t.str;
    };
    ackReactionScope = lib.mkOption {
      type = t.enum [ "group-mentions" "group-all" "direct" "all" ];
    };
    groupChat = lib.mkOption {
      type = t.submodule { options = {
      historyLimit = lib.mkOption {
        type = t.int;
      };
      mentionPatterns = lib.mkOption {
        type = t.listOf (t.str);
      };
    }; };
    };
    inbound = lib.mkOption {
      type = t.submodule { options = {
      byChannel = lib.mkOption {
        type = t.submodule { options = {
        discord = lib.mkOption {
          type = t.int;
        };
        imessage = lib.mkOption {
          type = t.int;
        };
        msteams = lib.mkOption {
          type = t.int;
        };
        signal = lib.mkOption {
          type = t.int;
        };
        slack = lib.mkOption {
          type = t.int;
        };
        telegram = lib.mkOption {
          type = t.int;
        };
        webchat = lib.mkOption {
          type = t.int;
        };
        whatsapp = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      debounceMs = lib.mkOption {
        type = t.int;
      };
    }; };
    };
    messagePrefix = lib.mkOption {
      type = t.str;
    };
    queue = lib.mkOption {
      type = t.submodule { options = {
      byChannel = lib.mkOption {
        type = t.submodule { options = {
        discord = lib.mkOption {
          type = t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ];
        };
        imessage = lib.mkOption {
          type = t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ];
        };
        msteams = lib.mkOption {
          type = t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ];
        };
        signal = lib.mkOption {
          type = t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ];
        };
        slack = lib.mkOption {
          type = t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ];
        };
        telegram = lib.mkOption {
          type = t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ];
        };
        webchat = lib.mkOption {
          type = t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ];
        };
        whatsapp = lib.mkOption {
          type = t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ];
        };
      }; };
      };
      cap = lib.mkOption {
        type = t.int;
      };
      debounceMs = lib.mkOption {
        type = t.int;
      };
      drop = lib.mkOption {
        type = t.oneOf [ t.enum [ "old" ] t.enum [ "new" ] t.enum [ "summarize" ] ];
      };
      mode = lib.mkOption {
        type = t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ];
      };
    }; };
    };
    removeAckAfterReply = lib.mkOption {
      type = t.bool;
    };
    responsePrefix = lib.mkOption {
      type = t.str;
    };
  }; };
  };

  models = lib.mkOption {
    type = t.submodule { options = {
    mode = lib.mkOption {
      type = t.oneOf [ t.enum [ "merge" ] t.enum [ "replace" ] ];
    };
    providers = lib.mkOption {
      type = t.attrsOf (t.submodule { options = {
      api = lib.mkOption {
        type = t.oneOf [ t.enum [ "openai-completions" ] t.enum [ "openai-responses" ] t.enum [ "anthropic-messages" ] t.enum [ "google-generative-ai" ] t.enum [ "github-copilot" ] ];
      };
      apiKey = lib.mkOption {
        type = t.str;
      };
      authHeader = lib.mkOption {
        type = t.bool;
      };
      baseUrl = lib.mkOption {
        type = t.str;
      };
      headers = lib.mkOption {
        type = t.attrsOf (t.str);
      };
      models = lib.mkOption {
        type = t.listOf (t.submodule { options = {
        api = lib.mkOption {
          type = t.oneOf [ t.enum [ "openai-completions" ] t.enum [ "openai-responses" ] t.enum [ "anthropic-messages" ] t.enum [ "google-generative-ai" ] t.enum [ "github-copilot" ] ];
        };
        compat = lib.mkOption {
          type = t.submodule { options = {
          maxTokensField = lib.mkOption {
            type = t.oneOf [ t.enum [ "max_completion_tokens" ] t.enum [ "max_tokens" ] ];
          };
          supportsDeveloperRole = lib.mkOption {
            type = t.bool;
          };
          supportsReasoningEffort = lib.mkOption {
            type = t.bool;
          };
          supportsStore = lib.mkOption {
            type = t.bool;
          };
        }; };
        };
        contextWindow = lib.mkOption {
          type = t.number;
        };
        cost = lib.mkOption {
          type = t.submodule { options = {
          cacheRead = lib.mkOption {
            type = t.number;
          };
          cacheWrite = lib.mkOption {
            type = t.number;
          };
          input = lib.mkOption {
            type = t.number;
          };
          output = lib.mkOption {
            type = t.number;
          };
        }; };
        };
        headers = lib.mkOption {
          type = t.attrsOf (t.str);
        };
        id = lib.mkOption {
          type = t.str;
        };
        input = lib.mkOption {
          type = t.listOf (t.oneOf [ t.enum [ "text" ] t.enum [ "image" ] ]);
        };
        maxTokens = lib.mkOption {
          type = t.number;
        };
        name = lib.mkOption {
          type = t.str;
        };
        reasoning = lib.mkOption {
          type = t.bool;
        };
      }; });
      };
    }; });
    };
  }; };
  };

  plugins = lib.mkOption {
    type = t.submodule { options = {
    allow = lib.mkOption {
      type = t.listOf (t.str);
    };
    deny = lib.mkOption {
      type = t.listOf (t.str);
    };
    enabled = lib.mkOption {
      type = t.bool;
    };
    entries = lib.mkOption {
      type = t.attrsOf (t.submodule { options = {
      config = lib.mkOption {
        type = t.attrsOf (t.anything);
      };
      enabled = lib.mkOption {
        type = t.bool;
      };
    }; });
    };
    installs = lib.mkOption {
      type = t.attrsOf (t.submodule { options = {
      installPath = lib.mkOption {
        type = t.str;
      };
      installedAt = lib.mkOption {
        type = t.str;
      };
      source = lib.mkOption {
        type = t.oneOf [ t.enum [ "npm" ] t.enum [ "archive" ] t.enum [ "path" ] ];
      };
      sourcePath = lib.mkOption {
        type = t.str;
      };
      spec = lib.mkOption {
        type = t.str;
      };
      version = lib.mkOption {
        type = t.str;
      };
    }; });
    };
    load = lib.mkOption {
      type = t.submodule { options = {
      paths = lib.mkOption {
        type = t.listOf (t.str);
      };
    }; };
    };
  }; };
  };

  session = lib.mkOption {
    type = t.submodule { options = {
    agentToAgent = lib.mkOption {
      type = t.submodule { options = {
      maxPingPongTurns = lib.mkOption {
        type = t.int;
      };
    }; };
    };
    dmScope = lib.mkOption {
      type = t.oneOf [ t.enum [ "main" ] t.enum [ "per-peer" ] t.enum [ "per-channel-peer" ] ];
    };
    heartbeatIdleMinutes = lib.mkOption {
      type = t.int;
    };
    identityLinks = lib.mkOption {
      type = t.attrsOf (t.listOf (t.str));
    };
    idleMinutes = lib.mkOption {
      type = t.int;
    };
    mainKey = lib.mkOption {
      type = t.str;
    };
    resetTriggers = lib.mkOption {
      type = t.listOf (t.str);
    };
    scope = lib.mkOption {
      type = t.oneOf [ t.enum [ "per-sender" ] t.enum [ "global" ] ];
    };
    sendPolicy = lib.mkOption {
      type = t.submodule { options = {
      default = lib.mkOption {
        type = t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ];
      };
      rules = lib.mkOption {
        type = t.listOf (t.submodule { options = {
        action = lib.mkOption {
          type = t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ];
        };
        match = lib.mkOption {
          type = t.submodule { options = {
          channel = lib.mkOption {
            type = t.str;
          };
          chatType = lib.mkOption {
            type = t.oneOf [ t.enum [ "direct" ] t.enum [ "group" ] t.enum [ "channel" ] ];
          };
          keyPrefix = lib.mkOption {
            type = t.str;
          };
        }; };
        };
      }; });
      };
    }; };
    };
    store = lib.mkOption {
      type = t.str;
    };
    typingIntervalSeconds = lib.mkOption {
      type = t.int;
    };
    typingMode = lib.mkOption {
      type = t.oneOf [ t.enum [ "never" ] t.enum [ "instant" ] t.enum [ "thinking" ] t.enum [ "message" ] ];
    };
  }; };
  };

  skills = lib.mkOption {
    type = t.submodule { options = {
    allowBundled = lib.mkOption {
      type = t.listOf (t.str);
    };
    entries = lib.mkOption {
      type = t.attrsOf (t.submodule { options = {
      apiKey = lib.mkOption {
        type = t.str;
      };
      enabled = lib.mkOption {
        type = t.bool;
      };
      env = lib.mkOption {
        type = t.attrsOf (t.str);
      };
    }; });
    };
    install = lib.mkOption {
      type = t.submodule { options = {
      nodeManager = lib.mkOption {
        type = t.oneOf [ t.enum [ "npm" ] t.enum [ "pnpm" ] t.enum [ "yarn" ] t.enum [ "bun" ] ];
      };
      preferBrew = lib.mkOption {
        type = t.bool;
      };
    }; };
    };
    load = lib.mkOption {
      type = t.submodule { options = {
      extraDirs = lib.mkOption {
        type = t.listOf (t.str);
      };
      watch = lib.mkOption {
        type = t.bool;
      };
      watchDebounceMs = lib.mkOption {
        type = t.int;
      };
    }; };
    };
  }; };
  };

  talk = lib.mkOption {
    type = t.submodule { options = {
    apiKey = lib.mkOption {
      type = t.str;
    };
    interruptOnSpeech = lib.mkOption {
      type = t.bool;
    };
    modelId = lib.mkOption {
      type = t.str;
    };
    outputFormat = lib.mkOption {
      type = t.str;
    };
    voiceAliases = lib.mkOption {
      type = t.attrsOf (t.str);
    };
    voiceId = lib.mkOption {
      type = t.str;
    };
  }; };
  };

  tools = lib.mkOption {
    type = t.submodule { options = {
    agentToAgent = lib.mkOption {
      type = t.submodule { options = {
      allow = lib.mkOption {
        type = t.listOf (t.str);
      };
      enabled = lib.mkOption {
        type = t.bool;
      };
    }; };
    };
    allow = lib.mkOption {
      type = t.listOf (t.str);
    };
    byProvider = lib.mkOption {
      type = t.attrsOf (t.submodule { options = {
      allow = lib.mkOption {
        type = t.listOf (t.str);
      };
      deny = lib.mkOption {
        type = t.listOf (t.str);
      };
      profile = lib.mkOption {
        type = t.oneOf [ t.enum [ "minimal" ] t.enum [ "coding" ] t.enum [ "messaging" ] t.enum [ "full" ] ];
      };
    }; });
    };
    deny = lib.mkOption {
      type = t.listOf (t.str);
    };
    elevated = lib.mkOption {
      type = t.submodule { options = {
      allowFrom = lib.mkOption {
        type = t.attrsOf (t.listOf (t.oneOf [ t.str t.number ]));
      };
      enabled = lib.mkOption {
        type = t.bool;
      };
    }; };
    };
    exec = lib.mkOption {
      type = t.submodule { options = {
      applyPatch = lib.mkOption {
        type = t.submodule { options = {
        allowModels = lib.mkOption {
          type = t.listOf (t.str);
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
      }; };
      };
      backgroundMs = lib.mkOption {
        type = t.int;
      };
      cleanupMs = lib.mkOption {
        type = t.int;
      };
      notifyOnExit = lib.mkOption {
        type = t.bool;
      };
      timeoutSec = lib.mkOption {
        type = t.int;
      };
    }; };
    };
    media = lib.mkOption {
      type = t.submodule { options = {
      audio = lib.mkOption {
        type = t.submodule { options = {
        attachments = lib.mkOption {
          type = t.submodule { options = {
          maxAttachments = lib.mkOption {
            type = t.int;
          };
          mode = lib.mkOption {
            type = t.oneOf [ t.enum [ "first" ] t.enum [ "all" ] ];
          };
          prefer = lib.mkOption {
            type = t.oneOf [ t.enum [ "first" ] t.enum [ "last" ] t.enum [ "path" ] t.enum [ "url" ] ];
          };
        }; };
        };
        baseUrl = lib.mkOption {
          type = t.str;
        };
        deepgram = lib.mkOption {
          type = t.submodule { options = {
          detectLanguage = lib.mkOption {
            type = t.bool;
          };
          punctuate = lib.mkOption {
            type = t.bool;
          };
          smartFormat = lib.mkOption {
            type = t.bool;
          };
        }; };
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        headers = lib.mkOption {
          type = t.attrsOf (t.str);
        };
        language = lib.mkOption {
          type = t.str;
        };
        maxBytes = lib.mkOption {
          type = t.int;
        };
        maxChars = lib.mkOption {
          type = t.int;
        };
        models = lib.mkOption {
          type = t.listOf (t.submodule { options = {
          args = lib.mkOption {
            type = t.listOf (t.str);
          };
          baseUrl = lib.mkOption {
            type = t.str;
          };
          capabilities = lib.mkOption {
            type = t.listOf (t.oneOf [ t.enum [ "image" ] t.enum [ "audio" ] t.enum [ "video" ] ]);
          };
          command = lib.mkOption {
            type = t.str;
          };
          deepgram = lib.mkOption {
            type = t.submodule { options = {
            detectLanguage = lib.mkOption {
              type = t.bool;
            };
            punctuate = lib.mkOption {
              type = t.bool;
            };
            smartFormat = lib.mkOption {
              type = t.bool;
            };
          }; };
          };
          headers = lib.mkOption {
            type = t.attrsOf (t.str);
          };
          language = lib.mkOption {
            type = t.str;
          };
          maxBytes = lib.mkOption {
            type = t.int;
          };
          maxChars = lib.mkOption {
            type = t.int;
          };
          model = lib.mkOption {
            type = t.str;
          };
          preferredProfile = lib.mkOption {
            type = t.str;
          };
          profile = lib.mkOption {
            type = t.str;
          };
          prompt = lib.mkOption {
            type = t.str;
          };
          provider = lib.mkOption {
            type = t.str;
          };
          providerOptions = lib.mkOption {
            type = t.attrsOf (t.attrsOf (t.oneOf [ t.str t.number t.bool ]));
          };
          timeoutSeconds = lib.mkOption {
            type = t.int;
          };
          type = lib.mkOption {
            type = t.oneOf [ t.enum [ "provider" ] t.enum [ "cli" ] ];
          };
        }; });
        };
        prompt = lib.mkOption {
          type = t.str;
        };
        providerOptions = lib.mkOption {
          type = t.attrsOf (t.attrsOf (t.oneOf [ t.str t.number t.bool ]));
        };
        scope = lib.mkOption {
          type = t.submodule { options = {
          default = lib.mkOption {
            type = t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ];
          };
          rules = lib.mkOption {
            type = t.listOf (t.submodule { options = {
            action = lib.mkOption {
              type = t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ];
            };
            match = lib.mkOption {
              type = t.submodule { options = {
              channel = lib.mkOption {
                type = t.str;
              };
              chatType = lib.mkOption {
                type = t.oneOf [ t.enum [ "direct" ] t.enum [ "group" ] t.enum [ "channel" ] ];
              };
              keyPrefix = lib.mkOption {
                type = t.str;
              };
            }; };
            };
          }; });
          };
        }; };
        };
        timeoutSeconds = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      concurrency = lib.mkOption {
        type = t.int;
      };
      image = lib.mkOption {
        type = t.submodule { options = {
        attachments = lib.mkOption {
          type = t.submodule { options = {
          maxAttachments = lib.mkOption {
            type = t.int;
          };
          mode = lib.mkOption {
            type = t.oneOf [ t.enum [ "first" ] t.enum [ "all" ] ];
          };
          prefer = lib.mkOption {
            type = t.oneOf [ t.enum [ "first" ] t.enum [ "last" ] t.enum [ "path" ] t.enum [ "url" ] ];
          };
        }; };
        };
        baseUrl = lib.mkOption {
          type = t.str;
        };
        deepgram = lib.mkOption {
          type = t.submodule { options = {
          detectLanguage = lib.mkOption {
            type = t.bool;
          };
          punctuate = lib.mkOption {
            type = t.bool;
          };
          smartFormat = lib.mkOption {
            type = t.bool;
          };
        }; };
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        headers = lib.mkOption {
          type = t.attrsOf (t.str);
        };
        language = lib.mkOption {
          type = t.str;
        };
        maxBytes = lib.mkOption {
          type = t.int;
        };
        maxChars = lib.mkOption {
          type = t.int;
        };
        models = lib.mkOption {
          type = t.listOf (t.submodule { options = {
          args = lib.mkOption {
            type = t.listOf (t.str);
          };
          baseUrl = lib.mkOption {
            type = t.str;
          };
          capabilities = lib.mkOption {
            type = t.listOf (t.oneOf [ t.enum [ "image" ] t.enum [ "audio" ] t.enum [ "video" ] ]);
          };
          command = lib.mkOption {
            type = t.str;
          };
          deepgram = lib.mkOption {
            type = t.submodule { options = {
            detectLanguage = lib.mkOption {
              type = t.bool;
            };
            punctuate = lib.mkOption {
              type = t.bool;
            };
            smartFormat = lib.mkOption {
              type = t.bool;
            };
          }; };
          };
          headers = lib.mkOption {
            type = t.attrsOf (t.str);
          };
          language = lib.mkOption {
            type = t.str;
          };
          maxBytes = lib.mkOption {
            type = t.int;
          };
          maxChars = lib.mkOption {
            type = t.int;
          };
          model = lib.mkOption {
            type = t.str;
          };
          preferredProfile = lib.mkOption {
            type = t.str;
          };
          profile = lib.mkOption {
            type = t.str;
          };
          prompt = lib.mkOption {
            type = t.str;
          };
          provider = lib.mkOption {
            type = t.str;
          };
          providerOptions = lib.mkOption {
            type = t.attrsOf (t.attrsOf (t.oneOf [ t.str t.number t.bool ]));
          };
          timeoutSeconds = lib.mkOption {
            type = t.int;
          };
          type = lib.mkOption {
            type = t.oneOf [ t.enum [ "provider" ] t.enum [ "cli" ] ];
          };
        }; });
        };
        prompt = lib.mkOption {
          type = t.str;
        };
        providerOptions = lib.mkOption {
          type = t.attrsOf (t.attrsOf (t.oneOf [ t.str t.number t.bool ]));
        };
        scope = lib.mkOption {
          type = t.submodule { options = {
          default = lib.mkOption {
            type = t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ];
          };
          rules = lib.mkOption {
            type = t.listOf (t.submodule { options = {
            action = lib.mkOption {
              type = t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ];
            };
            match = lib.mkOption {
              type = t.submodule { options = {
              channel = lib.mkOption {
                type = t.str;
              };
              chatType = lib.mkOption {
                type = t.oneOf [ t.enum [ "direct" ] t.enum [ "group" ] t.enum [ "channel" ] ];
              };
              keyPrefix = lib.mkOption {
                type = t.str;
              };
            }; };
            };
          }; });
          };
        }; };
        };
        timeoutSeconds = lib.mkOption {
          type = t.int;
        };
      }; };
      };
      models = lib.mkOption {
        type = t.listOf (t.submodule { options = {
        args = lib.mkOption {
          type = t.listOf (t.str);
        };
        baseUrl = lib.mkOption {
          type = t.str;
        };
        capabilities = lib.mkOption {
          type = t.listOf (t.oneOf [ t.enum [ "image" ] t.enum [ "audio" ] t.enum [ "video" ] ]);
        };
        command = lib.mkOption {
          type = t.str;
        };
        deepgram = lib.mkOption {
          type = t.submodule { options = {
          detectLanguage = lib.mkOption {
            type = t.bool;
          };
          punctuate = lib.mkOption {
            type = t.bool;
          };
          smartFormat = lib.mkOption {
            type = t.bool;
          };
        }; };
        };
        headers = lib.mkOption {
          type = t.attrsOf (t.str);
        };
        language = lib.mkOption {
          type = t.str;
        };
        maxBytes = lib.mkOption {
          type = t.int;
        };
        maxChars = lib.mkOption {
          type = t.int;
        };
        model = lib.mkOption {
          type = t.str;
        };
        preferredProfile = lib.mkOption {
          type = t.str;
        };
        profile = lib.mkOption {
          type = t.str;
        };
        prompt = lib.mkOption {
          type = t.str;
        };
        provider = lib.mkOption {
          type = t.str;
        };
        providerOptions = lib.mkOption {
          type = t.attrsOf (t.attrsOf (t.oneOf [ t.str t.number t.bool ]));
        };
        timeoutSeconds = lib.mkOption {
          type = t.int;
        };
        type = lib.mkOption {
          type = t.oneOf [ t.enum [ "provider" ] t.enum [ "cli" ] ];
        };
      }; });
      };
      video = lib.mkOption {
        type = t.submodule { options = {
        attachments = lib.mkOption {
          type = t.submodule { options = {
          maxAttachments = lib.mkOption {
            type = t.int;
          };
          mode = lib.mkOption {
            type = t.oneOf [ t.enum [ "first" ] t.enum [ "all" ] ];
          };
          prefer = lib.mkOption {
            type = t.oneOf [ t.enum [ "first" ] t.enum [ "last" ] t.enum [ "path" ] t.enum [ "url" ] ];
          };
        }; };
        };
        baseUrl = lib.mkOption {
          type = t.str;
        };
        deepgram = lib.mkOption {
          type = t.submodule { options = {
          detectLanguage = lib.mkOption {
            type = t.bool;
          };
          punctuate = lib.mkOption {
            type = t.bool;
          };
          smartFormat = lib.mkOption {
            type = t.bool;
          };
        }; };
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        headers = lib.mkOption {
          type = t.attrsOf (t.str);
        };
        language = lib.mkOption {
          type = t.str;
        };
        maxBytes = lib.mkOption {
          type = t.int;
        };
        maxChars = lib.mkOption {
          type = t.int;
        };
        models = lib.mkOption {
          type = t.listOf (t.submodule { options = {
          args = lib.mkOption {
            type = t.listOf (t.str);
          };
          baseUrl = lib.mkOption {
            type = t.str;
          };
          capabilities = lib.mkOption {
            type = t.listOf (t.oneOf [ t.enum [ "image" ] t.enum [ "audio" ] t.enum [ "video" ] ]);
          };
          command = lib.mkOption {
            type = t.str;
          };
          deepgram = lib.mkOption {
            type = t.submodule { options = {
            detectLanguage = lib.mkOption {
              type = t.bool;
            };
            punctuate = lib.mkOption {
              type = t.bool;
            };
            smartFormat = lib.mkOption {
              type = t.bool;
            };
          }; };
          };
          headers = lib.mkOption {
            type = t.attrsOf (t.str);
          };
          language = lib.mkOption {
            type = t.str;
          };
          maxBytes = lib.mkOption {
            type = t.int;
          };
          maxChars = lib.mkOption {
            type = t.int;
          };
          model = lib.mkOption {
            type = t.str;
          };
          preferredProfile = lib.mkOption {
            type = t.str;
          };
          profile = lib.mkOption {
            type = t.str;
          };
          prompt = lib.mkOption {
            type = t.str;
          };
          provider = lib.mkOption {
            type = t.str;
          };
          providerOptions = lib.mkOption {
            type = t.attrsOf (t.attrsOf (t.oneOf [ t.str t.number t.bool ]));
          };
          timeoutSeconds = lib.mkOption {
            type = t.int;
          };
          type = lib.mkOption {
            type = t.oneOf [ t.enum [ "provider" ] t.enum [ "cli" ] ];
          };
        }; });
        };
        prompt = lib.mkOption {
          type = t.str;
        };
        providerOptions = lib.mkOption {
          type = t.attrsOf (t.attrsOf (t.oneOf [ t.str t.number t.bool ]));
        };
        scope = lib.mkOption {
          type = t.submodule { options = {
          default = lib.mkOption {
            type = t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ];
          };
          rules = lib.mkOption {
            type = t.listOf (t.submodule { options = {
            action = lib.mkOption {
              type = t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ];
            };
            match = lib.mkOption {
              type = t.submodule { options = {
              channel = lib.mkOption {
                type = t.str;
              };
              chatType = lib.mkOption {
                type = t.oneOf [ t.enum [ "direct" ] t.enum [ "group" ] t.enum [ "channel" ] ];
              };
              keyPrefix = lib.mkOption {
                type = t.str;
              };
            }; };
            };
          }; });
          };
        }; };
        };
        timeoutSeconds = lib.mkOption {
          type = t.int;
        };
      }; };
      };
    }; };
    };
    message = lib.mkOption {
      type = t.submodule { options = {
      allowCrossContextSend = lib.mkOption {
        type = t.bool;
      };
      broadcast = lib.mkOption {
        type = t.submodule { options = {
        enabled = lib.mkOption {
          type = t.bool;
        };
      }; };
      };
      crossContext = lib.mkOption {
        type = t.submodule { options = {
        allowAcrossProviders = lib.mkOption {
          type = t.bool;
        };
        allowWithinProvider = lib.mkOption {
          type = t.bool;
        };
        marker = lib.mkOption {
          type = t.submodule { options = {
          enabled = lib.mkOption {
            type = t.bool;
          };
          prefix = lib.mkOption {
            type = t.str;
          };
          suffix = lib.mkOption {
            type = t.str;
          };
        }; };
        };
      }; };
      };
    }; };
    };
    profile = lib.mkOption {
      type = t.oneOf [ t.enum [ "minimal" ] t.enum [ "coding" ] t.enum [ "messaging" ] t.enum [ "full" ] ];
    };
    sandbox = lib.mkOption {
      type = t.submodule { options = {
      tools = lib.mkOption {
        type = t.submodule { options = {
        allow = lib.mkOption {
          type = t.listOf (t.str);
        };
        deny = lib.mkOption {
          type = t.listOf (t.str);
        };
      }; };
      };
    }; };
    };
    subagents = lib.mkOption {
      type = t.submodule { options = {
      tools = lib.mkOption {
        type = t.submodule { options = {
        allow = lib.mkOption {
          type = t.listOf (t.str);
        };
        deny = lib.mkOption {
          type = t.listOf (t.str);
        };
      }; };
      };
    }; };
    };
    web = lib.mkOption {
      type = t.submodule { options = {
      fetch = lib.mkOption {
        type = t.submodule { options = {
        cacheTtlMinutes = lib.mkOption {
          type = t.number;
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        maxChars = lib.mkOption {
          type = t.int;
        };
        timeoutSeconds = lib.mkOption {
          type = t.int;
        };
        userAgent = lib.mkOption {
          type = t.str;
        };
      }; };
      };
      search = lib.mkOption {
        type = t.submodule { options = {
        apiKey = lib.mkOption {
          type = t.str;
        };
        cacheTtlMinutes = lib.mkOption {
          type = t.number;
        };
        enabled = lib.mkOption {
          type = t.bool;
        };
        maxResults = lib.mkOption {
          type = t.int;
        };
        provider = lib.mkOption {
          type = t.oneOf [ t.enum [ "brave" ] ];
        };
        timeoutSeconds = lib.mkOption {
          type = t.int;
        };
      }; };
      };
    }; };
    };
  }; };
  };

  ui = lib.mkOption {
    type = t.submodule { options = {
    seamColor = lib.mkOption {
      type = t.str;
    };
  }; };
  };

  update = lib.mkOption {
    type = t.submodule { options = {
    channel = lib.mkOption {
      type = t.oneOf [ t.enum [ "stable" ] t.enum [ "beta" ] ];
    };
    checkOnStart = lib.mkOption {
      type = t.bool;
    };
  }; };
  };

  web = lib.mkOption {
    type = t.submodule { options = {
    enabled = lib.mkOption {
      type = t.bool;
    };
    heartbeatSeconds = lib.mkOption {
      type = t.int;
    };
    reconnect = lib.mkOption {
      type = t.submodule { options = {
      factor = lib.mkOption {
        type = t.number;
      };
      initialMs = lib.mkOption {
        type = t.number;
      };
      jitter = lib.mkOption {
        type = t.number;
      };
      maxAttempts = lib.mkOption {
        type = t.int;
      };
      maxMs = lib.mkOption {
        type = t.number;
      };
    }; };
    };
  }; };
  };

  wizard = lib.mkOption {
    type = t.submodule { options = {
    lastRunAt = lib.mkOption {
      type = t.str;
    };
    lastRunCommand = lib.mkOption {
      type = t.str;
    };
    lastRunCommit = lib.mkOption {
      type = t.str;
    };
    lastRunMode = lib.mkOption {
      type = t.oneOf [ t.enum [ "local" ] t.enum [ "remote" ] ];
    };
    lastRunVersion = lib.mkOption {
      type = t.str;
    };
  }; };
  };
}
