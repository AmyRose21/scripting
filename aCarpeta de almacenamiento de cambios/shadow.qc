// Created by Crowbar 0.74

$modelname "Noodles\OM\Shadow.mdl"

$bodygroup "Body"
{
	studio "ShadowBody.smd"
}
$bodygroup "gun"
{
	studio "ShadowGun.smd"
	blank
}


$surfaceprop "default"

$contents "solid"

$illumposition -0.026 0.438 26.808

$mostlyopaque

$cdmaterials "models\Noodles\OM\Shadow\"
$cdmaterials "models\Noodles\OM\sonic\"

$cbox 0 0 0 0 0 0

$bbox -40.074 -5.473 -0.195 39.198 5.422 53.812

$definebone "Root" "" 0 0 0 0 0 90.61528 0 0 0 0 0 0
$definebone "Torso" "Root" 0 21.659496 -2.036029 0 0 2.356117 0 0 0 0 0 0
$definebone "Head" "Torso" 0 9.106871 0 0 0 0.041368 0 0 0 0 0 0
$definebone "RightEye" "Head" -2.629473 7.144588 8.348132 0 0 11.79829 0 0 0 0 0 0
$definebone "MiddleTopHeadQuil" "Head" 0 16.972546 -1.336478 0 0 -68.945835 0 0 0 0 0 0
$definebone "MiddleBottomHeadQuil" "Head" 0 12.509521 -4.174327 0 0 -102.806218 0 0 0 0 0 0
$definebone "RightBottomHeadQuill" "Head" -5.728133 5.456779 -3.448578 30.219287 -2.593609 -95.142793 0 0 0 0 0 0
$definebone "RightTopHeadQuill" "Head" -4.673557 13.067787 -3.671886 29.625413 8.153247 -73.837077 0 0 0 0 0 0
$definebone "LeftEye" "Head" 2.629479 7.144588 8.348132 0 0 11.79829 0 0 0 0 0 0
$definebone "LeftBottomHeadQuill" "Head" 5.728133 5.456779 -3.448578 -30.219287 2.593609 -95.142793 0 0 0 0 0 0
$definebone "LeftTopHeadQuill" "Head" 4.673557 13.067787 -3.671886 -29.625355 -8.15319 -73.837077 0 0 0 0 0 0
$definebone "Tail" "Torso" 0 0.123236 -0.42002 0 0 -77.003409 0 0 0 0 0 0
$definebone "RightUpperLeg" "Torso" -2.263986 0.820528 -0.571953 0 0 173.08672 0 0 0 0 0 0
$definebone "RightLowerLeg" "RightUpperLeg" 0 4.690546 0 0 0 7.473718 0 0 0 0 0 0
$definebone "RightFoot" "RightLowerLeg" 0 10.21813 0 0 0.000057 -73.161551 0 0 0 0 0 0
$definebone "RightToe" "RightFoot" 0 10.034348 0 -0.000057 0.000057 -30.747435 0 0 0 0 0 0
$definebone "RightUpperArm" "Torso" -2.970968 8.337708 -0.712925 2.971416 89.999982 0 0 0 0 0 0 0
$definebone "RightLowerArm" "RightUpperArm" 0 4.547826 0 0 0 0 0 0 0 0 0 0
$definebone "RightHand" "RightLowerArm" 0 6.643495 0 0 0 0 0 0 0 0 0 0
$definebone "RightMiddleFinger1" "RightHand" 0 5.520761 0.313035 0 0 0 0 0 0 0 0 0
$definebone "RightMiddleFinger2" "RightMiddleFinger1" -0.000002 2.553585 0 0 0 0 0 0 0 0 0 0
$definebone "RightPinkyFinger1" "RightHand" 0.000002 5.32156 -1.223674 0 0 0 0 0 0 0 0 0
$definebone "RightPinkyFinger2" "RightPinkyFinger1" 0 2.553585 0 0 0 0 0 0 0 0 0 0
$definebone "RightPointyFinger1" "RightHand" 0 5.32156 2.134314 0 0 0 0 0 0 0 0 0
$definebone "RightPointyFinger2" "RightPointyFinger1" -0.000002 2.553585 0 0 0 0 0 0 0 0 0 0
$definebone "RightThumb1" "RightHand" 0 1.677047 1.291186 -8.866121 1.433655 80.626907 0 0 0 0 0 0
$definebone "RightThumb2" "RightThumb1" 0.000002 2.812077 0 1.005426 21.04543 -2.074564 0 0 0 0 0 0
$definebone "LeftUpperLeg" "Torso" 2.263986 0.820528 -0.571953 0 0 173.08672 0 0 0 0 0 0
$definebone "LeftLowerLeg" "LeftUpperLeg" 0 4.690546 0 0 0 7.473718 0 0 0 0 0 0
$definebone "LeftFoot" "LeftLowerLeg" 0 10.21813 0 0 -0.000057 -73.161551 0 0 0 0 0 0
$definebone "LeftToe" "LeftFoot" 0 10.034348 0 0.000057 -0.000057 -30.747435 0 0 0 0 0 0
$definebone "LeftUpperArm" "Torso" 2.970968 8.337706 -0.71293 -2.971416 -89.999982 0 0 0 0 0 0 0
$definebone "LeftLowerArm" "LeftUpperArm" 0 4.547826 0 0 0 0 0 0 0 0 0 0
$definebone "LeftHand" "LeftLowerArm" 0 6.643495 0 0 0 0 0 0 0 0 0 0
$definebone "LeftMiddleFinger1" "LeftHand" 0 5.520761 0.313035 0 0 0 0 0 0 0 0 0
$definebone "LeftMiddleFinger2" "LeftMiddleFinger1" 0.000002 2.553585 0 0 0 0 0 0 0 0 0 0
$definebone "LeftPinkyFinger1" "LeftHand" -0.000002 5.32156 -1.223674 0 0 0 0 0 0 0 0 0
$definebone "LeftPinkyFinger2" "LeftPinkyFinger1" 0 2.553585 0 0 0 0 0 0 0 0 0 0
$definebone "LeftPointyFinger1" "LeftHand" 0 5.32156 2.134314 0 0 0 0 0 0 0 0 0
$definebone "LeftPointyFinger2" "LeftPointyFinger1" 0.000002 2.553585 0 0 0 0 0 0 0 0 0 0
$definebone "LeftThumb1" "LeftHand" 0 1.677047 1.291186 8.866121 -1.433655 80.626907 0 0 0 0 0 0
$definebone "LeftThumb2" "LeftThumb1" -0.000002 2.812072 0.000001 -1.005426 -21.04543 -2.074507 0 0 0 0 0 0
$definebone "Gun" "RightHand" -2.366728 3.30341 4.679157 0 0 0 0 0 0 0 0 0


$sectionframes 30 160

$poseparameter "aim_yaw" -90 90 loop 0
$poseparameter "aim_pitch" -90 90 loop 0

$weightlist "weights_swingdeltatosequence1" {
	 "Root" 0
	 "Torso" 1
	 "Head" 1
	 "RightEye" 1
	 "MiddleTopHeadQuil" 1
	 "MiddleBottomHeadQuil" 1
	 "RightBottomHeadQuill" 1
	 "RightTopHeadQuill" 1
	 "LeftEye" 1
	 "LeftBottomHeadQuill" 1
	 "LeftTopHeadQuill" 1
	 "Tail" 1
	 "RightUpperLeg" 1
	 "RightLowerLeg" 1
	 "RightFoot" 1
	 "RightToe" 1
	 "RightUpperArm" 0
	 "RightLowerArm" 0
	 "RightHand" 0
	 "RightMiddleFinger1" 0
	 "RightMiddleFinger2" 0
	 "RightPinkyFinger1" 0
	 "RightPinkyFinger2" 0
	 "RightPointyFinger1" 0
	 "RightPointyFinger2" 0
	 "RightThumb1" 0
	 "RightThumb2" 0
	 "LeftUpperLeg" 1
	 "LeftLowerLeg" 1
	 "LeftFoot" 1
	 "LeftToe" 1
	 "LeftUpperArm" 0
	 "LeftLowerArm" 0
	 "LeftHand" 0
	 "LeftMiddleFinger1" 0
	 "LeftMiddleFinger2" 0
	 "LeftPinkyFinger1" 0
	 "LeftPinkyFinger2" 0
	 "LeftPointyFinger1" 0
	 "LeftPointyFinger2" 0
	 "LeftThumb1" 0
	 "LeftThumb2" 0
	 "Gun" 0
}

$weightlist "weights_Shoot_layer" {
	 "Root" 0
	 "Torso" 0
	 "Head" 0
	 "RightEye" 0
	 "MiddleTopHeadQuil" 0
	 "MiddleBottomHeadQuil" 0
	 "RightBottomHeadQuill" 0
	 "RightTopHeadQuill" 0
	 "LeftEye" 0
	 "LeftBottomHeadQuill" 0
	 "LeftTopHeadQuill" 0
	 "Tail" 0
	 "RightUpperLeg" 0
	 "RightLowerLeg" 0
	 "RightFoot" 0
	 "RightToe" 0
	 "RightUpperArm" 1
	 "RightLowerArm" 1
	 "RightHand" 1
	 "RightMiddleFinger1" 1
	 "RightMiddleFinger2" 1
	 "RightPinkyFinger1" 1
	 "RightPinkyFinger2" 1
	 "RightPointyFinger1" 1
	 "RightPointyFinger2" 1
	 "RightThumb1" 1
	 "RightThumb2" 1
	 "LeftUpperLeg" 0
	 "LeftLowerLeg" 0
	 "LeftFoot" 0
	 "LeftToe" 0
	 "LeftUpperArm" 1
	 "LeftLowerArm" 1
	 "LeftHand" 1
	 "LeftMiddleFinger1" 1
	 "LeftMiddleFinger2" 1
	 "LeftPinkyFinger1" 1
	 "LeftPinkyFinger2" 1
	 "LeftPointyFinger1" 1
	 "LeftPointyFinger2" 1
	 "LeftThumb1" 1
	 "LeftThumb2" 1
	 "Gun" 1
}

$animation "LookR_corrective_animation" "shadow_anims\LookR_corrective_animation.smd" {
}

$animation "LookC_corrective_animation" "shadow_anims\LookC_corrective_animation.smd" {
}

$animation "LookL_corrective_animation" "shadow_anims\LookL_corrective_animation.smd" {
}

$animation "LookU_corrective_animation" "shadow_anims\LookU_corrective_animation.smd" {
}

$animation "LookD_corrective_animation" "shadow_anims\LookD_corrective_animation.smd" {
}

$animation "swingdelta1_corrective_animation" "shadow_anims\swingdelta1_corrective_animation.smd" {
}

$animation "LookU" "shadow_anims\LookU.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookU_corrective_animation" 0
}

$animation "LookD" "shadow_anims\LookD.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookD_corrective_animation" 0
}

$animation "LookC" "shadow_anims\LookC.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookC_corrective_animation" 0
}

$animation "LookR" "shadow_anims\LookR.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookR_corrective_animation" 0
}

$animation "LookL" "shadow_anims\LookL.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookL_corrective_animation" 0
}

$animation "swingdelta1" "shadow_anims\swingdelta1.smd" {
	fps 60
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "swingdelta1_corrective_animation" 0
	weightlist "weights_swingdeltatosequence1"
}

$sequence "ref" {
	"shadow_anims\ref.smd"
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

$sequence "dash" {
	"shadow_anims\dash.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "kick" {
	"shadow_anims\kick.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
}

$sequence "Idle" {
	"shadow_anims\Idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "Walk" {
	"shadow_anims\Walk.smd"
	{ event 1100 20 "Step" }
	{ event 1100 100 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "ShootIdle_layer" {
	"shadow_anims\ShootIdle_layer.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "walkGun" {
	"shadow_anims\walkGun.smd"
	{ event 1100 20 "Step" }
	{ event 1100 100 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "Run" {
	"shadow_anims\Run.smd"
	{ event 1100 15 "RStep" }
	{ event 1100 65 "RStep" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "Run Gunless" {
	"shadow_anims\Run Gunless.smd"
	{ event 1100 15 "RStep" }
	{ event 1100 65 "RStep" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "Fall" {
	"shadow_anims\Fall.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "jump" {
	"shadow_anims\jump.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
}

$sequence "rolling" {
	"shadow_anims\rolling.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
}

$sequence "swingdeltatosequence1" {
	"swingdelta1"
	delta
	fadein 0.2
	fadeout 0.2
}

$sequence "Shoot_layer" {
	"shadow_anims\Shoot_layer.smd"
	activity "ACT_GESTURE_MELEE_ATTACK1" 1
	{ event 1100 8 "Attack" }
	fadein 0.2
	fadeout 0.2
	addlayer "swingdeltatosequence1"
	fps 60
	weightlist "weights_Shoot_layer"
}

$sequence "idle_lowhealth" {
	"shadow_anims\idle_lowhealth.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "walk_lowhealth" {
	"shadow_anims\walk_lowhealth.smd"
	{ event 1100 20 "Step" }
	{ event 1100 100 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "run_lowhealth" {
	"shadow_anims\run_lowhealth.smd"
	{ event 1100 15 "RStep" }
	{ event 1100 65 "RStep" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "DownedIdle" {
	"shadow_anims\DownedIdle.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "DownedWalk" {
	"shadow_anims\DownedWalk.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
	loop
}

$collisionjoints "shadow_physics.smd"
{
	$mass 70
	$inertia 10
	$damping 0.2
	$rotdamping 0.1
	$rootbone "Root"
	$concaveperjoint


	$jointconstrain "LeftUpperArm" x limit -70 70 0
	$jointconstrain "LeftUpperArm" y limit -70 70 0
	$jointconstrain "LeftUpperArm" z limit -70 70 0

	$jointconstrain "LeftLowerArm" x limit -70 70 0
	$jointconstrain "LeftLowerArm" y limit -70 70 0
	$jointconstrain "LeftLowerArm" z limit -70 70 0

	$jointconstrain "LeftUpperLeg" x limit -70 70 0
	$jointconstrain "LeftUpperLeg" y limit -70 70 0
	$jointconstrain "LeftUpperLeg" z limit -70 70 0

	$jointconstrain "LeftLowerLeg" x limit -70 70 0
	$jointconstrain "LeftLowerLeg" y limit -70 70 0
	$jointconstrain "LeftLowerLeg" z limit -70 70 0

	$jointconstrain "LeftFoot" x limit -70 70 0
	$jointconstrain "LeftFoot" y limit -70 70 0
	$jointconstrain "LeftFoot" z limit -70 70 0

	$jointconstrain "RightUpperArm" x limit -70 70 0
	$jointconstrain "RightUpperArm" y limit -70 70 0
	$jointconstrain "RightUpperArm" z limit -70 70 0

	$jointconstrain "RightLowerArm" x limit -70 70 0
	$jointconstrain "RightLowerArm" y limit -70 70 0
	$jointconstrain "RightLowerArm" z limit -70 70 0

	$jointconstrain "RightHand" x limit -70 70 0
	$jointconstrain "RightHand" y limit -70 70 0
	$jointconstrain "RightHand" z limit -70 70 0

	$jointconstrain "RightUpperLeg" x limit -70 70 0
	$jointconstrain "RightUpperLeg" y limit -70 70 0
	$jointconstrain "RightUpperLeg" z limit -70 70 0

	$jointconstrain "RightLowerLeg" x limit -70 70 0
	$jointconstrain "RightLowerLeg" y limit -70 70 0
	$jointconstrain "RightLowerLeg" z limit -70 70 0

	$jointconstrain "RightFoot" x limit -70 70 0
	$jointconstrain "RightFoot" y limit -70 70 0
	$jointconstrain "RightFoot" z limit -70 70 0

	$jointconstrain "Head" x limit -70 70 0
	$jointconstrain "Head" y limit -70 70 0
	$jointconstrain "Head" z limit -70 70 0

	$jointconstrain "LeftHand" x limit -70 70 0
	$jointconstrain "LeftHand" y limit -70 70 0
	$jointconstrain "LeftHand" z limit -70 70 0
}
