import fs from "node:fs";
import path from "node:path";
import { pathToFileURL } from "node:url";

const args = process.argv.slice(2);
const argValue = (flag: string): string | null => {
  const idx = args.indexOf(flag);
  if (idx === -1 || idx + 1 >= args.length) return null;
  return args[idx + 1];
};

const repo = argValue("--repo") ?? process.cwd();
const outPath = argValue("--out") ?? path.join(process.cwd(), "nix/generated/openclaw-config-options.nix");

const schemaPath = path.join(repo, "src/config/zod-schema.ts");
const schemaUrl = pathToFileURL(schemaPath).href;

const loadSchema = async (): Promise<Record<string, unknown>> => {
  const mod = await import(schemaUrl);
  const schema = mod.OpenClawSchema ?? mod.MoltbotSchema;
  if (!schema || typeof schema.toJSONSchema !== "function") {
    console.error(`OpenClawSchema/MoltbotSchema not found at ${schemaPath}`);
    process.exit(1);
  }
  return schema.toJSONSchema({
    target: "draft-07",
    unrepresentable: "any",
  }) as Record<string, unknown>;
};

const main = async (): Promise<void> => {
  const schema = await loadSchema();
  const definitions: Record<string, unknown> =
    (schema.definitions as Record<string, unknown>) ||
    (schema.$defs as Record<string, unknown>) ||
    {};

const stringify = (value: string): string => {
  const escaped = value.replace(/\\/g, "\\\\").replace(/"/g, "\\\"");
  return `"${escaped}"`;
};

const nixAttr = (key: string): string => {
  if (/^[A-Za-z_][A-Za-z0-9_']*$/.test(key)) return key;
  return stringify(key);
};

const nixLiteral = (value: unknown): string => {
  if (value === null) return "null";
  if (typeof value === "string") return stringify(value);
  if (typeof value === "number") return Number.isFinite(value) ? String(value) : "null";
  if (typeof value === "boolean") return value ? "true" : "false";
  if (Array.isArray(value)) {
    return `[ ${value.map(nixLiteral).join(" ")} ]`;
  }
  return "null";
};

type JsonSchema = Record<string, unknown>;

const resolveRef = (ref: string): JsonSchema | null => {
  const prefixDefs = "#/definitions/";
  const prefixDefsAlt = "#/$defs/";
  if (ref.startsWith(prefixDefs)) {
    const name = ref.slice(prefixDefs.length);
    return (definitions[name] as JsonSchema) || null;
  }
  if (ref.startsWith(prefixDefsAlt)) {
    const name = ref.slice(prefixDefsAlt.length);
    return (definitions[name] as JsonSchema) || null;
  }
  return null;
};

const deref = (input: JsonSchema, seen: Set<string>): JsonSchema => {
  if (input.$ref && typeof input.$ref === "string") {
    const ref = input.$ref as string;
    if (seen.has(ref)) {
      return {};
    }
    const resolved = resolveRef(ref);
    if (!resolved) return {};
    const nextSeen = new Set(seen);
    nextSeen.add(ref);
    return deref(resolved, nextSeen);
  }
  return input;
};

const isNullSchema = (value: unknown): boolean => {
  if (!value || typeof value !== "object") return false;
  const schemaObj = value as JsonSchema;
  if (schemaObj.type === "null") return true;
  if (Array.isArray(schemaObj.type)) return schemaObj.type.includes("null");
  return false;
};

const stripNullable = (schemaObj: JsonSchema): { schema: JsonSchema; nullable: boolean } => {
  const schema = deref(schemaObj, new Set());
  if (schema.anyOf && Array.isArray(schema.anyOf)) {
    const entries = schema.anyOf as JsonSchema[];
    const nullable = entries.some(isNullSchema);
    const next = entries.filter((entry) => !isNullSchema(entry));
    return {
      schema: { ...schema, anyOf: next },
      nullable,
    };
  }
  if (schema.oneOf && Array.isArray(schema.oneOf)) {
    const entries = schema.oneOf as JsonSchema[];
    const nullable = entries.some(isNullSchema);
    const next = entries.filter((entry) => !isNullSchema(entry));
    return {
      schema: { ...schema, oneOf: next },
      nullable,
    };
  }
  if (Array.isArray(schema.type)) {
    const nullable = schema.type.includes("null");
    const nextTypes = schema.type.filter((t) => t !== "null");
    const nextSchema = { ...schema };
    if (nextTypes.length === 1) {
      nextSchema.type = nextTypes[0];
    } else {
      nextSchema.type = nextTypes;
    }
    return { schema: nextSchema, nullable };
  }
  return { schema, nullable: false };
};

const typeForSchema = (schemaObj: JsonSchema, indent: string): string => {
  const { schema, nullable } = stripNullable(schemaObj);
  const typeExpr = baseTypeForSchema(schema, indent);
  if (nullable) {
    return `t.nullOr (${typeExpr})`;
  }
  return typeExpr;
};

const baseTypeForSchema = (schemaObj: JsonSchema, indent: string): string => {
  const schema = deref(schemaObj, new Set());
  if (schema.const !== undefined) {
    return `t.enum [ ${nixLiteral(schema.const)} ]`;
  }
  if (Array.isArray(schema.enum)) {
    const values = schema.enum.map((value) => nixLiteral(value)).join(" ");
    return `t.enum [ ${values} ]`;
  }

  if (schema.anyOf && Array.isArray(schema.anyOf) && schema.anyOf.length > 0) {
    const entries = schema.anyOf as JsonSchema[];
    const parts = entries.map((entry) => typeForSchema(entry, indent)).join(" ");
    return `t.oneOf [ ${parts} ]`;
  }

  if (schema.oneOf && Array.isArray(schema.oneOf) && schema.oneOf.length > 0) {
    const entries = schema.oneOf as JsonSchema[];
    const parts = entries.map((entry) => typeForSchema(entry, indent)).join(" ");
    return `t.oneOf [ ${parts} ]`;
  }

  if (schema.allOf && Array.isArray(schema.allOf) && schema.allOf.length > 0) {
    return "t.anything";
  }

  const schemaType = schema.type;
  if (Array.isArray(schemaType) && schemaType.length > 0) {
    const parts = schemaType.map((entry) => typeForSchema({ type: entry }, indent)).join(" ");
    return `t.oneOf [ ${parts} ]`;
  }

  switch (schemaType) {
    case "string":
      return "t.str";
    case "number":
      return "t.number";
    case "integer":
      return "t.int";
    case "boolean":
      return "t.bool";
    case "array": {
      const items = (schema.items as JsonSchema) || {};
      return `t.listOf (${typeForSchema(items, indent)})`;
    }
    case "object":
      return objectTypeForSchema(schema, indent);
    case undefined:
      if (schema.properties || schema.additionalProperties) {
        return objectTypeForSchema(schema, indent);
      }
      return "t.anything";
    default:
      return "t.anything";
  }
};

const objectTypeForSchema = (schema: JsonSchema, indent: string): string => {
  const properties = (schema.properties as Record<string, JsonSchema>) || {};
  const requiredList = new Set((schema.required as string[]) || []);
  const keys = Object.keys(properties);

  if (keys.length === 0) {
    if (schema.additionalProperties && typeof schema.additionalProperties === "object") {
      const valueType = typeForSchema(schema.additionalProperties as JsonSchema, indent);
      return `t.attrsOf (${valueType})`;
    }
    if (schema.additionalProperties === true) {
      return "t.attrs";
    }
    return "t.attrs";
  }

  const nextIndent = `${indent}  `;
  const inner = keys
    .sort()
    .map((key) => renderOption(key, properties[key], requiredList.has(key), nextIndent))
    .join("\n");

  return `t.submodule { options = {\n${inner}\n${indent}}; }`;
};

const renderOption = (key: string, schemaObj: JsonSchema, _required: boolean, indent: string): string => {
  const schema = deref(schemaObj, new Set());
  const description = typeof schema.description === "string" ? schema.description : null;
  const typeExpr = typeForSchema(schema, indent);
  const lines = [
    `${indent}${nixAttr(key)} = lib.mkOption {`,
    `${indent}  type = ${typeExpr};`,
  ];
  if (description) {
    lines.push(`${indent}  description = ${stringify(description)};`);
  }
  lines.push(`${indent}};`);
  return lines.join("\n");
};

// --- Metadata collection ---

interface TypeMeta {
  type: string;
  values?: unknown[];
  alternatives?: TypeMeta[];
  items?: TypeMeta;
}

const collectTypeMeta = (schemaObj: JsonSchema): TypeMeta => {
  const { schema, nullable } = stripNullable(schemaObj);
  const base = collectBaseTypeMeta(schema);
  if (nullable) return { type: "nullable", alternatives: [base] };
  return base;
};

const collectBaseTypeMeta = (schemaObj: JsonSchema): TypeMeta => {
  const schema = deref(schemaObj, new Set());
  if (schema.const !== undefined) return { type: "enum", values: [schema.const] };
  if (Array.isArray(schema.enum)) return { type: "enum", values: schema.enum };

  if (schema.anyOf && Array.isArray(schema.anyOf)) {
    const entries = (schema.anyOf as JsonSchema[]).filter((e) => !isNullSchema(e));
    if (entries.length === 1) return collectTypeMeta(entries[0]);
    const alts = entries.map(collectTypeMeta);
    if (alts.every((a) => a.type === "enum" && a.values?.length === 1)) {
      return { type: "enum", values: alts.map((a) => a.values![0]) };
    }
    return { type: "oneOf", alternatives: alts };
  }
  if (schema.oneOf && Array.isArray(schema.oneOf)) {
    const entries = (schema.oneOf as JsonSchema[]).filter((e) => !isNullSchema(e));
    if (entries.length === 1) return collectTypeMeta(entries[0]);
    const alts = entries.map(collectTypeMeta);
    if (alts.every((a) => a.type === "enum" && a.values?.length === 1)) {
      return { type: "enum", values: alts.map((a) => a.values![0]) };
    }
    return { type: "oneOf", alternatives: alts };
  }

  switch (schema.type) {
    case "string": return { type: "string" };
    case "number": return { type: "number" };
    case "integer": return { type: "integer" };
    case "boolean": return { type: "boolean" };
    case "array": {
      const items = (schema.items as JsonSchema) || {};
      return { type: "array", items: collectTypeMeta(items) };
    }
    case "object":
      return { type: "object" };
    default:
      if (schema.properties || schema.additionalProperties)
        return { type: "object" };
      return { type: "any" };
  }
};

interface SchemaMetadata {
  version: string;
  validPaths: Record<string, string[]>;
  types: Record<string, TypeMeta>;
  dynamicKeys: string[];
  knownChannels: string[];
}

const collectPaths = (
  schemaObj: JsonSchema,
  path: string,
  metadata: SchemaMetadata,
  seen: Set<string>,
): void => {
  const schema = deref(schemaObj, new Set());
  const properties = (schema.properties as Record<string, JsonSchema>) || {};
  const keys = Object.keys(properties).sort();

  if (keys.length === 0) {
    if (schema.additionalProperties && typeof schema.additionalProperties === "object") {
      metadata.dynamicKeys.push(path);
      // Recurse into additionalProperties value schema with wildcard
      const valueSchema = deref(schema.additionalProperties as JsonSchema, new Set());
      if (valueSchema.properties) {
        collectPaths(valueSchema, `${path}.*`, metadata, seen);
      }
    } else if (schema.additionalProperties === true) {
      metadata.dynamicKeys.push(path);
    }
    return;
  }

  metadata.validPaths[path] = keys;

  for (const key of keys) {
    const childSchema = deref(properties[key], new Set());
    const childPath = path === "" ? key : `${path}.${key}`;
    const typeMeta = collectTypeMeta(properties[key]);
    metadata.types[childPath] = typeMeta;

    if (childSchema.type === "object" || childSchema.properties || childSchema.additionalProperties) {
      collectPaths(childSchema, childPath, metadata, seen);
    }
    // Recurse into submodules that are behind $ref
    if (properties[key].$ref) {
      const resolved = deref(properties[key], new Set());
      if (resolved.properties || resolved.additionalProperties) {
        collectPaths(resolved, childPath, metadata, seen);
      }
    }
  }
};

  const rootSchema = deref(schema as JsonSchema, new Set());
  const rootProps = (rootSchema.properties as Record<string, JsonSchema>) || {};
  const requiredRoot = new Set((rootSchema.required as string[]) || []);

  const body = Object.keys(rootProps)
    .sort()
    .map((key) => renderOption(key, rootProps[key], requiredRoot.has(key), "  "))
    .join("\n\n");

  const output = `# Generated from upstream OpenClaw schema. DO NOT EDIT.\n{ lib }:\nlet\n  t = lib.types;\nin\n{\n${body}\n}\n`;

  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, output, "utf8");

  // --- Generate metadata JSON ---
  const metadata: SchemaMetadata = {
    version: "1.0",
    validPaths: {},
    types: {},
    dynamicKeys: [],
    knownChannels: [],
  };

  collectPaths(rootSchema, "", metadata, new Set());

  // Extract known channels from channels.* keys
  const channelsSchema = deref(rootProps.channels || {}, new Set());
  const channelProps = (channelsSchema.properties as Record<string, JsonSchema>) || {};
  metadata.knownChannels = Object.keys(channelProps)
    .filter((k) => k !== "defaults")
    .sort();

  const metadataPath = path.join(path.dirname(outPath), "openclaw-config-metadata.json");
  fs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2) + "\n", "utf8");
};

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
