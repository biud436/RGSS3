#if defined __cplusplus
extern "C" {
#endif

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

#include <ruby.h>

#ifdef _RSDLL
#define RSDLL __declspec(dllexport)
#else
#define RSDLL __declspec(dllimport)
#endif

	// Notice that it can't build without ruby header files.
	// I've built by using the stuff called RGSS-Ext by ken1882
	// and it is available at https://forums.rpgmakerweb.com/index.php?threads/combine-rgss-with-ruby-c-dll-and-speed-up-the-game-like-a-boss.107006/
	typedef VALUE(*rgss_obj_ivar_get_proto)(VALUE, VALUE);
	typedef VALUE(*rgss_obj_ivar_set_proto)(VALUE, VALUE, VALUE);
	typedef VALUE(*rgss_ary_at_proto)(VALUE, VALUE);
	typedef VALUE(*rgss_ascii_new_cstr_proto)(const char*);

	// I've added the new features that sets the floating points such as float or double in the DLL.
	typedef VALUE(*rgss_rb_float_new_proto)(double d);

	static int init_ok = false;
	static rgss_obj_ivar_get_proto rgss_obj_ivar_get;
	static rgss_obj_ivar_set_proto rgss_obj_ivar_set;
	static rgss_ary_at_proto rgss_ary_at;
	static rgss_ascii_new_cstr_proto rgss_ascii_new_cstr;
	static rgss_rb_float_new_proto rgss_rb_float_new;

	void RSDLL Initialize(HMODULE RGSSDLL) {
		rgss_obj_ivar_get = (rgss_obj_ivar_get_proto)((char*)RGSSDLL + 0x341F0);
		rgss_obj_ivar_set = (rgss_obj_ivar_set_proto)((char*)RGSSDLL + 0x34230);
		rgss_ary_at = (rgss_ary_at_proto)((char*)RGSSDLL + 0x89cc0);
		rgss_ascii_new_cstr = (rgss_ascii_new_cstr_proto)((char*)RGSSDLL + 0x365B0);

		// The ruby C function named rb_float_new is mapped at RGSS301.dll + 0x5A250
		// I checked its static address from the memory viewer of  the cheat engine.
		rgss_rb_float_new = (rgss_rb_float_new_proto)((char*)RGSSDLL + 0x5A250);

		init_ok = true;
	}

	RSDLL VALUE EchoMessage(VALUE d);

	// tt: current time, bb: begInnIng value, cc: change In value, dd: duration
	RSDLL VALUE BackEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE BackEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE BackEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE BounceEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE BounceEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE BounceEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE CircEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE CircEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE CircEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE CubicEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE CubicEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE CubicEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE ElasticEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE ElasticEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE ElasticEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE ExpoEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE ExpoEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE ExpoEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE LinearEaseNone(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE LinearEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE LinearEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE LinearEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE QuadEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE QuadEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE QuadEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE QuartEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE QuartEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE QuartEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE QuintEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE QuintEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE QuintEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE SineEaseIn(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE SineEaseOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);
	RSDLL VALUE SineEaseInOut(VALUE tt, VALUE bb, VALUE cc, VALUE dd);

#ifdef __cplusplus
}
#endif