
//TAU          :: 6.28318530717958647692528676655900576;
//PI           :: 3.14159265358979323846264338327950288;

E            :: 2.71828182845904523536;

RAD_PER_DEG :: TAU/360.0;
DEG_PER_RAD :: 360.0/TAU;


F16_EPSILON :: 0.003;//1e-3;
F32_EPSILON :: 0.0000001;//1e-7;
F64_EPSILON :: 0.000000000000001;//1e-15;


quaternion :: float4;
quaternion_identity :: quaternion.{};

radians :: (degrees : float) -> float #expand{
	return degrees * xx RAD_PER_DEG;
}

float2 :: struct{
    x,y : float;
	#place x;
	c : [2]float;
}

float3 :: struct{
	x,y,z : float;
	#place x;
	c : [3]float;
	#place x;
	xy : float2;
}

operator * :: (a : float3,b : float) -> float3 #symmetric{
	c : float3 = ---;
	c.x = a.x * b;
	c.y = a.y * b;
	c.z = a.z * b;
	return c;
}

operator * :: (a : float3,b : float3) -> float3 #symmetric{
	c : float3 = ---;
	c.x = a.x * b.x;
	c.y = a.y * b.y;
	c.z = a.z * b.z;
	return c;
}

get_scale :: (m : float4x4)->float3{
	return float3.{m._11,m._22,m._33};
}



//@note we are unsure of the cross product gives us a correct result for our handiness.
//and layout.
operator * :: (m: quaternion, a: quaternion) -> quaternion {
    v  := m.xyz;
    av := a.xyz;

    r: quaternion;
    r.w = m.w * a.w - dot(v, av);

    rv := cross(v, av);

    av *= m.w;
    v  *= a.w;

    rv = rv + av + v;

    r.x = rv.x;
    r.y = rv.y;
    r.z = rv.z;

    return r;
}

operator + :: (a: quaternion, b: quaternion) -> quaternion {
    return .{a.x+b.x, a.y+b.y, a.z+b.z, a.w+b.w};
}

operator * :: (a: quaternion, k: float) -> quaternion  #symmetric {
    return .{a.x*k, a.y*k, a.z*k, a.w*k};
}

operator - :: (a: quaternion, b: quaternion) -> quaternion {
    return .{a.x-b.x, a.y-b.y, a.z-b.z, a.w-b.w};
}

operator == :: (a: quaternion, b: quaternion) -> bool {
    return a.x == b.x && a.y == b.y && a.z == b.z && a.w == b.w;
}

operator - :: (using a: quaternion) -> Quaternion {
    return .{-x, -y, -z, -w};
}

operator + :: (a: float2, b: float2) -> float2{
	c : float2 =  ---;
	c.x = a.x + b.x;
	c.y = a.y + b.y;
	return c;
}

operator - :: (a: float2, b: float2) -> float2{
	c : float2 = ---;
	c.x = a.x - b.x;
	c.y = a.y - b.y;
	return c;
}


operator + :: (a: float3, b: float3) -> float3{
	c : float3 = ---;
	c.x = a.x + b.x;
	c.y = a.y + b.y;
	c.z = a.z + b.z;
	return c;
}

operator + :: (a: float3, b : float) -> float3 #symmetric{
	c : float3 = ---;
	c.x = a.x + b;
	c.y = a.y + b;
	c.z = a.z + b;
	return c;
}

operator - :: (a: float3, b : float) -> float3{
	c : float3 = ---;
	c.x = a.x - b;
	c.y = a.y - b;
	c.z = a.z - b;
	return c;
}

operator - :: (a: float3, b: float3) -> float3{
	c : float3 = ---;
	c.x = a.x - b.x;
	c.y = a.y - b.y;
	c.z = a.z - b.z;
	return c;
}

operator - :: (a: float3) -> float3{
	c : float3 = ---;
	c.x = -a.x;
	c.y = -a.y;
	c.z = -a.z;
	return c;
}

operator / :: (a : float4,b : float)->float4{
    r : float4 = ---;
    r.x = a.x / b;
    r.y = a.y / b;
    r.z = a.z / b;
    r.w = a.w / b;
    return r;    
}

operator / :: (a : float3,b : float)->float3 #symmetric{
    r : float3 = ---;
    r.x = a.x / b;
    r.y = a.y / b;
    r.z = a.z / b;
    return r;    
}

float4 :: struct{
    x,y,z,w : float;
	#place x;
	c : [4]float;
	#place x;
	xyz : float3;
	#place x;
	xy : float2;
}

/*
@incomplete @todo
There is an issue with the crossproduct being right handed it seems so I negated when doing a 
	vector quaternion mul this seems to work but I have kind of lost track of whats going on 
	with the handiness in the math.  
	WE should resvisit.
*/
multiply :: (q : quaternion,v : float3)->float3{
	t := -cross(2 * q.xyz, v);
	return xx (v + (q.w * t) + -cross(q.xyz, t));
}

length :: (v : float3)->float{
	return sqrt(dot(v, v));
}

distance :: (a : float3,b : float3)->float{
	return length(b-a);
}

normalize :: (v : float3)-> float3{
	return v / length(v);
}

normalize :: (a : quaternion)-> result : quaternion{
	result : quaternion;
	root := sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w);
	result = a / root;
	return xx result;
}

/*
normalize :: (q: quaternion) -> quaternion{
	return q / abs(q);
}
*/

float3x3 :: struct{
	_11, _21, _31 : float;
    _12, _22, _32 : float;
    _13, _23, _33 : float;

	#place _11;
	c : [3]float3;
	#place _11;
	a : [12]float;
	#place _11;
	aa : [3][3]float;
}

float4x4 :: struct{
	_11, _12, _13, _14 : float; // First column
    _21, _22, _23, _24 : float; // Second column
    _31, _32, _33, _34 : float; // Third column
    _41, _42, _43, _44 : float; // Fourth column

	#place _11;
	c : [4]float4;
	#place _11;
	a : [16]float;
	#place _11;
	aa : [4][4]float;
}

float4x4_identity :: float4x4.{_11 = 1,_22 = 1,_33 = 1,_44 = 1};

float4x4_from_trs :: (t: float3, r: quaternion, s: float3) -> float4x4{
	translation := float4x4_translate(t);
	rotation := float4x4_from_quaternion(r);
	scale := float4x4_scale(s);
	//return translation * rotation * scale;
	return multiply(translation, multiply(rotation, scale));
}


//note tested
float4x4_get_rotation_matrix :: (mat : float4x4)->float4x4{
	rot_mat : float4x4;
	xaxis := float3.{mat.aa[0][0],mat.aa[1][0],mat.aa[2][0]};
	yaxis := float3.{mat.aa[0][1],mat.aa[1][1],mat.aa[2][1]};
	zaxis := float3.{mat.aa[0][2],mat.aa[1][2],mat.aa[2][2]};

	xaxis = normalize(xaxis);
	yaxis = normalize(yaxis);
	zaxis = normalize(zaxis);

	rot_mat.c[0].xyz = xaxis;
	rot_mat.c[1].xyz = yaxis;
	rot_mat.c[2].xyz = zaxis;
	return rot_mat;
}

float4x4_translate :: (v: float3) -> float4x4{
	m := float4x4_identity;
	/*
	m.aa[3][0] = v.c[0];
	m.aa[3][1] = v.c[1];
	m.aa[3][2] = v.c[2];
	*/
	m._41 = v.x;
	m._42 = v.y;
	m._43 = v.z;
	return m;
}

float4x4_scale :: (v: float3) -> m: float4x4{
	m := float4x4_identity;
	m.aa[0][0] = v.c[0];
	m.aa[1][1] = v.c[1];
	m.aa[2][2] = v.c[2];
	m.aa[3][3] = 1;
	return m;
}

float4x4_from_quaternion :: (q: quaternion) -> float4x4{
	//if we try to do this we get weird stuff happening with rotation messing with scale.
	//what I think is happening is that when different things happen on the stack it sets
	//different types of garbage and the optimizer might compile out some instructions leaving 
	//of this proc?  Leaving garbage values around?
	//even though we set every component of the matrix
	//m : float4x4 = ---;
	m : float4x4 = float4x4_identity;
	qxx := q.x * q.x;
	qyy := q.y * q.y;
	qzz := q.z * q.z;
	qxz := q.x * q.z;
	qxy := q.x * q.y;
	qyz := q.y * q.z;
	qwx := q.w * q.x;
	qwy := q.w * q.y;
	qwz := q.w * q.z;

	m.aa[0][0] = 1 - 2 * (qyy + qzz);
	m.aa[1][0] = 2 * (qxy + qwz);
	m.aa[2][0] = 2 * (qxz - qwy);

	m.aa[0][1] = 2 * (qxy - qwz);
	m.aa[1][1] = 1 - 2 * (qxx + qzz);
	m.aa[2][1] = 2 * (qyz + qwx);

	m.aa[0][2] = 2 * (qxz + qwy);
	m.aa[1][2] = 2 * (qyz - qwx);
	m.aa[2][2] = 1 - 2 * (qxx + qyy);

	m.aa[3][3] = 1;
	m.aa[3][2] = 0;
	m.aa[3][1] = 0;
	m.aa[3][0] = 0;
	return m;
}

transpose :: (using input: float4x4) -> float4x4 {
    return .{
        input._11, input._21, input._31, input._41, // First row becomes the first column
        input._12, input._22, input._32, input._42, // Second row becomes the second column
        input._13, input._23, input._33, input._43, // Third row becomes the third column
        input._14, input._24, input._34, input._44  // Fourth row becomes the fourth column
    };
}

operator * :: (a: float4x4, b: float4x4) -> float4x4{
    return inline multiply(a, b);
}

multiply :: (m : float4x4, n : float4x4) -> float4x4 {
    result : float4x4 = ---;

    result._11 = m._11 * n._11 + m._21 * n._12 + m._31 * n._13 + m._41 * n._14;
    result._12 = m._12 * n._11 + m._22 * n._12 + m._32 * n._13 + m._42 * n._14;
    result._13 = m._13 * n._11 + m._23 * n._12 + m._33 * n._13 + m._43 * n._14;
    result._14 = m._14 * n._11 + m._24 * n._12 + m._34 * n._13 + m._44 * n._14;

    result._21 = m._11 * n._21 + m._21 * n._22 + m._31 * n._23 + m._41 * n._24;
    result._22 = m._12 * n._21 + m._22 * n._22 + m._32 * n._23 + m._42 * n._24;
    result._23 = m._13 * n._21 + m._23 * n._22 + m._33 * n._23 + m._43 * n._24;
    result._24 = m._14 * n._21 + m._24 * n._22 + m._34 * n._23 + m._44 * n._24;

    result._31 = m._11 * n._31 + m._21 * n._32 + m._31 * n._33 + m._41 * n._34;
    result._32 = m._12 * n._31 + m._22 * n._32 + m._32 * n._33 + m._42 * n._34;
    result._33 = m._13 * n._31 + m._23 * n._32 + m._33 * n._33 + m._43 * n._34;
    result._34 = m._14 * n._31 + m._24 * n._32 + m._34 * n._33 + m._44 * n._34;

    result._41 = m._11 * n._41 + m._21 * n._42 + m._31 * n._43 + m._41 * n._44;
    result._42 = m._12 * n._41 + m._22 * n._42 + m._32 * n._43 + m._42 * n._44;
    result._43 = m._13 * n._41 + m._23 * n._42 + m._33 * n._43 + m._43 * n._44;
    result._44 = m._14 * n._41 + m._24 * n._42 + m._34 * n._43 + m._44 * n._44;

    return result;
}

float_compare :: (a : float,b : float,tolerance : float)-> bool{
	return abs(a - b) < tolerance;
}

multiply_test :: (){
    m : = float4x4.{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
    n := float4x4.{17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32};
    expectedResult := float4x4.{
        250, 260, 270, 280,
        618, 644, 670, 696,
        986, 1028, 1070, 1112,
        1354, 1412, 1470, 1528
    };
	result := multiply(m,n);
	// Compare each element of the result matrix with the expected result
	tolerance := 0.0001; // Define a tolerance for floating point comparison
    for v,i : result.a{
        if !float_compare(result.a[i],expectedResult.a[i],tolerance){
            print("Test failed: Incorrect result at element %\n", i);
			assert(false);
        }
    }
}

cross :: inline (a : float2 , b: float2) ->float2 #must{
	return a.x*b.y - b.x*a.y;
}

cross :: inline (a : float3, b: float3) -> float3 #must{
	c : float3;
	c.x = a.y*b.z - b.y*a.z;
	c.y = a.z*b.x - b.z*a.x;
	c.z = a.x*b.y - b.x*a.y;
	return c;
}

dot :: (a : float2, b: float2) -> float #must { return a.x*b.x + a.y*b.y; }
dot :: (a : float3, b: float3) -> float #must{ return a.x*b.x + a.y*b.y + a.z*b.z; }

angle_axis :: (angle : float, axis: float3) -> quaternion{
	t := radians(angle)*0.5;
	v := normalize(axis) * sin(t);
	q : quaternion;
	q.x = v.x;
	q.y = v.y;
	q.z = v.z;
	q.w = cos(t);
	return q;
}

orthogonal :: (v: float2) -> float2{
	return .{-v.y, v.x};
}

orthogonal :: (v: float3) -> float3{
	x := abs(v.x);
	y := abs(v.y);
	z := abs(v.z);

	other : float3;
	if x < y {
		if x < z {
			other = float3.{1, 0, 0};
		} else {
			other = float3.{0, 0, 1};
		}
	} else {
		if y < z {
			other = float3.{0, 1, 0};
		} else {
			other = float3.{0, 0, 1};
		}
	}
	return normalize(cross(v, other));
}

quaternion_from_float4x4 :: (m: float4x4) -> quaternion {
    m3: float3x3;

    m3.aa[0][0], m3.aa[1][0], m3.aa[2][0] = m.aa[0][0], m.aa[1][0], m.aa[2][0];
    m3.aa[0][1], m3.aa[1][1], m3.aa[2][1] = m.aa[0][1], m.aa[1][1], m.aa[2][1];
    m3.aa[0][2], m3.aa[1][2], m3.aa[2][2] = m.aa[0][2], m.aa[1][2], m.aa[2][2];

    return quaternion_from_float3x3(m3);
}

quaternion_from_float3x3 :: (m: float3x3) -> quaternion{
    four_x_squared_minus_1 := m.aa[0][0] - m.aa[1][1] - m.aa[2][2];
    four_y_squared_minus_1 := m.aa[1][1] - m.aa[0][0] - m.aa[2][2];
    four_z_squared_minus_1 := m.aa[2][2] - m.aa[0][0] - m.aa[1][1];
    four_w_squared_minus_1 := m.aa[0][0] + m.aa[1][1] + m.aa[2][2];

    biggest_index := 0;
    four_biggest_squared_minus_1 := four_w_squared_minus_1;
    if four_x_squared_minus_1 > four_biggest_squared_minus_1 {
        four_biggest_squared_minus_1 = four_x_squared_minus_1;
        biggest_index = 1;
    }
    if four_y_squared_minus_1 > four_biggest_squared_minus_1 {
        four_biggest_squared_minus_1 = four_y_squared_minus_1;
        biggest_index = 2;
    }
    if four_z_squared_minus_1 > four_biggest_squared_minus_1 {
        four_biggest_squared_minus_1 = four_z_squared_minus_1;
        biggest_index = 3;
    }

    biggest_val := sqrt(four_biggest_squared_minus_1 + 1) * 0.5;
    mult := 0.25 / biggest_val;

    q := quaternion.{};
    if biggest_index== {
        case 0;
            q.w = biggest_val;
            q.x = (m.aa[2][1] - m.aa[1][2]) * mult;
            q.y = (m.aa[0][2] - m.aa[2][0]) * mult;
            q.z = (m.aa[1][0] - m.aa[0][1]) * mult;
        case 1;
            q.w = (m.aa[2][1] - m.aa[1][2]) * mult;
            q.x = biggest_val;
            q.y = (m.aa[1][0] + m.aa[0][1]) * mult;
            q.z = (m.aa[0][2] + m.aa[2][0]) * mult;
        case 2;
            q.w = (m.aa[0][2] - m.aa[2][0]) * mult;
            q.x = (m.aa[1][0] + m.aa[0][1]) * mult;
            q.y = biggest_val;
            q.z = (m.aa[2][1] + m.aa[1][2]) * mult;
        case 3;
            q.w = (m.aa[1][0] - m.aa[0][1]) * mult;
            q.x = (m.aa[0][2] + m.aa[2][0]) * mult;
            q.y = (m.aa[2][1] + m.aa[1][2]) * mult;
            q.z = biggest_val;
    }
    return q;
}

quaternion_between_two_vectors :: (from : float3, to: float3) -> q: quaternion {
	q : quaternion;
	x := normalize(from);
	y := normalize(to);

	cos_theta := dot(x, y);
	if abs(cos_theta + 1) < 2*F32_EPSILON {
		v := orthogonal(x);
		q.x = v.x;
		q.y = v.y;
		q.z = v.z;
		q.w = 0;
		return q;
	}
	v := cross(x, y);
	w := cos_theta + 1;
	q.w = w;
	q.x = v.x;
	q.y = v.y;
	q.z = v.z;
	return normalize(q);
}

dot :: (a : quaternion, b: quaternion) -> (c: float) {
	return a.w*a.w + a.x*b.x + a.y*b.y + a.z*b.z;
}

quaternion_inverse :: (q: quaternion) -> quaternion{
	jq : Quaternion;
	jq.x = q.x;
	jq.y = q.y;
	jq.z = q.z;
	jq.w = q.w;
	qq := conjugate(jq);
	emq : quaternion;
	emq.x = jq.x;
	emq.y = jq.y;
	emq.z = jq.z;
	emq.w = jq.w;
	return emq * quaternion.{w=1.0/dot(q, q), x=0, y=0, z=0};
}

matrix3_look_at :: (eye : float3, centre : float3 , up: float3) -> float3x3{
	f := normalize(centre - eye);
	s := normalize(cross(f, up));
	u := cross(s, f);
	return float3x3.{
		+s.x, +s.y, +s.z,
		+u.x, +u.y, +u.z,
		-f.x, -f.y, -f.z,
	};
}

quaternion_look_at :: (eye : float3, centre: float3 , up: float3) -> quaternion{
	return quaternion_from_float3x3(matrix3_look_at(eye, centre, up));
}

rotate :: (v: float3, axis: float3, angle: float) -> float3{
    // Normalize the rotation axis
    axisn := normalize(axis);

    // Calculate trigonometric functions
    cosTheta := cos(angle);
    sinTheta := sin(angle);

    // Calculate components of the rotation matrix
    x, y, z := axis.x, axis.y, axis.z;
    oneMinusCosTheta := 1.0 - cosTheta;

    rotMatrix := ([3]float).[
        .[cosTheta + x * x * oneMinusCosTheta, x * y * oneMinusCosTheta - z * sinTheta, x * z * oneMinusCosTheta + y * sinTheta],
        .[y * x * oneMinusCosTheta + z * sinTheta, cosTheta + y * y * oneMinusCosTheta, y * z * oneMinusCosTheta - x * sinTheta],
        .[z * x * oneMinusCosTheta - y * sinTheta, z * y * oneMinusCosTheta + x * sinTheta, cosTheta + z * z * oneMinusCosTheta]
    ];

    // Perform the rotation
    result: float3;
    result.x = rotMatrix[0][0] * v.x + rotMatrix[0][1] * v.y + rotMatrix[0][2] * v.z;
    result.y = rotMatrix[1][0] * v.x + rotMatrix[1][1] * v.y + rotMatrix[1][2] * v.z;
    result.z = rotMatrix[2][0] * v.x + rotMatrix[2][1] * v.y + rotMatrix[2][2] * v.z;

    return result;
}

inverse :: (m : float4x4)->float4x4,bool{
	in_m : Matrix4 = cast,force(Matrix4)m;
	value,success := inverse(in_m);
	return cast,force(float4x4)(value),success;
}

mul :: (v: float4, m: float4x4) -> float4{
    result: float4 = ---;
    result.x = v.x * m._11 + v.y * m._21 + v.z * m._31 + v.w * m._41;
    result.y = v.x * m._12 + v.y * m._22 + v.z * m._32 + v.w * m._42;
    result.z = v.x * m._13 + v.y * m._23 + v.z * m._33 + v.w * m._43;
    result.w = v.x * m._14 + v.y * m._24 + v.z * m._34 + v.w * m._44;
    return result;
}

mul :: (m: float4x4, v: float4) -> float4 {
    result: float4;
    result.x = m._11 * v.x + m._21 * v.y + m._31 * v.z + m._41 * v.w;
    result.y = m._12 * v.x + m._22 * v.y + m._32 * v.z + m._42 * v.w;
    result.z = m._13 * v.x + m._23 * v.y + m._33 * v.z + m._43 * v.w;
    result.w = m._14 * v.x + m._24 * v.y + m._34 * v.z + m._44 * v.w;
    return result;
}

operator * :: (v : float4, m : float4x4)->float4{
	return mul(v,m);
}

operator * :: (m : float4x4,v : float4)->float4{
	return mul(m,v);
}

screen_to_world :: (projection_matrix : float4x4,cam_matrix : float4x4,buffer_dim : float2,screen_xy :  float2,z_depth :  float) -> float3{
    result : float3;
    ndc_p := float4.{
        2.0 * screen_xy.x / buffer_dim.x - 1.0,
        2.0 * screen_xy.y / buffer_dim.y - 1.0,
        z_depth,
        1.0,
    };

	clip_p := float4.{-ndc_p.x,-ndc_p.y,1.0,1.0};

	inv_pro := inverse(projection_matrix);
	view_space_p := inv_pro * clip_p;
	view_space_p.z = 1.0;
	view_space_p.w = 1.0;

	inv_cam := inverse(cam_matrix);

	world_space_p := inv_cam * view_space_p;
	final_p := (world_space_p.xyz / world_space_p.w).xyz;
	return final_p.xyz;
}

abs :: (a : float3)->float3{
	ina := cast,force(Vector3)a;
	return cast,force(float3)abs(ina);
}

#import "Math";
#import "Basic";

