// Created by Crowbar 0.74

$modelname "Noodles\OM\Sonic.mdl"

$bodygroup "Body"
{
	studio "SonicBody.smd"
}


$surfaceprop "default"

$contents "solid"

$illumposition -0.026 0.438 26.808

$mostlyopaque

$cdmaterials "models\Noodles\OM\Sonic\"
$cdmaterials "models\Noodles\OM\shared\"

$attachment "Trail" "Trail" 0 0 0 rotate 90 90 0
$attachment "LeftFootTrail" "LeftFootTrail" 0 0 0 rotate 90 90 0
$attachment "RightFootTrail" "RightFootTrail" 0 0 0 rotate 90 90 0

$cbox 0 0 0 0 0 0

$bbox -40.074 -5.473 -0.195 39.198 5.422 53.812

$definebone "Trail" "" 0 0 19.081257 0 0 89.999982 0 0 0 0 0 0
$definebone "Root" "" 0 0 0 0 0 89.999982 0 0 0 0 0 0
$definebone "Torso" "Root" 0 19.315357 -0.154523 0 0 0 0 0 0 0 0 0
$definebone "LeftUpperLeg" "Torso" 2.317837 0.085487 0.074516 85.927741 -89.999921 90.000153 0 0 0 0 0 0
$definebone "LeftLowerLeg" "LeftUpperLeg" 0 4.487018 0 0 -3.966873 0 0 0 0 0 0 0
$definebone "LeftFoot" "LeftLowerLeg" 0 8.949699 0 0 63.447225 0 0 0 0 0 0 0
$definebone "LeftUpperArm" "Torso" 3.81083 10.241421 0.154523 0 -89.999982 -0.490108 0 0 0 0 0 0
$definebone "LeftLowerArm" "LeftUpperArm" -0.000004 5.226873 0 0.031627 -3.696034 1.50453 0 0 0 0 0 0
$definebone "LeftHand" "LeftLowerArm" -0.000004 8.363291 0 5.772836 9.215512 -1.007145 0 0 0 0 0 0
$definebone "LeftMiddleFinger1" "LeftHand" 0 6.055754 0 -5.38735 -16.583179 1.59861 0 0 0 0 0 0
$definebone "LeftMiddleFinger2" "LeftMiddleFinger1" 0 2.568302 0 -0.000114 -10.069112 -0.001719 0 0 0 0 0 0
$definebone "LeftPinkyFinger1" "LeftHand" 0.126558 5.720999 -1.62552 -5.38735 -16.583179 1.59861 0 0 0 0 0 0
$definebone "LeftPinkyFinger2" "LeftPinkyFinger1" 0 2.5683 0 -0.000114 -10.069112 -0.001719 0 0 0 0 0 0
$definebone "LeftPointyFinger1" "LeftHand" -0.22748 5.592247 1.849598 -5.38735 -16.583179 1.59861 0 0 0 0 0 0
$definebone "LeftPointyFinger2" "LeftPointyFinger1" 0 2.5683 0 -0.000114 -10.069112 -0.001719 0 0 0 0 0 0
$definebone "LeftThumb1" "LeftHand" 0.125738 2.281605 1.016454 1.161099 -5.869611 85.733163 0 0 0 0 0 0
$definebone "LeftThumb2" "LeftThumb1" -0.000002 2.674256 -0.000004 0.76902 -24.019134 -8.124252 0 0 0 0 0 0
$definebone "Head" "Torso" 0 11.7502 -0.006438 0 0 0 0 0 0 0 0 0
$definebone "RightEye" "Head" -2.189564 6.623884 8.068788 0.000057 -0.000115 110.000046 0 0 0 0 0 0
$definebone "LeftEye" "Head" 2.189564 6.623884 8.068788 -0.000057 0.000115 110.000046 0 0 0 0 0 0
$definebone "RightEar" "Head" -6.783088 16.331255 3.429961 -29.450205 14.682101 10.744506 0 0 0 0 0 0
$definebone "LeftEar" "Head" 6.783088 16.331255 3.429961 29.450205 -14.682101 10.744506 0 0 0 0 0 0
$definebone "TopQuill" "Head" 0 16.20347 -0.310378 0 0 -68.612153 0 0 0 0 0 0
$definebone "RightTopQuill" "Head" -4.883153 12.745573 -2.286824 28.597126 -4.040556 -90.623305 0 0 0 0 0 0
$definebone "RightBottomQuill" "Head" -3.493599 7.038279 -4.464949 30.136492 -14.72387 -126.180833 0 0 0 0 0 0
$definebone "LeftTopQuill" "Head" 4.883153 12.745573 -2.286824 -28.597126 4.040556 -90.623305 0 0 0 0 0 0
$definebone "LeftBottomQuill" "Head" 3.493599 7.038279 -4.464949 -30.136492 14.72387 -126.180833 0 0 0 0 0 0
$definebone "MiddleQuill" "Head" 0 10.45262 -7.340299 0 0 -104.759898 0 0 0 0 0 0
$definebone "LeftTorsoQuill" "Torso" 3.024996 9.632793 -3.187715 -24.985544 0.414363 -111.131583 0 0 0 0 0 0
$definebone "RightTorsoQuill" "Torso" -3.024996 9.632793 -3.187715 24.985544 -0.414363 -111.131583 0 0 0 0 0 0
$definebone "RightUpperLeg" "Torso" -2.317837 0.085487 0.074516 -85.927741 89.999982 90.000098 0 0 0 0 0 0
$definebone "RightLowerLeg" "RightUpperLeg" 0 4.487018 0 0 3.966873 0 0 0 0 0 0 0
$definebone "RightFoot" "RightLowerLeg" 0 8.949699 0 0 -63.447225 0 0 0 0 0 0 0
$definebone "RightUpperArm" "Torso" -3.81083 10.241421 0.154523 0 89.999982 -0.490108 0 0 0 0 0 0
$definebone "RightLowerArm" "RightUpperArm" 0.000004 5.226873 0 -0.031627 3.696034 1.50453 0 0 0 0 0 0
$definebone "RightHand" "RightLowerArm" 0.000004 8.363291 0 -5.772836 -9.215512 -1.007145 0 0 0 0 0 0
$definebone "RightMiddleFinger1" "RightHand" 0 6.055754 0 5.38735 16.583179 1.59861 0 0 0 0 0 0
$definebone "RightMiddleFinger2" "RightMiddleFinger1" 0 2.568302 0 0.000114 10.069112 -0.001719 0 0 0 0 0 0
$definebone "RightPinkyFinger1" "RightHand" -0.126558 5.720999 -1.62552 5.38735 16.583179 1.59861 0 0 0 0 0 0
$definebone "RightPinkyFinger2" "RightPinkyFinger1" 0 2.5683 0 0.000114 10.069112 -0.001719 0 0 0 0 0 0
$definebone "RightPointyFinger1" "RightHand" 0.22748 5.592247 1.849598 5.38735 16.583179 1.59861 0 0 0 0 0 0
$definebone "RightPointyFinger2" "RightPointyFinger1" 0 2.5683 0 0.000114 10.069112 -0.001719 0 0 0 0 0 0
$definebone "RightThumb1" "RightHand" -0.125738 2.281605 1.016454 -1.161099 5.869611 85.733163 0 0 0 0 0 0
$definebone "RightThumb2" "RightThumb1" 0.000002 2.674256 -0.000004 -0.76902 24.019134 -8.124252 0 0 0 0 0 0
$definebone "LeftFootTrail" "LeftFoot" 2.461732 0.168979 0 0 0 0 0 0 0 0 0 0
$definebone "RightFootTrail" "RightFoot" -2.461732 0.168979 0 0 0 0 0 0 0 0 0 0


$sectionframes 30 160

$poseparameter "aim_yaw" -90 90 loop 0
$poseparameter "aim_pitch" -90 90 loop 0

$weightlist "weights_attatchfix" {
	 "Trail" 1
	 "Root" 0
	 "Torso" 0
	 "LeftUpperLeg" 0
	 "LeftLowerLeg" 0
	 "LeftFoot" 0
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
	 "Head" 0
	 "RightEye" 0
	 "LeftEye" 0
	 "RightEar" 0
	 "LeftEar" 0
	 "TopQuill" 0
	 "RightTopQuill" 0
	 "RightBottomQuill" 0
	 "LeftTopQuill" 0
	 "LeftBottomQuill" 0
	 "MiddleQuill" 0
	 "LeftTorsoQuill" 0
	 "RightTorsoQuill" 0
	 "RightUpperLeg" 0
	 "RightLowerLeg" 0
	 "RightFoot" 0
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
	 "LeftFootTrail" 0
	 "RightFootTrail" 0
}

$animation "LookR_corrective_animation" "sonic_anims\LookR_corrective_animation.smd" {
}

$animation "LookC_corrective_animation" "sonic_anims\LookC_corrective_animation.smd" {
}

$animation "LookL_corrective_animation" "sonic_anims\LookL_corrective_animation.smd" {
}

$animation "LookU_corrective_animation" "sonic_anims\LookU_corrective_animation.smd" {
}

$animation "LookD_corrective_animation" "sonic_anims\LookD_corrective_animation.smd" {
}

$animation "LookR_corrective_animation" "sonic_anims\LookR_corrective_animation.smd" {
	fps 30
}

$animation "LookC_corrective_animation" "sonic_anims\LookC_corrective_animation.smd" {
	fps 30
}

$animation "LookL_corrective_animation" "sonic_anims\LookL_corrective_animation.smd" {
	fps 30
}

$animation "LookU_corrective_animation" "sonic_anims\LookU_corrective_animation.smd" {
	fps 30
}

$animation "LookD_corrective_animation" "sonic_anims\LookD_corrective_animation.smd" {
	fps 30
}

$animation "LookU" "sonic_anims\LookU.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookU_corrective_animation" 0
}

$animation "LookD" "sonic_anims\LookD.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookD_corrective_animation" 0
}

$animation "LookC" "sonic_anims\LookC.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookC_corrective_animation" 0
}

$animation "LookR" "sonic_anims\LookR.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookR_corrective_animation" 0
}

$animation "LookL" "sonic_anims\LookL.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookL_corrective_animation" 0
}

$sequence "ref" {
	"sonic_anims\ref.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "attatchfix" {
	"sonic_anims\attatchfix.smd"
	autoplay
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
	weightlist "weights_attatchfix"
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
	"sonic_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "walk" {
	"sonic_anims\walk.smd"
	{ event 1100 10 "Step" }
	{ event 1100 50 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "run" {
	"sonic_anims\run.smd"
	{ event 1100 8 "Step" }
	{ event 1100 28 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "idle_lowhealth" {
	"sonic_anims\idle_lowhealth.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "walk_lowhealth" {
	"sonic_anims\walk_lowhealth.smd"
	{ event 1100 10 "Step" }
	{ event 1100 50 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "run_lowhealth" {
	"sonic_anims\run_lowhealth.smd"
	{ event 1100 10 "Step" }
	{ event 1100 30 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "Spindash" {
	"sonic_anims\Spindash.smd"
	fadein 1
	fadeout 0.2
	fps 70
	loop
}

$sequence "PeelOut" {
	"sonic_anims\PeelOut.smd"
	{ event 1100 5 "Step" }
	{ event 1100 15 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "PeelOutStart" {
	"sonic_anims\PeelOutStart.smd"
	{ event 1100 20 "Step" }
	{ event 1100 60 "Step" }
	{ event 1100 95 "Step" }
	{ event 1100 125 "Step" }
	{ event 1100 148 "Step" }
	{ event 1100 163 "Step" }
	{ event 1100 178 "Step" }
	{ event 1100 193 "Step" }
	{ event 1100 208 "Step" }
	{ event 1100 223 "Step" }
	{ event 1100 238 "Step" }
	{ event 1100 253 "Step" }
	{ event 1100 266 "Step" }
	{ event 1100 277 "Step" }
	{ event 1100 289 "Step" }
	{ event 1100 300 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
}

$sequence "fall" {
	"sonic_anims\fall.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "dive" {
	"sonic_anims\dive.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "jump" {
	"sonic_anims\jump.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
}

$sequence "Undisolve" {
	"sonic_anims\Undisolve.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "Dodge1" {
	"sonic_anims\Dodge1.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "Dodge2" {
	"sonic_anims\Dodge2.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "Dodge3" {
	"sonic_anims\Dodge3.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "Dodge4" {
	"sonic_anims\Dodge4.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$sequence "roll" {
	"sonic_anims\roll.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
}

$sequence "DownedIdle" {
	"sonic_anims\DownedIdle.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "DownedWalk" {
	"sonic_anims\DownedWalk.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
	loop
}

$sequence "Braking" {
	"sonic_anims\Braking.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
}

$collisionjoints "sonic_physics.smd"
{
	$mass 70
	$inertia 10
	$damping 0.2
	$rotdamping 0.1
	$rootbone "Root"


	$jointconstrain "RightUpperArm" x limit -90 90 0
	$jointconstrain "RightUpperArm" y limit -90 90 0
	$jointconstrain "RightUpperArm" z limit -90 90 0

	$jointconstrain "RightLowerArm" x limit -90 90 0
	$jointconstrain "RightLowerArm" y limit -90 90 0
	$jointconstrain "RightLowerArm" z limit -90 90 0

	$jointconstrain "RightUpperLeg" x limit -90 90 0
	$jointconstrain "RightUpperLeg" y limit -90 90 0
	$jointconstrain "RightUpperLeg" z limit -90 90 0

	$jointconstrain "RightLowerLeg" x limit -90 90 0
	$jointconstrain "RightLowerLeg" y limit -90 90 0
	$jointconstrain "RightLowerLeg" z limit -90 90 0

	$jointconstrain "RightFoot" x limit -90 90 0
	$jointconstrain "RightFoot" y limit -90 90 0
	$jointconstrain "RightFoot" z limit -90 90 0

	$jointconstrain "Head" x limit -90 90 0
	$jointconstrain "Head" y limit -90 90 0
	$jointconstrain "Head" z limit -90 90 0

	$jointconstrain "LeftUpperArm" x limit -90 90 0
	$jointconstrain "LeftUpperArm" y limit -90 90 0
	$jointconstrain "LeftUpperArm" z limit -90 90 0

	$jointconstrain "LeftLowerArm" x limit -90 90 0
	$jointconstrain "LeftLowerArm" y limit -90 90 0
	$jointconstrain "LeftLowerArm" z limit -90 90 0

	$jointconstrain "LeftHand" x limit -90 90 0
	$jointconstrain "LeftHand" y limit -90 90 0
	$jointconstrain "LeftHand" z limit -90 90 0

	$jointconstrain "LeftUpperLeg" x limit -90 90 0
	$jointconstrain "LeftUpperLeg" y limit -90 90 0
	$jointconstrain "LeftUpperLeg" z limit -90 90 0

	$jointconstrain "LeftLowerLeg" x limit -90 90 0
	$jointconstrain "LeftLowerLeg" y limit -90 90 0
	$jointconstrain "LeftLowerLeg" z limit -90 90 0

	$jointconstrain "LeftFoot" x limit -90 90 0
	$jointconstrain "LeftFoot" y limit -90 90 0
	$jointconstrain "LeftFoot" z limit -90 90 0

	$jointconstrain "RightHand" x limit -90 90 0
	$jointconstrain "RightHand" y limit -90 90 0
	$jointconstrain "RightHand" z limit -90 90 0
}
