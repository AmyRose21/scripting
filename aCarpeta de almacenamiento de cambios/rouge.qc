// Created by Crowbar 0.74

$modelname "Noodles\OM\Rouge.mdl"

$bodygroup "Body"
{
	studio "Rouge.smd"
}


$surfaceprop "default"

$contents "solid"

$illumposition -0.026 0.438 26.808

$mostlyopaque

$cdmaterials "models\Noodles\OM\Rouge\"
$cdmaterials "models\Noodles\OM\shared\"

$cbox 0 0 0 0 0 0

$bbox -40.074 -5.473 -0.195 39.198 5.422 53.812

$definebone "Root" "" 0 0 0 0 0 89.999982 0 0 0 0 0 0
$definebone "Torso" "Root" 0 22.721849 -1.614557 0 0 0 0 0 0 0 0 0
$definebone "LeftUpperLeg" "Torso" 2.454095 0.40642 0.004649 87.702709 -89.999873 90.000153 0 0 0 0 0 0
$definebone "LeftLowerLeg" "LeftUpperLeg" 0 6.192892 0 0 -6.206221 0 0 0 0 0 0 0
$definebone "LeftFoot" "LeftLowerLeg" 0 8.837991 0 0 67.461485 0 0 0 0 0 0 0
$definebone "LeftUpperArm" "Torso" 3.844708 8.678043 0.051154 0.000057 -89.999982 -0.632717 0 0 0 0 0 0
$definebone "LeftLowerArm" "LeftUpperArm" 0 4.286849 0 0.078209 -4.882288 1.971261 0 0 0 0 0 0
$definebone "LeftHand" "LeftLowerArm" 0 6.70634 0 5.828241 10.369848 -1.329663 0 0 0 0 0 0
$definebone "LeftMiddleFinger1" "LeftHand" 0.198252 5.632994 0.214067 -5.38735 -16.58323 1.59861 0 0 0 0 0 0
$definebone "LeftMiddleFinger2" "LeftMiddleFinger1" -0.016163 2.803314 0.000005 -0.000172 -10.0691 -0.001719 0 0 0 0 0 0
$definebone "LeftPinkyFinger1" "LeftHand" 0.34609 5.033264 -1.894839 -5.387351 -16.583175 1.59861 0 0 0 0 0 0
$definebone "LeftPinkyFinger2" "LeftPinkyFinger1" -0.016171 2.803318 0.000005 -0.000172 -10.06916 -0.001719 0 0 0 0 0 0
$definebone "LeftPointyFinger1" "LeftHand" -0.034815 5.332174 2.284254 -5.38735 -16.58323 1.59861 0 0 0 0 0 0
$definebone "LeftPointyFinger2" "LeftPointyFinger1" -0.016159 2.803318 0.000005 -0.000172 -10.0691 -0.001719 0 0 0 0 0 0
$definebone "LeftThumb1" "LeftHand" 0.04421 1.431742 0.991046 1.161098 -5.869494 85.733163 0 0 0 0 0 0
$definebone "LeftThumb2" "LeftThumb1" 0 2.831458 0 0.768967 -24.019081 -8.124199 0 0 0 0 0 0
$definebone "Head" "Torso" 0 11.205091 0.13426 0 0 0 0 0 0 0 0 0
$definebone "RightEye" "Head" -2.318274 4.304794 6.785337 0.000057 -0.000115 109.999992 0 0 0 0 0 0
$definebone "LeftEye" "Head" 2.318274 4.304794 6.785337 -0.000057 0.000115 109.999992 0 0 0 0 0 0
$definebone "RightUpperLeg" "Torso" -2.454095 0.40642 0.004649 -87.702709 89.999982 89.999982 0 0 0 0 0 0
$definebone "RightLowerLeg" "RightUpperLeg" 0 6.192892 0 0 6.206221 0 0 0 0 0 0 0
$definebone "RightFoot" "RightLowerLeg" 0 8.837992 0 0 -67.461485 0 0 0 0 0 0 0
$definebone "RightUpperArm" "Torso" -3.844708 8.678043 0.051154 -0.000057 89.999982 -0.632717 0 0 0 0 0 0
$definebone "RightLowerArm" "RightUpperArm" 0 4.286849 0 -0.078209 4.882288 1.971261 0 0 0 0 0 0
$definebone "RightHand" "RightLowerArm" 0 6.70634 0 -5.828241 -10.369848 -1.329663 0 0 0 0 0 0
$definebone "RightMiddleFinger1" "RightHand" -0.198252 5.632994 0.214067 5.38735 16.58323 1.59861 0 0 0 0 0 0
$definebone "RightMiddleFinger2" "RightMiddleFinger1" 0.016163 2.803314 0.000005 0.000172 10.0691 -0.001719 0 0 0 0 0 0
$definebone "RightPinkyFinger1" "RightHand" -0.34609 5.033264 -1.894839 5.387351 16.583175 1.59861 0 0 0 0 0 0
$definebone "RightPinkyFinger2" "RightPinkyFinger1" 0.016171 2.803318 0.000005 0.000172 10.06916 -0.001719 0 0 0 0 0 0
$definebone "RightPointyFinger1" "RightHand" 0.034815 5.332174 2.284254 5.38735 16.58323 1.59861 0 0 0 0 0 0
$definebone "RightPointyFinger2" "RightPointyFinger1" 0.016159 2.803318 0.000005 0.000172 10.0691 -0.001719 0 0 0 0 0 0
$definebone "RightThumb1" "RightHand" -0.04421 1.431742 0.991046 -1.161098 5.869494 85.733163 0 0 0 0 0 0
$definebone "RightThumb2" "RightThumb1" 0 2.831458 0 -0.768967 24.019081 -8.124199 0 0 0 0 0 0
$definebone "LeftWing" "Torso" 3.259386 8.610294 -4.33849 0 -89.999982 0 0 0 0 0 0 0
$definebone "RightWing" "Torso" -3.259386 8.610294 -4.33849 0 89.999982 0 0 0 0 0 0 0


$sectionframes 30 120

$poseparameter "aim_yaw" -90 90 loop 0
$poseparameter "aim_pitch" -90 90 loop 0

$weightlist "weights_SmokeBomb" {
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
	 "RightUpperLeg" 0
	 "RightLowerLeg" 0
	 "RightFoot" 0
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
	 "LeftWing" 0
	 "RightWing" 0
}

$animation "LookR_corrective_animation" "rouge_anims\LookR_corrective_animation.smd" {
}

$animation "LookC_corrective_animation" "rouge_anims\LookC_corrective_animation.smd" {
}

$animation "LookL_corrective_animation" "rouge_anims\LookL_corrective_animation.smd" {
}

$animation "LookU_corrective_animation" "rouge_anims\LookU_corrective_animation.smd" {
}

$animation "LookD_corrective_animation" "rouge_anims\LookD_corrective_animation.smd" {
}

$animation "LookU" "rouge_anims\LookU.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookU_corrective_animation" 0
}

$animation "LookD" "rouge_anims\LookD.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookD_corrective_animation" 0
}

$animation "LookC" "rouge_anims\LookC.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookC_corrective_animation" 0
}

$animation "LookR" "rouge_anims\LookR.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookR_corrective_animation" 0
}

$animation "LookL" "rouge_anims\LookL.smd" {
	fps 30
	// Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
	subtract "LookL_corrective_animation" 0
}

$sequence "ref" {
	"rouge_anims\ref.smd"
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
	"rouge_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "walk" {
	"rouge_anims\walk.smd"
	{ event 1100 8 "Step" }
	{ event 1100 38 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "run" {
	"rouge_anims\run.smd"
	{ event 1100 8 "Step" }
	{ event 1100 28 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "fall" {
	"rouge_anims\fall.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "jump" {
	"rouge_anims\jump.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
}

$sequence "roll" {
	"rouge_anims\roll.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
}

$sequence "FlyIdle" {
	"rouge_anims\FlyIdle.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "FlyRun" {
	"rouge_anims\FlyRun.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
	loop
}

$sequence "flap" {
	"rouge_anims\flap.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
}

$sequence "latch" {
	"rouge_anims\latch.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
	loop
}

$sequence "SweepKick" {
	"rouge_anims\SweepKick.smd"
	fadein 0.7
	fadeout 0.7
	fps 60
}

$sequence "IdleLowHealth" {
	"rouge_anims\IdleLowHealth.smd"
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "WalkLowHealth" {
	"rouge_anims\WalkLowHealth.smd"
	{ event 1100 15 "Step" }
	{ event 1100 55 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "RunLowHealth" {
	"rouge_anims\RunLowHealth.smd"
	{ event 1100 8 "Step" }
	{ event 1100 28 "Step" }
	fadein 0.2
	fadeout 0.2
	fps 60
	loop
}

$sequence "SmokeBomb" {
	"rouge_anims\SmokeBomb.smd"
	activity "ACT_BARNACLE_HIT" 1
	fadein 0.2
	fadeout 0.2
	fps 60
	weightlist "weights_SmokeBomb"
}

// ---------------------------------------------------------------------------
// v15 - GLIDE DE ROUGE (pose de piernas de la imagen de referencia):
// tijera asimetrica - rodilla adelantada recogida (~85 gr) bajo la panza
// con la punta cayendo hacia el suelo, trasera enganchada (~42 gr) con
// talon levantado, rodillas juntas, puntas de ballet con abertura y roll
// alado (las botas del modelo son anchisimas: separamos bordes internos).
// Brazos atras (v14), aleteo autentico (v12), dedos ripple (v13),
// cabeza seno puro (v14). 41 frames @ 30fps, loop t40==t0.
// Posiciones = bind (anti-desgarro v12).
// Generado por scripts/glide_rouge_v15.py
// ---------------------------------------------------------------------------

$sequence "glide" {
        "rouge_anims\\glide.smd"
        fadein 0.7
        fadeout 0.7
        fps 30
        loop
}

$collisionjoints "rouge_physics.smd"
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
