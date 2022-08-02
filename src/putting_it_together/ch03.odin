package putting_it_together

import "core:fmt"
import rm "raytracer:math"

CH03 :: proc() {
    fmt.println("Puttin it together for chapter 3");

    using rm;

    fmt.println();
    fmt.println("================================================================================");
    fmt.println("1. What happens when you invert the identity matrix?");
    {
        idm :: matrix4_identity;
        idm_inverse := matrix_inverse(idm);

        fmt.println();
        fmt.println("    id         :", idm);
        fmt.println("    inverse(id):", idm_inverse);
        fmt.println();
        fmt.println("    eq(id, inverse(id)):", eq(idm, idm_inverse));
        fmt.println();
        fmt.println("    The matrix is funcionally the same, zeros become negative zeros.");
    }
    fmt.println("\n");


    fmt.println("================================================================================");
    fmt.println("2. What do you get when you multiply a matrix by it's inverse?");
    {
        a :: Matrix4 { -1, 2, 3, 4, 5, 6, 7, 8, -9, 8, 7, 6, 5, 4, -3, 2 };
        assert(matrix_is_invertible(a));

        a_inverse := matrix_inverse(a);
        result := mul(a, a_inverse);

        fmt.println();
        fmt.println("    a          :", a);
        fmt.println("    a * inverse:", result);
        fmt.println("    inverse    :", a_inverse);
        fmt.println();
        fmt.println("    eq(a * inverse, identity):", eq(result, matrix4_identity));
        fmt.println();
        fmt.println("    The result is the identity matrix.");
        fmt.println("    This is the same as with normal numbers (e.g. x * (1 / x) == 1).");
    }
    fmt.println("\n");


    fmt.println("================================================================================");
    fmt.println("3. Is there a difference between the inverse of the transpose of a matrix and");
    fmt.println("    the transpose of the inverse?");
    {
        a :: Matrix4 { -1, 2, 3, 4, 5, 6, 7, 8, -9, 8, 7, 6, 5, 4, -3, 2 };
        assert(matrix_is_invertible(a));

        ait := matrix_inverse(matrix_transpose(a));
        ati := matrix_transpose(matrix_inverse(a));

        b :: Matrix4 { 1, 2, 3, 4, 5, 6, 7, 8, 9, 8, 7, 6, 5, 4, -3, 2 };
        bt := matrix_transpose(b);

        fmt.println();
        fmt.println("    a  :", a);
        fmt.println("    ait:", ait);
        fmt.println("    ati:", ati);
        fmt.println();
        fmt.println("    No difference, transpose and inverse are commutative.")
        fmt.println();
        fmt.println("    The transpose of a non invertible matrix is also non invertible:")
        fmt.println();
        fmt.println("    b                :", a);
        fmt.println("    is_invertible(b) :", matrix_is_invertible(b));
        fmt.println("    bt               :", bt);
        fmt.println("    is_invertible(bt):", matrix_is_invertible(bt));
    }
    fmt.println("\n");


    fmt.println("================================================================================");
    fmt.println("4. Multiplying the identity matrix by a tuple results in the same tuple.");
    fmt.println("   What happens when you change a single element of the identity matrix?");
    {
        idm :: matrix4_identity;
        t :: Tuple { 2, 3, 4, 5 };

        mod_id1 := idm;
        mod_id1[1, 1] = 3;

        fmt.println();
        fmt.println("    mod_id1     :", mod_id1);
        fmt.println("    t           :", t);
        fmt.println("    identity * t:", mul(idm, t));
        fmt.println("    mod_id1 * t :", mul(mod_id1, t));

        mod_id2 := mod_id1;
        mod_id2[0, 0] = 2;
        mod_id2[2, 2] = 4;
        mod_id2[3, 3] = 5;

        fmt.println();
        fmt.println("    mod_id2     :", mod_id2);
        fmt.println("    t           :", t);
        fmt.println("    mod_id2 * t :", mul(mod_id2, t));

        fmt.println();
        fmt.println("    The corresponding tuple and matrix elements are multiplied by each other.")
        fmt.println("     (result[i] = t[i] * m[i, i])")

    }
    fmt.println("\n");
    fmt.println("================================================================================");
}
