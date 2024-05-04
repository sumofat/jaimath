
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
	return sqrt(dot(cast,force(Vector3)v, cast,force(Vector3)v));
}

normalize :: (v : float3)-> float3{
	return xx (cast,force(Vector3)v / length(v));
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

float4x4 :: struct{
	_11, _21, _31, _41 : float;
    _12, _22, _32, _42 : float;
    _13, _23, _33, _43 : float;
    _14, _24, _34, _44 : float;

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
	return multiply(translation, multiply(rotation, scale));
}

float4x4_translate :: (v: float3) -> float4x4{
	m := float4x4_identity;
	m.aa[3][0] = v.c[0];
	m.aa[3][1] = v.c[1];
	m.aa[3][2] = v.c[2];
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

transpose :: (using input : float4x4)-> float4x4{
	return .{_11, _12, _13, _14,
			 _21, _22, _23, _24,
		 	 _31, _32, _33, _43,
			 _41, _42, _43, _44};
}

operator * :: (a: float4x4, b: float4x4) -> float4x4{
    return inline multiply(a, b);
}

multiply :: (m : float4x4,n : float4x4) -> float4x4 {
    //result : float4x4 = float4x4_identity;
    result : float4x4 = ---;
    
    result._11 = m._11 * n._11 + m._12 * n._21 + m._13 * n._31 + m._14 * n._41;
    result._12 = m._11 * n._12 + m._12 * n._22 + m._13 * n._32 + m._14 * n._42;
    result._13 = m._11 * n._13 + m._12 * n._23 + m._13 * n._33 + m._14 * n._43;
    result._14 = m._11 * n._14 + m._12 * n._24 + m._13 * n._34 + m._14 * n._44;

    result._21 = m._21 * n._11 + m._22 * n._21 + m._23 * n._31 + m._24 * n._41;
    result._22 = m._21 * n._12 + m._22 * n._22 + m._23 * n._32 + m._24 * n._42;
    result._23 = m._21 * n._13 + m._22 * n._23 + m._23 * n._33 + m._24 * n._43;
    result._24 = m._21 * n._14 + m._22 * n._24 + m._23 * n._34 + m._24 * n._44;

    result._31 = m._31 * n._11 + m._32 * n._21 + m._33 * n._31 + m._34 * n._41;
    result._32 = m._31 * n._12 + m._32 * n._22 + m._33 * n._32 + m._34 * n._42;
    result._33 = m._31 * n._13 + m._32 * n._23 + m._33 * n._33 + m._34 * n._43;
    result._34 = m._31 * n._14 + m._32 * n._24 + m._33 * n._34 + m._34 * n._44;

    result._41 = m._41 * n._11 + m._42 * n._21 + m._43 * n._31 + m._44 * n._41;
    result._42 = m._41 * n._12 + m._42 * n._22 + m._43 * n._32 + m._44 * n._42;
    result._43 = m._41 * n._13 + m._42 * n._23 + m._43 * n._33 + m._44 * n._43;
    result._44 = m._41 * n._14 + m._42 * n._24 + m._43 * n._34 + m._44 * n._44;

    return result;
}
/*

//This is the row matrix multiply
multiply :: (m : float4x4,n : float4x4) -> float4x4 {
	result : float4x4 = float4x4_identity;
	
    result._11 = m._11 * n._11 + m._21 * n._12 + m._31 * n._13 + m._41 * n._14;
    result._21 = m._11 * n._21 + m._21 * n._22 + m._31 * n._23 + m._41 * n._24;
    result._31 = m._11 * n._31 + m._21 * n._32 + m._31 * n._33 + m._41 * n._34;
    result._41 = m._11 * n._41 + m._21 * n._42 + m._31 * n._43 + m._41 * n._44;

    result._12 = m._12 * n._11 + m._22 * n._12 + m._32 * n._13 + m._42 * n._14;
    result._22 = m._12 * n._21 + m._22 * n._22 + m._32 * n._23 + m._42 * n._24;
    result._32 = m._12 * n._31 + m._22 * n._32 + m._32 * n._33 + m._42 * n._34;
    result._42 = m._12 * n._41 + m._22 * n._42 + m._32 * n._43 + m._42 * n._44;

    result._13 = m._13 * n._11 + m._23 * n._12 + m._33 * n._13 + m._43 * n._14;
    result._23 = m._13 * n._21 + m._23 * n._22 + m._33 * n._23 + m._43 * n._24;
    result._33 = m._13 * n._31 + m._23 * n._32 + m._33 * n._33 + m._43 * n._34;
    result._43 = m._13 * n._41 + m._23 * n._42 + m._33 * n._43 + m._43 * n._44;

    result._14 = m._14 * n._11 + m._24 * n._12 + m._34 * n._13 + m._44 * n._14;
    result._24 = m._14 * n._21 + m._24 * n._22 + m._34 * n._23 + m._44 * n._24;
    result._34 = m._14 * n._31 + m._24 * n._32 + m._34 * n._33 + m._44 * n._34;
    result._44 = m._14 * n._41 + m._24 * n._42 + m._34 * n._43 + m._44 * n._44;

	return result;
}
*/

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

#import "Math";
#import "Basic";

