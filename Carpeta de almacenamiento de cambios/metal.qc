// Created by Crowbar 0.74

$modelname "Noodles\OM\Metal.mdl"

$bodygroup "Body"
{
	studio "Metal.smd"
}


$surfaceprop "default"

$contents "solid"

$illumposition -0.026 0.438 26.808

$mostlyopaque

$cdmaterials "models\Noodles\OM\Metal\"
$cdmaterials "models\Noodles\OM\shared\"

$texturegroup "skinfamilies"
{
	{ "OrangeGlow"         "Metalbody"     "Metalbody2"    }
	{ "orangeglowinverted" "MetalInverted" "MetalInverted" }
}

$cbox 0 0 0 0 0 0

$bbox -40.074 -5.473 -0.195 39.198 5.422 53.812

$definebone "Root" "" 0 0 0 0 0 89.999982 0 0 0 0 0 0
$definebone "Torso" "Root" 0 20.820543 0.407448 0 0 0 0 0 0 0 0 0
$definebone "RightUpperLeg" "Torso" -2.512592 0.327751 -0.113968 0.172231 -1.692288 -175.32709 0 0 0 0 0 0
$definebone "RightLowerLeg" "RightUpperLeg" 0 8.008676 0 0.033174 -1.700653 6.356681 0 0 0 0 0 0
$definebone "RightFoot" "RightLowerLeg" 0 6.836698 0 0 0 -74.307984 0 0 0 0 0 0
$definebone "LeftUpperLeg" "Torso" 2.512592 0.327751 -0.113968 -0.172231 1.692288 -175.32709 0 0 0 0 0 0
$definebone "LeftLowerLeg" "LeftUpperLeg" 0 8.008676 0 -0.033174 1.700653 6.356681 0 0 0 0 0 0
$definebone "LeftFoot" "LeftLowerLeg" 0 6.836698 0 0 0 -74.307984 0 0 0 0 0 0
$definebone "Head" "Torso" 0 9.752024 0 0 0 0 0 0 0 0 0 0
$definebone "LeftEye" "Head" 3.395984 5.638077 7.392832 0 0 0 0 0 0 0 0 0
$definebone "RightEye" "Head" -3.395984 5.638077 7.392832 0 0 0 0 0 0 0 0 0
$definebone "LeftUpperArm" "Torso" 5.313872 7.050735 0.10344 0 -89.999982 0 0 0 0 0 0 0
$definebone "LeftLowerArm" "LeftUpperArm" 0 7.714857 0 0 -2.798899 0 0 0 0 0 0 0
$definebone "LeftHand" "LeftLowerArm" 0 5.633504 0 0 -7.331966 1.060717 0 0 0 0 0 0
$definebone "LeftRingFinger1" "LeftHand" -0.109955 5.256546 -0.768792 0.147307 -1.587726 -1.45898 0 0 0 0 0 0
$definebone "LeftRingFinger2" "LeftRingFinger1" 0 3.168577 0 -0.007047 1.782584 -1.888297 0 0 0 0 0 0
$definebone "LeftPinkyFinger1" "LeftHand" -0.084215 5.092159 -1.866168 0.147078 -1.592765 -2.297847 0 0 0 0 0 0
$definebone "LeftPinkyFinger2" "LeftPinkyFinger1" 0 3.168573 0 -0.033403 1.777712 -1.893683 0 0 0 0 0 0
$definebone "LeftMiddleFinger1" "LeftHand" -0.125074 5.362076 0.360296 0.144786 -1.597411 2.40648 0 0 0 0 0 0
$definebone "LeftMiddleFinger2" "LeftMiddleFinger1" 0 3.168581 0 0.114878 1.80493 -1.863087 0 0 0 0 0 0
$definebone "LeftPointyFinger1" "LeftHand" -0.100126 5.246115 1.639256 0.145646 -1.615798 3.914276 0 0 0 0 0 0
$definebone "LeftPointyFinger2" "LeftPointyFinger1" 0.000004 3.168573 0 0.162262 1.813587 -1.853172 0 0 0 0 0 0
$definebone "LeftThumb1" "LeftHand" 1.214998 1.87934 2.210968 9.99989 -18.206875 34.500993 0 0 0 0 0 0
$definebone "LeftThumb2" "LeftThumb1" 0 2.436934 -0.000001 1.653324 6.653986 -9.827192 0 0 0 0 0 0
$definebone "RightUpperArm" "Torso" -5.313872 7.050735 0.10344 0 89.999982 0 0 0 0 0 0 0
$definebone "RightLowerArm" "RightUpperArm" 0 7.714857 0 0 2.798899 0 0 0 0 0 0 0
$definebone "RightHand" "RightLowerArm" 0 5.633504 0 0 7.331966 1.060717 0 0 0 0 0 0
$definebone "RightRingFinger1" "RightHand" 0.109955 5.256546 -0.768792 -0.147307 1.587726 -1.45898 0 0 0 0 0 0
$definebone "RightRingFinger2" "RightRingFinger1" 0 3.168577 0 0.007047 -1.782584 -1.888297 0 0 0 0 0 0
$definebone "RightPinkyFinger1" "RightHand" 0.084215 5.092159 -1.866168 -0.147078 1.592765 -2.297847 0 0 0 0 0 0
$definebone "RightPinkyFinger2" "RightPinkyFinger1" 0 3.168573 0 0.033403 -1.777712 -1.893683 0 0 0 0 0 0
$definebone "RightMiddleFinger1" "RightHand" 0.125074 5.362076 0.360296 -0.144786 1.597411 2.40648 0 0 0 0 0 0
$definebone "RightMiddleFinger2" "RightMiddleFinger1" 0 3.168581 0 -0.114878 -1.80493 -1.863087 0 0 0 0 0 0
$definebone "RightPointyFinger1" "RightHand" 0.100126 5.246115 1.639256 -0.145646 1.615798 3.914276 0 0 0 0 0 0
$definebone "RightPointyFinger2" "RightPointyFinger1" -0.000004 3.168573 0 -0.162262 -1.813587 -1.853172 0 0 0 0 0 0
$definebone "RightThumb1" "RightHand" -1.214998 1.87934 2.210968 -9.99989 18.206875 34.500993 0 0 0 0 0 0
$definebone "RightThumb2" "RightThumb1" 0 2.436934 -0.000001 -1.653324 -6.653986 -9.827192 0 0 0 0 0 0


$sectionframes 30 120

$poseparameter "aim_yaw" -90 90 loop 0
$poseparameter "aim_pitch" -90 90 loop 0

$animation "LookR_corrective_animation" "metal_anims\LookR_corrective_animation.smd" {
}

$animation "LookC_corrective_animation" "metal_anims\LookC_corrective_animation.smd" {
}

$animation "LookL_corrective_animation" "metal_anims\LookL_corrective_animation.smd" {
}

$animation "LookU_corrective_animation" "metal_anims\LookU_corrective_animation.smd" {
}

$animation "LookD_corrective_animation" "metal_anims\LookD_corrective_animation.smd" {
}

$animation "LookR_corrective_animation" "metal_anims\LookR_corrective_animation.smd" {
	fps 30
}

$animation "LookC_corrective_animation" "metal_anims\LookC_corrective_animation.smd" {
	fps 30
}

$animation "LookL_corrective_animation" "metal_anims\LookL_corrective_animation.smd" {
	fps 30
}

$animation "LookU_corrective_animation" "metal_anims\LookU_corrective_animation.smd" {
	fps 30
}

$animation "LookD_corrective_animation" "metal_anims\LookD_corrective_animation.smd" {
	fps 30
}

$animation "LookU" "metal_anims\LookU.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookU_corrective_animation" 0
}

$animation "LookD" "metal_anims\LookD.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookD_corrective_animation" 0
}

$animation "LookC" "metal_anims\LookC.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookC_corrective_animation" 0
}

$animation "LookR" "metal_anims\LookR.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookR_corrective_animation" 0
}

$animation "LookL" "metal_anims\LookL.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookL_corrective_animation" 0
}

$sequence "ref" {
	"metal_anims\ref.smd"
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
	"metal_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "Heal" {
	"metal_anims\Heal.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "walk" {
	"metal_anims\walk.smd"
	{ event 1100 15 "Step" }
	{ event 1100 40 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "run" {
	"metal_anims\run.smd"
	{ event 1100 5 "Step" }
	{ event 1100 25 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "ChargeUp" {
	"metal_anims\ChargeUp.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
}

$sequence "Charge" {
	"metal_anims\Charge.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "fall" {
	"metal_anims\fall.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "Jump" {
	"metal_anims\Jump.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
}

$sequence "roll" {
	"metal_anims\roll.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
}

$sequence "Slam1" {
	"metal_anims\Slam1.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
}

$sequence "Slam2" {
	"metal_anims\Slam2.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
}

$sequence "HealToIldle" {
	"metal_anims\HealToIldle.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
}

$sequence "IdleToHeal" {
	"metal_anims\IdleToHeal.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
}

$sequence "ChargeGrab" {
	"metal_anims\ChargeGrab.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
}

$collisionjoints "metal_physics.smd"
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

	$jointconstrain "LeftUpperArm" x limit -90 90 0
	$jointconstrain "LeftUpperArm" y limit -90 90 0
	$jointconstrain "LeftUpperArm" z limit -90 90 0

	$jointconstrain "LeftLowerArm" x limit -90 90 0
	$jointconstrain "LeftLowerArm" y limit -90 90 0
	$jointconstrain "LeftLowerArm" z limit -90 90 0

	$jointconstrain "LeftHand" x limit -90 90 0
	$jointconstrain "LeftHand" y limit -90 90 0
	$jointconstrain "LeftHand" z limit -90 90 0

	$jointconstrain "Head" x limit -90 90 0
	$jointconstrain "Head" y limit -90 90 0
	$jointconstrain "Head" z limit -90 90 0

	$jointconstrain "LeftUpperLeg" x limit -90 90 0
	$jointconstrain "LeftUpperLeg" y limit -90 90 0
	$jointconstrain "LeftUpperLeg" z limit -90 90 0

	$jointconstrain "LeftLowerLeg" x limit -90 90 0
	$jointconstrain "LeftLowerLeg" y limit -90 90 0
	$jointconstrain "LeftLowerLeg" z limit -90 90 0

	$jointconstrain "LeftFoot" x limit -90 90 0
	$jointconstrain "LeftFoot" y limit -90 90 0
	$jointconstrain "LeftFoot" z limit -90 90 0

	$jointconstrain "RightUpperLeg" x limit -90 90 0
	$jointconstrain "RightUpperLeg" y limit -90 90 0
	$jointconstrain "RightUpperLeg" z limit -90 90 0

	$jointconstrain "RightLowerLeg" x limit -90 90 0
	$jointconstrain "RightLowerLeg" y limit -90 90 0
	$jointconstrain "RightLowerLeg" z limit -90 90 0

	$jointconstrain "RightFoot" x limit -90 90 0
	$jointconstrain "RightFoot" y limit -90 90 0
	$jointconstrain "RightFoot" z limit -90 90 0

	$jointconstrain "RightHand" x limit -90 90 0
	$jointconstrain "RightHand" y limit -90 90 0
	$jointconstrain "RightHand" z limit -90 90 0
}
