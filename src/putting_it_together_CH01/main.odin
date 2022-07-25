package putting_it_together_CH01

import "core:fmt"

import m "../rtmath"

main :: proc() {
    fmt.println("Putting it together for chapter 1...");

    using m;

    Projectile :: struct {
        position: m.Point,
        velocity: m.Vector,
    };

    Environment :: struct {
        gravity: m.Vector,
        wind: m.Vector,
    };

    tick :: proc(env: ^Environment, proj: Projectile) -> Projectile {
        p := add(proj.position, proj.velocity);
        v := add(add(proj.velocity, env.gravity), env.wind);
        return Projectile { position = p, velocity = v };
    }

    p := Projectile {
        position = point(0, 1, 0),
        velocity = normalize(vector(1, 1, 0))
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
