package raytracer

import "core:fmt"
import "core:time"

timings := make(map[string]Timing);

start_time : time.Tick;

Timing :: struct {
    name: string,

    start_tick: time.Tick,
    duration: time.Duration,
};

start_timing_system :: proc() {
    start_time = time.tick_now();
}

start_timing :: proc(name: string) -> Timing {

    t : Timing = {
        name = name,
        start_tick = time.tick_now(),
    };

    return t;
}

end_timing :: proc(t: ^Timing) {
    t.duration += time.tick_since(t.start_tick);

    if t.name in timings {
        saved_t := timings[t.name];
        saved_t.duration += t.duration;
        timings[t.name] = saved_t;
    } else {
        timings[t.name] = Timing { name = t.name, start_tick = {}, duration = t.duration };
    }
}

report_timing :: proc() {

    total_time := time.tick_since(start_time);

    for _, t in timings {
        percentage := f64(t.duration) / f64(total_time) * 100;
        fmt.printf("%s: %dms, %.2f%%\n", t.name, t.duration / time.Millisecond, percentage);
    }

    fmt.printf("\nTotal time: %dms\n", total_time / time.Millisecond)
}
