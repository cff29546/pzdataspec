import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.charset.StandardCharsets;

class DictionaryData {
    static class DictInfo {
        short registryId;
        int moduleIndex;
        String name;
        byte flags;
        int modId;
        List<Integer> modOverrides = new ArrayList<>();
    }

    int numModIds;
    int numModules;
    List<DictInfo> entries = new ArrayList<>();

    void save(ByteBuffer bb) {
        bb.putInt(numModIds);
        bb.putInt(numModules);
        bb.putInt(entries.size());

        for (DictInfo e : entries) {
            bb.putShort(e.registryId);
            if (numModules > 127) bb.putShort((short)e.moduleIndex);
            else bb.put((byte)e.moduleIndex);

            StringIO.writeUTF(bb, e.name);
            bb.put(e.flags);

            if ((e.flags & 0x01) != 0) {
                if (numModIds > 127) bb.putShort((short)e.modId);
                else bb.put((byte)e.modId);
            }

            if ((e.flags & 0x10) != 0 && (e.flags & 0x20) == 0) {
                bb.put((byte)e.modOverrides.size());
            }

            if ((e.flags & 0x10) != 0) {
                int n = ((e.flags & 0x20) != 0) ? 1 : e.modOverrides.size();
                for (int i = 0; i < n; i++) {
                    int value = ((e.flags & 0x20) != 0) ? e.modId : e.modOverrides.get(i);
                    if (numModIds > 127) bb.putShort((short)value);
                    else bb.put((byte)value);
                }
            }
        }
    }

    static DictionaryData load(ByteBuffer bb) {
        DictionaryData d = new DictionaryData();
        d.numModIds = bb.getInt();
        d.numModules = bb.getInt();
        int numEntries = bb.getInt();
        for (int i = 0; i < numEntries; i++) {
            DictInfo e = new DictInfo();
            e.registryId = bb.getShort();
            e.moduleIndex = d.numModules > 127 ? Short.toUnsignedInt(bb.getShort()) : Byte.toUnsignedInt(bb.get());
            e.name = StringIO.readUTF(bb);
            e.flags = bb.get();
            if ((e.flags & 0x01) != 0) {
                e.modId = d.numModIds > 127 ? Short.toUnsignedInt(bb.getShort()) : Byte.toUnsignedInt(bb.get());
            }
            int numOverrides = 0;
            if ((e.flags & 0x10) != 0 && (e.flags & 0x20) == 0) {
                numOverrides = Byte.toUnsignedInt(bb.get());
            } else if ((e.flags & 0x20) != 0) {
                numOverrides = 1;
            }
            if ((e.flags & 0x10) != 0) {
                for (int j = 0; j < numOverrides; j++) {
                    int value = d.numModIds > 127 ? Short.toUnsignedInt(bb.getShort()) : Byte.toUnsignedInt(bb.get());
                    e.modOverrides.add(value);
                }
            }
            d.entries.add(e);
        }
        return d;
    }

    static void assertRoundTrip(DictionaryData expected, DictionaryData actual) {
        if (expected.numModIds != actual.numModIds || expected.numModules != actual.numModules || expected.entries.size() != actual.entries.size()) {
            throw new RuntimeException("DictionaryData header mismatch");
        }
        for (int i = 0; i < expected.entries.size(); i++) {
            DictInfo e = expected.entries.get(i);
            DictInfo a = actual.entries.get(i);
            if (e.registryId != a.registryId || e.moduleIndex != a.moduleIndex || !e.name.equals(a.name) || e.flags != a.flags || e.modId != a.modId) {
                throw new RuntimeException("DictInfo mismatch at index " + i);
            }
            List<Integer> expectedOverrides = new ArrayList<>();
            if ((e.flags & 0x10) != 0) {
                if ((e.flags & 0x20) != 0) {
                    expectedOverrides.add(e.modId);
                } else {
                    expectedOverrides.addAll(e.modOverrides);
                }
            }

            if (expectedOverrides.size() != a.modOverrides.size()) {
                throw new RuntimeException("modOverrides length mismatch at index " + i);
            }
            for (int j = 0; j < expectedOverrides.size(); j++) {
                if (!expectedOverrides.get(j).equals(a.modOverrides.get(j))) {
                    throw new RuntimeException("modOverride mismatch at entry=" + i + ", index=" + j);
                }
            }
        }
    }

    public static void main(String[] args) throws Exception {
        String outPath = args.length > 0 ? args[0] : "../output/dictionary_data.bin";

        DictionaryData d = new DictionaryData();
        d.numModIds = 200;
        d.numModules = 130;

        DictInfo a = new DictInfo();
        a.registryId = 12;
        a.moduleIndex = 128;
        a.name = "campfire";
        a.flags = 0x11;
        a.modId = 300;
        a.modOverrides.add(111);
        a.modOverrides.add(222);
        d.entries.add(a);

        DictInfo b = new DictInfo();
        b.registryId = 33;
        b.moduleIndex = 10;
        b.name = "wall_lamp";
        b.flags = 0x31;
        b.modId = 123;
        d.entries.add(b);

        ByteBuffer bb = ByteBuffer.allocate(4096);
        d.save(bb);
        bb.flip();
        byte[] data = new byte[bb.remaining()];
        bb.get(data);

        DictionaryData parsed = load(ByteBuffer.wrap(data));
        assertRoundTrip(d, parsed);

        Path out = Paths.get(outPath).normalize();
        Files.createDirectories(out.getParent());
        Files.write(out, data);
        System.out.println("Round-trip OK");
        System.out.println("Wrote: " + out.toAbsolutePath());
    }
}

class StringIO {
    static void writeUTF(ByteBuffer bb, String value) {
        byte[] raw = value.getBytes(StandardCharsets.UTF_8);
        bb.putShort((short)raw.length);
        bb.put(raw);
    }

    static String readUTF(ByteBuffer bb) {
        int len = Short.toUnsignedInt(bb.getShort());
        byte[] raw = new byte[len];
        bb.get(raw);
        return new String(raw, StandardCharsets.UTF_8);
    }
}
