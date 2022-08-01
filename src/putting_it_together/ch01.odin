package putting_it_together

import "core:fmt"

import rm "raytracer:math"

Projectile :: struct {
    position: rm.Point,
    velocity: rm.Vector,
};

Environment :: struct {
    gravity: rm.Vector,
    wind: rm.Vector,
};

tick :: proc(env: ^Environment, proj: Projectile) -> Projectile {
    p := rm.add(proj.position, proj.velocity);
    v := rm.add(rm.add(proj.velocity, env.gravity), env.wind);
    return Projectile { position = p, velocity = v };
}

putting_it_together_CH01 :: proc() {
    fmt.println("Putting it together for chapter 1...");

    using rm;


    p := Projectile {
        position = point(0, 1, 0),
        velocity = normalize(vector(1, 1, 0)),
    };
    e := Environment {
        gravity = vector(0, -0.1, 0),
        wind = vector(-0.01, 0, 0),
    };

    fmt.println(p.position);

    tick_count := 0;

    for (p.position.y > 0) {
        p = tick(&e, p);
        fmt.println(p.position);
        tick_count += 1;
    }

    fmt.printf("The projectile took %v ticks to hit the ground.\n", tick_count);

}
