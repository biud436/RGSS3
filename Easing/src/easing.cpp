/*
*
* TERMS OF USE - EASING EQUATIONS
*
* Open source under the BSD License.
*
* Copyright © 2001 Robert Penner
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* Redistributions of source code must retain the above copyright notice, this list of
* conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list
* of conditions and the following disclaimer in the documentation and/or other materials
* provided with the distribution.
*
* Neither the name of the author nor the names of contributors may be used to endorse
* or promote products derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
* MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
*  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
*  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
*  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
* AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
*  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
* OF THE POSSIBILITY OF SUCH DAMAGE.
*
*/

#define _USE_MATH_DEFINES
#define _RSDLL
#include <cmath>
#include <Windows.h>
#include "easing.h"

#define PI M_PI

// The following two macro convert between double and VALUE types.
#define CONVERT_VALUE(A, B, C, D) \
	double t = RFLOAT_VALUE(A); \
	double b = RFLOAT_VALUE(B); \
	double c = RFLOAT_VALUE(C); \
	double d = RFLOAT_VALUE(D); 

#define RET(x) \
	double ret = x; \
	return rgss_rb_float_new(ret);

#define TO_F(x) rgss_rb_float_new(x)

RSDLL VALUE EchoMessage(VALUE d)
{
	double t = RFLOAT_VALUE(d);
	return rgss_rb_float_new(t);
}

RSDLL VALUE BackEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);

	double s = 1.70158;
	double postFix = t /= d;
	
	RET(c*(postFix)*t*((s + 1)*t - s) + b);
}

RSDLL VALUE BackEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd)
	double s = 1.70158;
	RET(c*((t = t / d - 1)*t*((s + 1)*t + s) + 1) + b);
}

RSDLL VALUE BackEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd)
	double s = 1.70158;
	if ((t /= d / 2) < 1) { RET(c / 2 * (t*t*(((s *= (1.525)) + 1)*t - s)) + b) };
	double postFix = t -= 2;
	RET(c / 2 * ((postFix)*t*(((s *= (1.525)) + 1)*t + s) + 2) + b);
}

RSDLL VALUE BounceEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	VALUE v = BounceEaseOut(TO_F(d - t), TO_F(0), TO_F(c), TO_F(d));
	RET (c - v + b);
}

RSDLL VALUE BounceEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd)

	if ((t /= d) < (1 / 2.75)) {
		RET(c*(7.5625*t*t) + b);
	}
	else if (t < (2 / 2.75)) {
		double postFix = t -= (1.5 / 2.75);
		RET(c*(7.5625*(postFix)*t + .75) + b);
	}
	else if (t < (2.5 / 2.75)) {
		double postFix = t -= (2.25 / 2.75);
		RET(c*(7.5625*(postFix)*t + .9375) + b);
	}
	else {
		double postFix = t -= (2.625 / 2.75);
		RET(c*(7.5625*(postFix)*t + .984375) + b);
	}
}

RSDLL VALUE BounceEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);

	if (t < d / 2) {
		VALUE v = BounceEaseIn(TO_F(t * 2), TO_F(0), TO_F(c), TO_F(d));
		double d = RFLOAT_VALUE(v);
		RET(d *.5 + b);
	} else {
		VALUE v = BounceEaseOut(TO_F(t * 2 - d), TO_F(0), TO_F(c), TO_F(d));
		double d = RFLOAT_VALUE(v);
		RET(d * .5 + c*.5 + b);
	}
}

RSDLL VALUE CircEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	RET(-c * (sqrt(1 - (t /= d)*t) - 1) + b);
}

RSDLL VALUE CircEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	RET(c * sqrt(1 - (t = t / d - 1)*t) + b);
}

RSDLL VALUE CircEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	
	if ((t /= d / 2) < 1) {
		RET(-c / 2 * (sqrt(1 - t*t) - 1) + b);
	}

	RET(c / 2 * (sqrt(1 - t*(t -= 2)) + 1) + b);
}

RSDLL VALUE CubicEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	RET(c*(t /= d)*t*t + b);
}

RSDLL VALUE CubicEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	RET(c*((t = t / d - 1)*t*t + 1) + b);
}

RSDLL VALUE CubicEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	if ((t /= d / 2) < 1) {
		RET(c / 2 * t*t*t + b);
	}
	RET(c / 2 * ((t -= 2)*t*t + 2) + b);
}

RSDLL VALUE ElasticEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);

	if (t == 0) {
		RET(b);
	}
	
	if ((t /= d) == 1) {
		RET(b + c);
	}

	double p = d*.3;
	double a = c;
	double s = p / 4;
	double postFix = a*pow(2, 10 * (t -= 1)); // this is a fix, again, with post-increment operators
	
	RET(-(postFix * sin((t*d - s)*(2 * M_PI) / p)) + b);

}

RSDLL VALUE ElasticEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);

	if (t == 0) {
		RET(b);
	}

	if ((t /= d) == 1) {
		RET(b + c);
	}

	double p = d*.3;
	double a = c;
	double s = p / 4;

	RET((a*pow(2, -10 * t) * sin((t*d - s)*(2 * M_PI) / p) + c + b));

}

RSDLL VALUE ElasticEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);

	if (t == 0) {
		RET(b);
	}
	
	if ((t /= d / 2) == 2) {
		RET(b + c);
	}

	double p = d*(.3*1.5);
	double a = c;
	double s = p / 4;

	if (t < 1) {
		double postFix = a*pow(2, 10 * (t -= 1));
		RET( -.5*(postFix* sin((t*d - s)*(2 * PI) / p)) + b );
	}

	double postFix = a*pow(2, -10 * (t -= 1));
	RET( postFix * sin((t*d - s)*(2 * PI) / p)*.5 + c + b );
}

RSDLL VALUE ExpoEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);

	RET( (t == 0) ? b : c * pow(2, 10 * (t / d - 1)) + b );
}

RSDLL VALUE ExpoEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);

	RET( (t == d) ? b + c : c * (-pow(2, -10 * t / d) + 1) + b );
}

RSDLL VALUE ExpoEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);

	if (t == 0) { RET(b) };
	if (t == d) { RET(b + c) };
	if ((t /= d / 2) < 1) { RET( c / 2 * pow(2, 10 * (t - 1)) + b ) };
	RET( c / 2 * (-pow(2, -10 * --t) + 2) + b );
}

RSDLL VALUE LinearEaseNone(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);

	RET( c*t / d + b );
}

RSDLL VALUE LinearEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);

	RET( c*t / d + b );
}

RSDLL VALUE LinearEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);

	RET( c*t / d + b );
}

RSDLL VALUE LinearEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	RET(c*t / d + b);
}

RSDLL VALUE QuadEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	RET(c*(t /= d)*t + b);
}

RSDLL VALUE QuadEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	RET(-c *(t /= d)*(t - 2) + b);
}

RSDLL VALUE QuadEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	if ((t /= d / 2) < 1)
	{
		RET( ((c / 2)*(t*t)) + b );
	}
	
	RET( -c / 2 * (((t - 2)*(--t)) - 1) + b );
}

RSDLL VALUE QuartEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	RET ( c*(t /= d)*t*t*t + b );
}

RSDLL VALUE QuartEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	RET( -c * ((t = t / d - 1)*t*t*t - 1) + b );
}

RSDLL VALUE QuartEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	if ((t /= d / 2) < 1) {
		RET( c / 2 * t*t*t*t + b );
	}
	RET( -c / 2 * ((t -= 2)*t*t*t - 2) + b );
}

RSDLL VALUE QuintEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	RET( c*(t /= d)*t*t*t*t + b );
}

RSDLL VALUE QuintEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	RET( c*((t = t / d - 1)*t*t*t*t + 1) + b );
}

RSDLL VALUE QuintEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	if ((t /= d / 2) < 1) { RET(c / 2 * t*t*t*t*t + b;); }
	RET( c / 2 * ((t -= 2)*t*t*t*t + 2) + b ); 
}

RSDLL VALUE SineEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	RET(-c * cos(t / d * (PI / 2)) + c + b);
}

RSDLL VALUE SineEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	RET( c * sin(t / d * (PI / 2)) + b );
}

RSDLL VALUE SineEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd)
{
	CONVERT_VALUE(tt, bb, cc, dd);
	RET( -c / 2 * (cos(PI*t / d) - 1) + b );
}