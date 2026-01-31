# Generated from upstream OpenClaw schema. DO NOT EDIT.
{ lib }:
let
  t = lib.types;
in
{
  agents = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    defaults = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      blockStreamingBreak = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "text_end" ] t.enum [ "message_end" ] ]);
        default = null;
      };
      blockStreamingChunk = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        breakPreference = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "paragraph" ] t.enum [ "newline" ] t.enum [ "sentence" ] ]);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      blockStreamingDefault = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "on" ] ]);
        default = null;
      };
      bootstrapMaxChars = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      cliBackends = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        args = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        clearEnv = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        command = lib.mkOption {
          type = t.str;
        };
        env = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.str));
          default = null;
        };
        imageArg = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        imageMode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "repeat" ] t.enum [ "list" ] ]);
          default = null;
        };
        input = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "arg" ] t.enum [ "stdin" ] ]);
          default = null;
        };
        maxPromptArgChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        modelAliases = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.str));
          default = null;
        };
        modelArg = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        output = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "json" ] t.enum [ "text" ] t.enum [ "jsonl" ] ]);
          default = null;
        };
        resumeArgs = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        resumeOutput = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "json" ] t.enum [ "text" ] t.enum [ "jsonl" ] ]);
          default = null;
        };
        serialize = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        sessionArg = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        sessionArgs = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        sessionIdFields = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        sessionMode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "always" ] t.enum [ "existing" ] t.enum [ "none" ] ]);
          default = null;
        };
        systemPromptArg = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        systemPromptMode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "append" ] t.enum [ "replace" ] ]);
          default = null;
        };
        systemPromptWhen = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "first" ] t.enum [ "always" ] t.enum [ "never" ] ]);
          default = null;
        };
      }; }));
        default = null;
      };
      compaction = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        maxHistoryShare = lib.mkOption {
          type = t.nullOr (t.number);
          default = null;
        };
        memoryFlush = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          prompt = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          softThresholdTokens = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          systemPrompt = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
        }; });
          default = null;
        };
        mode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "default" ] t.enum [ "safeguard" ] ]);
          default = null;
        };
        reserveTokensFloor = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      contextPruning = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        hardClear = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          placeholder = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
        }; });
          default = null;
        };
        hardClearRatio = lib.mkOption {
          type = t.nullOr (t.number);
          default = null;
        };
        keepLastAssistants = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minPrunableToolChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        mode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "cache-ttl" ] ]);
          default = null;
        };
        softTrim = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          headChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          maxChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          tailChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        softTrimRatio = lib.mkOption {
          type = t.nullOr (t.number);
          default = null;
        };
        tools = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; });
          default = null;
        };
        ttl = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; });
        default = null;
      };
      contextTokens = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      elevatedDefault = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "on" ] t.enum [ "ask" ] t.enum [ "full" ] ]);
        default = null;
      };
      envelopeElapsed = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "on" ] t.enum [ "off" ] ]);
        default = null;
      };
      envelopeTimestamp = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "on" ] t.enum [ "off" ] ]);
        default = null;
      };
      envelopeTimezone = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      heartbeat = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        ackMaxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        activeHours = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          end = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          start = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          timezone = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
        }; });
          default = null;
        };
        every = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        includeReasoning = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        model = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        prompt = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        session = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        target = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        to = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; });
        default = null;
      };
      humanDelay = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        maxMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        mode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "natural" ] t.enum [ "custom" ] ]);
          default = null;
        };
      }; });
        default = null;
      };
      imageModel = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        fallbacks = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        primary = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; });
        default = null;
      };
      maxConcurrent = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      mediaMaxMb = lib.mkOption {
        type = t.nullOr (t.number);
        default = null;
      };
      memorySearch = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        cache = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          maxEntries = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        chunking = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          overlap = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          tokens = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        experimental = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          sessionMemory = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        extraPaths = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        fallback = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "openai" ] t.enum [ "gemini" ] t.enum [ "local" ] t.enum [ "none" ] ]);
          default = null;
        };
        local = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          modelCacheDir = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          modelPath = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
        }; });
          default = null;
        };
        model = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        provider = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "openai" ] t.enum [ "local" ] t.enum [ "gemini" ] ]);
          default = null;
        };
        query = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          hybrid = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            candidateMultiplier = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            enabled = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            textWeight = lib.mkOption {
              type = t.nullOr (t.number);
              default = null;
            };
            vectorWeight = lib.mkOption {
              type = t.nullOr (t.number);
              default = null;
            };
          }; });
            default = null;
          };
          maxResults = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          minScore = lib.mkOption {
            type = t.nullOr (t.number);
            default = null;
          };
        }; });
          default = null;
        };
        remote = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          apiKey = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          baseUrl = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          batch = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            concurrency = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            enabled = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            pollIntervalMs = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            timeoutMinutes = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            wait = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
          }; });
            default = null;
          };
          headers = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.str));
            default = null;
          };
        }; });
          default = null;
        };
        sources = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.enum [ "memory" ] t.enum [ "sessions" ] ]));
          default = null;
        };
        store = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          driver = lib.mkOption {
            type = t.nullOr (t.enum [ "sqlite" ]);
            default = null;
          };
          path = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          vector = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            enabled = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            extensionPath = lib.mkOption {
              type = t.nullOr (t.str);
              default = null;
            };
          }; });
            default = null;
          };
        }; });
          default = null;
        };
        sync = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          intervalMinutes = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          onSearch = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          onSessionStart = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          sessions = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            deltaBytes = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            deltaMessages = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
          }; });
            default = null;
          };
          watch = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          watchDebounceMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
      }; });
        default = null;
      };
      model = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        fallbacks = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        primary = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; });
        default = null;
      };
      models = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        alias = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        params = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.anything));
          default = null;
        };
      }; }));
        default = null;
      };
      repoRoot = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      sandbox = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        browser = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          allowHostControl = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          autoStart = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          autoStartTimeoutMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          cdpPort = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          containerPrefix = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          enableNoVnc = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          headless = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          image = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          noVncPort = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          vncPort = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        docker = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          apparmorProfile = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          binds = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          capDrop = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          containerPrefix = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          cpus = lib.mkOption {
            type = t.nullOr (t.number);
            default = null;
          };
          dns = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          env = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.str));
            default = null;
          };
          extraHosts = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          image = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          memory = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.str t.number ]);
            default = null;
          };
          memorySwap = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.str t.number ]);
            default = null;
          };
          network = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          pidsLimit = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          readOnlyRoot = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          seccompProfile = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          setupCommand = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          tmpfs = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          ulimits = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.oneOf [ t.str t.number t.submodule { options = {
            hard = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            soft = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
          }; } ]));
            default = null;
          };
          user = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          workdir = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
        }; });
          default = null;
        };
        mode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "non-main" ] t.enum [ "all" ] ]);
          default = null;
        };
        perSession = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        prune = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          idleHours = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          maxAgeDays = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        scope = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "session" ] t.enum [ "agent" ] t.enum [ "shared" ] ]);
          default = null;
        };
        sessionToolsVisibility = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "spawned" ] t.enum [ "all" ] ]);
          default = null;
        };
        workspaceAccess = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "none" ] t.enum [ "ro" ] t.enum [ "rw" ] ]);
          default = null;
        };
        workspaceRoot = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; });
        default = null;
      };
      skipBootstrap = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      subagents = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        archiveAfterMinutes = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxConcurrent = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        model = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.str t.submodule { options = {
          fallbacks = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          primary = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
        }; } ]);
          default = null;
        };
      }; });
        default = null;
      };
      thinkingDefault = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "minimal" ] t.enum [ "low" ] t.enum [ "medium" ] t.enum [ "high" ] t.enum [ "xhigh" ] ]);
        default = null;
      };
      timeFormat = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "auto" ] t.enum [ "12" ] t.enum [ "24" ] ]);
        default = null;
      };
      timeoutSeconds = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      typingIntervalSeconds = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      typingMode = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "never" ] t.enum [ "instant" ] t.enum [ "thinking" ] t.enum [ "message" ] ]);
        default = null;
      };
      userTimezone = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      verboseDefault = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "on" ] t.enum [ "full" ] ]);
        default = null;
      };
      workspace = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; });
      default = null;
    };
    list = lib.mkOption {
      type = t.nullOr (t.listOf (t.submodule { options = {
      agentDir = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      default = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      groupChat = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        mentionPatterns = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
      }; });
        default = null;
      };
      heartbeat = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        ackMaxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        activeHours = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          end = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          start = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          timezone = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
        }; });
          default = null;
        };
        every = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        includeReasoning = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        model = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        prompt = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        session = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        target = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        to = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; });
        default = null;
      };
      humanDelay = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        maxMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        mode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "natural" ] t.enum [ "custom" ] ]);
          default = null;
        };
      }; });
        default = null;
      };
      id = lib.mkOption {
        type = t.str;
      };
      identity = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        avatar = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        emoji = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        name = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        theme = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; });
        default = null;
      };
      memorySearch = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        cache = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          maxEntries = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        chunking = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          overlap = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          tokens = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        experimental = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          sessionMemory = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        extraPaths = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        fallback = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "openai" ] t.enum [ "gemini" ] t.enum [ "local" ] t.enum [ "none" ] ]);
          default = null;
        };
        local = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          modelCacheDir = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          modelPath = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
        }; });
          default = null;
        };
        model = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        provider = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "openai" ] t.enum [ "local" ] t.enum [ "gemini" ] ]);
          default = null;
        };
        query = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          hybrid = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            candidateMultiplier = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            enabled = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            textWeight = lib.mkOption {
              type = t.nullOr (t.number);
              default = null;
            };
            vectorWeight = lib.mkOption {
              type = t.nullOr (t.number);
              default = null;
            };
          }; });
            default = null;
          };
          maxResults = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          minScore = lib.mkOption {
            type = t.nullOr (t.number);
            default = null;
          };
        }; });
          default = null;
        };
        remote = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          apiKey = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          baseUrl = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          batch = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            concurrency = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            enabled = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            pollIntervalMs = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            timeoutMinutes = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            wait = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
          }; });
            default = null;
          };
          headers = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.str));
            default = null;
          };
        }; });
          default = null;
        };
        sources = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.enum [ "memory" ] t.enum [ "sessions" ] ]));
          default = null;
        };
        store = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          driver = lib.mkOption {
            type = t.nullOr (t.enum [ "sqlite" ]);
            default = null;
          };
          path = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          vector = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            enabled = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            extensionPath = lib.mkOption {
              type = t.nullOr (t.str);
              default = null;
            };
          }; });
            default = null;
          };
        }; });
          default = null;
        };
        sync = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          intervalMinutes = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          onSearch = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          onSessionStart = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          sessions = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            deltaBytes = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            deltaMessages = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
          }; });
            default = null;
          };
          watch = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          watchDebounceMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
      }; });
        default = null;
      };
      model = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.str t.submodule { options = {
        fallbacks = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        primary = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; } ]);
        default = null;
      };
      name = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      sandbox = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        browser = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          allowHostControl = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          autoStart = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          autoStartTimeoutMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          cdpPort = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          containerPrefix = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          enableNoVnc = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          headless = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          image = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          noVncPort = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          vncPort = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        docker = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          apparmorProfile = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          binds = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          capDrop = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          containerPrefix = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          cpus = lib.mkOption {
            type = t.nullOr (t.number);
            default = null;
          };
          dns = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          env = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.str));
            default = null;
          };
          extraHosts = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          image = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          memory = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.str t.number ]);
            default = null;
          };
          memorySwap = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.str t.number ]);
            default = null;
          };
          network = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          pidsLimit = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          readOnlyRoot = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          seccompProfile = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          setupCommand = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          tmpfs = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          ulimits = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.oneOf [ t.str t.number t.submodule { options = {
            hard = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            soft = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
          }; } ]));
            default = null;
          };
          user = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          workdir = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
        }; });
          default = null;
        };
        mode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "non-main" ] t.enum [ "all" ] ]);
          default = null;
        };
        perSession = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        prune = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          idleHours = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          maxAgeDays = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        scope = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "session" ] t.enum [ "agent" ] t.enum [ "shared" ] ]);
          default = null;
        };
        sessionToolsVisibility = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "spawned" ] t.enum [ "all" ] ]);
          default = null;
        };
        workspaceAccess = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "none" ] t.enum [ "ro" ] t.enum [ "rw" ] ]);
          default = null;
        };
        workspaceRoot = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; });
        default = null;
      };
      subagents = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        allowAgents = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        model = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.str t.submodule { options = {
          fallbacks = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          primary = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
        }; } ]);
          default = null;
        };
      }; });
        default = null;
      };
      tools = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        allow = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        alsoAllow = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        byProvider = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          alsoAllow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          profile = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "minimal" ] t.enum [ "coding" ] t.enum [ "messaging" ] t.enum [ "full" ] ]);
            default = null;
          };
        }; }));
          default = null;
        };
        deny = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        elevated = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          allowFrom = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.listOf (t.oneOf [ t.str t.number ])));
            default = null;
          };
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        exec = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          applyPatch = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            allowModels = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            enabled = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
          }; });
            default = null;
          };
          approvalRunningNoticeMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          ask = lib.mkOption {
            type = t.nullOr (t.enum [ "off" "on-miss" "always" ]);
            default = null;
          };
          backgroundMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          cleanupMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          host = lib.mkOption {
            type = t.nullOr (t.enum [ "sandbox" "gateway" "node" ]);
            default = null;
          };
          node = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          notifyOnExit = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          pathPrepend = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          safeBins = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          security = lib.mkOption {
            type = t.nullOr (t.enum [ "deny" "allowlist" "full" ]);
            default = null;
          };
          timeoutSec = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        profile = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "minimal" ] t.enum [ "coding" ] t.enum [ "messaging" ] t.enum [ "full" ] ]);
          default = null;
        };
        sandbox = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          tools = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; });
            default = null;
          };
        }; });
          default = null;
        };
      }; });
        default = null;
      };
      workspace = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; }));
      default = null;
    };
  }; });
    default = null;
  };

  approvals = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    exec = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      agentFilter = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      mode = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "session" ] t.enum [ "targets" ] t.enum [ "both" ] ]);
        default = null;
      };
      sessionFilter = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      targets = lib.mkOption {
        type = t.nullOr (t.listOf (t.submodule { options = {
        accountId = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        channel = lib.mkOption {
          type = t.str;
        };
        threadId = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.str t.number ]);
          default = null;
        };
        to = lib.mkOption {
          type = t.str;
        };
      }; }));
        default = null;
      };
    }; });
      default = null;
    };
  }; });
    default = null;
  };

  audio = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    transcription = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      command = lib.mkOption {
        type = t.listOf (t.str);
      };
      timeoutSeconds = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
    }; });
      default = null;
    };
  }; });
    default = null;
  };

  auth = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    cooldowns = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      billingBackoffHours = lib.mkOption {
        type = t.nullOr (t.number);
        default = null;
      };
      billingBackoffHoursByProvider = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.number));
        default = null;
      };
      billingMaxHours = lib.mkOption {
        type = t.nullOr (t.number);
        default = null;
      };
      failureWindowHours = lib.mkOption {
        type = t.nullOr (t.number);
        default = null;
      };
    }; });
      default = null;
    };
    order = lib.mkOption {
      type = t.nullOr (t.attrsOf (t.listOf (t.str)));
      default = null;
    };
    profiles = lib.mkOption {
      type = t.nullOr (t.attrsOf (t.submodule { options = {
      email = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      mode = lib.mkOption {
        type = t.oneOf [ t.enum [ "api_key" ] t.enum [ "oauth" ] t.enum [ "token" ] ];
      };
      provider = lib.mkOption {
        type = t.str;
      };
    }; }));
      default = null;
    };
  }; });
    default = null;
  };

  bindings = lib.mkOption {
    type = t.nullOr (t.listOf (t.submodule { options = {
    agentId = lib.mkOption {
      type = t.str;
    };
    match = lib.mkOption {
      type = t.submodule { options = {
      accountId = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      channel = lib.mkOption {
        type = t.str;
      };
      guildId = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      peer = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        id = lib.mkOption {
          type = t.str;
        };
        kind = lib.mkOption {
          type = t.oneOf [ t.enum [ "dm" ] t.enum [ "group" ] t.enum [ "channel" ] ];
        };
      }; });
        default = null;
      };
      teamId = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; };
    };
  }; }));
    default = null;
  };

  broadcast = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    strategy = lib.mkOption {
      type = t.nullOr (t.enum [ "parallel" "sequential" ]);
      default = null;
    };
  }; });
    default = null;
  };

  browser = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    attachOnly = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    cdpUrl = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    color = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    defaultProfile = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    enabled = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    evaluateEnabled = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    executablePath = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    headless = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    noSandbox = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    profiles = lib.mkOption {
      type = t.nullOr (t.attrsOf (t.submodule { options = {
      cdpPort = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      cdpUrl = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      color = lib.mkOption {
        type = t.str;
      };
      driver = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "openclaw" ] t.enum [ "extension" ] ]);
        default = null;
      };
    }; }));
      default = null;
    };
    remoteCdpHandshakeTimeoutMs = lib.mkOption {
      type = t.nullOr (t.int);
      default = null;
    };
    remoteCdpTimeoutMs = lib.mkOption {
      type = t.nullOr (t.int);
      default = null;
    };
    snapshotDefaults = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      mode = lib.mkOption {
        type = t.nullOr (t.enum [ "efficient" ]);
        default = null;
      };
    }; });
      default = null;
    };
  }; });
    default = null;
  };

  canvasHost = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    enabled = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    liveReload = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    port = lib.mkOption {
      type = t.nullOr (t.int);
      default = null;
    };
    root = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
  }; });
    default = null;
  };

  channels = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    bluebubbles = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      accounts = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        allowFrom = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        blockStreaming = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        blockStreamingCoalesce = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          idleMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          maxChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          minChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        capabilities = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        chunkMode = lib.mkOption {
          type = t.nullOr (t.enum [ "length" "newline" ]);
          default = null;
        };
        configWrites = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        dmHistoryLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        dmPolicy = lib.mkOption {
          type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
          default = null;
        };
        dms = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          historyLimit = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; }));
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        groupAllowFrom = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        groupPolicy = lib.mkOption {
          type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
          default = null;
        };
        groups = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          requireMention = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          tools = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; });
            default = null;
          };
          toolsBySender = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; }));
            default = null;
          };
        }; }));
          default = null;
        };
        heartbeat = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          showAlerts = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          showOk = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          useIndicator = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        markdown = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          tables = lib.mkOption {
            type = t.nullOr (t.enum [ "off" "bullets" "code" ]);
            default = null;
          };
        }; });
          default = null;
        };
        mediaMaxMb = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        name = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        password = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        sendReadReceipts = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        serverUrl = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        textChunkLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        webhookPath = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; }));
        default = null;
      };
      actions = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        addParticipant = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        edit = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        leaveGroup = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        reactions = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        removeParticipant = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        renameGroup = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        reply = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        sendAttachment = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        sendWithEffect = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        setGroupIcon = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        unsend = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      allowFrom = lib.mkOption {
        type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
        default = null;
      };
      blockStreaming = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      capabilities = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      chunkMode = lib.mkOption {
        type = t.nullOr (t.enum [ "length" "newline" ]);
        default = null;
      };
      configWrites = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      dmHistoryLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      dmPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
        default = null;
      };
      dms = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; }));
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      groupAllowFrom = lib.mkOption {
        type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
        default = null;
      };
      groupPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
        default = null;
      };
      groups = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        requireMention = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        tools = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          alsoAllow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; });
          default = null;
        };
        toolsBySender = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          alsoAllow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; }));
          default = null;
        };
      }; }));
        default = null;
      };
      heartbeat = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        showAlerts = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        showOk = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        useIndicator = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      historyLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      markdown = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        tables = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "bullets" "code" ]);
          default = null;
        };
      }; });
        default = null;
      };
      mediaMaxMb = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      name = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      password = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      sendReadReceipts = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      serverUrl = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      textChunkLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      webhookPath = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; });
      default = null;
    };
    defaults = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      groupPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
        default = null;
      };
      heartbeat = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        showAlerts = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        showOk = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        useIndicator = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
    }; });
      default = null;
    };
    discord = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      accounts = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        actions = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          channelInfo = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          channels = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          emojiUploads = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          events = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          memberInfo = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          messages = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          moderation = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          permissions = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          pins = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          polls = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          reactions = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          roleInfo = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          roles = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          search = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          stickerUploads = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          stickers = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          threads = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          voiceStatus = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        allowBots = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        blockStreaming = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        blockStreamingCoalesce = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          idleMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          maxChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          minChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        capabilities = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        chunkMode = lib.mkOption {
          type = t.nullOr (t.enum [ "length" "newline" ]);
          default = null;
        };
        commands = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          native = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.bool t.enum [ "auto" ] ]);
            default = null;
          };
          nativeSkills = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.bool t.enum [ "auto" ] ]);
            default = null;
          };
        }; });
          default = null;
        };
        configWrites = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        dm = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          allowFrom = lib.mkOption {
            type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
            default = null;
          };
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          groupChannels = lib.mkOption {
            type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
            default = null;
          };
          groupEnabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          policy = lib.mkOption {
            type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
            default = null;
          };
        }; });
          default = null;
        };
        dmHistoryLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        dms = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          historyLimit = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; }));
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        execApprovals = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          agentFilter = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          approvers = lib.mkOption {
            type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
            default = null;
          };
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          sessionFilter = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; });
          default = null;
        };
        groupPolicy = lib.mkOption {
          type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
          default = null;
        };
        guilds = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          channels = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            autoThread = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            enabled = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            requireMention = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            skills = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            systemPrompt = lib.mkOption {
              type = t.nullOr (t.str);
              default = null;
            };
            tools = lib.mkOption {
              type = t.nullOr (t.submodule { options = {
              allow = lib.mkOption {
                type = t.nullOr (t.listOf (t.str));
                default = null;
              };
              alsoAllow = lib.mkOption {
                type = t.nullOr (t.listOf (t.str));
                default = null;
              };
              deny = lib.mkOption {
                type = t.nullOr (t.listOf (t.str));
                default = null;
              };
            }; });
              default = null;
            };
            toolsBySender = lib.mkOption {
              type = t.nullOr (t.attrsOf (t.submodule { options = {
              allow = lib.mkOption {
                type = t.nullOr (t.listOf (t.str));
                default = null;
              };
              alsoAllow = lib.mkOption {
                type = t.nullOr (t.listOf (t.str));
                default = null;
              };
              deny = lib.mkOption {
                type = t.nullOr (t.listOf (t.str));
                default = null;
              };
            }; }));
              default = null;
            };
            users = lib.mkOption {
              type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
              default = null;
            };
          }; }));
            default = null;
          };
          reactionNotifications = lib.mkOption {
            type = t.nullOr (t.enum [ "off" "own" "all" "allowlist" ]);
            default = null;
          };
          requireMention = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          slug = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          tools = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; });
            default = null;
          };
          toolsBySender = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; }));
            default = null;
          };
          users = lib.mkOption {
            type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
            default = null;
          };
        }; }));
          default = null;
        };
        heartbeat = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          showAlerts = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          showOk = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          useIndicator = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        intents = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          guildMembers = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          presence = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        markdown = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          tables = lib.mkOption {
            type = t.nullOr (t.enum [ "off" "bullets" "code" ]);
            default = null;
          };
        }; });
          default = null;
        };
        maxLinesPerMessage = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        mediaMaxMb = lib.mkOption {
          type = t.nullOr (t.number);
          default = null;
        };
        name = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        replyToMode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
          default = null;
        };
        retry = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          attempts = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          jitter = lib.mkOption {
            type = t.nullOr (t.number);
            default = null;
          };
          maxDelayMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          minDelayMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        textChunkLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        token = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; }));
        default = null;
      };
      actions = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        channelInfo = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        channels = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        emojiUploads = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        events = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        memberInfo = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        messages = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        moderation = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        permissions = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        pins = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        polls = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        reactions = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        roleInfo = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        roles = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        search = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        stickerUploads = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        stickers = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        threads = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        voiceStatus = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      allowBots = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      blockStreaming = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      capabilities = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      chunkMode = lib.mkOption {
        type = t.nullOr (t.enum [ "length" "newline" ]);
        default = null;
      };
      commands = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        native = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.bool t.enum [ "auto" ] ]);
          default = null;
        };
        nativeSkills = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.bool t.enum [ "auto" ] ]);
          default = null;
        };
      }; });
        default = null;
      };
      configWrites = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      dm = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        allowFrom = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        groupChannels = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        groupEnabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        policy = lib.mkOption {
          type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
          default = null;
        };
      }; });
        default = null;
      };
      dmHistoryLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      dms = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; }));
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      execApprovals = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        agentFilter = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        approvers = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        sessionFilter = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
      }; });
        default = null;
      };
      groupPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
        default = null;
      };
      guilds = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        channels = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          autoThread = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          requireMention = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          skills = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          systemPrompt = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          tools = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; });
            default = null;
          };
          toolsBySender = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; }));
            default = null;
          };
          users = lib.mkOption {
            type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
            default = null;
          };
        }; }));
          default = null;
        };
        reactionNotifications = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "own" "all" "allowlist" ]);
          default = null;
        };
        requireMention = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        slug = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        tools = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          alsoAllow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; });
          default = null;
        };
        toolsBySender = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          alsoAllow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; }));
          default = null;
        };
        users = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
      }; }));
        default = null;
      };
      heartbeat = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        showAlerts = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        showOk = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        useIndicator = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      historyLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      intents = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        guildMembers = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        presence = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      markdown = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        tables = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "bullets" "code" ]);
          default = null;
        };
      }; });
        default = null;
      };
      maxLinesPerMessage = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      mediaMaxMb = lib.mkOption {
        type = t.nullOr (t.number);
        default = null;
      };
      name = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      replyToMode = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
        default = null;
      };
      retry = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        attempts = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        jitter = lib.mkOption {
          type = t.nullOr (t.number);
          default = null;
        };
        maxDelayMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minDelayMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      textChunkLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      token = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; });
      default = null;
    };
    googlechat = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      accounts = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        actions = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          reactions = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        allowBots = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        audience = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        audienceType = lib.mkOption {
          type = t.nullOr (t.enum [ "app-url" "project-number" ]);
          default = null;
        };
        blockStreaming = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        blockStreamingCoalesce = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          idleMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          maxChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          minChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        botUser = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        capabilities = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        chunkMode = lib.mkOption {
          type = t.nullOr (t.enum [ "length" "newline" ]);
          default = null;
        };
        configWrites = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        dm = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          allowFrom = lib.mkOption {
            type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
            default = null;
          };
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          policy = lib.mkOption {
            type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
            default = null;
          };
        }; });
          default = null;
        };
        dmHistoryLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        dms = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          historyLimit = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; }));
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        groupAllowFrom = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        groupPolicy = lib.mkOption {
          type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
          default = null;
        };
        groups = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          requireMention = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          systemPrompt = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          users = lib.mkOption {
            type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
            default = null;
          };
        }; }));
          default = null;
        };
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        mediaMaxMb = lib.mkOption {
          type = t.nullOr (t.number);
          default = null;
        };
        name = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        replyToMode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
          default = null;
        };
        requireMention = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        serviceAccount = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.str t.attrsOf (t.anything) ]);
          default = null;
        };
        serviceAccountFile = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        textChunkLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        typingIndicator = lib.mkOption {
          type = t.nullOr (t.enum [ "none" "message" "reaction" ]);
          default = null;
        };
        webhookPath = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        webhookUrl = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; }));
        default = null;
      };
      actions = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        reactions = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      allowBots = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      audience = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      audienceType = lib.mkOption {
        type = t.nullOr (t.enum [ "app-url" "project-number" ]);
        default = null;
      };
      blockStreaming = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      botUser = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      capabilities = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      chunkMode = lib.mkOption {
        type = t.nullOr (t.enum [ "length" "newline" ]);
        default = null;
      };
      configWrites = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      defaultAccount = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      dm = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        allowFrom = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        policy = lib.mkOption {
          type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
          default = null;
        };
      }; });
        default = null;
      };
      dmHistoryLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      dms = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; }));
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      groupAllowFrom = lib.mkOption {
        type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
        default = null;
      };
      groupPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
        default = null;
      };
      groups = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        allow = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        requireMention = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        systemPrompt = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        users = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
      }; }));
        default = null;
      };
      historyLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      mediaMaxMb = lib.mkOption {
        type = t.nullOr (t.number);
        default = null;
      };
      name = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      replyToMode = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
        default = null;
      };
      requireMention = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      serviceAccount = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.str t.attrsOf (t.anything) ]);
        default = null;
      };
      serviceAccountFile = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      textChunkLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      typingIndicator = lib.mkOption {
        type = t.nullOr (t.enum [ "none" "message" "reaction" ]);
        default = null;
      };
      webhookPath = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      webhookUrl = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; });
      default = null;
    };
    imessage = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      accounts = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        allowFrom = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        blockStreaming = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        blockStreamingCoalesce = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          idleMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          maxChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          minChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        capabilities = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        chunkMode = lib.mkOption {
          type = t.nullOr (t.enum [ "length" "newline" ]);
          default = null;
        };
        cliPath = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        configWrites = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        dbPath = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        dmHistoryLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        dmPolicy = lib.mkOption {
          type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
          default = null;
        };
        dms = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          historyLimit = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; }));
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        groupAllowFrom = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        groupPolicy = lib.mkOption {
          type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
          default = null;
        };
        groups = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          requireMention = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          tools = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; });
            default = null;
          };
          toolsBySender = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; }));
            default = null;
          };
        }; }));
          default = null;
        };
        heartbeat = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          showAlerts = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          showOk = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          useIndicator = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        includeAttachments = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        markdown = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          tables = lib.mkOption {
            type = t.nullOr (t.enum [ "off" "bullets" "code" ]);
            default = null;
          };
        }; });
          default = null;
        };
        mediaMaxMb = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        name = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        region = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        remoteHost = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        service = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "imessage" ] t.enum [ "sms" ] t.enum [ "auto" ] ]);
          default = null;
        };
        textChunkLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; }));
        default = null;
      };
      allowFrom = lib.mkOption {
        type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
        default = null;
      };
      blockStreaming = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      capabilities = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      chunkMode = lib.mkOption {
        type = t.nullOr (t.enum [ "length" "newline" ]);
        default = null;
      };
      cliPath = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      configWrites = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      dbPath = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      dmHistoryLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      dmPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
        default = null;
      };
      dms = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; }));
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      groupAllowFrom = lib.mkOption {
        type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
        default = null;
      };
      groupPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
        default = null;
      };
      groups = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        requireMention = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        tools = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          alsoAllow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; });
          default = null;
        };
        toolsBySender = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          alsoAllow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; }));
          default = null;
        };
      }; }));
        default = null;
      };
      heartbeat = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        showAlerts = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        showOk = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        useIndicator = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      historyLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      includeAttachments = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      markdown = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        tables = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "bullets" "code" ]);
          default = null;
        };
      }; });
        default = null;
      };
      mediaMaxMb = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      name = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      region = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      remoteHost = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      service = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "imessage" ] t.enum [ "sms" ] t.enum [ "auto" ] ]);
        default = null;
      };
      textChunkLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
    }; });
      default = null;
    };
    msteams = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      allowFrom = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      appId = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      appPassword = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      capabilities = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      chunkMode = lib.mkOption {
        type = t.nullOr (t.enum [ "length" "newline" ]);
        default = null;
      };
      configWrites = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      dmHistoryLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      dmPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
        default = null;
      };
      dms = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; }));
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      groupAllowFrom = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      groupPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
        default = null;
      };
      heartbeat = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        showAlerts = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        showOk = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        useIndicator = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      historyLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      markdown = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        tables = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "bullets" "code" ]);
          default = null;
        };
      }; });
        default = null;
      };
      mediaAllowHosts = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      mediaMaxMb = lib.mkOption {
        type = t.nullOr (t.number);
        default = null;
      };
      replyStyle = lib.mkOption {
        type = t.nullOr (t.enum [ "thread" "top-level" ]);
        default = null;
      };
      requireMention = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      sharePointSiteId = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      teams = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        channels = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          replyStyle = lib.mkOption {
            type = t.nullOr (t.enum [ "thread" "top-level" ]);
            default = null;
          };
          requireMention = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          tools = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; });
            default = null;
          };
          toolsBySender = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; }));
            default = null;
          };
        }; }));
          default = null;
        };
        replyStyle = lib.mkOption {
          type = t.nullOr (t.enum [ "thread" "top-level" ]);
          default = null;
        };
        requireMention = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        tools = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          alsoAllow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; });
          default = null;
        };
        toolsBySender = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          alsoAllow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; }));
          default = null;
        };
      }; }));
        default = null;
      };
      tenantId = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      textChunkLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      webhook = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        path = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        port = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
    }; });
      default = null;
    };
    signal = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      account = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      accounts = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        account = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        actions = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          reactions = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        allowFrom = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        autoStart = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        blockStreaming = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        blockStreamingCoalesce = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          idleMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          maxChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          minChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        capabilities = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        chunkMode = lib.mkOption {
          type = t.nullOr (t.enum [ "length" "newline" ]);
          default = null;
        };
        cliPath = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        configWrites = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        dmHistoryLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        dmPolicy = lib.mkOption {
          type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
          default = null;
        };
        dms = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          historyLimit = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; }));
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        groupAllowFrom = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        groupPolicy = lib.mkOption {
          type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
          default = null;
        };
        heartbeat = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          showAlerts = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          showOk = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          useIndicator = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        httpHost = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        httpPort = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        httpUrl = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        ignoreAttachments = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        ignoreStories = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        markdown = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          tables = lib.mkOption {
            type = t.nullOr (t.enum [ "off" "bullets" "code" ]);
            default = null;
          };
        }; });
          default = null;
        };
        mediaMaxMb = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        name = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        reactionAllowlist = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        reactionLevel = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "ack" "minimal" "extensive" ]);
          default = null;
        };
        reactionNotifications = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "own" "all" "allowlist" ]);
          default = null;
        };
        receiveMode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "on-start" ] t.enum [ "manual" ] ]);
          default = null;
        };
        sendReadReceipts = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        startupTimeoutMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        textChunkLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; }));
        default = null;
      };
      actions = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        reactions = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      allowFrom = lib.mkOption {
        type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
        default = null;
      };
      autoStart = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      blockStreaming = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      capabilities = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      chunkMode = lib.mkOption {
        type = t.nullOr (t.enum [ "length" "newline" ]);
        default = null;
      };
      cliPath = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      configWrites = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      dmHistoryLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      dmPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
        default = null;
      };
      dms = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; }));
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      groupAllowFrom = lib.mkOption {
        type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
        default = null;
      };
      groupPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
        default = null;
      };
      heartbeat = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        showAlerts = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        showOk = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        useIndicator = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      historyLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      httpHost = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      httpPort = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      httpUrl = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      ignoreAttachments = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      ignoreStories = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      markdown = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        tables = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "bullets" "code" ]);
          default = null;
        };
      }; });
        default = null;
      };
      mediaMaxMb = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      name = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      reactionAllowlist = lib.mkOption {
        type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
        default = null;
      };
      reactionLevel = lib.mkOption {
        type = t.nullOr (t.enum [ "off" "ack" "minimal" "extensive" ]);
        default = null;
      };
      reactionNotifications = lib.mkOption {
        type = t.nullOr (t.enum [ "off" "own" "all" "allowlist" ]);
        default = null;
      };
      receiveMode = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "on-start" ] t.enum [ "manual" ] ]);
        default = null;
      };
      sendReadReceipts = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      startupTimeoutMs = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      textChunkLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
    }; });
      default = null;
    };
    slack = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      accounts = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        actions = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          channelInfo = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          emojiList = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          memberInfo = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          messages = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          permissions = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          pins = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          reactions = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          search = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        allowBots = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        appToken = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        blockStreaming = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        blockStreamingCoalesce = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          idleMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          maxChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          minChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        botToken = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        capabilities = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        channels = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          allowBots = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          requireMention = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          skills = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          systemPrompt = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          tools = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; });
            default = null;
          };
          toolsBySender = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; }));
            default = null;
          };
          users = lib.mkOption {
            type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
            default = null;
          };
        }; }));
          default = null;
        };
        chunkMode = lib.mkOption {
          type = t.nullOr (t.enum [ "length" "newline" ]);
          default = null;
        };
        commands = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          native = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.bool t.enum [ "auto" ] ]);
            default = null;
          };
          nativeSkills = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.bool t.enum [ "auto" ] ]);
            default = null;
          };
        }; });
          default = null;
        };
        configWrites = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        dm = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          allowFrom = lib.mkOption {
            type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
            default = null;
          };
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          groupChannels = lib.mkOption {
            type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
            default = null;
          };
          groupEnabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          policy = lib.mkOption {
            type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
            default = null;
          };
          replyToMode = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
            default = null;
          };
        }; });
          default = null;
        };
        dmHistoryLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        dms = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          historyLimit = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; }));
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        groupPolicy = lib.mkOption {
          type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
          default = null;
        };
        heartbeat = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          showAlerts = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          showOk = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          useIndicator = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        markdown = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          tables = lib.mkOption {
            type = t.nullOr (t.enum [ "off" "bullets" "code" ]);
            default = null;
          };
        }; });
          default = null;
        };
        mediaMaxMb = lib.mkOption {
          type = t.nullOr (t.number);
          default = null;
        };
        mode = lib.mkOption {
          type = t.nullOr (t.enum [ "socket" "http" ]);
          default = null;
        };
        name = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        reactionAllowlist = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        reactionNotifications = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "own" "all" "allowlist" ]);
          default = null;
        };
        replyToMode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
          default = null;
        };
        replyToModeByChatType = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          channel = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
            default = null;
          };
          direct = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
            default = null;
          };
          group = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
            default = null;
          };
        }; });
          default = null;
        };
        requireMention = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        signingSecret = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        slashCommand = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          ephemeral = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          name = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          sessionPrefix = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
        }; });
          default = null;
        };
        textChunkLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        thread = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          historyScope = lib.mkOption {
            type = t.nullOr (t.enum [ "thread" "channel" ]);
            default = null;
          };
          inheritParent = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        userToken = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        userTokenReadOnly = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        webhookPath = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; }));
        default = null;
      };
      actions = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        channelInfo = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        emojiList = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        memberInfo = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        messages = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        permissions = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        pins = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        reactions = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        search = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      allowBots = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      appToken = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      blockStreaming = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      botToken = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      capabilities = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      channels = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        allow = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        allowBots = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        requireMention = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        skills = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        systemPrompt = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        tools = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          alsoAllow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; });
          default = null;
        };
        toolsBySender = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          alsoAllow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; }));
          default = null;
        };
        users = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
      }; }));
        default = null;
      };
      chunkMode = lib.mkOption {
        type = t.nullOr (t.enum [ "length" "newline" ]);
        default = null;
      };
      commands = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        native = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.bool t.enum [ "auto" ] ]);
          default = null;
        };
        nativeSkills = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.bool t.enum [ "auto" ] ]);
          default = null;
        };
      }; });
        default = null;
      };
      configWrites = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      dm = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        allowFrom = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        groupChannels = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        groupEnabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        policy = lib.mkOption {
          type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
          default = null;
        };
        replyToMode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
          default = null;
        };
      }; });
        default = null;
      };
      dmHistoryLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      dms = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; }));
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      groupPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
        default = null;
      };
      heartbeat = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        showAlerts = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        showOk = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        useIndicator = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      historyLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      markdown = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        tables = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "bullets" "code" ]);
          default = null;
        };
      }; });
        default = null;
      };
      mediaMaxMb = lib.mkOption {
        type = t.nullOr (t.number);
        default = null;
      };
      mode = lib.mkOption {
        type = t.nullOr (t.enum [ "socket" "http" ]);
        default = null;
      };
      name = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      reactionAllowlist = lib.mkOption {
        type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
        default = null;
      };
      reactionNotifications = lib.mkOption {
        type = t.nullOr (t.enum [ "off" "own" "all" "allowlist" ]);
        default = null;
      };
      replyToMode = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
        default = null;
      };
      replyToModeByChatType = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        channel = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
          default = null;
        };
        direct = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
          default = null;
        };
        group = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
          default = null;
        };
      }; });
        default = null;
      };
      requireMention = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      signingSecret = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      slashCommand = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        ephemeral = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        name = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        sessionPrefix = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; });
        default = null;
      };
      textChunkLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      thread = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        historyScope = lib.mkOption {
          type = t.nullOr (t.enum [ "thread" "channel" ]);
          default = null;
        };
        inheritParent = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      userToken = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      userTokenReadOnly = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      webhookPath = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; });
      default = null;
    };
    telegram = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      accounts = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        actions = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          deleteMessage = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          reactions = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          sendMessage = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          sticker = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        allowFrom = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        blockStreaming = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        blockStreamingCoalesce = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          idleMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          maxChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          minChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        botToken = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        capabilities = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.listOf (t.str) t.submodule { options = {
          inlineButtons = lib.mkOption {
            type = t.nullOr (t.enum [ "off" "dm" "group" "all" "allowlist" ]);
            default = null;
          };
        }; } ]);
          default = null;
        };
        chunkMode = lib.mkOption {
          type = t.nullOr (t.enum [ "length" "newline" ]);
          default = null;
        };
        commands = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          native = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.bool t.enum [ "auto" ] ]);
            default = null;
          };
          nativeSkills = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.bool t.enum [ "auto" ] ]);
            default = null;
          };
        }; });
          default = null;
        };
        configWrites = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        customCommands = lib.mkOption {
          type = t.nullOr (t.listOf (t.submodule { options = {
          command = lib.mkOption {
            type = t.anything;
          };
          description = lib.mkOption {
            type = t.anything;
          };
        }; }));
          default = null;
        };
        dmHistoryLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        dmPolicy = lib.mkOption {
          type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
          default = null;
        };
        dms = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          historyLimit = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; }));
          default = null;
        };
        draftChunk = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          breakPreference = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "paragraph" ] t.enum [ "newline" ] t.enum [ "sentence" ] ]);
            default = null;
          };
          maxChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          minChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        groupAllowFrom = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        groupPolicy = lib.mkOption {
          type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
          default = null;
        };
        groups = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          allowFrom = lib.mkOption {
            type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
            default = null;
          };
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          requireMention = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          skills = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          systemPrompt = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          tools = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; });
            default = null;
          };
          toolsBySender = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; }));
            default = null;
          };
          topics = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.submodule { options = {
            allowFrom = lib.mkOption {
              type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
              default = null;
            };
            enabled = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            requireMention = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            skills = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            systemPrompt = lib.mkOption {
              type = t.nullOr (t.str);
              default = null;
            };
          }; }));
            default = null;
          };
        }; }));
          default = null;
        };
        heartbeat = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          showAlerts = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          showOk = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          useIndicator = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        linkPreview = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        markdown = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          tables = lib.mkOption {
            type = t.nullOr (t.enum [ "off" "bullets" "code" ]);
            default = null;
          };
        }; });
          default = null;
        };
        mediaMaxMb = lib.mkOption {
          type = t.nullOr (t.number);
          default = null;
        };
        name = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        network = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          autoSelectFamily = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        proxy = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        reactionLevel = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "ack" "minimal" "extensive" ]);
          default = null;
        };
        reactionNotifications = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "own" "all" ]);
          default = null;
        };
        replyToMode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
          default = null;
        };
        retry = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          attempts = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          jitter = lib.mkOption {
            type = t.nullOr (t.number);
            default = null;
          };
          maxDelayMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          minDelayMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        streamMode = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "partial" "block" ]);
          default = null;
        };
        textChunkLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        timeoutSeconds = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        tokenFile = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        webhookPath = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        webhookSecret = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        webhookUrl = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; }));
        default = null;
      };
      actions = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        deleteMessage = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        reactions = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        sendMessage = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        sticker = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      allowFrom = lib.mkOption {
        type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
        default = null;
      };
      blockStreaming = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      botToken = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      capabilities = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.listOf (t.str) t.submodule { options = {
        inlineButtons = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "dm" "group" "all" "allowlist" ]);
          default = null;
        };
      }; } ]);
        default = null;
      };
      chunkMode = lib.mkOption {
        type = t.nullOr (t.enum [ "length" "newline" ]);
        default = null;
      };
      commands = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        native = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.bool t.enum [ "auto" ] ]);
          default = null;
        };
        nativeSkills = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.bool t.enum [ "auto" ] ]);
          default = null;
        };
      }; });
        default = null;
      };
      configWrites = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      customCommands = lib.mkOption {
        type = t.nullOr (t.listOf (t.submodule { options = {
        command = lib.mkOption {
          type = t.anything;
        };
        description = lib.mkOption {
          type = t.anything;
        };
      }; }));
        default = null;
      };
      dmHistoryLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      dmPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
        default = null;
      };
      dms = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; }));
        default = null;
      };
      draftChunk = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        breakPreference = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "paragraph" ] t.enum [ "newline" ] t.enum [ "sentence" ] ]);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      groupAllowFrom = lib.mkOption {
        type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
        default = null;
      };
      groupPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
        default = null;
      };
      groups = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        allowFrom = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        requireMention = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        skills = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        systemPrompt = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        tools = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          alsoAllow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; });
          default = null;
        };
        toolsBySender = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          alsoAllow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; }));
          default = null;
        };
        topics = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          allowFrom = lib.mkOption {
            type = t.nullOr (t.listOf (t.oneOf [ t.str t.number ]));
            default = null;
          };
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          requireMention = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          skills = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          systemPrompt = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
        }; }));
          default = null;
        };
      }; }));
        default = null;
      };
      heartbeat = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        showAlerts = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        showOk = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        useIndicator = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      historyLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      linkPreview = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      markdown = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        tables = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "bullets" "code" ]);
          default = null;
        };
      }; });
        default = null;
      };
      mediaMaxMb = lib.mkOption {
        type = t.nullOr (t.number);
        default = null;
      };
      name = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      network = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        autoSelectFamily = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      proxy = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      reactionLevel = lib.mkOption {
        type = t.nullOr (t.enum [ "off" "ack" "minimal" "extensive" ]);
        default = null;
      };
      reactionNotifications = lib.mkOption {
        type = t.nullOr (t.enum [ "off" "own" "all" ]);
        default = null;
      };
      replyToMode = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "first" ] t.enum [ "all" ] ]);
        default = null;
      };
      retry = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        attempts = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        jitter = lib.mkOption {
          type = t.nullOr (t.number);
          default = null;
        };
        maxDelayMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minDelayMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      streamMode = lib.mkOption {
        type = t.nullOr (t.enum [ "off" "partial" "block" ]);
        default = null;
      };
      textChunkLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      timeoutSeconds = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      tokenFile = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      webhookPath = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      webhookSecret = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      webhookUrl = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; });
      default = null;
    };
    whatsapp = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      accounts = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        ackReaction = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          direct = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          emoji = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          group = lib.mkOption {
            type = t.nullOr (t.enum [ "always" "mentions" "never" ]);
            default = null;
          };
        }; });
          default = null;
        };
        allowFrom = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        authDir = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        blockStreaming = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        blockStreamingCoalesce = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          idleMs = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          maxChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          minChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
        capabilities = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        chunkMode = lib.mkOption {
          type = t.nullOr (t.enum [ "length" "newline" ]);
          default = null;
        };
        configWrites = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        debounceMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        dmHistoryLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        dmPolicy = lib.mkOption {
          type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
          default = null;
        };
        dms = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          historyLimit = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; }));
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        groupAllowFrom = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        groupPolicy = lib.mkOption {
          type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
          default = null;
        };
        groups = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          requireMention = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          tools = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; });
            default = null;
          };
          toolsBySender = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.submodule { options = {
            allow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            alsoAllow = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            deny = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
          }; }));
            default = null;
          };
        }; }));
          default = null;
        };
        heartbeat = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          showAlerts = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          showOk = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          useIndicator = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        markdown = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          tables = lib.mkOption {
            type = t.nullOr (t.enum [ "off" "bullets" "code" ]);
            default = null;
          };
        }; });
          default = null;
        };
        mediaMaxMb = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        messagePrefix = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        name = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        selfChatMode = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        sendReadReceipts = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        textChunkLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; }));
        default = null;
      };
      ackReaction = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        direct = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        emoji = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        group = lib.mkOption {
          type = t.nullOr (t.enum [ "always" "mentions" "never" ]);
          default = null;
        };
      }; });
        default = null;
      };
      actions = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        polls = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        reactions = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        sendMessage = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      allowFrom = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      blockStreaming = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      blockStreamingCoalesce = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        idleMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        minChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      capabilities = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      chunkMode = lib.mkOption {
        type = t.nullOr (t.enum [ "length" "newline" ]);
        default = null;
      };
      configWrites = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      debounceMs = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      dmHistoryLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      dmPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "pairing" "allowlist" "open" "disabled" ]);
        default = null;
      };
      dms = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        historyLimit = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; }));
        default = null;
      };
      groupAllowFrom = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      groupPolicy = lib.mkOption {
        type = t.nullOr (t.enum [ "open" "disabled" "allowlist" ]);
        default = null;
      };
      groups = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        requireMention = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        tools = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          alsoAllow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; });
          default = null;
        };
        toolsBySender = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.submodule { options = {
          allow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          alsoAllow = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          deny = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
        }; }));
          default = null;
        };
      }; }));
        default = null;
      };
      heartbeat = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        showAlerts = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        showOk = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        useIndicator = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      historyLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      markdown = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        tables = lib.mkOption {
          type = t.nullOr (t.enum [ "off" "bullets" "code" ]);
          default = null;
        };
      }; });
        default = null;
      };
      mediaMaxMb = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      messagePrefix = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      selfChatMode = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      sendReadReceipts = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      textChunkLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
    }; });
      default = null;
    };
  }; });
    default = null;
  };

  commands = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    bash = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    bashForegroundMs = lib.mkOption {
      type = t.nullOr (t.int);
      default = null;
    };
    config = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    debug = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    native = lib.mkOption {
      type = t.nullOr (t.oneOf [ t.bool t.enum [ "auto" ] ]);
      default = null;
    };
    nativeSkills = lib.mkOption {
      type = t.nullOr (t.oneOf [ t.bool t.enum [ "auto" ] ]);
      default = null;
    };
    restart = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    text = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    useAccessGroups = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
  }; });
    default = null;
  };

  cron = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    enabled = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    maxConcurrentRuns = lib.mkOption {
      type = t.nullOr (t.int);
      default = null;
    };
    store = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
  }; });
    default = null;
  };

  diagnostics = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    cacheTrace = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      filePath = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      includeMessages = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      includePrompt = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      includeSystem = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
    }; });
      default = null;
    };
    enabled = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    flags = lib.mkOption {
      type = t.nullOr (t.listOf (t.str));
      default = null;
    };
    otel = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      endpoint = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      flushIntervalMs = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      headers = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.str));
        default = null;
      };
      logs = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      metrics = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      protocol = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "http/protobuf" ] t.enum [ "grpc" ] ]);
        default = null;
      };
      sampleRate = lib.mkOption {
        type = t.nullOr (t.number);
        default = null;
      };
      serviceName = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      traces = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
    }; });
      default = null;
    };
  }; });
    default = null;
  };

  discovery = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    mdns = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      mode = lib.mkOption {
        type = t.nullOr (t.enum [ "off" "minimal" "full" ]);
        default = null;
      };
    }; });
      default = null;
    };
    wideArea = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      domain = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
    }; });
      default = null;
    };
  }; });
    default = null;
  };

  env = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    shellEnv = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      timeoutMs = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
    }; });
      default = null;
    };
    vars = lib.mkOption {
      type = t.nullOr (t.attrsOf (t.str));
      default = null;
    };
  }; });
    default = null;
  };

  gateway = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    auth = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      allowTailscale = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      mode = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "token" ] t.enum [ "password" ] ]);
        default = null;
      };
      password = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      token = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; });
      default = null;
    };
    bind = lib.mkOption {
      type = t.nullOr (t.oneOf [ t.enum [ "auto" ] t.enum [ "lan" ] t.enum [ "loopback" ] t.enum [ "custom" ] t.enum [ "tailnet" ] ]);
      default = null;
    };
    controlUi = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      allowInsecureAuth = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      basePath = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      dangerouslyDisableDeviceAuth = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
    }; });
      default = null;
    };
    http = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      endpoints = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        chatCompletions = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        responses = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          files = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            allowUrl = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            allowedMimes = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            maxBytes = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            maxChars = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            maxRedirects = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            pdf = lib.mkOption {
              type = t.nullOr (t.submodule { options = {
              maxPages = lib.mkOption {
                type = t.nullOr (t.int);
                default = null;
              };
              maxPixels = lib.mkOption {
                type = t.nullOr (t.int);
                default = null;
              };
              minTextChars = lib.mkOption {
                type = t.nullOr (t.int);
                default = null;
              };
            }; });
              default = null;
            };
            timeoutMs = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
          }; });
            default = null;
          };
          images = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            allowUrl = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            allowedMimes = lib.mkOption {
              type = t.nullOr (t.listOf (t.str));
              default = null;
            };
            maxBytes = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            maxRedirects = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
            timeoutMs = lib.mkOption {
              type = t.nullOr (t.int);
              default = null;
            };
          }; });
            default = null;
          };
          maxBodyBytes = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
        }; });
          default = null;
        };
      }; });
        default = null;
      };
    }; });
      default = null;
    };
    mode = lib.mkOption {
      type = t.nullOr (t.oneOf [ t.enum [ "local" ] t.enum [ "remote" ] ]);
      default = null;
    };
    nodes = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      allowCommands = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      browser = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        mode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "auto" ] t.enum [ "manual" ] t.enum [ "off" ] ]);
          default = null;
        };
        node = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; });
        default = null;
      };
      denyCommands = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
    }; });
      default = null;
    };
    port = lib.mkOption {
      type = t.nullOr (t.int);
      default = null;
    };
    reload = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      debounceMs = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      mode = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "restart" ] t.enum [ "hot" ] t.enum [ "hybrid" ] ]);
        default = null;
      };
    }; });
      default = null;
    };
    remote = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      password = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      sshIdentity = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      sshTarget = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      tlsFingerprint = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      token = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      transport = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "ssh" ] t.enum [ "direct" ] ]);
        default = null;
      };
      url = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; });
      default = null;
    };
    tailscale = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      mode = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "serve" ] t.enum [ "funnel" ] ]);
        default = null;
      };
      resetOnExit = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
    }; });
      default = null;
    };
    tls = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      autoGenerate = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      caPath = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      certPath = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      keyPath = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; });
      default = null;
    };
    trustedProxies = lib.mkOption {
      type = t.nullOr (t.listOf (t.str));
      default = null;
    };
  }; });
    default = null;
  };

  hooks = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    enabled = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    gmail = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      account = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      allowUnsafeExternalContent = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      hookUrl = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      includeBody = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      label = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      maxBytes = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      model = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      pushToken = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      renewEveryMinutes = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      serve = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        bind = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        path = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        port = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      subscription = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      tailscale = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        mode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "serve" ] t.enum [ "funnel" ] ]);
          default = null;
        };
        path = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        target = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; });
        default = null;
      };
      thinking = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "minimal" ] t.enum [ "low" ] t.enum [ "medium" ] t.enum [ "high" ] ]);
        default = null;
      };
      topic = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; });
      default = null;
    };
    internal = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      entries = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        env = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.str));
          default = null;
        };
      }; }));
        default = null;
      };
      handlers = lib.mkOption {
        type = t.nullOr (t.listOf (t.submodule { options = {
        event = lib.mkOption {
          type = t.str;
        };
        export = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        module = lib.mkOption {
          type = t.str;
        };
      }; }));
        default = null;
      };
      installs = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.submodule { options = {
        hooks = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        installPath = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        installedAt = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        source = lib.mkOption {
          type = t.oneOf [ t.enum [ "npm" ] t.enum [ "archive" ] t.enum [ "path" ] ];
        };
        sourcePath = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        spec = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        version = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; }));
        default = null;
      };
      load = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        extraDirs = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
      }; });
        default = null;
      };
    }; });
      default = null;
    };
    mappings = lib.mkOption {
      type = t.nullOr (t.listOf (t.submodule { options = {
      action = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "wake" ] t.enum [ "agent" ] ]);
        default = null;
      };
      allowUnsafeExternalContent = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      channel = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "last" ] t.enum [ "whatsapp" ] t.enum [ "telegram" ] t.enum [ "discord" ] t.enum [ "slack" ] t.enum [ "signal" ] t.enum [ "imessage" ] t.enum [ "msteams" ] ]);
        default = null;
      };
      deliver = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      id = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      match = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        path = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        source = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; });
        default = null;
      };
      messageTemplate = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      model = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      name = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      sessionKey = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      textTemplate = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      thinking = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      timeoutSeconds = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      to = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      transform = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        export = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        module = lib.mkOption {
          type = t.str;
        };
      }; });
        default = null;
      };
      wakeMode = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "now" ] t.enum [ "next-heartbeat" ] ]);
        default = null;
      };
    }; }));
      default = null;
    };
    maxBodyBytes = lib.mkOption {
      type = t.nullOr (t.int);
      default = null;
    };
    path = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    presets = lib.mkOption {
      type = t.nullOr (t.listOf (t.str));
      default = null;
    };
    token = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    transformsDir = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
  }; });
    default = null;
  };

  logging = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    consoleLevel = lib.mkOption {
      type = t.nullOr (t.oneOf [ t.enum [ "silent" ] t.enum [ "fatal" ] t.enum [ "error" ] t.enum [ "warn" ] t.enum [ "info" ] t.enum [ "debug" ] t.enum [ "trace" ] ]);
      default = null;
    };
    consoleStyle = lib.mkOption {
      type = t.nullOr (t.oneOf [ t.enum [ "pretty" ] t.enum [ "compact" ] t.enum [ "json" ] ]);
      default = null;
    };
    file = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    level = lib.mkOption {
      type = t.nullOr (t.oneOf [ t.enum [ "silent" ] t.enum [ "fatal" ] t.enum [ "error" ] t.enum [ "warn" ] t.enum [ "info" ] t.enum [ "debug" ] t.enum [ "trace" ] ]);
      default = null;
    };
    redactPatterns = lib.mkOption {
      type = t.nullOr (t.listOf (t.str));
      default = null;
    };
    redactSensitive = lib.mkOption {
      type = t.nullOr (t.oneOf [ t.enum [ "off" ] t.enum [ "tools" ] ]);
      default = null;
    };
  }; });
    default = null;
  };

  media = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    preserveFilenames = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
  }; });
    default = null;
  };

  messages = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    ackReaction = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    ackReactionScope = lib.mkOption {
      type = t.nullOr (t.enum [ "group-mentions" "group-all" "direct" "all" ]);
      default = null;
    };
    groupChat = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      historyLimit = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      mentionPatterns = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
    }; });
      default = null;
    };
    inbound = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      byChannel = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.int));
        default = null;
      };
      debounceMs = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
    }; });
      default = null;
    };
    messagePrefix = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    queue = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      byChannel = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        discord = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ]);
          default = null;
        };
        imessage = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ]);
          default = null;
        };
        mattermost = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ]);
          default = null;
        };
        msteams = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ]);
          default = null;
        };
        signal = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ]);
          default = null;
        };
        slack = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ]);
          default = null;
        };
        telegram = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ]);
          default = null;
        };
        webchat = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ]);
          default = null;
        };
        whatsapp = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ]);
          default = null;
        };
      }; });
        default = null;
      };
      cap = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      debounceMs = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      debounceMsByChannel = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.int));
        default = null;
      };
      drop = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "old" ] t.enum [ "new" ] t.enum [ "summarize" ] ]);
        default = null;
      };
      mode = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "steer" ] t.enum [ "followup" ] t.enum [ "collect" ] t.enum [ "steer-backlog" ] t.enum [ "steer+backlog" ] t.enum [ "queue" ] t.enum [ "interrupt" ] ]);
        default = null;
      };
    }; });
      default = null;
    };
    removeAckAfterReply = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    responsePrefix = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    tts = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      auto = lib.mkOption {
        type = t.nullOr (t.enum [ "off" "always" "inbound" "tagged" ]);
        default = null;
      };
      edge = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        lang = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        outputFormat = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        pitch = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        proxy = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        rate = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        saveSubtitles = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        timeoutMs = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        voice = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        volume = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; });
        default = null;
      };
      elevenlabs = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        apiKey = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        applyTextNormalization = lib.mkOption {
          type = t.nullOr (t.enum [ "auto" "on" "off" ]);
          default = null;
        };
        baseUrl = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        languageCode = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        modelId = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        seed = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        voiceId = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        voiceSettings = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          similarityBoost = lib.mkOption {
            type = t.nullOr (t.number);
            default = null;
          };
          speed = lib.mkOption {
            type = t.nullOr (t.number);
            default = null;
          };
          stability = lib.mkOption {
            type = t.nullOr (t.number);
            default = null;
          };
          style = lib.mkOption {
            type = t.nullOr (t.number);
            default = null;
          };
          useSpeakerBoost = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
      }; });
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      maxTextLength = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      mode = lib.mkOption {
        type = t.nullOr (t.enum [ "final" "all" ]);
        default = null;
      };
      modelOverrides = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        allowModelId = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        allowNormalization = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        allowProvider = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        allowSeed = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        allowText = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        allowVoice = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        allowVoiceSettings = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      openai = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        apiKey = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        model = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        voice = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; });
        default = null;
      };
      prefsPath = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      provider = lib.mkOption {
        type = t.nullOr (t.enum [ "elevenlabs" "openai" "edge" ]);
        default = null;
      };
      summaryModel = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      timeoutMs = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
    }; });
      default = null;
    };
  }; });
    default = null;
  };

  meta = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    lastTouchedAt = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    lastTouchedVersion = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
  }; });
    default = null;
  };

  models = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    bedrockDiscovery = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      defaultContextWindow = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      defaultMaxTokens = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      providerFilter = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      refreshInterval = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      region = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; });
      default = null;
    };
    mode = lib.mkOption {
      type = t.nullOr (t.oneOf [ t.enum [ "merge" ] t.enum [ "replace" ] ]);
      default = null;
    };
    providers = lib.mkOption {
      type = t.nullOr (t.attrsOf (t.submodule { options = {
      api = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "openai-completions" ] t.enum [ "openai-responses" ] t.enum [ "anthropic-messages" ] t.enum [ "google-generative-ai" ] t.enum [ "github-copilot" ] t.enum [ "bedrock-converse-stream" ] ]);
        default = null;
      };
      apiKey = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      auth = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "api-key" ] t.enum [ "aws-sdk" ] t.enum [ "oauth" ] t.enum [ "token" ] ]);
        default = null;
      };
      authHeader = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      baseUrl = lib.mkOption {
        type = t.str;
      };
      headers = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.str));
        default = null;
      };
      models = lib.mkOption {
        type = t.listOf (t.submodule { options = {
        api = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "openai-completions" ] t.enum [ "openai-responses" ] t.enum [ "anthropic-messages" ] t.enum [ "google-generative-ai" ] t.enum [ "github-copilot" ] t.enum [ "bedrock-converse-stream" ] ]);
          default = null;
        };
        compat = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          maxTokensField = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "max_completion_tokens" ] t.enum [ "max_tokens" ] ]);
            default = null;
          };
          supportsDeveloperRole = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          supportsReasoningEffort = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          supportsStore = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        contextWindow = lib.mkOption {
          type = t.nullOr (t.number);
          default = null;
        };
        cost = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          cacheRead = lib.mkOption {
            type = t.nullOr (t.number);
            default = null;
          };
          cacheWrite = lib.mkOption {
            type = t.nullOr (t.number);
            default = null;
          };
          input = lib.mkOption {
            type = t.nullOr (t.number);
            default = null;
          };
          output = lib.mkOption {
            type = t.nullOr (t.number);
            default = null;
          };
        }; });
          default = null;
        };
        headers = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.str));
          default = null;
        };
        id = lib.mkOption {
          type = t.str;
        };
        input = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.enum [ "text" ] t.enum [ "image" ] ]));
          default = null;
        };
        maxTokens = lib.mkOption {
          type = t.nullOr (t.number);
          default = null;
        };
        name = lib.mkOption {
          type = t.str;
        };
        reasoning = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
      };
    }; }));
      default = null;
    };
  }; });
    default = null;
  };

  nodeHost = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    browserProxy = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      allowProfiles = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
    }; });
      default = null;
    };
  }; });
    default = null;
  };

  plugins = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    allow = lib.mkOption {
      type = t.nullOr (t.listOf (t.str));
      default = null;
    };
    deny = lib.mkOption {
      type = t.nullOr (t.listOf (t.str));
      default = null;
    };
    enabled = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    entries = lib.mkOption {
      type = t.nullOr (t.attrsOf (t.submodule { options = {
      config = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.anything));
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
    }; }));
      default = null;
    };
    installs = lib.mkOption {
      type = t.nullOr (t.attrsOf (t.submodule { options = {
      installPath = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      installedAt = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      source = lib.mkOption {
        type = t.oneOf [ t.enum [ "npm" ] t.enum [ "archive" ] t.enum [ "path" ] ];
      };
      sourcePath = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      spec = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      version = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; }));
      default = null;
    };
    load = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      paths = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
    }; });
      default = null;
    };
    slots = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      memory = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; });
      default = null;
    };
  }; });
    default = null;
  };

  session = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    agentToAgent = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      maxPingPongTurns = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
    }; });
      default = null;
    };
    dmScope = lib.mkOption {
      type = t.nullOr (t.oneOf [ t.enum [ "main" ] t.enum [ "per-peer" ] t.enum [ "per-channel-peer" ] t.enum [ "per-account-channel-peer" ] ]);
      default = null;
    };
    identityLinks = lib.mkOption {
      type = t.nullOr (t.attrsOf (t.listOf (t.str)));
      default = null;
    };
    idleMinutes = lib.mkOption {
      type = t.nullOr (t.int);
      default = null;
    };
    mainKey = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    reset = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      atHour = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      idleMinutes = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      mode = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "daily" ] t.enum [ "idle" ] ]);
        default = null;
      };
    }; });
      default = null;
    };
    resetByChannel = lib.mkOption {
      type = t.nullOr (t.attrsOf (t.submodule { options = {
      atHour = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      idleMinutes = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      mode = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "daily" ] t.enum [ "idle" ] ]);
        default = null;
      };
    }; }));
      default = null;
    };
    resetByType = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      dm = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        atHour = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        idleMinutes = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        mode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "daily" ] t.enum [ "idle" ] ]);
          default = null;
        };
      }; });
        default = null;
      };
      group = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        atHour = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        idleMinutes = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        mode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "daily" ] t.enum [ "idle" ] ]);
          default = null;
        };
      }; });
        default = null;
      };
      thread = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        atHour = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        idleMinutes = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        mode = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "daily" ] t.enum [ "idle" ] ]);
          default = null;
        };
      }; });
        default = null;
      };
    }; });
      default = null;
    };
    resetTriggers = lib.mkOption {
      type = t.nullOr (t.listOf (t.str));
      default = null;
    };
    scope = lib.mkOption {
      type = t.nullOr (t.oneOf [ t.enum [ "per-sender" ] t.enum [ "global" ] ]);
      default = null;
    };
    sendPolicy = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      default = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ]);
        default = null;
      };
      rules = lib.mkOption {
        type = t.nullOr (t.listOf (t.submodule { options = {
        action = lib.mkOption {
          type = t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ];
        };
        match = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          channel = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          chatType = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "direct" ] t.enum [ "group" ] t.enum [ "channel" ] ]);
            default = null;
          };
          keyPrefix = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
        }; });
          default = null;
        };
      }; }));
        default = null;
      };
    }; });
      default = null;
    };
    store = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    typingIntervalSeconds = lib.mkOption {
      type = t.nullOr (t.int);
      default = null;
    };
    typingMode = lib.mkOption {
      type = t.nullOr (t.oneOf [ t.enum [ "never" ] t.enum [ "instant" ] t.enum [ "thinking" ] t.enum [ "message" ] ]);
      default = null;
    };
  }; });
    default = null;
  };

  skills = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    allowBundled = lib.mkOption {
      type = t.nullOr (t.listOf (t.str));
      default = null;
    };
    entries = lib.mkOption {
      type = t.nullOr (t.attrsOf (t.submodule { options = {
      apiKey = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      config = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.anything));
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      env = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.str));
        default = null;
      };
    }; }));
      default = null;
    };
    install = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      nodeManager = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "npm" ] t.enum [ "pnpm" ] t.enum [ "yarn" ] t.enum [ "bun" ] ]);
        default = null;
      };
      preferBrew = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
    }; });
      default = null;
    };
    load = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      extraDirs = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      watch = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      watchDebounceMs = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
    }; });
      default = null;
    };
  }; });
    default = null;
  };

  talk = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    apiKey = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    interruptOnSpeech = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    modelId = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    outputFormat = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    voiceAliases = lib.mkOption {
      type = t.nullOr (t.attrsOf (t.str));
      default = null;
    };
    voiceId = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
  }; });
    default = null;
  };

  tools = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    agentToAgent = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      allow = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
    }; });
      default = null;
    };
    allow = lib.mkOption {
      type = t.nullOr (t.listOf (t.str));
      default = null;
    };
    alsoAllow = lib.mkOption {
      type = t.nullOr (t.listOf (t.str));
      default = null;
    };
    byProvider = lib.mkOption {
      type = t.nullOr (t.attrsOf (t.submodule { options = {
      allow = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      alsoAllow = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      deny = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      profile = lib.mkOption {
        type = t.nullOr (t.oneOf [ t.enum [ "minimal" ] t.enum [ "coding" ] t.enum [ "messaging" ] t.enum [ "full" ] ]);
        default = null;
      };
    }; }));
      default = null;
    };
    deny = lib.mkOption {
      type = t.nullOr (t.listOf (t.str));
      default = null;
    };
    elevated = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      allowFrom = lib.mkOption {
        type = t.nullOr (t.attrsOf (t.listOf (t.oneOf [ t.str t.number ])));
        default = null;
      };
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
    }; });
      default = null;
    };
    exec = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      applyPatch = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        allowModels = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      ask = lib.mkOption {
        type = t.nullOr (t.enum [ "off" "on-miss" "always" ]);
        default = null;
      };
      backgroundMs = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      cleanupMs = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      host = lib.mkOption {
        type = t.nullOr (t.enum [ "sandbox" "gateway" "node" ]);
        default = null;
      };
      node = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      notifyOnExit = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      pathPrepend = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      safeBins = lib.mkOption {
        type = t.nullOr (t.listOf (t.str));
        default = null;
      };
      security = lib.mkOption {
        type = t.nullOr (t.enum [ "deny" "allowlist" "full" ]);
        default = null;
      };
      timeoutSec = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
    }; });
      default = null;
    };
    links = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      enabled = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      maxLinks = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      models = lib.mkOption {
        type = t.nullOr (t.listOf (t.submodule { options = {
        args = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        command = lib.mkOption {
          type = t.str;
        };
        timeoutSeconds = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        type = lib.mkOption {
          type = t.nullOr (t.enum [ "cli" ]);
          default = null;
        };
      }; }));
        default = null;
      };
      scope = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        default = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ]);
          default = null;
        };
        rules = lib.mkOption {
          type = t.nullOr (t.listOf (t.submodule { options = {
          action = lib.mkOption {
            type = t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ];
          };
          match = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            channel = lib.mkOption {
              type = t.nullOr (t.str);
              default = null;
            };
            chatType = lib.mkOption {
              type = t.nullOr (t.oneOf [ t.enum [ "direct" ] t.enum [ "group" ] t.enum [ "channel" ] ]);
              default = null;
            };
            keyPrefix = lib.mkOption {
              type = t.nullOr (t.str);
              default = null;
            };
          }; });
            default = null;
          };
        }; }));
          default = null;
        };
      }; });
        default = null;
      };
      timeoutSeconds = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
    }; });
      default = null;
    };
    media = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      audio = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        attachments = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          maxAttachments = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          mode = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "first" ] t.enum [ "all" ] ]);
            default = null;
          };
          prefer = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "first" ] t.enum [ "last" ] t.enum [ "path" ] t.enum [ "url" ] ]);
            default = null;
          };
        }; });
          default = null;
        };
        baseUrl = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        deepgram = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          detectLanguage = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          punctuate = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          smartFormat = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        headers = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.str));
          default = null;
        };
        language = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        maxBytes = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        models = lib.mkOption {
          type = t.nullOr (t.listOf (t.submodule { options = {
          args = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          baseUrl = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          capabilities = lib.mkOption {
            type = t.nullOr (t.listOf (t.oneOf [ t.enum [ "image" ] t.enum [ "audio" ] t.enum [ "video" ] ]));
            default = null;
          };
          command = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          deepgram = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            detectLanguage = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            punctuate = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            smartFormat = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
          }; });
            default = null;
          };
          headers = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.str));
            default = null;
          };
          language = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          maxBytes = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          maxChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          model = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          preferredProfile = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          profile = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          prompt = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          provider = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          providerOptions = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.attrsOf (t.oneOf [ t.str t.number t.bool ])));
            default = null;
          };
          timeoutSeconds = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          type = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "provider" ] t.enum [ "cli" ] ]);
            default = null;
          };
        }; }));
          default = null;
        };
        prompt = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        providerOptions = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.attrsOf (t.oneOf [ t.str t.number t.bool ])));
          default = null;
        };
        scope = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          default = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ]);
            default = null;
          };
          rules = lib.mkOption {
            type = t.nullOr (t.listOf (t.submodule { options = {
            action = lib.mkOption {
              type = t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ];
            };
            match = lib.mkOption {
              type = t.nullOr (t.submodule { options = {
              channel = lib.mkOption {
                type = t.nullOr (t.str);
                default = null;
              };
              chatType = lib.mkOption {
                type = t.nullOr (t.oneOf [ t.enum [ "direct" ] t.enum [ "group" ] t.enum [ "channel" ] ]);
                default = null;
              };
              keyPrefix = lib.mkOption {
                type = t.nullOr (t.str);
                default = null;
              };
            }; });
              default = null;
            };
          }; }));
            default = null;
          };
        }; });
          default = null;
        };
        timeoutSeconds = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      concurrency = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      image = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        attachments = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          maxAttachments = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          mode = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "first" ] t.enum [ "all" ] ]);
            default = null;
          };
          prefer = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "first" ] t.enum [ "last" ] t.enum [ "path" ] t.enum [ "url" ] ]);
            default = null;
          };
        }; });
          default = null;
        };
        baseUrl = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        deepgram = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          detectLanguage = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          punctuate = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          smartFormat = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        headers = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.str));
          default = null;
        };
        language = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        maxBytes = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        models = lib.mkOption {
          type = t.nullOr (t.listOf (t.submodule { options = {
          args = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          baseUrl = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          capabilities = lib.mkOption {
            type = t.nullOr (t.listOf (t.oneOf [ t.enum [ "image" ] t.enum [ "audio" ] t.enum [ "video" ] ]));
            default = null;
          };
          command = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          deepgram = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            detectLanguage = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            punctuate = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            smartFormat = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
          }; });
            default = null;
          };
          headers = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.str));
            default = null;
          };
          language = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          maxBytes = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          maxChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          model = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          preferredProfile = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          profile = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          prompt = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          provider = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          providerOptions = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.attrsOf (t.oneOf [ t.str t.number t.bool ])));
            default = null;
          };
          timeoutSeconds = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          type = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "provider" ] t.enum [ "cli" ] ]);
            default = null;
          };
        }; }));
          default = null;
        };
        prompt = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        providerOptions = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.attrsOf (t.oneOf [ t.str t.number t.bool ])));
          default = null;
        };
        scope = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          default = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ]);
            default = null;
          };
          rules = lib.mkOption {
            type = t.nullOr (t.listOf (t.submodule { options = {
            action = lib.mkOption {
              type = t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ];
            };
            match = lib.mkOption {
              type = t.nullOr (t.submodule { options = {
              channel = lib.mkOption {
                type = t.nullOr (t.str);
                default = null;
              };
              chatType = lib.mkOption {
                type = t.nullOr (t.oneOf [ t.enum [ "direct" ] t.enum [ "group" ] t.enum [ "channel" ] ]);
                default = null;
              };
              keyPrefix = lib.mkOption {
                type = t.nullOr (t.str);
                default = null;
              };
            }; });
              default = null;
            };
          }; }));
            default = null;
          };
        }; });
          default = null;
        };
        timeoutSeconds = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
      models = lib.mkOption {
        type = t.nullOr (t.listOf (t.submodule { options = {
        args = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        baseUrl = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        capabilities = lib.mkOption {
          type = t.nullOr (t.listOf (t.oneOf [ t.enum [ "image" ] t.enum [ "audio" ] t.enum [ "video" ] ]));
          default = null;
        };
        command = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        deepgram = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          detectLanguage = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          punctuate = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          smartFormat = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        headers = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.str));
          default = null;
        };
        language = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        maxBytes = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        model = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        preferredProfile = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        profile = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        prompt = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        provider = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        providerOptions = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.attrsOf (t.oneOf [ t.str t.number t.bool ])));
          default = null;
        };
        timeoutSeconds = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        type = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "provider" ] t.enum [ "cli" ] ]);
          default = null;
        };
      }; }));
        default = null;
      };
      video = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        attachments = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          maxAttachments = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          mode = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "first" ] t.enum [ "all" ] ]);
            default = null;
          };
          prefer = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "first" ] t.enum [ "last" ] t.enum [ "path" ] t.enum [ "url" ] ]);
            default = null;
          };
        }; });
          default = null;
        };
        baseUrl = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        deepgram = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          detectLanguage = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          punctuate = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          smartFormat = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
        }; });
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        headers = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.str));
          default = null;
        };
        language = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        maxBytes = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        models = lib.mkOption {
          type = t.nullOr (t.listOf (t.submodule { options = {
          args = lib.mkOption {
            type = t.nullOr (t.listOf (t.str));
            default = null;
          };
          baseUrl = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          capabilities = lib.mkOption {
            type = t.nullOr (t.listOf (t.oneOf [ t.enum [ "image" ] t.enum [ "audio" ] t.enum [ "video" ] ]));
            default = null;
          };
          command = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          deepgram = lib.mkOption {
            type = t.nullOr (t.submodule { options = {
            detectLanguage = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            punctuate = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
            smartFormat = lib.mkOption {
              type = t.nullOr (t.bool);
              default = null;
            };
          }; });
            default = null;
          };
          headers = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.str));
            default = null;
          };
          language = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          maxBytes = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          maxChars = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          model = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          preferredProfile = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          profile = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          prompt = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          provider = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          providerOptions = lib.mkOption {
            type = t.nullOr (t.attrsOf (t.attrsOf (t.oneOf [ t.str t.number t.bool ])));
            default = null;
          };
          timeoutSeconds = lib.mkOption {
            type = t.nullOr (t.int);
            default = null;
          };
          type = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "provider" ] t.enum [ "cli" ] ]);
            default = null;
          };
        }; }));
          default = null;
        };
        prompt = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        providerOptions = lib.mkOption {
          type = t.nullOr (t.attrsOf (t.attrsOf (t.oneOf [ t.str t.number t.bool ])));
          default = null;
        };
        scope = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          default = lib.mkOption {
            type = t.nullOr (t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ]);
            default = null;
          };
          rules = lib.mkOption {
            type = t.nullOr (t.listOf (t.submodule { options = {
            action = lib.mkOption {
              type = t.oneOf [ t.enum [ "allow" ] t.enum [ "deny" ] ];
            };
            match = lib.mkOption {
              type = t.nullOr (t.submodule { options = {
              channel = lib.mkOption {
                type = t.nullOr (t.str);
                default = null;
              };
              chatType = lib.mkOption {
                type = t.nullOr (t.oneOf [ t.enum [ "direct" ] t.enum [ "group" ] t.enum [ "channel" ] ]);
                default = null;
              };
              keyPrefix = lib.mkOption {
                type = t.nullOr (t.str);
                default = null;
              };
            }; });
              default = null;
            };
          }; }));
            default = null;
          };
        }; });
          default = null;
        };
        timeoutSeconds = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
    }; });
      default = null;
    };
    message = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      allowCrossContextSend = lib.mkOption {
        type = t.nullOr (t.bool);
        default = null;
      };
      broadcast = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
      }; });
        default = null;
      };
      crossContext = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        allowAcrossProviders = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        allowWithinProvider = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        marker = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          enabled = lib.mkOption {
            type = t.nullOr (t.bool);
            default = null;
          };
          prefix = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          suffix = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
        }; });
          default = null;
        };
      }; });
        default = null;
      };
    }; });
      default = null;
    };
    profile = lib.mkOption {
      type = t.nullOr (t.oneOf [ t.enum [ "minimal" ] t.enum [ "coding" ] t.enum [ "messaging" ] t.enum [ "full" ] ]);
      default = null;
    };
    sandbox = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      tools = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        allow = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        alsoAllow = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        deny = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
      }; });
        default = null;
      };
    }; });
      default = null;
    };
    subagents = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      tools = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        allow = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        alsoAllow = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
        deny = lib.mkOption {
          type = t.nullOr (t.listOf (t.str));
          default = null;
        };
      }; });
        default = null;
      };
    }; });
      default = null;
    };
    web = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      fetch = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        cacheTtlMinutes = lib.mkOption {
          type = t.nullOr (t.number);
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        maxChars = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        maxRedirects = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        timeoutSeconds = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        userAgent = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
      }; });
        default = null;
      };
      search = lib.mkOption {
        type = t.nullOr (t.submodule { options = {
        apiKey = lib.mkOption {
          type = t.nullOr (t.str);
          default = null;
        };
        cacheTtlMinutes = lib.mkOption {
          type = t.nullOr (t.number);
          default = null;
        };
        enabled = lib.mkOption {
          type = t.nullOr (t.bool);
          default = null;
        };
        maxResults = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
        perplexity = lib.mkOption {
          type = t.nullOr (t.submodule { options = {
          apiKey = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          baseUrl = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
          model = lib.mkOption {
            type = t.nullOr (t.str);
            default = null;
          };
        }; });
          default = null;
        };
        provider = lib.mkOption {
          type = t.nullOr (t.oneOf [ t.enum [ "brave" ] t.enum [ "perplexity" ] ]);
          default = null;
        };
        timeoutSeconds = lib.mkOption {
          type = t.nullOr (t.int);
          default = null;
        };
      }; });
        default = null;
      };
    }; });
      default = null;
    };
  }; });
    default = null;
  };

  ui = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    assistant = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      avatar = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
      name = lib.mkOption {
        type = t.nullOr (t.str);
        default = null;
      };
    }; });
      default = null;
    };
    seamColor = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
  }; });
    default = null;
  };

  update = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    channel = lib.mkOption {
      type = t.nullOr (t.oneOf [ t.enum [ "stable" ] t.enum [ "beta" ] t.enum [ "dev" ] ]);
      default = null;
    };
    checkOnStart = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
  }; });
    default = null;
  };

  web = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    enabled = lib.mkOption {
      type = t.nullOr (t.bool);
      default = null;
    };
    heartbeatSeconds = lib.mkOption {
      type = t.nullOr (t.int);
      default = null;
    };
    reconnect = lib.mkOption {
      type = t.nullOr (t.submodule { options = {
      factor = lib.mkOption {
        type = t.nullOr (t.number);
        default = null;
      };
      initialMs = lib.mkOption {
        type = t.nullOr (t.number);
        default = null;
      };
      jitter = lib.mkOption {
        type = t.nullOr (t.number);
        default = null;
      };
      maxAttempts = lib.mkOption {
        type = t.nullOr (t.int);
        default = null;
      };
      maxMs = lib.mkOption {
        type = t.nullOr (t.number);
        default = null;
      };
    }; });
      default = null;
    };
  }; });
    default = null;
  };

  wizard = lib.mkOption {
    type = t.nullOr (t.submodule { options = {
    lastRunAt = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    lastRunCommand = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    lastRunCommit = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
    lastRunMode = lib.mkOption {
      type = t.nullOr (t.oneOf [ t.enum [ "local" ] t.enum [ "remote" ] ]);
      default = null;
    };
    lastRunVersion = lib.mkOption {
      type = t.nullOr (t.str);
      default = null;
    };
  }; });
    default = null;
  };
}
