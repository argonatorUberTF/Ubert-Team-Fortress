void () nehahra_checkvolume =
{
	local vector dave;
	local float num;
	local entity head;
	head = find (world, classname, "player");
	if ((head == world))
	{
		self.volume = 0.1;
		return;
	}
	dave = head.origin - self.origin;
	num = vlen (dave);
	if ((num < 500))
	{
		self.volume = 1;
		return;
	}
	if ((num < 600))
	{
		self.volume = 0.8;
		return;
	}
	if ((num < 700))
	{
		self.volume = 0.6;
		return;
	}
	if ((num < 800))
	{
		self.volume = 0.4;
		return;
	}
	if ((num < 1000))
	{
		self.volume = 0.3;
		return;
	}
	self.volume = 0.2;
};
void () monster_nehahra1 =
{
	return;
};
void () monster_nehahra =
{
	if (deathmatch)
	{
		remove (self);
		return;
	}
	total_monsters = total_monsters + 1;
	precache_model2 ("progs/nehah.mdl");
	precache_model2 ("progs/nehjet.mdl");
	precache_model2 ("maps/finale1.bsp");
	precache_sound2 ("boss3/hit.wav");
	precache_sound2 ("ambience/sphum.wav");
	precache_sound2 ("hknight/idle.wav");
	precache_sound2 ("ambience/fire1.wav");
	precache_sound2 ("sets/set2_4.wav");
	precache_sound2 ("boss3/swing.wav");
	precache_sound2 ("boss3/neh1.wav");
	precache_sound2 ("boss3/neh2.wav");
	precache_sound2 ("boss3/neh3.wav");
	precache_sound2 ("boss3/step1.wav");
	precache_sound2 ("boss3/step2.wav");
	precache_sound2 ("boss3/nehdie1.wav");
	precache_sound2 ("boss3/nehdie2.wav");
	precache_sound2 ("boss3/nehdie3.wav");
	precache_sound2 ("boss3/nehdie4.wav");
	precache_model2 ("progs/gstorm.mdl");
	precache_sound ("sets/set2_3.wav");
	precache_sound ("sets/set2_5.wav");
	precache_sound ("cuts1/flf1.wav");
	precache_sound ("cuts1/flf2.wav");
	precache_sound ("vondur/fan1.wav");
	precache_sound ("ambience/class2.wav");
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel (self, "progs/nehah.mdl");
	setsize (self, VEC_HULL2_MIN, '60 60 300');
	self.yaw_speed = 30;
	self.brain = 0;
	MTF_Setup_Monster_Presets ( 0, "Nehahra", monster_nehahra1 );
	self.lives = 0;
	self.health = MTF_Monster_Health((2500 + (skill * 500)));
	self.event = "nehahra_frame";
	self.th_stand = nehahra_stand;
	self.th_walk = nehahra_goal;
	self.th_melee = nehahra_melee;
	self.th_run = nehahra_goal;
	self.th_special = nehahra_handlebsp;
	self.th_pain = SUB_Null;
	self.th_die = nehahra_die;
	self.origin_z = (self.origin_z + 1);
	self.button1 = 90;
	droptofloor ();
	if (!walkmove (0, 0))
	{
		dprint ("nehahra stuck in wall at: ");
		dprint (vtos (self.origin));
		dprint ("\n");
	}
	self.takedamage = DAMAGE_AIM;
	self.ideal_yaw = (self.angles * '0 1 0');
	self.view_ofs = '0 0 265';
	self.use = monster_use;
	self.flags = (self.flags | FL_MONSTER);
	self.soul = "undead";
	if (self.target)
	{
		self.movetarget = find (world, targetname, self.target);
		self.goalentity = find (world, targetname, self.target);
		self.ideal_yaw = vectoyaw ((self.goalentity.origin - self.origin));
		if (!self.movetarget)
		{
			dprint ("Nehahra can't find target at ");
			dprint (vtos (self.origin));
			dprint ("\n");
		}
		if ((self.movetarget.classname == "path_corner"))
		{
			self.th_walk ();
		}
		else
		{
			self.pausetime = 100000000;
			self.goalentity = world;
			self.movetarget = world;
		}
		self.th_stand ();
	}
	else
	{
		self.pausetime = 100000000;
		self.th_stand ();
	}
	self.nextthink = (self.nextthink + (random () * 0.5));
};
void (float dist) nehahra_motion =
{
	local entity putz;
	movedist = dist;
	self.goalentity = self.enemy;
	if ((self.enemy.health <= 0))
	{
		putz = self.enemy;
		self.enemy = world;
		self.goalentity = world;
		self.objekt = world;
		self.walkframe = 0;
		if (((self.th_wins && visible (putz)) && (putz.classname == "player")))
		{
			self.th_wins ();
			return;
		}
		if ((self.oldenemy.health > 0))
		{
			self.enemy = self.oldenemy;
			HuntTarget ();
		}
		else
		{
			if (self.movetarget)
			{
				self.th_walk ();
			}
			else
			{
				self.th_stand ();
			}
			return;
		}
	}
	self.show_hostile = (time + 1);
	enemy_vis = visible (self.enemy);
	if (enemy_vis)
	{
		self.search_time = (time + MOVETYPE_FLY);
	}
	if ((coop && (self.search_time < time)))
	{
		if (FindTarget ())
		{
			return;
		}
	}
	if (visible (self.enemy))
	{
		if (nehahra_checkhit ())
		{
			self.th_melee ();
			return;
		}
	}
	if (neh_findbsp ())
	{
		self.th_special ();
		return;
	}
	enemy_infront = infront (self.enemy);
	enemy_range = range (self.enemy);
	enemy_yaw = vectoyaw ((self.enemy.origin - self.origin));
	movetogoal (30);
};
void () nehahra_damage =
{
	local float ldmg;
	if (!self.enemy)
	{
		return;
	}
	if (!CanDamage (self.enemy, self))
	{
		return;
	}
	if (!nehahra_checkhit ())
	{
		return;
	}
	random ();
	ldmg = ((random () + random ()) + random ()) * 200;
	T_Damage (self.enemy, self, self, ldmg);
	sound (self, CHAN_BODY, "boss3/step1.wav", 1, ATTN_NONE);
	if ((random () < 0.2))
	{
		if ((((self.enemy.flags & FL_MONSTER) || self.enemy.flags) & FL_CLIENT))
		{
			if ((self.enemy.flags & FL_ONGROUND))
			{
				self.enemy.flags = (self.enemy.flags - FL_ONGROUND);
			}
			self.enemy.origin_z = (self.enemy.origin_z + 1);
			self.enemy.velocity_z = (ldmg * 0.4);
		}
	}
};
void () nehahra_bspdamage =
{
	if ((self.enemy.classname == "player"))
	{
		return;
	}
	T_Damage (self.enemy, self, self, 2000);
	sound (self, CHAN_BODY, "boss3/step1.wav", 1, ATTN_NONE);
};
float () nehahra_checkhit =
{
	local entity mark;
	local vector delta;
	local vector dave;
	local float num;
	num = 0;
	if (visible (self.enemy))
	{
		num = 1;
	}
	else
	{
		mark = find (world, classname, "nehahra_body");
		if ((mark != world))
		{
			num = num + mark.nojump;
		}
	}
	if (((self.enemy.classname == "player") && (num == 0)))
	{
		return (0);
	}
	delta = self.enemy.origin - self.origin;
	if ((vlen (delta) < 250))
	{
		return (1);
	}
	dave = self.origin + '0 0 240';
	delta = self.enemy.origin - dave;
	if ((vlen (delta) < 350))
	{
		return (1);
	}
	return (0);
};
void () nehahra_field_goal =
{
	local entity mark;
	mark = self.enemy;
	if (!nehahra_checkhit ())
	{
		return;
	}
	if ((((self.enemy.flags & FL_MONSTER) || self.enemy.flags) & FL_CLIENT))
	{
		if ((mark.flags & FL_ONGROUND))
		{
			mark.flags = (mark.flags - FL_ONGROUND);
		}
		makevectors (self.angles);
		mark.origin_z = (mark.origin_z + 1);
		mark.velocity = ((v_forward * 800) + '0 0 450');
	}
};
void () nehahra_stand =
{
	self.touch = SUB_Null;
	if ((self.walkframe >= 14))
	{
		self.walkframe = 0;
	}
	parse_anim ( 0, nehahra_stand );
	self.frame = (0 + self.walkframe);
	self.walkframe = (self.walkframe + 1);
	ai_stand ();
};
void () nehahra_missile =
{
	local vector spot;
	self.walkframe = 0;
	spot = self.origin + '0 0 75';
	if ((spot_z < self.enemy.origin_z))
	{
		nehahra_bspspit ();
		return;
	}
	nehahra_spitting ();
};
void () nehahra_spitting =
{
	self.touch = SUB_Null;
	if ((self.walkframe >= 11))
	{
		self.walkframe = 0;
		nehahra_goal ();
		return;
	}
	parse_anim ( 14, nehahra_spitting );
	self.frame = (14 + self.walkframe);
	self.walkframe = (self.walkframe + 1);
	ai_face ();
	if (((self.walkframe > 3) && (self.walkframe < 10)))
	{
		nehahra_spitfire (0);
	}
};
void () nehahra_bspspit =
{
	self.touch = SUB_Null;
	if ((self.walkframe >= 12))
	{
		self.walkframe = 0;
		self.enemy = self.oldenemy;
		nehahra_goal ();
		return;
	}
	parse_anim ( 25, nehahra_bspspit );
	self.frame = (25 + self.walkframe);
	self.walkframe = (self.walkframe + 1);
	if ((self.enemy.classname == "player"))
	{
		ai_face ();
		nehahra_spitfire (0);
	}
	else
	{
		face_bsp (self.enemy);
		if (((self.walkframe > 3) && (self.walkframe < 10)))
		{
			nehahra_bspfire (0);
		}
	}
};
void () nehahra_squashing =
{
	if (other.takedamage)
	{
		if (other.health)
		{
			if (infront (other))
			{
				T_Damage (other, self, self, 200);
			}
		}
	}
};
void () nehahra_goal =
{
	self.touch = nehahra_squashing;
	if ((self.walkframe >= 24))
	{
		self.walkframe = 0;
	}
	if (!nehahra_checkhit ())
	{
		if (visible (self.enemy))
		{
			if ((random () < 0.1))
			{
				nehahra_missile ();
				return;
			}
		}
	}
	parse_anim ( 52, nehahra_goal );
	self.frame = (52 + self.walkframe);
	self.walkframe = (self.walkframe + 1);
	if ((self.enemy != world))
	{
		nehahra_motion (10); // xav: should be more or less?
	}
	else
	{
		if ((self.goalentity != world))
		{
			ai_walk (SVC_INTERMISSION);
		}
		else
		{
			self.th_stand ();
		}
	}
	if (((self.walkframe == 5) || (self.walkframe == 10)))
	{
		nehahra_checkvolume ();
		sound (self, CHAN_BODY, "boss3/step2.wav", self.volume, ATTN_NONE);
		if ((random () < 0.2))
		{
			sound (self, CHAN_VOICE, "boss3/neh1.wav", self.volume, ATTN_NONE);
		}
	}
};
void () nehahra_melee =
{
	nehahra_sounds ();
	if ((random () < 0.5))
	{
		nehahra_smash1 ();
	}
	else
	{
		nehahra_kick1 ();
	}
};
void () nehahra_sounds =
{
	local float num;
	nehahra_checkvolume ();
	num = random ();
	if ((num < 0.3))
	{
		sound (self, CHAN_ITEM, "boss3/neh1.wav", self.volume, ATTN_NONE);
	}
	else
	{
		if ((num < 0.7))
		{
			sound (self, CHAN_ITEM, "boss3/neh2.wav", self.volume, ATTN_NONE);
		}
		else
		{
			sound (self, CHAN_BODY, "boss3/neh3.wav", self.volume, ATTN_NONE);
		}
	}
};
void () nehahra_smash1 = [ 45, nehahra_smash2 ]
{
	ai_charge (FL_MONSTER);
};
void () nehahra_smash2 = [ 46, nehahra_smash3 ]
{
	ai_charge (FL_MONSTER);
};
void () nehahra_smash3 = [ 47, nehahra_smash4 ]
{
	ai_charge (FL_INWATER);
	nehahra_checkvolume ();
	sound (self, CHAN_BODY, "boss3/swing.wav", self.volume, ATTN_NONE);
};
void () nehahra_smash4 = [ 48, nehahra_smash5 ]
{
	ai_charge (FL_MONSTER);
};
void () nehahra_smash5 = [ 49, nehahra_smash6 ]
{
	ai_charge (FL_MONSTER);
};
void () nehahra_smash6 = [ 50, nehahra_smash7 ]
{
	ai_face ();
};
void () nehahra_smash7 = [ 51, nehahra_smash8 ]
{
	ai_face ();
	nehahra_damage ();
};
void () nehahra_smash8 = [ 50, nehahra_smash9 ]
{};
void () nehahra_smash9 = [ 49, nehahra_smash10 ]
{};
void () nehahra_smash10 = [ 48, nehahra_smash11 ]
{};
void () nehahra_smash11 = [ 47, nehahra_smash12 ]
{};
void () nehahra_smash12 = [ 46, nehahra_goal ]
{};
void () nehbsp_smash1 = [ 45, nehbsp_smash2 ]
{
	ai_charge (FL_MONSTER);
};
void () nehbsp_smash2 = [ 46, nehbsp_smash3 ]
{
	face_bsp (self.enemy);
};
void () nehbsp_smash3 = [ 47, nehbsp_smash4 ]
{
	face_bsp (self.enemy);
};
void () nehbsp_smash4 = [ 48, nehbsp_smash5 ]
{
	ai_charge (FL_MONSTER);
	face_bsp (self.enemy);
};
void () nehbsp_smash5 = [ 49, nehbsp_smash6 ]
{
	ai_charge (FL_MONSTER);
	face_bsp (self.enemy);
	nehahra_checkvolume ();
	sound (self, CHAN_BODY, "boss3/swing.wav", self.volume, ATTN_NONE);
};
void () nehbsp_smash6 = [ 50, nehbsp_smash7 ]
{
	face_bsp (self.enemy);
};
void () nehbsp_smash7 = [ 51, nehbsp_smash8 ]
{
	face_bsp (self.enemy);
	nehahra_bspdamage ();
};
void () nehbsp_smash8 = [ 50, nehbsp_smash9 ]
{};
void () nehbsp_smash9 = [ 49, nehbsp_smash10 ]
{};
void () nehbsp_smash10 = [ 48, nehbsp_smash11 ]
{};
void () nehbsp_smash11 = [ 47, nehbsp_smash12 ]
{
	self.enemy = self.oldenemy;
};
void () nehbsp_smash12 = [ 46, nehahra_goal ]
{};
void () nehahra_handlebsp =
{
	self.walkframe = 0;
	if ((random () < 0.3))
	{
		nehahra_bspspit ();
	}
	else
	{
		nehbsp_smash1 ();
	}
};
void () nehahra_kick1 = [ 37, nehahra_kick2 ]
{
	ai_face ();
};
void () nehahra_kick2 = [ 38, nehahra_kick3 ]
{
	ai_face ();
};
void () nehahra_kick3 = [ 39, nehahra_kick4 ]
{
	ai_face ();
};
void () nehahra_kick4 = [ 40, nehahra_kick5 ]
{
	ai_face ();
};
void () nehahra_kick5 = [ 41, nehahra_kick6 ]
{
	self.touch = nehahra_squashing;
	if ((random () < 0.7))
	{
		return;
	}
	makevectors (self.angles);
	self.origin_z = (self.origin_z + 1);
	self.velocity = ((v_forward * 300) + '0 0 450');
	if ((self.flags & FL_ONGROUND))
	{
		self.flags = (self.flags - FL_ONGROUND);
	}
};
void () nehahra_kick6 = [ 42, nehahra_kick7 ]
{
	ai_face ();
	nehahra_damage ();
	nehahra_field_goal ();
};
void () nehahra_kick7 = [ 43, nehahra_kick8 ]
{
	nehahra_damage ();
	nehahra_field_goal ();
};
void () nehahra_kick8 = [ 44, nehahra_kick9 ]
{};
void () nehahra_kick9 = [ 42, nehahra_goal ]
{};
float (entity targ) visible_bsp =
{
	local vector spot1;
	local vector spot2;
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.absmin + ((targ.absmax - targ.absmin) * 0.5);
	traceline (spot1, spot2, TRUE, self);
	if ((trace_inopen && trace_inwater))
	{
		return (FALSE);
	}
	if (((trace_fraction == 1) || (trace_ent == targ)))
	{
		return (TRUE);
	}
	return (FALSE);
};
void (entity targ) face_bsp =
{
	local vector spot1;
	spot1 = targ.absmin + ((targ.absmax - targ.absmin) * 0.5);
	self.ideal_yaw = vectoyaw ((spot1 - self.origin));
	ChangeYaw ();
};
void (float offset) nehahra_bspfire =
{
	local vector org;
	local vector vec;
	local vector spot;
	makevectors (self.angles);
	spot = self.origin + '0 0 230';
	org = spot + (v_forward * 10);
	vec = normalize (((self.enemy.absmin + ((self.enemy.absmax - self.enemy.absmin) * 0.5)) - spot));
	WeldFire (org, vec);
};
float () neh_findbsp =
{
	local entity head;
	head = findradius (self.origin, 300);
	while (head)
	{
		if ((((head.classname == "func_explodable") || (head.classname == "func_mindcrime")) || (head.classname == "func_sobject")))
		{
			self.oldenemy = self.enemy;
			self.goalentity = head;
			self.enemy = head;
			return (1);
		}
		head = head.chain;
	}
	return (0);
};
void () nehahra_wreckbsp =
{
	if ((self.waterlevel > 1))
	{
		remove (self);
		return;
	}
	if ((self.enemy.items & IT_SUIT))
	{
		remove (self);
		return;
	}
	if (!(other.flags & FL_BLOODLESS))
	{
		self.touch = WeldTouch;
		return;
	}
	other = self.enemy;
	nehahra_bspdamage ();
	neh_findbsp ();
	nehahra_bspdamage ();
};
void () nehahra_carnify_body =
{
	local entity body;
	local vector dave;
	body = spawn ();
	body.event = "nehahra_frame";
	body.classname = "nehahra_body";
	body.aether = '0 0 90';
	body.angles = self.angles;
	body.model = string_null;
	body.flags = (body.flags | FL_MONSTER);
	body.solid = SOLID_SLIDEBOX;
	body.movetype = MOVETYPE_NONE;
	body.objekt = self;
	body.owner = self;
	body.health = self.health;
	body.takedamage = DAMAGE_AIM;
	body.th_die = kill_nehahra;
	body.th_pain = bod_neh_pain;
	setsize (body, VEC_HULL_MIN, '17 32 50');
	dave = self.origin + body.aether;
	setorigin (body, dave);
	body.think = nehahra_frame;
	body.nextthink = (time + 0.3);
};
void () nehahra_carnify_head =
{
	local entity head;
	local vector dave;
	head = spawn ();
	head.angles = self.angles;
	head.event = "nehahra_frame";
	head.classname = "nehahra_head";
	head.model = string_null;
	head.aether = '0 0 180';
	head.solid = SOLID_SLIDEBOX;
	head.movetype = MOVETYPE_NONE;
	head.flags = (head.flags | FL_MONSTER);
	head.objekt = self;
	head.owner = self;
	head.health = self.health;
	head.takedamage = DAMAGE_AIM;
	head.th_die = kill_nehahra;
	head.th_pain = bod_neh_pain;
	setsize (head, '-50 -50 -24', '50 50 100');
	dave = self.origin + head.aether;
	setorigin (head, dave);
	head.think = nehahra_frame;
	head.nextthink = (time + 0.5);
};
void () bod_neh_pain =
{
//	self.objekt.enemy = attacker;
//	T_Damage (self.objekt, attacker, self, 1);
};
void () nehahra_frame =
{
	local vector dave;
	local float num;
	local entity head;
	local float t;
	if ((self.classname != "monster_nehahra"))
	{
		if ((self.enemy == world))
		{
			self.enemy = self.objekt.enemy;
		}
		if ((self.objekt.health < 1))
		{
			remove (self);
			return;
		}
		dave = self.objekt.origin + self.aether;
		self.origin = dave;
		setorigin (self, dave);
	}
	t = 0;
	num = 100000;
	head = find (world, event, "nehahra_frame");
	while (head)
	{
		if ((head.health <= num))
		{
			num = head.health;
		}
		else
		{
			head.health = num;
		}
		head = find (head, event, "nehahra_frame");
	}
	if (visible (self.enemy))
	{
		self.nojump = 1;
	}
	else
	{
		self.nojump = 0;
	}
	self.think = nehahra_frame;
	self.nextthink = (time + 0.1);
};
void () kill_nehahra =
{
	local entity head;
	local float num;
	local string pie1;
	if ((self.classname == "nehahra_head"))
	{
		pie1 = "nehahra_body";
	}
	else
	{
		pie1 = "nehahra_head";
	}
	head = find (world, classname, pie1);
	if ((head != world))
	{
		remove (head);
	}
	num = self.objekt.health * 5;
	T_Damage (self.objekt, self, self, num);
	remove (self);
};
void () nehahra_die = [ 76, n_die2 ]
{
	self.health = -120;
	SUB_UseTargets ();
	nehjet ();
	nehjet ();
	lavasplash (self.origin);
	sound (self, CHAN_ITEM, "boss3/nehdie2.wav", self.volume, ATTN_NONE);
};
void () n_die2 = [ 81, n_die3 ]
{
	nehjet ();
	nehjet ();
};
void () n_die3 = [ 80, n_die4 ]
{
	lavasplash (self.origin);
	nehjet ();
	nehjet ();
};
void () n_die4 = [ 79, n_die5 ]
{
	nehjet ();
	nehjet ();
};
void () n_die5 = [ 78, n_die6 ]
{
	lavasplash ((self.origin + '0 0 100'));
	nehjet ();
	nehjet ();
};
void () n_die6 = [ 77, n_die7 ]
{
	ThrowGib ("progs/gib2.mdl", self.health);
	nehjet ();
	nehjet ();
};
void () n_die7 = [ 78, n_die8 ]
{
	lavasplash (self.origin);
	nehjet ();
	nehjet ();
};
void () n_die8 = [ 79, n_die9 ]
{
	nehjet ();
	nehjet ();
};
void () n_die9 = [ 80, n_die10 ]
{
	lavasplash ((self.origin + '0 0 100'));
	ThrowGib ("progs/gib3.mdl", self.health);
	nehjet ();
	nehjet ();
};
void () n_die10 = [ 81, n_die11 ]
{
	nehjet ();
	nehjet ();
};
void () n_die11 = [ 82, n_die12 ]
{
	nehjet ();
	nehjet ();
};
void () n_die12 = [ 83, n_die13 ]
{
	lavasplash (self.origin);
	nehjet ();
	nehjet ();
};
void () n_die13 = [ 84, n_die14 ]
{
	nehjet ();
	nehjet ();
};
void () n_die14 = [ 85, n_die15 ]
{
	lavasplash ((self.origin + '0 0 140'));
	nehjet ();
	nehjet ();
};
void () n_die15 = [ 86, n_die16 ]
{
	nehjet ();
	nehjet ();
};
void () n_die16 = [ 87, n_die17 ]
{
	nehjet ();
};
void () n_die17 = [ 83, n_die18 ]
{
	lavasplash (self.origin);
	nehjet ();
	nehjet ();
};
void () n_die18 = [ 84, n_die19 ]
{
	nehjet ();
	nehjet ();
};
void () n_die19 = [ 85, n_die20 ]
{
	lavasplash (self.origin);
	nehjet ();
	nehjet ();
};
void () n_die20 = [ 86, n_die21 ]
{
	lavasplash (self.origin);
	nehjet ();
	nehjet ();
};
void () n_die21 = [ 87, n_die22 ]
{
	lavasplash ((self.origin + '0 0 150'));
	nehjet ();
	nehjet ();
};
void () n_die22 = [ 88, n_die23 ]
{
	nehjet ();
	nehjet ();
};
void () n_die23 = [ 89, n_die24 ]
{
	lavasplash ((self.origin + '0 0 50'));
	nehjet ();
	nehjet ();
};
void () n_die24 = [ 88, n_die25 ]
{
	nehjet ();
	nehjet ();
};
void () n_die25 = [ 87, n_die26 ]
{
	lavasplash ((self.origin + '0 0 50'));
	nehjet ();
	nehjet ();
};
void () n_die26 = [ 86, n_die27 ]
{
	lavasplash ((self.origin + '0 0 150'));
	nehjet ();
	nehjet ();
};
void () n_die27 =
{
	self.cnt = (self.cnt + 1);
	if ((self.cnt < 5))
	{
		if ((self.cnt == 3))
		{
			sound (self, CHAN_ITEM, "boss3/nehdie1.wav", 1, ATTN_NONE);
		}
		parse_anim ( 85, n_die2 );
		nehjet ();
		nehjet ();
		nehjet ();
	}
	else
	{
		parse_anim ( 85, n_die28 );
		ambientsound (self.origin, "ambience/sphum.wav", 1, ATTN_STATIC);
		self.flags = (self.flags - FL_ONGROUND);
		self.velocity_z = 800;
		sound (self, CHAN_ITEM, "boss3/nehdie3.wav", 1, ATTN_NONE);
		ThrowGibstorm ("progs/gstorm.mdl", self.health);
		ThrowGibstorm ("progs/gstorm.mdl", self.health);
		ThrowGibstorm ("progs/gstorm.mdl", self.health);
		ThrowGibstorm ("progs/gstorm.mdl", self.health);
		ThrowGibstorm ("progs/gstorm.mdl", self.health);
	}
};
void () n_die28 = [ 90, n_die29 ]
{
	if ((world.model == "maps/nehahra.bsp"))
	{
		nehahra_setupfinale ();
		drop_nehahra_finale_sensor ();
	}
	lavasplash ((self.origin + '0 0 150'));
	lavasplash (self.origin);
	ThrowGibstorm ("progs/gstorm.mdl", self.health);
	ThrowGibstorm ("progs/gstorm.mdl", self.health);
	ThrowGibstorm ("progs/gstorm.mdl", self.health);
	ThrowGibstorm ("progs/gstorm.mdl", self.health);
	ThrowGibstorm ("progs/gstorm.mdl", self.health);
	ThrowGibstorm ("progs/gstorm.mdl", self.health);
};
void () n_die29 = [ 91, n_die30 ]
{
	lavasplash ((self.origin + '0 0 150'));
	sound (self, CHAN_AUTO, "boss3/nehdie4.wav", 1, ATTN_NONE);
	lavasplash (self.origin);
	ThrowGibstorm ("progs/gstorm.mdl", self.health);
	ThrowGibstorm ("progs/gstorm.mdl", self.health);
	ThrowGibstorm ("progs/gstorm.mdl", self.health);
};
void () n_die30 = [ 92, n_die31 ]
{
	ThrowGibstorm ("progs/gstorm.mdl", self.health);
	ThrowGibstorm ("progs/gstorm.mdl", self.health);
	ThrowGibstorm ("progs/gstorm.mdl", self.health);
	ThrowGibstorm ("progs/gstorm.mdl", self.health);
	ThrowGibstorm ("progs/gstorm.mdl", self.health);
	ThrowGibstorm ("progs/gstorm.mdl", self.health);
	lavasplash ((self.origin + '0 0 150'));
	lavasplash (self.origin);
};
void () n_die31 = [ 93, BecomeExplosion ]
{};
void (string gibname, float dm) ThrowGibstorm =
{
	local entity new;
	new = spawn ();
	new.origin = self.origin;
	setmodel (new, gibname);
	setsize (self, VEC_HULL_MIN, '16 16 40');
	new.velocity = VelocityForDamage (dm);
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.health = -120;
	new.avelocity_x = (random () * 600);
	new.avelocity_y = (random () * 600);
	new.avelocity_z = (random () * 600);
	new.touch = throwgibs;
	new.think = throwgibs;
	new.nextthink = (((time + 1) + random ()) + random ());
};
void () throwgibs =
{
	if ((pointcontents (self.origin) == CONTENT_SKY))
	{
		remove (self);
		return;
	}
	sound (self, CHAN_AUTO, "player/udeath.wav", 1, ATTN_NONE);
	ThrowGib ("progs/gib1.mdl", self.health);
	ThrowGib ("progs/gib2.mdl", self.health);
	ThrowGib ("progs/gib3.mdl", self.health);
	ThrowHead ("progs/gib2.mdl", self.health);
};
void () nehjet =
{
	nehahra_deathbeams ();
	nehahra_deathbeams ();
	nehahra_deathbeams ();
};
void () nehahra_deathbeams =
{
	local entity mark;
	local vector vec;
	sound (self, CHAN_AUTO, "sets/set2_4.wav", 1, ATTN_NONE);
	mark = spawn ();
	mark.solid = SOLID_NOT;
	mark.fullbright = 1;
	mark.alpha = 0.1;
	mark.movetype = MOVETYPE_NONE;
	mark.event = "nehahra_jetdeath";
	vec = self.origin;
	if ((random () < 0.4))
	{
		vec_x = vec_x + (random () * 20);
	}
	else
	{
		vec_x = vec_x - (random () * 20);
	}
	if ((random () < 0.4))
	{
		vec_y = vec_y - (random () * 20);
	}
	else
	{
		vec_y = vec_y + (random () * 20);
	}
	if ((random () < 0.4))
	{
		vec_z = (vec_z + 100) - (random () * 20);
	}
	else
	{
		vec_z = (vec_z + 100) + (random () * 20);
	}
	setorigin (mark, vec);
	setsize (mark, VEC_ORIGIN, VEC_ORIGIN);
	setmodel (mark, "progs/nehjet.mdl");
	mark.angles_x = (360 * random ());
	mark.angles_y = (360 * random ());
	mark.angles_z = (360 * random ());
	mark.effects = (mark.effects | EF_DIMLIGHT);
	mark.think = SUB_Remove;
	mark.nextthink = (time + 0.1);
};
//END 