// Created by Crowbar 0.74

$modelname "Noodles\OM\Knuckles.mdl"

$bodygroup "Body"
{
	studio "Knuckles_body.smd"
}


$surfaceprop "default"

$contents "solid"

$illumposition -0.026 0.438 26.808

$mostlyopaque

$cdmaterials "models\Noodles\OM\Knuckles\"

$cbox 0 0 0 0 0 0

$bbox -40.074 -5.473 -0.195 39.198 5.422 53.812

$definebone "Root" "" 0 0 0 0 -179.999978 89.999982 0 0 0 0 0 0
$definebone "LowerTorso" "Root" 0 18.048264 -0.202368 0 0 -24.885048 0 0 0 0 0 0
$definebone "UpperTorso" "LowerTorso" 0 5.025232 0 0 0 32.419729 0 0 0 0 0 0
$definebone "Head" "UpperTorso" 0 10.105186 -0.551176 0 0 -7.809529 0 0 0 0 0 0
$definebone "RightEye" "Head" 2.292384 5.468506 -8.169762 0.000019 180.000005 179.725213 0 0 0 0 0 0
$definebone "LeftEye" "Head" -2.292392 5.468506 -8.169762 0.000019 180.000005 179.725213 0 0 0 0 0 0
$definebone "RightUpperArm" "UpperTorso" 3.130696 9.049801 0.4754 -7.534739 -89.999982 0 0 0 0 0 0 0
$definebone "RightLowerArm" "RightUpperArm" 0 4.220712 0 0 0 0 0 0 0 0 0 0
$definebone "RightHand" "RightLowerArm" 0 5.326631 0 0 9.078746 0 0 0 0 0 0 0
$definebone "RightKnuckle" "RightHand" 0 8.579609 0 0 -20.741131 0 0 0 0 0 0 0
$definebone "RightThumb1" "RightHand" 0.0352 3.037758 -2.274512 1.181153 80.633498 -108.231902 0 0 0 0 0 0
$definebone "RightThumb2" "RightThumb1" 0 3.640191 -0.000002 3.20289 -19.523708 9.609705 0 0 0 0 0 0
$definebone "LeftUpperArm" "UpperTorso" -3.130696 9.049801 0.4754 7.534739 89.999982 0 0 0 0 0 0 0
$definebone "LeftLowerArm" "LeftUpperArm" 0 4.220712 0 0 0 0 0 0 0 0 0 0
$definebone "LeftHand" "LeftLowerArm" 0 5.326632 0 0 -9.078746 0 0 0 0 0 0 0
$definebone "LeftKnuckle" "LeftHand" 0 8.579607 0 0 20.741131 0 0 0 0 0 0 0
$definebone "LeftThumb1" "LeftHand" -0.0352 3.03776 -2.274512 -1.181153 -80.633498 -108.231902 0 0 0 0 0 0
$definebone "LeftThumb2" "LeftThumb1" 0 3.640192 -0.000002 -3.202889 19.523705 9.609707 0 0 0 0 0 0
$definebone "Tail" "LowerTorso" 0 0.457079 3.009945 0 0 116.304133 0 0 0 0 0 0
$definebone "RightUpperLeg" "LowerTorso" 1.790128 0.059198 0.054904 0 0 -147.454987 0 0 0 0 0 0
$definebone "RightLowerLeg" "RightUpperLeg" 0 4.334392 0 0 0 -13.644991 0 0 0 0 0 0
$definebone "RightFoot" "RightLowerLeg" 0 4.749272 0 0 -0.000057 62.114983 0 0 0 0 0 0
$definebone "LeftUpperLeg" "LowerTorso" -1.790128 0.059198 0.054904 0 0 -147.454987 0 0 0 0 0 0
$definebone "LeftLowerLeg" "LeftUpperLeg" 0 4.334392 0 0 0 -13.644991 0 0 0 0 0 0
$definebone "LeftFoot" "LeftLowerLeg" 0 4.749272 0 0 0.000057 62.114983 0 0 0 0 0 0


$sectionframes 30 120

$poseparameter "aim_yaw" -90 90 loop 0
$poseparameter "aim_pitch" -90 90 loop 0

$weightlist "weights_swingdeltatosequence" {
	 "Root" 1
	 "LowerTorso" 1
	 "UpperTorso" 1
	 "Head" 1
	 "RightEye" 1
	 "LeftEye" 1
	 "RightUpperArm" 0
	 "RightLowerArm" 0
	 "RightHand" 0
	 "RightKnuckle" 0
	 "RightThumb1" 0
	 "RightThumb2" 0
	 "LeftUpperArm" 0
	 "LeftLowerArm" 0
	 "LeftHand" 0
	 "LeftKnuckle" 0
	 "LeftThumb1" 0
	 "LeftThumb2" 0
	 "Tail" 1
	 "RightUpperLeg" 1
	 "RightLowerLeg" 1
	 "RightFoot" 1
	 "LeftUpperLeg" 1
	 "LeftLowerLeg" 1
	 "LeftFoot" 1
}

$weightlist "weights_counter" {
	 "Root" 0
	 "LowerTorso" 0
	 "UpperTorso" 0
	 "Head" 0
	 "RightEye" 0
	 "LeftEye" 0
	 "RightUpperArm" 1
	 "RightLowerArm" 1
	 "RightHand" 1
	 "RightKnuckle" 1
	 "RightThumb1" 1
	 "RightThumb2" 1
	 "LeftUpperArm" 1
	 "LeftLowerArm" 1
	 "LeftHand" 1
	 "LeftKnuckle" 1
	 "LeftThumb1" 1
	 "LeftThumb2" 1
	 "Tail" 0
	 "RightUpperLeg" 0
	 "RightLowerLeg" 0
	 "RightFoot" 0
	 "LeftUpperLeg" 0
	 "LeftLowerLeg" 0
	 "LeftFoot" 0
}

$animation "LookR_corrective_animation" "knuckles_anims\LookR_corrective_animation.smd" {
}

$animation "LookC_corrective_animation" "knuckles_anims\LookC_corrective_animation.smd" {
}

$animation "LookL_corrective_animation" "knuckles_anims\LookL_corrective_animation.smd" {
}

$animation "LookU_corrective_animation" "knuckles_anims\LookU_corrective_animation.smd" {
}

$animation "LookD_corrective_animation" "knuckles_anims\LookD_corrective_animation.smd" {
}

$animation "counterdelta_corrective_animation" "knuckles_anims\counterdelta_corrective_animation.smd" {
}

$animation "counterdelta2_corrective_animation" "knuckles_anims\counterdelta2_corrective_animation.smd" {
}

$animation "LookU" "knuckles_anims\LookU.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookU_corrective_animation" 0
}

$animation "LookD" "knuckles_anims\LookD.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookD_corrective_animation" 0
}

$animation "LookC" "knuckles_anims\LookC.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookC_corrective_animation" 0
}

$animation "LookR" "knuckles_anims\LookR.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookR_corrective_animation" 0
}

$animation "LookL" "knuckles_anims\LookL.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookL_corrective_animation" 0
}

$animation "counterdelta" "knuckles_anims\counterdelta.smd" {
	fps 60
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "counterdelta_corrective_animation" 0
	weightlist "weights_swingdeltatosequence"
}

$animation "counterdelta2" "knuckles_anims\counterdelta2.smd" {
	fps 60
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "counterdelta2_corrective_animation" 0
	weightlist "weights_swingdeltatosequence"
}

$sequence "ref" {
	"knuckles_anims\ref.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "aim_yaw" {
	"LookR"
	"LookC"
	"LookL"
	autoplay
	blend "aim_yaw" -90 90
	blendwidth 3
	delta
	fadein 0.2
	fadeout 0.2
}

$sequence "aim_pitch" {
	"LookU"
	"LookC"
	"LookD"
	autoplay
	blend "aim_pitch" -90 90
	blendwidth 3
	delta
	fadein 0.2
	fadeout 0.2
}

$sequence "idle" {
	"knuckles_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "walk" {
	"knuckles_anims\walk.smd"
	{ event 1100 14 "Step" }
	{ event 1100 54 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "run" {
	"knuckles_anims\run.smd"
	{ event 1100 9 "Step" }
	{ event 1100 29 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "idle_LowHealth" {
	"knuckles_anims\idle_LowHealth.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "walk_LowHealth" {
	"knuckles_anims\walk_LowHealth.smd"
	{ event 1100 13 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "run_LowHealth" {
	"knuckles_anims\run_LowHealth.smd"
	{ event 1100 9 "Step" }
	{ event 1100 29 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "AttackIdle" {
	"knuckles_anims\AttackIdle.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "attackwalk" {
	"knuckles_anims\attackwalk.smd"
	{ event 1100 14 "Step" }
	{ event 1100 54 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "attack" {
	"knuckles_anims\attack.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
}

$sequence "PunchAnim" {
	"knuckles_anims\PunchAnim.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
}

$sequence "Jump" {
	"knuckles_anims\Jump.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
}

$sequence "fall" {
	"knuckles_anims\fall.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "FallAttack" {
	"knuckles_anims\FallAttack.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
	loop
}

$sequence "Undisolve" {
	"knuckles_anims\Undisolve.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "latch" {
	"knuckles_anims\latch.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "LatchOff" {
	"knuckles_anims\LatchOff.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
}

$sequence "glide" {
	"knuckles_anims\glide.smd"
	fadein 0.7
	fadeout 0.7
	fps 30
	loop
}

$sequence "swingdeltatosequence" {
	"counterdelta"
	delta
	fadein 0.2
	fadeout 0.2
}

$sequence "counter" {
	"knuckles_anims\counter.smd"
	activity "ACT_GESTURE_RANGE_ATTACK1_LOW" 1
	fadein 0.2
	fadeout 0.2
	addlayer "swingdeltatosequence"
	fps 60
	weightlist "weights_counter"
}

$sequence "swingdeltatosequence2" {
	"counterdelta2"
	delta
	fadein 0.2
	fadeout 0.2
}

$sequence "counter_hit" {
	"knuckles_anims\counter_hit.smd"
	activity "ACT_GESTURE_RANGE_ATTACK2_LOW" 1
	fadein 0.2
	fadeout 0.2
	addlayer "swingdeltatosequence2"
	fps 60
	weightlist "weights_counter"
}

$sequence "roll" {
	"knuckles_anims\roll.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
}

$sequence "DownedIdle" {
	"knuckles_anims\DownedIdle.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "DownedWalk" {
	"knuckles_anims\DownedWalk.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
	loop
}

$sequence "GroundSmash" {
	"knuckles_anims\GroundSmash.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
}

$collisionjoints "knuckles_physics.smd"
{
	$mass 70
	$inertia 10
	$damping 0.2
	$rotdamping 0.1
	$rootbone "Root"
	$concaveperjoint


	$jointconstrain "LeftUpperLeg" x limit -80 80 0
	$jointconstrain "LeftUpperLeg" y limit -80 80 0
	$jointconstrain "LeftUpperLeg" z limit -80 80 0

	$jointconstrain "LeftLowerLeg" x limit -80 80 0
	$jointconstrain "LeftLowerLeg" y limit -80 80 0
	$jointconstrain "LeftLowerLeg" z limit -80 80 0

	$jointconstrain "RightUpperLeg" x limit -80 80 0
	$jointconstrain "RightUpperLeg" y limit -80 80 0
	$jointconstrain "RightUpperLeg" z limit -80 80 0

	$jointconstrain "RightLowerLeg" x limit -80 80 0
	$jointconstrain "RightLowerLeg" y limit -80 80 0
	$jointconstrain "RightLowerLeg" z limit -80 80 0

	$jointconstrain "RightFoot" x limit -80 80 0
	$jointconstrain "RightFoot" y limit -80 80 0
	$jointconstrain "RightFoot" z limit -80 80 0

	$jointconstrain "UpperTorso" x limit -80 80 0
	$jointconstrain "UpperTorso" y limit -80 80 0
	$jointconstrain "UpperTorso" z limit -80 80 0

	$jointconstrain "LeftUpperArm" x limit -80 80 0
	$jointconstrain "LeftUpperArm" y limit -80 80 0
	$jointconstrain "LeftUpperArm" z limit -80 80 0

	$jointconstrain "LeftLowerArm" x limit -80 80 0
	$jointconstrain "LeftLowerArm" y limit -80 80 0
	$jointconstrain "LeftLowerArm" z limit -80 80 0

	$jointconstrain "RightUpperArm" x limit -80 80 0
	$jointconstrain "RightUpperArm" y limit -80 80 0
	$jointconstrain "RightUpperArm" z limit -80 80 0

	$jointconstrain "RightLowerArm" x limit -80 80 0
	$jointconstrain "RightLowerArm" y limit -80 80 0
	$jointconstrain "RightLowerArm" z limit -80 80 0

	$jointconstrain "RightHand" x limit -80 80 0
	$jointconstrain "RightHand" y limit -80 80 0
	$jointconstrain "RightHand" z limit -80 80 0

	$jointconstrain "Head" x limit -80 80 0
	$jointconstrain "Head" y limit -80 80 0
	$jointconstrain "Head" z limit -80 80 0

	$jointconstrain "LeftHand" x limit -80 80 0
	$jointconstrain "LeftHand" y limit -80 80 0
	$jointconstrain "LeftHand" z limit -80 80 0

	$jointconstrain "LeftFoot" x limit -80 80 0
	$jointconstrain "LeftFoot" y limit -80 80 0
	$jointconstrain "LeftFoot" z limit -80 80 0
}
