import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

class IsoGridSquareLite {
    static class ObjectRef {
        short objectId;
        byte z;

        void save(ByteBuffer bb, int worldVersion) {
            bb.putShort(objectId);
            if (worldVersion >= 160) {
                bb.put(z);
            }
        }

        static ObjectRef load(ByteBuffer bb, int worldVersion) {
            ObjectRef r = new ObjectRef();
            r.objectId = bb.getShort();
            if (worldVersion >= 160) {
                r.z = bb.get();
            }
            return r;
        }
    }

    byte x;
    byte y;
    byte level;
    int tileFlags;
    List<ObjectRef> objects = new ArrayList<>();

    void save(ByteBuffer bb, int worldVersion) {
        bb.put(x);
        bb.put(y);
        bb.put(level);

        if (worldVersion >= 125) {
            bb.putInt(tileFlags);
        }

        bb.put((byte)objects.size());
        for (ObjectRef objectRef : objects) {
            objectRef.save(bb, worldVersion);
        }
    }

    static IsoGridSquareLite load(ByteBuffer bb, int worldVersion) {
        IsoGridSquareLite g = new IsoGridSquareLite();
        g.x = bb.get();
        g.y = bb.get();
        g.level = bb.get();
        if (worldVersion >= 125) {
            g.tileFlags = bb.getInt();
        }
        int numObjects = Byte.toUnsignedInt(bb.get());
        for (int i = 0; i < numObjects; i++) {
            g.objects.add(ObjectRef.load(bb, worldVersion));
        }
        return g;
    }

    public static void main(String[] args) throws Exception {
        String outPath = args.length > 0 ? args[0] : "../output/iso_grid_square_lite.bin";

        int worldVersion = 160;
        IsoGridSquareLite g = new IsoGridSquareLite();
        g.x = 10;
        g.y = 20;
        g.level = 2;
        g.tileFlags = 0x11223344;

        ObjectRef o1 = new ObjectRef();
        o1.objectId = 500;
        o1.z = 1;
        g.objects.add(o1);

        ObjectRef o2 = new ObjectRef();
        o2.objectId = 900;
        o2.z = 2;
        g.objects.add(o2);

        ByteBuffer bb = ByteBuffer.allocate(1024);
        g.save(bb, worldVersion);
        bb.flip();
        byte[] data = new byte[bb.remaining()];
        bb.get(data);

        IsoGridSquareLite parsed = load(ByteBuffer.wrap(data), worldVersion);
        if (parsed.x != g.x || parsed.y != g.y || parsed.level != g.level || parsed.tileFlags != g.tileFlags || parsed.objects.size() != g.objects.size()) {
            throw new RuntimeException("IsoGridSquareLite round-trip mismatch");
        }
        for (int i = 0; i < g.objects.size(); i++) {
            ObjectRef e = g.objects.get(i);
            ObjectRef a = parsed.objects.get(i);
            if (e.objectId != a.objectId || e.z != a.z) {
                throw new RuntimeException("ObjectRef mismatch at index " + i);
            }
        }

        Path out = Paths.get(outPath).normalize();
        Files.createDirectories(out.getParent());
        Files.write(out, data);
        System.out.println("Round-trip OK");
        System.out.println("Wrote: " + out.toAbsolutePath());
    }
}
