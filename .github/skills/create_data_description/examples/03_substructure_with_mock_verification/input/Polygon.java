import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

class Polygon {
    static class Vertex {
        float x;
        float y;
        short weight;

        void save(ByteBuffer bb) {
            bb.putFloat(x);
            bb.putFloat(y);
            bb.putShort(weight);
        }

        static Vertex load(ByteBuffer bb) {
            Vertex v = new Vertex();
            v.x = bb.getFloat();
            v.y = bb.getFloat();
            v.weight = bb.getShort();
            return v;
        }
    }

    static class Ring {
        byte flags;
        List<Vertex> vertices = new ArrayList<>();

        void save(ByteBuffer bb) {
            bb.put(flags);
            bb.putShort((short)vertices.size());
            for (Vertex vertex : vertices) {
                vertex.save(bb);
            }
        }

        static Ring load(ByteBuffer bb) {
            Ring ring = new Ring();
            ring.flags = bb.get();
            int numVertices = Short.toUnsignedInt(bb.getShort());
            for (int i = 0; i < numVertices; i++) {
                ring.vertices.add(Vertex.load(bb));
            }
            return ring;
        }
    }

    int id;
    short color;
    byte flags;
    String label = "";
    List<Ring> rings = new ArrayList<>();

    void save(ByteBuffer bb) {
        bb.putInt(id);
        bb.putShort(color);
        bb.put(flags);

        if ((flags & 0x01) != 0) {
            byte[] raw = label.getBytes(StandardCharsets.UTF_8);
            bb.putShort((short)raw.length);
            bb.put(raw);
        }

        bb.put((byte)rings.size());
        for (Ring ring : rings) {
            int lenPos = bb.position();
            bb.putShort((short)0);
            int ringStart = bb.position();
            ring.save(bb);
            int ringEnd = bb.position();
            bb.putShort(lenPos, (short)(ringEnd - ringStart));
        }
    }

    static Polygon load(ByteBuffer bb) {
        Polygon polygon = new Polygon();
        polygon.id = bb.getInt();
        polygon.color = bb.getShort();
        polygon.flags = bb.get();

        if ((polygon.flags & 0x01) != 0) {
            int len = Short.toUnsignedInt(bb.getShort());
            byte[] raw = new byte[len];
            bb.get(raw);
            polygon.label = new String(raw, StandardCharsets.UTF_8);
        }

        int numRings = Byte.toUnsignedInt(bb.get());
        for (int i = 0; i < numRings; i++) {
            int lenRing = Short.toUnsignedInt(bb.getShort());
            int start = bb.position();
            polygon.rings.add(Ring.load(bb));
            int consumed = bb.position() - start;
            if (consumed != lenRing) {
                throw new RuntimeException("Invalid ring length: expected=" + lenRing + ", actual=" + consumed);
            }
        }

        return polygon;
    }

    static Polygon sample() {
        Polygon polygon = new Polygon();
        polygon.id = 701;
        polygon.color = (short)0x3A1C;
        polygon.flags = 0x01;
        polygon.label = "room_outline";

        Ring outer = new Ring();
        outer.flags = 0x00;
        outer.vertices.add(vertex(0f, 0f, (short)10));
        outer.vertices.add(vertex(4f, 0f, (short)11));
        outer.vertices.add(vertex(4f, 3f, (short)12));
        outer.vertices.add(vertex(0f, 3f, (short)13));

        Ring hole = new Ring();
        hole.flags = 0x02;
        hole.vertices.add(vertex(1f, 1f, (short)3));
        hole.vertices.add(vertex(2f, 1f, (short)3));
        hole.vertices.add(vertex(2f, 2f, (short)3));
        hole.vertices.add(vertex(1f, 2f, (short)3));

        polygon.rings.add(outer);
        polygon.rings.add(hole);
        return polygon;
    }

    private static Vertex vertex(float x, float y, short weight) {
        Vertex v = new Vertex();
        v.x = x;
        v.y = y;
        v.weight = weight;
        return v;
    }
}
