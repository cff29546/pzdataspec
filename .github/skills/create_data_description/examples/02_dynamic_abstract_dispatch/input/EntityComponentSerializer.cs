using System;
using System.Collections.Generic;
using System.IO;

abstract class Component {
    public abstract ushort ComponentId { get; }
    public abstract void Serialize(BinaryWriter writer, uint worldVersion);
    public abstract void Deserialize(BinaryReader reader, uint worldVersion);
}

class FuelComponent : Component {
    public override ushort ComponentId => 2;
    public float Liters;
    public override void Serialize(BinaryWriter writer, uint worldVersion) {
        writer.Write(Liters);
    }
    public override void Deserialize(BinaryReader reader, uint worldVersion) {
        Liters = reader.ReadSingle();
    }
}

class SignComponent : Component {
    public override ushort ComponentId => 8;
    public string Text = "";
    public override void Serialize(BinaryWriter writer, uint worldVersion) {
        var raw = System.Text.Encoding.UTF8.GetBytes(Text);
        writer.Write((ushort)raw.Length);
        writer.Write(raw);
    }
    public override void Deserialize(BinaryReader reader, uint worldVersion) {
        ushort len = reader.ReadUInt16();
        var raw = reader.ReadBytes(len);
        Text = System.Text.Encoding.UTF8.GetString(raw);
    }
}

static class ComponentTypeTable {
    public static readonly Dictionary<ushort, Type> IdToType = new Dictionary<ushort, Type> {
        { 2, typeof(FuelComponent) },
        { 8, typeof(SignComponent) }
    };
}

class EntitySerializer {
    public void Serialize(List<Component> components, BinaryWriter writer, uint worldVersion) {
        writer.Write((byte)components.Count);
        foreach (var c in components) {
            using (var ms = new MemoryStream()) {
                using (var block = new BinaryWriter(ms)) {
                    block.Write(c.ComponentId);
                    c.Serialize(block, worldVersion);
                    block.Flush();
                }
                byte[] payload = ms.ToArray();
                writer.Write((uint)payload.Length);
                writer.Write(payload);
            }
        }
    }

    public List<Component> Deserialize(BinaryReader reader, uint worldVersion) {
        byte numComponents = reader.ReadByte();
        var result = new List<Component>();
        for (int i = 0; i < numComponents; i++) {
            uint payloadLen = reader.ReadUInt32();
            var payload = reader.ReadBytes((int)payloadLen);
            using var ms = new MemoryStream(payload);
            using var block = new BinaryReader(ms);
            ushort componentId = block.ReadUInt16();
            Component component = componentId switch {
                2 => new FuelComponent(),
                8 => new SignComponent(),
                _ => throw new InvalidDataException($"Unknown component id: {componentId}")
            };
            component.Deserialize(block, worldVersion);
            result.Add(component);
            if (ms.Position != ms.Length) {
                throw new InvalidDataException($"Component payload not fully consumed for id={componentId}");
            }
        }
        return result;
    }
}

class Program {
    static int Main(string[] args) {
        string outPath = args.Length > 0 ? args[0] : "..\\output\\entity_component.bin";
        try {
            var components = new List<Component> {
                new FuelComponent { Liters = 42.5f },
                new SignComponent { Text = "HELLO" }
            };

            Directory.CreateDirectory(Path.GetDirectoryName(outPath)!);
            using (var fs = File.Create(outPath))
            using (var writer = new BinaryWriter(fs)) {
                new EntitySerializer().Serialize(components, writer, 241);
            }

            using (var fs = File.OpenRead(outPath))
            using (var reader = new BinaryReader(fs)) {
                var parsed = new EntitySerializer().Deserialize(reader, 241);
                if (parsed.Count != components.Count) {
                    throw new Exception("Round-trip count mismatch");
                }
                var p0 = (FuelComponent)parsed[0];
                var p1 = (SignComponent)parsed[1];
                if (Math.Abs(p0.Liters - ((FuelComponent)components[0]).Liters) > 0.0001f) {
                    throw new Exception("FuelComponent round-trip mismatch");
                }
                if (p1.Text != ((SignComponent)components[1]).Text) {
                    throw new Exception("SignComponent round-trip mismatch");
                }
            }

            Console.WriteLine("Round-trip OK");
            Console.WriteLine("Wrote: " + Path.GetFullPath(outPath));
            return 0;
        } catch (Exception ex) {
            Console.Error.WriteLine(ex.ToString());
            return 1;
        }
    }
}
