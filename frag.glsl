#version 300 es

precision highp float;

#define PI 3.1415926
#define EPSILON 0.00001
#define INFINITY 99999999.0

out vec4 outColor;

uniform vec2 u_resolution;

struct HitRecord {
    bool hit;
    vec3 p;
    vec3 normal;
    float t;
};

struct Sphere {
    vec3 center;
    float radius;
};

struct Triangle {
    vec3 v0, v1, v2;
};

HitRecord triangle_intersect(vec3 ray_origin, vec3 ray_dir, Triangle tri, float t_min, float t_max) {
    HitRecord rec;
    vec3 v0v1 = tri.v1 - tri.v0; // v0 -> v1
    vec3 v0v2 = tri.v2 - tri.v0; // v0 -> v2
    vec3 v1v2 = tri.v2 - tri.v1; // v1 -> v2
    vec3 v2v0 = tri.v0 - tri.v2; // v2 -> v0
    vec3 N = normalize(cross(v0v1, v0v2));

    float d = -dot(N, tri.v0);

    // Check if ray is parallel to the plane of the triangle
    if (abs(dot(N, ray_dir)) < EPSILON) {
        rec.hit = false;
        return rec;
    }

    // Get intersection point with pane
    float t = -(dot(N, ray_origin) + d) / dot(N, ray_dir);
    if (t < t_min || t > t_max) {
        rec.hit = false;
        return rec;
    }

    // Get point on plane
    vec3 p = ray_origin + ray_dir * t;

    // Test if point is within triangle
    if (dot(cross(v0v1, p - tri.v0), N) >= 0.0 && dot(cross(v1v2, p - tri.v1), N) >= 0.0 && dot(cross(v2v0, p - tri.v2), N) >= 0.0) {
        rec.hit = true;
        return rec;
    }
    // Hit not within triangle
    rec.hit = false;
    return rec;
}


HitRecord sphere_intersect(vec3 ray_origin, vec3 ray_dir, Sphere s, float t_min, float t_max) {
    HitRecord rec;
    // Solve quadratic
    vec3 oc = ray_origin - s.center;
    float a = dot(ray_dir, ray_dir);
    float half_b = dot(oc, ray_dir);
    float c = dot(oc, oc) - s.radius * s.radius;

    float discriminant = half_b * half_b - a * c;
    if (discriminant < 0.0) {
        // No real solutions exist
        rec.hit = false;
        return rec;
    }

    float sqrtd = sqrt(discriminant);

    // Find the nearest root that lies in the acceptable range
    float root = (-half_b - sqrtd) / a;
    if (root < t_min || root > t_max) {
        // Root lies outside acceptable range
        root = (-half_b + sqrtd) / a;
        if (root < t_min || root > t_max) {
            rec.hit = false;
            return rec;
        }
    }

    // Hit occurred, so record hit information
    rec.hit = true;
    rec.t = root;
    rec.p = ray_origin + ray_dir * rec.t;
    rec.normal = normalize(rec.p - s.center);
    

    return rec;
}


// Returns the color a given ray is pointing at
vec3 ray_color(vec3 orig, vec3 dir) {
    // dir = normalize(dir);
    // float t = 0.5 * (dir.y + 1.0);
    // vec3 start_col = vec3(1.0, 1.0, 1.0);
    // vec3 end_col = vec3(0.0, 0.0, 1.0);
    // vec3 col = mix(start_col, end_col, t);

    vec3 col;

    Sphere s;
    s.center = vec3(0, 0, 0);
    s.radius = 1.0;

    Triangle tri;
    tri.v0 = vec3(-0.5, -0.5, 0);
    tri.v1 = vec3(0.5, -0.5, 0);
    tri.v2 = vec3(0, 0.5, 0);

    HitRecord rec;
    rec = sphere_intersect(orig, dir, s, EPSILON, INFINITY);
    // rec = triangle_intersect(orig, dir, tri, EPSILON, INFINITY);

    if (rec.hit == false) {
        return col;
    } 
    col = vec3(1.0) + rec.normal;
    return col;
}

void main() {
    // Normalized coordinates from 0 to 1
    vec2 st = gl_FragCoord.xy / u_resolution;

    // Set up viewport
    float vfov = 40.0;
    float theta = vfov * PI / 180.0;
    float h = tan(theta / 2.0);
    float focal_length = 1.0;

    float aspect_ratio = u_resolution.x / u_resolution.y;
    float viewport_height = 2.0 * h;
    float viewport_width = viewport_height * aspect_ratio;

    // Orthonormal bases
    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 look_from = vec3(0.0, 0.0, 5.0);
    vec3 look_at = vec3(0.0, 0.0, 0.0);
    vec3 w = normalize(look_from - look_at);
    vec3 u = normalize(cross(up, w));
    vec3 v = cross(w, u);

    vec3 horizontal = u * viewport_width;
    vec3 vertical = v * viewport_height;
    vec3 lower_left_corner = look_from - vec3(0, 0, focal_length) - (vertical * 0.5) - (horizontal * 0.5);


    vec3 ray_dir = lower_left_corner + (horizontal * st.x) + (vertical * st.y) - look_from;
    ray_dir = normalize(ray_dir);

    vec3 col = ray_color(look_from, ray_dir);

    outColor = vec4(col, 1.0);
}