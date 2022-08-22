package raytracer

import "core:fmt"
import "core:time"

timings := make([dynamic]Timing);

start_time : time.Tick;

Timing :: struct {
    name: string,

    start_tick: time.Tick,
    duration: time.Duration,
};

start_timing_system :: #force_inline proc() {
    start_time = time.tick_now();
}

start_timing :: #force_inline proc(name: string) -> Timing {

    t : Timing = {
        name = name,
        start_tick = time.tick_now(),
    };

    return t;
}

end_timing :: #force_inline proc(t: ^Timing) {

    t.duration = time.tick_since(t.start_tick);
    append(&timings, t^);
}

report_timing :: proc() {

    total_time := time.tick_since(start_time);

    Merged_Timing :: struct {
        name: string,
        duration: time.Duration,
        hits: int,
    };

    merged_timings := make(map[string]Merged_Timing);
    defer delete(merged_timings);

    for t in timings {

        if t.name in merged_timings {
            mt := &merged_timings[t.name];
            mt.duration += t.duration;
            mt.hits += 1;
        } else {
            merged_timings[t.name] = Merged_Timing { t.name, t.duration, 1 };
        }
    }

    for _, t in merged_timings {
        percentage := f64(t.duration) / f64(total_time) * 100;
        ms := t.duration / time.Millisecond;
        fmt.printf("%s: %d hits, %dms, %.2f%%\n", t.name, t.hits, ms, percentage);
        // fmt.printf("\taverage per hit: %fns\n", f64(t.duration) / f64(t.hits));
    }

    fmt.printf("\nTotal time: %dms\n", total_time / time.Millisecond)
}
