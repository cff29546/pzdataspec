import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

class IsoObjectFactoryInitSnippet {
    interface IsoObjectLike {
        byte classId();
        void save(ByteBuffer bb);
        void load(ByteBuffer bb);
    }

    static class LightSwitchObject implements IsoObjectLike {
        boolean isOn;
        int watts;

        public byte classId() { return 29; }
        public void save(ByteBuffer bb) {
            bb.put((byte)(isOn ? 1 : 0));
            bb.putInt(watts);
        }
        public void load(ByteBuffer bb) {
            isOn = bb.get() != 0;
            watts = bb.getInt();
        }
    }

    static class DoorObject implements IsoObjectLike {
        byte lockState;
        short health;

        public byte classId() { return 17; }
        public void save(ByteBuffer bb) {
            bb.put(lockState);
            bb.putShort(health);
        }
        public void load(ByteBuffer bb) {
            lockState = bb.get();
            health = bb.getShort();
        }
    }

    static class RadioObject implements IsoObjectLike {
        String channel;

        public byte classId() { return 9; }
        public void save(ByteBuffer bb) {
            byte[] raw = channel.getBytes(StandardCharsets.UTF_8);
            bb.putShort((short)raw.length);
            bb.put(raw);
        }
        public void load(ByteBuffer bb) {
            int len = Short.toUnsignedInt(bb.getShort());
            byte[] raw = new byte[len];
            bb.get(raw);
            channel = new String(raw, StandardCharsets.UTF_8);
        }
    }

    static class ThermostatObject implements IsoObjectLike {
        byte mode;
        short targetTemp;
        List<ScheduleEntry> schedule = new ArrayList<>();
        String label;

        static class ScheduleEntry {
            short minuteOfDay;
            short temp;
        }

        public byte classId() { return 41; }
        public void save(ByteBuffer bb) {
            bb.put(mode);
            bb.putShort(targetTemp);
            bb.put((byte)schedule.size());
            for (ScheduleEntry entry : schedule) {
                bb.putShort(entry.minuteOfDay);
                bb.putShort(entry.temp);
            }
            byte[] raw = label.getBytes(StandardCharsets.UTF_8);
            bb.put((byte)raw.length);
            bb.put(raw);
        }
        public void load(ByteBuffer bb) {
            mode = bb.get();
            targetTemp = bb.getShort();
            int count = Byte.toUnsignedInt(bb.get());
            schedule.clear();
            for (int i = 0; i < count; i++) {
                ScheduleEntry entry = new ScheduleEntry();
                entry.minuteOfDay = bb.getShort();
                entry.temp = bb.getShort();
                schedule.add(entry);
            }
            int len = Byte.toUnsignedInt(bb.get());
            byte[] raw = new byte[len];
            bb.get(raw);
            label = new String(raw, StandardCharsets.UTF_8);
        }
    }

    private static final Map<Byte, String> TYPE_TABLE = new HashMap<>();
    static {
        // Pattern mirrors IsoObject.initFactory() class-id table registration.
        TYPE_TABLE.put((byte)9, "Radio");
        TYPE_TABLE.put((byte)17, "Door");
        TYPE_TABLE.put((byte)29, "LightSwitch");
        TYPE_TABLE.put((byte)41, "Thermostat");
    }

    static void saveRecord(ByteBuffer bb, IsoObjectLike obj) {
        bb.put(obj.classId());
        int lenPos = bb.position();
        bb.putShort((short)0);
        int start = bb.position();
        obj.save(bb);
        int end = bb.position();
        bb.putShort(lenPos, (short)(end - start));
    }

    static IsoObjectLike loadRecord(ByteBuffer bb) {
        byte classId = bb.get();
        int lenPayload = Short.toUnsignedInt(bb.getShort());
        int start = bb.position();

        IsoObjectLike obj;
        if (classId == 9) obj = new RadioObject();
        else if (classId == 17) obj = new DoorObject();
        else if (classId == 29) obj = new LightSwitchObject();
        else if (classId == 41) obj = new ThermostatObject();
        else throw new RuntimeException("Unknown class id: " + classId);

        obj.load(bb);
        int consumed = bb.position() - start;
        if (consumed != lenPayload) {
            throw new RuntimeException("Invalid payload length for class id " + classId);
        }
        return obj;
    }

    public static void main(String[] args) throws Exception {
        String outPath = args.length > 0 ? args[0] : "../output/iso_object_dispatch_table.bin";

        ByteBuffer bb = ByteBuffer.allocate(1024);

        RadioObject radio = new RadioObject();
        radio.channel = "AM 1080";
        saveRecord(bb, radio);

        DoorObject door = new DoorObject();
        door.lockState = 1;
        door.health = 750;
        saveRecord(bb, door);

        LightSwitchObject light = new LightSwitchObject();
        light.isOn = true;
        light.watts = 60;
        saveRecord(bb, light);

        bb.flip();
        byte[] data = new byte[bb.remaining()];
        bb.get(data);

        ByteBuffer in = ByteBuffer.wrap(data);
        IsoObjectLike r0 = loadRecord(in);
        IsoObjectLike r1 = loadRecord(in);
        IsoObjectLike r2 = loadRecord(in);
        if (!(r0 instanceof RadioObject) || !(r1 instanceof DoorObject) || !(r2 instanceof LightSwitchObject)) {
            throw new RuntimeException("Round-trip type mismatch");
        }

        Path out = Paths.get(outPath).normalize();
        Files.createDirectories(out.getParent());
        Files.write(out, data);
        System.out.println("Round-trip OK");
        System.out.println("Wrote: " + out.toAbsolutePath());
    }
}
