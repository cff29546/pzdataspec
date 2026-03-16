import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

class ChunkTopLevel {
    static class Square {
        void save(ByteBuffer bb) {
            bb.put((byte)0xAB);
            bb.put((byte)0xCD);
        }

        void load(ByteBuffer bb) {
            byte b1 = bb.get();
            byte b2 = bb.get();
            if (b1 != (byte)0xAB || b2 != (byte)0xCD) {
                throw new RuntimeException("Invalid square data");
            }
        }
    }

    int worldVersion;
    int crc;
    List<Square> squares = new ArrayList<>();
    List<Polygon> polygons = new ArrayList<>();

    void save(ByteBuffer bb) {
        bb.put((byte)0x79);
        bb.putInt(worldVersion);

        int lenPos = bb.position();
        bb.putInt(0);
        bb.putInt(crc);

        int payloadStart = bb.position();

        bb.putShort((short)squares.size());
        for (Square s : squares) {
            int squareStart = bb.position();
            bb.putShort((short)0);
            s.save(bb);
            int squareEnd = bb.position();
            int squareLen = squareEnd - squareStart - 2;
            bb.putShort(squareStart, (short)squareLen);
        }

        bb.putShort((short)polygons.size());
        for (Polygon polygon : polygons) {
            int polygonStart = bb.position();
            bb.putShort((short)0);
            polygon.save(bb);
            int polygonEnd = bb.position();
            int polygonLen = polygonEnd - polygonStart - 2;
            bb.putShort(polygonStart, (short)polygonLen);
        }

        int payloadEnd = bb.position();
        int payloadLen = payloadEnd - payloadStart;
        bb.putInt(lenPos, payloadLen);
    }

    static ChunkTopLevel load(ByteBuffer bb) {
        ChunkTopLevel c = new ChunkTopLevel();
        byte debug = bb.get();
        if (debug != (byte)0x79) {
            throw new RuntimeException("Invalid debug marker");
        }
        c.worldVersion = bb.getInt();
        int lenPayload = bb.getInt();
        c.crc = bb.getInt();

        int payloadStart = bb.position();

        int numSquares = Short.toUnsignedInt(bb.getShort());
        for (int i = 0; i < numSquares; i++) {
            int lenSquare = Short.toUnsignedInt(bb.getShort());
            int start = bb.position();
            Square s = new Square();
            s.load(bb);
            c.squares.add(s);
            int consumed = bb.position() - start;
            if (consumed != lenSquare) {
                throw new RuntimeException("Invalid square length");
            }
        }

        int numPolygons = Short.toUnsignedInt(bb.getShort());
        for (int i = 0; i < numPolygons; i++) {
            int lenPolygon = Short.toUnsignedInt(bb.getShort());
            int start = bb.position();
            c.polygons.add(Polygon.load(bb));
            int consumed = bb.position() - start;
            if (consumed != lenPolygon) {
                throw new RuntimeException("Invalid polygon length");
            }
        }

        int consumedPayload = bb.position() - payloadStart;
        if (consumedPayload != lenPayload) {
            throw new RuntimeException("Invalid payload length");
        }

        return c;
    }

    public static void main(String[] args) throws Exception {
        String outPath = args.length > 0 ? args[0] : "../output/chunk_top_level.bin";

        ChunkTopLevel c = new ChunkTopLevel();
        c.worldVersion = 241;
        c.crc = 0x01020304;
        c.squares.add(new Square());
        c.squares.add(new Square());

        Polygon p1 = Polygon.sample();
        c.polygons.add(p1);

        Polygon p2 = Polygon.sample();
        p2.id = 702;
        p2.label = "roof_outline";
        c.polygons.add(p2);

        ByteBuffer bb = ByteBuffer.allocate(4096);
        c.save(bb);
        bb.flip();
        byte[] data = new byte[bb.remaining()];
        bb.get(data);

        ChunkTopLevel parsed = load(ByteBuffer.wrap(data));
        if (parsed.worldVersion != c.worldVersion || parsed.crc != c.crc || parsed.squares.size() != c.squares.size() || parsed.polygons.size() != c.polygons.size()) {
            throw new RuntimeException("ChunkTopLevel round-trip mismatch");
        }

        Path out = Paths.get(outPath).normalize();
        Files.createDirectories(out.getParent());
        Files.write(out, data);
        System.out.println("Round-trip OK");
        System.out.println("Wrote: " + out.toAbsolutePath());
    }
}
