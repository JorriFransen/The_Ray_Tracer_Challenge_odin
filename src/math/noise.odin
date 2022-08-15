package rtmath
import "core:math"

import "core:fmt"

@(private="file")
hash := [?]int {
    151,160,137, 91, 90, 15,131, 13,201, 95, 96, 53,194,233,  7,225,
    140, 36,103, 30, 69,142,  8, 99, 37,240, 21, 10, 23,190,  6,148,
    247,120,234, 75,  0, 26,197, 62, 94,252,219,203,117, 35, 11, 32,
     57,177, 33, 88,237,149, 56, 87,174, 20,125,136,171,168, 68,175,
     74,165, 71,134,139, 48, 27,166, 77,146,158,231, 83,111,229,122,
     60,211,133,230,220,105, 92, 41, 55, 46,245, 40,244,102,143, 54,
     65, 25, 63,161,  1,216, 80, 73,209, 76,132,187,208, 89, 18,169,
    200,196,135,130,116,188,159, 86,164,100,109,198,173,186,  3, 64,
     52,217,226,250,124,123,  5,202, 38,147,118,126,255, 82, 85,212,
    207,206, 59,227, 47, 16, 58, 17,182,189, 28, 42,223,183,170,213,
    119,248,152,  2, 44,154,163, 70,221,153,101,155,167, 43,172,  9,
    129, 22, 39,253, 19, 98,108,110, 79,113,224,232,178,185,112,104,
    218,246, 97,228,251, 34,242,193,238,210,144, 12,191,179,162,241,
     81, 51,145,235,249, 14,239,107, 49,192,214, 31,181,199,106,157,
    184, 84,204,176,115,121, 50, 45,127,  4,150,254,138,236,205, 93,
    222,114, 67, 29, 24, 72,243,141,128,195, 78, 66,215, 61,156,180,

    // Repeat
    151,160,137, 91, 90, 15,131, 13,201, 95, 96, 53,194,233,  7,225,
    140, 36,103, 30, 69,142,  8, 99, 37,240, 21, 10, 23,190,  6,148,
    247,120,234, 75,  0, 26,197, 62, 94,252,219,203,117, 35, 11, 32,
     57,177, 33, 88,237,149, 56, 87,174, 20,125,136,171,168, 68,175,
     74,165, 71,134,139, 48, 27,166, 77,146,158,231, 83,111,229,122,
     60,211,133,230,220,105, 92, 41, 55, 46,245, 40,244,102,143, 54,
     65, 25, 63,161,  1,216, 80, 73,209, 76,132,187,208, 89, 18,169,
    200,196,135,130,116,188,159, 86,164,100,109,198,173,186,  3, 64,
     52,217,226,250,124,123,  5,202, 38,147,118,126,255, 82, 85,212,
    207,206, 59,227, 47, 16, 58, 17,182,189, 28, 42,223,183,170,213,
    119,248,152,  2, 44,154,163, 70,221,153,101,155,167, 43,172,  9,
    129, 22, 39,253, 19, 98,108,110, 79,113,224,232,178,185,112,104,
    218,246, 97,228,251, 34,242,193,238,210,144, 12,191,179,162,241,
     81, 51,145,235,249, 14,239,107, 49,192,214, 31,181,199,106,157,
    184, 84,204,176,115,121, 50, 45,127,  4,150,254,138,236,205, 93,
    222,114, 67, 29, 24, 72,243,141,128,195, 78, 66,215, 61,156,180,
};

@(private="file")
hash_mask :: 255;

@(private="file")
smooth :: proc(t: real) -> real {
    return t * t * t * (t * (t * 6 - 15) + 10);
}

value_noise_1D :: proc(p: Point, frequency: real) -> real {
    p := p * frequency;
    i0 := int(math.floor(p.x));
    t := smooth(p.x - real(i0));
    i0 &= hash_mask;
    i1 := i0 + 1;

    h0 := hash[i0];
    h1 := hash[i1];

    return lerp(real(h0), real(h1), t) / hash_mask;
}

value_noise_2D :: proc(p: Point, frequency: real) -> real {
    p := p * frequency;
    i0 := int(math.floor(p.x));
    j0 := int(math.floor(p.y));
    tx := smooth(p.x - real(i0));
    ty := smooth(p.y - real(j0));
    i0 &= hash_mask;
    j0 &= hash_mask;
    i1 := i0 + 1;
    j1 := j0 + 1;

    h0 := hash[i0];
    h1 := hash[i1];
    h00 := real(hash[h0 + j0]);
    h10 := real(hash[h1 + j0]);
    h01 := real(hash[h0 + j1]);
    h11 := real(hash[h1 + j1]);

    // return h00 / hash_mask;
    return lerp(
            lerp(h00, h10, tx),
            lerp(h01, h11, tx),
            ty) / hash_mask;
}

value_noise_3D :: proc(p: Point, frequency: real) -> real {

    p := p * frequency;
    i0 := int(math.floor(p.x));
    j0 := int(math.floor(p.y));
    k0 := int(math.floor(p.z));
    tx := smooth(p.x - real(i0));
    ty := smooth(p.y - real(j0));
    tz := smooth(p.z - real(k0));
    i0 &= hash_mask;
    j0 &= hash_mask;
    k0 &= hash_mask;
    i1 := i0 + 1;
    j1 := j0 + 1;
    k1 := k0 + 1;

    h0 := hash[i0];
    h1 := hash[i1];
    h00 := hash[h0 + j0];
    h10 := hash[h1 + j0];
    h01 := hash[h0 + j1];
    h11 := hash[h1 + j1];
    h000 := real(hash[h00 + k0]);
    h100 := real(hash[h10 + k0]);
    h010 := real(hash[h01 + k0]);
    h110 := real(hash[h11 + k0]);
    h001 := real(hash[h00 + k1]);
    h101 := real(hash[h10 + k1]);
    h011 := real(hash[h01 + k1]);
    h111 := real(hash[h11 + k1]);

    // return h000 / hash_mask;
    return lerp(
            lerp(lerp(h000, h100, tx), lerp(h010, h110, tx), ty),
            lerp(lerp(h001, h101, tx), lerp(h011, h111, tx), ty),
            tz) / hash_mask;
}

value_noise_4D :: proc(p: Point, w: real, frequency: real) -> real {

    p := p * frequency;
    i0 := int(math.floor(p.x));
    j0 := int(math.floor(p.y));
    k0 := int(math.floor(p.z));
    l0 := int(math.floor(w));
    tx := smooth(p.x - real(i0));
    ty := smooth(p.y - real(j0));
    tz := smooth(p.z - real(k0));
    tw := smooth(w - real(l0));
    i0 &= hash_mask;
    j0 &= hash_mask;
    k0 &= hash_mask;
    l0 &= hash_mask;
    i1 := i0 + 1;
    j1 := j0 + 1;
    k1 := k0 + 1;
    l1 := l0 + 1;

    h0 := hash[i0];
    h1 := hash[i1];

    h00 := hash[h0 + j0];
    h10 := hash[h1 + j0];
    h01 := hash[h0 + j1];
    h11 := hash[h1 + j1];

    h000 := hash[h00 + k0];
    h100 := hash[h10 + k0];
    h010 := hash[h01 + k0];
    h110 := hash[h11 + k0];
    h001 := hash[h00 + k1];
    h101 := hash[h10 + k1];
    h011 := hash[h01 + k1];
    h111 := hash[h11 + k1];

    h0000 := real(hash[h000 + l0]);
    h1000 := real(hash[h100 + l0]);
    h0100 := real(hash[h010 + l0]);
    h1100 := real(hash[h110 + l0]);
    h0010 := real(hash[h001 + l0]);
    h1010 := real(hash[h101 + l0]);
    h0110 := real(hash[h011 + l0]);
    h1110 := real(hash[h111 + l0]);
    h0001 := real(hash[h000 + l1]);
    h1001 := real(hash[h100 + l1]);
    h0101 := real(hash[h010 + l1]);
    h1101 := real(hash[h110 + l1]);
    h0011 := real(hash[h001 + l1]);
    h1011 := real(hash[h101 + l1]);
    h0111 := real(hash[h011 + l1]);
    h1111 := real(hash[h111 + l1]);

    return lerp(
             lerp(
               lerp(lerp(h0000, h1000, tx), lerp(h0100, h1100, tx), ty),
               lerp(lerp(h0010, h1010, tx), lerp(h0110, h1110, tx), ty),
               tz),
             lerp(
               lerp(lerp(h0001, h1001, tx), lerp(h0101, h1101, tx), ty),
               lerp(lerp(h0011, h1011, tx), lerp(h0111, h1111, tx), ty),
               tz),
             tw) / hash_mask;

}

